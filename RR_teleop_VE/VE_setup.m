%% VE setup for teleop
%% boundaries of the VE, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_VE_lim = 50;
y_VE_lim = 50; 
%% placing static obstacles, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%
scenario = randi([1 4],1);
if scenario == 1
    obs1_center = [(1/3)*x_VE_lim;(2/3)*y_VE_lim];
    obs2_center = [(1/3)*x_VE_lim;(1/4)*y_VE_lim];
    obs3_center = [(2/3)*x_VE_lim;(1/2)*y_VE_lim];
    target_center = [(1/3)*x_VE_lim (1/2)*y_VE_lim];
elseif scenario == 2
    obs1_center = [(2/3)*x_VE_lim;(2/3)*y_VE_lim];
    obs2_center = [(1/4)*x_VE_lim;(1/2)*y_VE_lim];
    obs3_center = [(1/3)*x_VE_lim;(1/5)*y_VE_lim];
    target_center = [(3/4)*x_VE_lim (1/2)*y_VE_lim];
elseif scenario == 3
    obs1_center = [(1/4)*x_VE_lim;(1/2)*y_VE_lim];
    obs2_center = [(1/3)*x_VE_lim;(1/8)*y_VE_lim];
    obs3_center = [(3/4)*x_VE_lim;(1/2)*y_VE_lim];
    target_center = [(1/8)*x_VE_lim (1/4)*y_VE_lim];
elseif scenario == 4
    obs1_center = [(1/4)*x_VE_lim;(2/3)*y_VE_lim];
    obs2_center = [(1/4)*x_VE_lim;(1/6)*y_VE_lim];
    obs3_center = [(2/3)*x_VE_lim;(1/2)*y_VE_lim];
    target_center = [(2/3)*x_VE_lim (1/5)*y_VE_lim];
end 

% for this particular trial 
obs1 = makeCircle(obs1_center, 5);
obs2 = makeCircle(obs2_center, 5);
obs3 = makeCircle(obs3_center, 5);

obs = [obs1;obs2;obs3];
% obs = [obs1;obs2;obs3;obs4];
%% placing target, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_radius = 1;
target = makeCircle(target_center,target_radius);
%% define robot geometric parameters, subject to change %%%%%%%%%%%%%%%%%%%
geometry = [15;15;[x_VE_lim/2;0]]; % L1 L2 base