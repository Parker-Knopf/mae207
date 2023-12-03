% implement function to get the boundary of the links 
function link_shape = getLinkBoundary_RR(geometry,joint_values)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUTS: 
% geometry (4x1) [L1;L2;base], the length of each link, base position of the robot  
% joint_values (2x1) [theta_1; theta_2], the +CCW rotation of each
% joint of the manipulator, measured from the x-axis

% OUTPUT:
% link_shape (2x1) [link1; link2], polyshape objects that store the
% rectangles that describe the link's occupancy area 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% unpack variable 
L1 = geometry(1);
L2 = geometry(2);
base = geometry(3:4);
theta1 = joint_values(1);
theta2 = joint_values(2);

% find link shapes (as rectangles) 
width = 2; % can change this 

% convention:  [bottom left top left top right bottom right]
x_coord = [0+base(1) 0+base(1) width+base(1) width+base(1)];
y_coord = [0+base(2) L1+base(2) L1+base(2) 0+base(2)];

% construct polyshape objects for the robot links
link1 = polyshape(x_coord,...
                  y_coord);
link2 = polyshape(x_coord,...
                  y_coord);

% define the rotation ref points (around the joints)
% refpoint = [(x_coord(1)+x_coord(end))/2;
%             (y_coord(1)+y_coord(end))/2];
 refpoint = [x_coord(1);
             y_coord(1)];

% compute position of the second joint 
joint_x_2 = L1*cos(theta1);
joint_y_2 = L1*sin(theta1);

% account for joint rotations
% note: rotate function takes in angles in deg not rad! 
link1 = rotate(link1,rad2deg(-(pi/2 - theta1)),refpoint');
link2 = rotate(link2,rad2deg(-(pi/2 - theta2)),refpoint');
link2 = translate(link2,joint_x_2,joint_y_2);

link_shape = [link1; link2];

end 



