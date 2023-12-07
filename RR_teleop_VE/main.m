%% main function - TO RUN
clc;clear;close all
%% run the VE_setup script 
run VE_setup.m

%% create figure object for visualization 
figure 
tab1 = uitab('Title','Global View');
ax1 = axes(tab1);
tab2 = uitab('Title','User View');
ax2 = axes(tab2);
%% test IK function and check collision with teleoperated input 

thres = 2.5; % threshold around obstacle

% initial configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tip_position_init = [x_VE_lim/2;geometry(1)+geometry(2)];
joint_values_init = inverseKinematics_RR(geometry,tip_position_init);
link_shape = getLinkBoundary_RR(geometry,joint_values_init);
d = dist2Obstacle(link_shape,obs,thres);
[ax1,camera_target] = plotVE(geometry,link_shape,target,obs,d,joint_values_init,ax1);
plotUserPOV(ax1,ax2,camera_target); 
pause(0.01);
 
%% set up controller
% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);
%% Calibration
%%%%%%%%%%%%%%%%%%%%%%%% Calibration Process %%%%%%%%%%%%%%%%%%%%%%%%%%%
disp("Move the joystick up and down to calibrate each motor");
calibrate(myController);

%%  teleoperate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user interaction with the VE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joystick_limit = 32768;
VE_limit = 0.5; % scale wrt to workspace size? 
R2Sim_Ratio = VE_limit/joystick_limit;

% signal processing
filter_window = 1;

% setup simulation time parameters 
t_stable = 1e3;
t_end = 1e5;

% setup data collection
DATA.tip_position_all  = Inf(2,t_end-t_stable);
DATA.joint_values_all  = Inf(2,t_end-t_stable);
DATA.control_mode_all  = Inf(1,t_end-t_stable);

% initialize d object (contains field d.dist)
d.dist = zeros(1,5);
d.link = zeros(5,2);
d.obs = zeros(5,2);

k = 0;
cond_idx = [false false false false];
use_forwardKinematics = false;
tip_position = tip_position_init;
joint_values = joint_values_init;
link_quadrant = [];

