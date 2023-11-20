%% main function - TO RUN
clc;clear;close all
%% run the VE_setup script 
run VE_setup.m

%% test IK function and check collision with teleoperated input 
figure
% initial configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tip_position_init = [x_VE_lim/2;40];
joint_values = inverseKinematics_RR(geometry,tip_position_init);
link_shape = getLinkBoundary_RR(geometry,joint_values);
d = dist2Obstacle(link_shape,obs,1);
plotVE(geometry,link_shape,target,obs,d);
pause(0.01);

%%  teleoperate 

% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);

% user interaction with the VE
joystick_limit = 32768;
VE_limit = 20; % scale wrt to workspace size? 
R2Sim_Ratio = VE_limit/joystick_limit;

% signal processing 
filter_window = 5;

t_stable = 1e2;
t_end = 1e5;

k = 0;

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

     if i == 1
        rjoystick.xdot(i) = 0;
        rjoystick.ydot(i) = 0;
     end 

     if i >= t_stable % do teleoperation task
         disp('do teleoperation task!')
         k = k + 1;
         if k == 1
             % stablized positions
             rjoystick_xstable = rjoystick.x(i);
             rjoystick_ystable = rjoystick.y(i);
         end
         % accounting for joystick offset
         rjoystick_offset.x(k) = rjoystick.x(i) - rjoystick_xstable;
         rjoystick_offset.y(k) = rjoystick.y(i) - rjoystick_ystable;

         target_x = double(rjoystick_offset.x(k) * R2Sim_Ratio);
         target_y = double(rjoystick_offset.y(k) * R2Sim_Ratio);
    
         % do inverse kinematics and check collision 
         tip_position = [target_x; target_y] + tip_position_init;
         plot(tip_position(1),tip_position(2),'ro');
         joint_values = inverseKinematics_RR(geometry,tip_position);
         link_shape = getLinkBoundary_RR(geometry,joint_values);
         d = dist2Obstacle(link_shape,obs,1);
         plotVE(geometry,link_shape,target,obs,d);
         pause(0.01);
         clf;
     end   
end

%% test FK function and check collision 
