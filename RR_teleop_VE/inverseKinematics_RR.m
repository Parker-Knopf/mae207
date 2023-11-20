% implements the inverse kinematics function of a planar RR manipulator 
function joint_values = inverseKinematics_RR(geometry,tip_position)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
% geometry (4x1) [L1;L2;base], the length of each link, base position of the robot  
% tip_position (2x1) [x;y], the Cartesian position of the end
% effector

% OUTPUTS: 
% joint_values (2x1) [theta_1; theta_2], the +CCW rotation of each
% joint of the manipulator, measured from the x-axis
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Analytical IK kinematics implemented from Chapter 6 pg 187-188 Modern Robotics 

% unpack variables
L1 = geometry(1);
L2 = geometry(2);
base = geometry(3:4);

% check if the tip_position is within the workspace, if not, return the
% closest position in the workspace 
workspace = makeCircle(base,L1+L2);
feasible_pt = isinterior(workspace,tip_position(1),tip_position(2));
if ~feasible_pt
    [idx,~,~] = nearestvertex(workspace,tip_position(1),tip_position(2));
    tip_position = workspace.Vertices(idx,:);
    fprintf("workspace boundary!")
end 

% the tip position, need to account for the base
x = tip_position(1) - base(1);
y = tip_position(2) - base(2);

% compute gamma 
gamma = atan2(y,x);

% compute beta 
beta_arg = (L1^2+L2^2-x^2-y^2)/(2*L1*L2);
beta = acos(beta_arg);

% compute alpha 
alpha_arg = (x^2+y^2+L1^2-L2^2)/(2*L1*sqrt(x^2+y^2));
alpha = acos(alpha_arg);

% calculate joint values, always assume lefty solution
theta1 = real(gamma - alpha);
theta2 = real(pi - beta + theta1);

joint_values = [theta1; theta2];

end