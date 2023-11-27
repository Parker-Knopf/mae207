% implement distance to obstacle function 
function[d,stop_motion]  = dist2Obstacle(link_shape,obs,thres)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT:
% link_shape (2x1) [link1; link2], polyshape objects that store the
% rectangles that describe the link's occupancy area 
% obs (mx1) [obs1;...;obsm], polyshape object that store the obstacles'
% occupancy area
% thres (1x1), the threshold for "almost collide" 

% OUTPUT:
% d (4x1) [d1;d2;d3;d4], "distance" to obstacle of each side of each link, d1
% and d2 denotes distances on the left and right side of link 1, whereas
% d3,d4 denotes distances on the left and right side of link 2 %%% revise
% this - TODO
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% unpack variables
nObs = numel(obs);
obsX = cell(1,nObs); obsY = cell(1,nObs);
obsX_padded = cell(1,nObs); obsY_padded = cell(1,nObs);

for i = 1:nObs
    obs_tmp = obs(i);
    obs_tmp_padded = polybuffer(obs(i),thres);
    obsX{i} = obs_tmp.Vertices(:,1);
    obsY{i} = obs_tmp.Vertices(:,2);
    obsX_padded{i} = obs_tmp_padded.Vertices(:,1);
    obsY_padded{i} = obs_tmp_padded.Vertices(:,2);
end
obs_padded = polyshape(obsX_padded,obsY_padded);
obs = polyshape(obsX,obsY);

link1 = link_shape(1);
link2 = link_shape(2);

% define line segments that represent each side of each link 
link1_left  =  [link1.Vertices(1,:); link1.Vertices(2,:)]; 
link1_right =  [link1.Vertices(3,:);link1.Vertices(4,:)]; 

link2_left  =  [link2.Vertices(1,:); link2.Vertices(2,:)]; 
link2_right =  [link2.Vertices(3,:);link2.Vertices(4,:)]; 

[d.m(1),d.b(1)] = fitLine(link1_left(:,1),link1_left(:,2));
[d.m(2),d.b(2)] = fitLine(link1_right(:,1),link1_right(:,2));
[d.m(3),d.b(3)] = fitLine(link2_left(:,1),link2_left(:,2));
[d.m(4),d.b(4)] = fitLine(link2_right(:,1),link2_right(:,2));

% check intersection with padded obs with each sides of each link 
[in1,~] = intersect(obs_padded,link1_left);
[in2,~] = intersect(obs_padded,link1_right);
[in3,~] = intersect(obs_padded,link2_left);
[in4,~] = intersect(obs_padded,link2_right);

in1 = in1(~isnan(in1(:,1)),:);
in2 = in2(~isnan(in2(:,1)),:);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        
in3 = in3(~isnan(in3(:,1)),:);
in4 = in4(~isnan(in4(:,1)),:);

d.dist = zeros(1,4);
d.link = zeros(4,2);
d.obs = zeros(4,2);

stop_motion = 0;
% will calculate the distance to obstacle if the link surpasses thres 
if ~isempty(in1) % if left side of link 1 collides 
    line_seg = linspace(in1(1,1),in1(end,1))';
    line_seg = [line_seg interp1(in1(:,1),in1(:,2),linspace(in1(1,1),in1(end,1),100))'];
    inside_obs = isinterior(obs,line_seg(:,1),line_seg(:,2));
    if  any(inside_obs == 1)
        stop_motion = 1;
    end 
    % compute minimal distance between obs and left side of link 1
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(1) = sqrt(dist); d.link(1,:) = line_seg(row,:); d.obs(1,:) = obs.Vertices(col,:);
end
if ~isempty(in2) % if right side of link 1 collides 
    line_seg = linspace(in2(1,1),in2(end,1))';
    line_seg = [line_seg interp1(in2(:,1),in2(:,2),linspace(in2(1,1),in2(end,1),100))'];
    inside_obs = isinterior(obs,line_seg(:,1),line_seg(:,2));
    if  any(inside_obs == 1)
        stop_motion = 1;
    end 
    % compute minimal distance between obs and right side of link 1
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(2) = sqrt(dist); d.link(2,:) = line_seg(row,:); d.obs(2,:) = obs.Vertices(col,:);
end
if ~isempty(in3) % if left side of link 2 collides
    line_seg = linspace(in3(1,1),in3(end,1))';
    line_seg = [line_seg interp1(in3(:,1),in3(:,2),linspace(in3(1,1),in3(end,1),100))'];
    inside_obs = isinterior(obs,line_seg(:,1),line_seg(:,2));
    if any(inside_obs == 1)
        stop_motion = 1;
    end 
    % compute minimal distance between obs and left side of link 2
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(3) = sqrt(dist); d.link(3,:) = line_seg(row,:); d.obs(3,:) = obs.Vertices(col,:);
end
if ~isempty(in4) % if right side of link 2 collides 
    line_seg = linspace(in4(1,1),in4(end,1))';
    line_seg = [line_seg interp1(in4(:,1),in4(:,2),linspace(in4(1,1),in4(end,1),100))'];
    inside_obs = isinterior(obs,line_seg(:,1),line_seg(:,2));
    if any(inside_obs == 1)
        stop_motion = 1;
    end 
    % compute minimal distance between obs and right side of link 2
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(4) = sqrt(dist); d.link(4,:) = line_seg(row,:); d.obs(4,:) = obs.Vertices(col,:);
end

end

function [m,b] = fitLine(x,y)
    if abs(x(1)-x(2)) < 1e-5
        m = Inf;
    else 
        m = (y(2) - y(1))/(x(2) - x(1));
    end 
    b =  y(1) - m*x(1);
end 

