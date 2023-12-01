%% main function - TO RUN
clc;clear;close all
%% run the VE_setup script 
run VE_setup.m

%% test IK function and check collision with teleoperated input 
% initial configuration %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
tip_position_init = [x_VE_lim/2;geometry(1)+geometry(2)];
joint_values = inverseKinematics_RR(geometry,tip_position_init);
link_shape = getLinkBoundary_RR(geometry,joint_values);
d = dist2Obstacle(link_shape,obs,1);

% plot the global view 
figure
plotVE(geometry,link_shape,target,obs,d);
pause(0.01);


% plot the limited view 
% UserPOV_visual = plotUserPOV(VE_visual);
% pause(0.01);


%% offline debug  
% do inverse kinematics and check collision 
target_x = 26 - tip_position_init(1);
target_y = 28 - tip_position_init(2);

tip_position = [target_x; target_y] + tip_position_init;
plot(tip_position(1),tip_position(2),'ro');
joint_values = inverseKinematics_RR(geometry,tip_position);
link_shape = getLinkBoundary_RR(geometry,joint_values);
[d,stop_motion] = dist2Obstacle(link_shape,obs,0.5);
if stop_motion ~= 0 % update position only if motion is allowed
    cond_idx = (d.dist~=0);
end
plotVE(geometry,link_shape,target,obs,d); hold on

target_x = 27 - tip_position_init(1);
target_y = 28 - tip_position_init(2);
tip_position = [target_x; target_y] + tip_position;
plot(tip_position(1),tip_position(2),'go');

if any(cond_idx == 1)
    candidate_position = [target_x + tip_position(1);
                          target_y  + tip_position(2)];
    [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
    violation = checkViolation(candidate_position,joint_2_position,d,...
                               joint_values,cond_idx,link_shape);
end 
plotVE(geometry,link_shape,target,obs,d); hold on

target_x = 23 - tip_position_init(1);
target_y = 25 - tip_position_init(2);
tip_position = [target_x; target_y] + tip_position;
plot(tip_position(1),tip_position(2),'ko');

if any(cond_idx == 1)
    candidate_position = [target_x + tip_position(1);
                          target_y  + tip_position(2)];
    [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
    violation = checkViolation(candidate_position,joint_2_position,d,...
                               joint_values,cond_idx,link_shape);
end
plotVE(geometry,link_shape,target,obs,d); hold on
%%  teleoperate 

% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);

% user interaction with the VE
joystick_limit = 32768;
VE_limit = 50; % scale wrt to workspace size? 
R2Sim_Ratio = VE_limit/joystick_limit;

% signal processing 
filter_window = 10;

t_stable = 1e2;
t_end = 1e5;

k = 0;
cond_idx = [false false false false];
% 
% link_shape_old = getLinkBoundary_RR(geometry,[pi/2; pi/2]);
% [d_old,~] = dist2Obstacle(link_shape_old,obs,2);
tip_position = tip_position_init;

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
         if any(cond_idx == 1)
             candidate_position = [target_x + tip_position(1);
                                   target_y  + tip_position(2)];
             [~,joint_2_position] = forwardKinematics_RR(geometry,joint_values,true);
             violation = checkViolation(candidate_position,joint_2_position,d,...
                                        joint_values,cond_idx,link_shape);
             if violation
                 continue 
             end
         end
         tip_position = [target_x; target_y] + tip_position;
         joint_values = inverseKinematics_RR(geometry,tip_position);
         link_shape = getLinkBoundary_RR(geometry,joint_values);
         [d,stop_motion] = dist2Obstacle(link_shape,obs,0.5);
         if stop_motion ~= 0 % update position only if motion is allowed 
            cond_idx = (d.dist~=0);
            continue
         end
         clf;
         plotVE(geometry,link_shape,target,obs,d); hold on
         plot((target_x + tip_position(1)),(target_y + tip_position(2)),'ro')
         pause(0.001);
     end   
end
%% test FK function and check collision 
