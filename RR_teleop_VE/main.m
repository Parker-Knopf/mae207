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
thres = 1; % threshold around obstacle
% initial configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tip_position_init = [x_VE_lim/2;geometry(1)+geometry(2)];
joint_values = inverseKinematics_RR(geometry,tip_position_init);
link_shape = getLinkBoundary_RR(geometry,joint_values);
d = dist2Obstacle(link_shape,obs,thres);
[ax1,camera_target] = plotVE(geometry,link_shape,target,obs,d,joint_values,ax1);
plotUserPOV(ax1,ax2,camera_target); 
pause(0.01);
 
%% set up controller
% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);
%% Calibration
%%%%%%%%%%%%%%%%%%%%%%%% Calibration Process %%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp("Move the joystick up and down to calibrate each motor");
% calibrate(myController);

%%  teleoperate
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% user interaction with the VE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joystick_limit = 32768;
VE_limit = 0.5; % scale wrt to workspace size? 
R2Sim_Ratio = VE_limit/joystick_limit;

% signal processing
filter_window = 1;

t_stable = 1e3;
t_end = 1e5;

k = 0;
cond_idx = [false false false false];
use_forwardKinematics = false;
tip_position = tip_position_init;
link_quadrant = [];

% control loop for operation
for i = 1:t_end

    % M(i) = getframe(gcf);

    State = myController.GetState();
    ButtonStates = ButtonStateParser(State.Gamepad.Buttons); % Put this into a structure

    % poll to see if joint control is triggered
    if ButtonStates.DPadUp || ButtonStates.DPadDown
        use_forwardKinematics = true;
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
            tip_position = [target_x; target_y] + tip_position;
        else
            joint_values = [target_x; target_y] + joint_values;
        end 
       
        % do inverse kinematics and check collision %%%%%%%%%%%%%%%%%%%%%%%
        if any(cond_idx == 1)
            plot(ax1,tip_position(1),tip_position(2),'ro'); hold on; 
            plot(ax2,tip_position(1),tip_position(2),'ro'); pause(0.0001);
            joint_values = inverseKinematics_RR(geometry,tip_position);
            [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
            violation = checkViolation(tip_position,joint_2_position,d,...
                link_quadrant,cond_idx);
            if violation == true
                continue
            end
            cond_idx = [false false false false];
            VE_limit = 0.25; % scale wrt to workspace size? 
            R2Sim_Ratio = VE_limit/joystick_limit;
        end
        if ~use_forwardKinematics
            [joint_values,tip_position] = inverseKinematics_RR(geometry,tip_position);
        end 
        link_shape = getLinkBoundary_RR(geometry,joint_values);
        [d,stop_motion] = dist2Obstacle(link_shape,obs,thres);
        
        %%%%%%%%% distance to obstacles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % h1 = mapDist(d.dist(1), 0.5);
        % h2 = mapDist(d.dist(2), 0.5);
        % h3 = mapDist(d.dist(3), 0.5);
        % h4 = mapDist(d.dist(4), 0.5);
        
        % fprintf("L1L dist to obstacle:%d\n",mapDist(d.dist(1), VE_limit)); % link 1 left 
        % fprintf("L1R dist to obstacle:%d\n",mapDist(d.dist(2), VE_limit)); % link 1 right 
        % fprintf("L2L dist to obstacle:%d\n",mapDist(d.dist(3), VE_limit)); % link 2 left 
        % fprintf("L2R dist to obstacle:%d\n",mapDist(d.dist(4), VE_limit)); % link 2 right 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        %%%%%%%%%%%%%%%%%%%%%%% Serial Communication %%%%%%%%%%%%%%%%%%%
        
        % senseVals = [h1;h2;h3;h4];
        % moveSense(senseVals);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
%% test FK function and check collision