% control loop for operation
for i = 1:t_end

    State = myController.GetState();
    ButtonStates = ButtonStateParser(State.Gamepad.Buttons); % Put this into a structure

    % poll to see if joint control is triggered
    if ButtonStates.DPadUp || ButtonStates.DPadDown
        use_forwardKinematics = true;
    else 
        use_forwardKinematics = false;
    end 

    % poll to see if termination button is triggered 
    if ButtonStates.X
        fprintf("Terminate and save data!\n");
        break
    end

    % get x,y input from joystick%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rjoystick.x(i) = double(State.Gamepad.RightThumbX);
    rjoystick.y(i) = double(State.Gamepad.RightThumbY);

    if i < filter_window 
        % filtered signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rjoystick.x(i) = mean(rjoystick.x(1:i));
        rjoystick.y(i) = mean(rjoystick.y(1:i));
    else 
        % filtered position signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rjoystick.x(i) = mean(rjoystick.x(i-filter_window+1:i));
        rjoystick.y(i) = mean(rjoystick.y(i-filter_window+1:i));  
    end

    if i >= t_stable % do teleoperation task %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        k = k + 1; 

        % capture data %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        DATA.tip_position_all(:,k) = tip_position;
        DATA.joint_values_all(:,k) = joint_values;
        DATA.control_mode_all(:,k) = use_forwardKinematics;

        %%%%%%%%% distance to obstacles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % h1 = mapDist(d.dist(2), thres,i);
        % h2 = mapDist(d.dist(1), thres,i);
        % h3 = mapDist(d.dist(3), thres,i);
        % h4 = mapDist(d.dist(4), thres,i);
        
        fprintf("L1L dist to obstacle:%d\n",d.dist(1)); % link 1 left 
        fprintf("L1R dist to obstacle:%d\n",d.dist(2)); % link 1 right 
        fprintf("L2L dist to obstacle:%d\n",d.dist(3)); % link 2 left 
        fprintf("L2R dist to obstacle:%d\n",d.dist(4)); % link 2 right 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%% Serial Communication %%%%%%%%%%%%%%%%%%%
        
        % senseVals = [h1;h2;h3;h4];
        % moveSense(senseVals);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if k == 1
            fprintf("start teleoperation\n");
            % stablized positions
            rjoystick_xstable = rjoystick.x(i);
            rjoystick_ystable = rjoystick.y(i);
        end
        % accounting for joystick offset
        rjoystick_offset.x(k) = rjoystick.x(i) - rjoystick_xstable;
        rjoystick_offset.y(k) = rjoystick.y(i) - rjoystick_ystable;

        target_x = double(rjoystick_offset.x(k) * R2Sim_Ratio);
        target_y = double(rjoystick_offset.y(k) * R2Sim_Ratio);

        if ~use_forwardKinematics
            % cap minimal tip movement as well? 
            tip_position = [target_x; target_y] + tip_position;
        else
            % cap minimal joint movement at 5 deg
            djoint = 0;
            if target_y ~= 0
                djoint = sign(target_y/100)*max(abs(target_y/100),deg2rad(0.1));
            end
            % move either joint 1 or joint 2 depending on up/down button pressed
            if ButtonStates.DPadUp 
                joint_values(2) = djoint + joint_values(2);
            end 
            if ButtonStates.DPadDown 
                joint_values(1) = djoint + joint_values(1);
            end
        end 
       
        % do kinematics mapping and check collision %%%%%%%%%%%%%%%%%%%%%%%
        if any(cond_idx == 1)
            if ~use_forwardKinematics
                joint_values = inverseKinematics_RR(geometry,tip_position);
            else 
                tip_position = forwardKinematics_RR(geometry,joint_values);
            end 

            plot(ax1,tip_position(1),tip_position(2),'ro'); hold on; 
            plot(ax2,tip_position(1),tip_position(2),'ro'); pause(0.0001);

            [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
            violation = checkViolation(tip_position,joint_2_position,d,...
                                       link_quadrant,cond_idx);
            if violation == true
                continue
            end
            cond_idx = [false false false false];
            VE_limit = 0.5; % scale wrt to workspace size? 
            R2Sim_Ratio = VE_limit/joystick_limit;
        end

        % update tip position/joint values depending on the kinematics
        % scheme %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~use_forwardKinematics
            [joint_values,tip_position] = inverseKinematics_RR(geometry,tip_position);
        else
            tip_position = forwardKinematics_RR(geometry,joint_values);
        end 

        % check for obstacle collisions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        link_shape = getLinkBoundary_RR(geometry,joint_values);
        [d,stop_motion] = dist2Obstacle(link_shape,obs,thres);

        if stop_motion ~= 0 % update position only if motion is allowed
            cond_idx = (d.dist~=0);
            VE_limit = 0.005; % scale wrt to workspace size?
            R2Sim_Ratio = VE_limit/joystick_limit;
            link_quadrant(1) = checkQuadrant(joint_values(1));
            link_quadrant(2) = checkQuadrant(joint_values(2));
            continue
        end
        cla(ax1); cla(ax2);
        plot(ax1,tip_position(1),tip_position(2),'ro'); hold on
        plot(ax2,tip_position(1),tip_position(2),'ro');
        [ax1,camera_target] = plotVE(geometry,link_shape,target,obs,d,joint_values,ax1);
        plotUserPOV(ax1,ax2,camera_target); pause(0.0001); 
    end
end

% saving data 
cd('DATA_COLLECTION\')
filename = strcat('VE_DATA_',datestr(now));
filename = strrep(filename,' ','_');
filename = strrep(filename,':','_');
filename = strrep(filename,'-','_');
save(filename, 'DATA');
cd ..

