% implement distance to obstacle function 
function[d]  = dist2Obstacle(link_shape,obs,thres)
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
obs1 = obs(1);
obs2 = obs(2);
obs3 = obs(3);
obs  = polyshape({obs1.Vertices(:,1),...
                obs2.Vertices(:,1), ...
                obs3.Vertices(:,1)},...
                {obs1.Vertices(:,2),...
                obs2.Vertices(:,2), ...
                obs3.Vertices(:,2)});

link1 = link_shape(1);
link2 = link_shape(2);

% pad the obs by thres, create a global obstacle object 
obs1_padded  = polybuffer(obs1,thres);
obs2_padded  = polybuffer(obs2,thres);
obs3_padded  = polybuffer(obs3,thres);
obs_padded   = polyshape({obs1_padded.Vertices(:,1),...
                          obs2_padded.Vertices(:,1), ...
                          obs3_padded.Vertices(:,1)},...
                         {obs1_padded.Vertices(:,2),...
                          obs2_padded.Vertices(:,2), ...
                          obs3_padded.Vertices(:,2)});

% define line segments that represent each side of each link 
link1_left  =  [link1.Vertices(1,:); link1.Vertices(2,:)]; 
link1_right =  [link1.Vertices(3,:);link1.Vertices(4,:)]; 
link2_left  =  [link2.Vertices(1,:); link2.Vertices(2,:)]; 
link2_right =  [link2.Vertices(3,:);link2.Vertices(4,:)]; 

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

% will calculate the distance to obstacle if the link surpasses thres 
if ~isempty(in1) % if left side of link 1 collides 
    line_seg = linspace(in1(1,1),in1(end,1))';
    line_seg = [line_seg interp1(in1(:,1),in1(:,2),linspace(in1(1,1),in1(end,1),100))'];
    % compute minimal distance between obs and left side of link 1
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(1) = sqrt(dist); d.link(1,:) = line_seg(row,:); d.obs(1,:) = obs.Vertices(col,:);
end
if ~isempty(in2) % if right side of link 1 collides 
    line_seg = linspace(in2(1,1),in2(end,1))';
    line_seg = [line_seg interp1(in2(:,1),in2(:,2),linspace(in2(1,1),in2(end,1),100))'];
    % compute minimal distance between obs and right side of link 1
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(2) = sqrt(dist); d.link(2,:) = line_seg(row,:); d.obs(2,:) = obs.Vertices(col,:);
end
if ~isempty(in3) % if left side of link 2 collides 
    line_seg = linspace(in3(1,1),in3(end,1))';
    line_seg = [line_seg interp1(in3(:,1),in3(:,2),linspace(in3(1,1),in3(end,1),100))'];
    % compute minimal distance between obs and left side of link 2
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(3) = sqrt(dist); d.link(3,:) = line_seg(row,:); d.obs(3,:) = obs.Vertices(col,:);
end
if ~isempty(in4) % if right side of link 2 collides 
    line_seg = linspace(in4(1,1),in4(end,1))';
    line_seg = [line_seg interp1(in4(:,1),in4(:,2),linspace(in4(1,1),in4(end,1),100))'];
    % compute minimal distance between obs and right side of link 2
    dist = (obs.Vertices(:,2)' - line_seg(:,2)).^2  +  (obs.Vertices(:,1)' - line_seg(:,1)).^2;
    [dist,idx] = min(dist,[],'all','linear');
    [row,col] = ind2sub([100,numel(obs.Vertices(:,2))],idx);
    d.dist(4) = sqrt(dist); d.link(4,:) = line_seg(row,:); d.obs(4,:) = obs.Vertices(col,:);
end

% if no collision
if (isempty(in1) && isempty(in2) && isempty(in3) && isempty(in4))
    d = 0;
end

end