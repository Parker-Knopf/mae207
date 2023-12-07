% implements the forward kinematics function of a planar RR manipulator 
function [tip_position,varagout] = forwardKinematics_RR(geometry,joint_values,varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
% geometry (4x1) [L1;L2;base], the length of each link, base position of the robot  
% joint_values (2x1) [theta_1; theta_2], the +CCW rotation of each
% joint of the manipulator

% OUTPUTS: 
% tip_position (2x1) [x;y], the Cartesian position of the end
% effector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% FK kinematics implemented from Haptics Lec4 

% unpack variables
L1 = geometry(1);
L2 = geometry(2);
base = geometry(3:4);

theta1 = joint_values(1);
theta2 = joint_values(2);

% compute position of the second joint 
joint_x_2 = L1*cos(theta1);
joint_y_2 = L1*sin(theta1);

if nargin > 2 
    query_joint_2 = varargin{1};
    if query_joint_2 == true
        joint_2 = [joint_x_2;joint_y_2];
        joint_2 = joint_2 + base;
        varagout = joint_2;
    end 
end 

% compute position of the end effector
tip_x = joint_x_2 + L2*cos(theta2);
tip_y = joint_y_2 + L2*sin(theta2);

tip_position = [tip_x;tip_y] + base;

% check if the tip_position is within the workspace, if not, return the
% closest position in the workspace 
workspace = makeCircle(base,L1+L2);
feasible_pt = isinterior(workspace,tip_position(1),tip_position(2));
if ~feasible_pt
    [idx,~,~] = nearestvertex(workspace,tip_position(1),tip_position(2));
    tip_position = workspace.Vertices(idx,:)';
end 

end