%% main function - TO RUN
clc;clear;close all
%% run the VE_setup script 
run VE_setup.m

%% test IK function and check collision with teleoperated input 
figure
% initial configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tip_position_init = [x_VE_lim/2;geometry(1)+geometry(2)];
joint_values = inverseKinematics_RR(geometry,tip_position_init);
link_shape = getLinkBoundary_RR(geometry,joint_values);
d = dist2Obstacle(link_shape,obs,0.5);
plotVE(geometry,link_shape,target,obs,d);
pause(0.01);
%%  teleoperate 

% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);

% user interaction with the VE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
joystick_limit = 32768;
VE_limit = 0.25; % scale wrt to workspace size? 
R2Sim_Ratio = VE_limit/joystick_limit;

% signal processing %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filter_window = 1;

t_stable = 1e3;
t_end = 1e5;

k = 0;
cond_idx = [false false false false];
tip_position = tip_position_init;
link_quadrant = [];

% control loop 
for i = 1:t_end
    State = myController.GetState();
    ButtonStates = ButtonStateParser(State.Gamepad.Buttons); % Put this into a structure

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

        tip_position = [target_x; target_y] + tip_position;
        plot(tip_position(1),tip_position(2),'go'); hold on;  pause(0.0001);
       

        % do inverse kinematics and check collision %%%%%%%%%%%%%%%%%%%%%%%
        if any(cond_idx == 1)
            joint_values = inverseKinematics_RR(geometry,tip_position);
            [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
            violation = checkViolation(tip_position,joint_2_position,d,...
                link_quadrant,cond_idx);
            if violation == true
                VE_limit = 0.005; % scale wrt to workspace size? 
                R2Sim_Ratio = VE_limit/joystick_limit;
                continue
            end
            cond_idx = [false false false false];
            VE_limit = 0.25; % scale wrt to workspace size? 
            R2Sim_Ratio = VE_limit/joystick_limit;
        end
        [joint_values,tip_position] = inverseKinematics_RR(geometry,tip_position);
        link_shape = getLinkBoundary_RR(geometry,joint_values);
        [d,stop_motion] = dist2Obstacle(link_shape,obs,0.5); 

        %%%%%%%%% distance to obstacles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf("L1L dist to obstacle:%d\n",d.dist(1)); % link 1 left 
        fprintf("L1R dist to obstacle:%d\n",d.dist(2)); % link 1 right 
        fprintf("L2L dist to obstacle:%d\n",d.dist(3)); % link 2 left 
        fprintf("L2R dist to obstacle:%d\n",d.dist(4)); % link 2 right 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if stop_motion ~= 0 % update position only if motion is allowed
            cond_idx = (d.dist~=0);
            link_quadrant(1) = checkQuadrant(joint_values(1));
            link_quadrant(2) = checkQuadrant(joint_values(2));
            continue
        end
        clf;
        plot(tip_position(1),tip_position(2),'ro'); hold on
        plotVE(geometry,link_shape,target,obs,d); pause(0.0001);
    end
end
%% test FK function and check collision 
