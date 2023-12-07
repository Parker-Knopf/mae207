% implements plotting function that visualizes the VE 
function [ax,camera_target] = plotVE(geometry,link_shape,target,obs,thres,d,theta,ax)
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
plot(ax,link_shape(1),'FaceColor',[.75 .75 .75]); hold(ax,"on");
plot(ax,link_shape(2),'FaceColor',[.75 .75 .75]);

% plot end effector 
base = geometry(3:4);
poly1 = polyshape([0 0 1 1],...
                  [1 0 0 1]);
poly2 = polyshape([0.25 0.25 0.75 0.75],...
                  [0.25 1 1 0.25]);
EE    = subtract(poly1,poly2);
EE    = scale(EE,2);
EE    = translate(EE,base(1),base(2));
trans = link_shape(2).Vertices(2,:) - base';
EE    = rotate(EE,rad2deg(-(pi/2 - theta(2))), base');
EE    = translate(EE,trans(1),trans(2));

camera_target = mean([EE.Vertices(1,:);EE.Vertices(4,:)]);

plot(ax,EE,'FaceColor',[.75 .75 .75]);

% plot the robot joints 
x_coord = link_shape(1).Vertices(:,1); % first column denotes x values 
y_coord = link_shape(1).Vertices(:,2); % second column denotes y values

joint_1_position = [(x_coord(1)+x_coord(end))/2;
                    (y_coord(1)+y_coord(end))/2];
joint_2_position = [(x_coord(2)+x_coord(3))/2;
                    (y_coord(2)+y_coord(3))/2];

joint1 = makeCircle(joint_1_position,1.5);
joint2 = makeCircle(joint_2_position,1.5);

plot(ax,joint1,'FaceColor',[1 1 1]);
plot(ax,joint2,'FaceColor',[1 1 1]);

% plot the robot workspace 

% unpack variables
L1 = geometry(1);
L2 = geometry(2);
base = geometry(3:4);

% plot the obstacles 
plot(ax,obs(1),'FaceColor',[0.3010 0.7450 0.9330]);
plot(ax,obs(2),'FaceColor',[0.9290 0.6940 0.1250]);
plot(ax,obs(3),'FaceColor',[0.8500 0.3250 0.0980]);
plot(ax,obs(4),'FaceColor',[0.4660 0.6740 0.1880]);

% plot the obstacle thresholds 
nObs = numel(obs);
obsX_padded = cell(1,nObs); obsY_padded = cell(1,nObs);

for i = 1:nObs
    obs_tmp_padded = polybuffer(obs(i),thres);
    obsX_padded{i} = obs_tmp_padded.Vertices(:,1);
    obsY_padded{i} = obs_tmp_padded.Vertices(:,2);
end
obs_padded = polyshape(obsX_padded,obsY_padded);
plot(ax,obs_padded,'FaceColor',[0.75 0.75 0.75]);

% plot the target
plot(ax,target,'FaceColor','g');

% plot distance to the obstacle, if necessary
if isstruct(d)
    idx = (d.dist~=0);
    % plot closest point (to the obstacle) on the link 
    plot(ax,d.link(idx,1),d.link(idx,2),'*','Color','k');
    % plot closest point (to the obstable) on the obstacle
    plot(ax,d.obs(idx,1),d.obs(idx,2),'*','Color','k'); 
    % plot the vector connecting these points
    % plot([d.link(idx,1);d.obs(idx,1)],[d.link(idx,2);d.obs(idx,2)],'k');
end 


% plot boundaries! 
% vertical boundaries
xline(ax,50,'LineWidth',5,'Color','k');
xline(ax,0,'LineWidth',5,'Color','k');
% horizontal boundaries
yline(ax,0,'LineWidth',5,'Color','k');
yline(ax,50,'LineWidth',5,'Color','k');

grid(ax,"on")
axis(ax,'equal')
