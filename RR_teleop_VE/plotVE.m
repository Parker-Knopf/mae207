% implements plotting function that visualizes the VE 
function [] = plotVE(geometry,link_shape, target, obs,d)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% geometry
% link_shape (2x1) [link1 link2], polyshape objects that store the
% rectangles that describe the link's occupancy area 
% obs (3x1) [obs1 obs2 obs2], polyshape objects that store the circles that
% describe the obstacles' occupancy area
% target (1x1) [target], polyshape object that store the circle that
% describe the obstacles' occupancy area
% d = 

% OUTPUT: 
% nothing 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% plot the robot links 
plot(link_shape(1),'FaceColor',[.75 .75 .75]); hold on
plot(link_shape(2),'FaceColor',[.75 .75 .75]);

% plot the robot joints 
x_coord = link_shape(1).Vertices(:,1); % first column denotes x values 
y_coord = link_shape(1).Vertices(:,2); % second column denotes y values

joint_1_position = [(x_coord(1)+x_coord(end))/2;
                    (y_coord(1)+y_coord(end))/2];
joint_2_position = [(x_coord(2)+x_coord(3))/2;
                    (y_coord(2)+y_coord(3))/2];

joint1 = makeCircle(joint_1_position,1);
joint2 = makeCircle(joint_2_position,1);

plot(joint1,'FaceColor',[1 1 1]);
plot(joint2,'FaceColor',[1 1 1]);

% plot the robot workspace 

% unpack variables
L1 = geometry(1);
L2 = geometry(2);
base = geometry(3:4);

% plot the obstacles 
plot(obs(1),'FaceColor',[0.3010 0.7450 0.9330]);
plot(obs(2),'FaceColor',[0.9290 0.6940 0.1250]);
plot(obs(3),'FaceColor',[0.8500 0.3250 0.0980]);

% plot the target
plot(target,'FaceColor','g');

% plot distance to the obstacle, if necessary
if isstruct(d)
    idx = (d.dist~=0);
    % plot closest point (to the obstacle) on the link 
    plot(d.link(idx,1),d.link(idx,2),'*','Color','k');
    % plot closest point (to the obstable) on the obstacle
    plot(d.obs(idx,1),d.obs(idx,2),'*','Color','k'); 
    % plot the vector connecting these points
    plot([d.link(idx,1);d.obs(idx,1)],[d.link(idx,2);d.obs(idx,2)],'k');
end 

grid on 
axis equal
