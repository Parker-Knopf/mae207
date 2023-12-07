function [x_VE_lim,y_VE_lim,obs,target,geometry] = VE_setup(scenario)
%% boundaries of the VE, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_VE_lim = 50;
y_VE_lim = 50; 
%% placing static obstacles, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%
if scenario == 1
    obs1_center = [(4/16)*x_VE_lim;(7/16)*y_VE_lim];
    obs2_center = [(5/16)*x_VE_lim;(3/16)*y_VE_lim];
    obs3_center = [(11/16)*x_VE_lim;(8/16)*y_VE_lim];
    obs4_center = [(11/16)*x_VE_lim;(3/16)*y_VE_lim];
    target_center = [(2/16)*x_VE_lim;(5/16)*y_VE_lim];
elseif scenario == 2
    obs1_center = [(12/16)*x_VE_lim;(7/16)*y_VE_lim];
    obs2_center = [(11/16)*x_VE_lim;(3/16)*y_VE_lim];
    obs3_center = [(5/16)*x_VE_lim;(8/16)*y_VE_lim];
    obs4_center = [(5/16)*x_VE_lim;(3/16)*y_VE_lim];
    target_center = [(14/16)*x_VE_lim;(5/16)*y_VE_lim];
elseif scenario == 3
    obs1_center = [(5/16)*x_VE_lim;(8/16)*y_VE_lim];
    obs2_center = [(5/16)*x_VE_lim;(1/16)*y_VE_lim];
    obs3_center = [(10/16)*x_VE_lim;(7/16)*y_VE_lim];
    obs4_center = [(12/16)*x_VE_lim;(2/16)*y_VE_lim];
    target_center = [(2/16)*x_VE_lim;(8/16)*y_VE_lim];
elseif scenario == 4
    obs1_center = [(11/16)*x_VE_lim;(8/16)*y_VE_lim];
    obs2_center = [(11/16)*x_VE_lim;(1/16)*y_VE_lim];
    obs3_center = [(6/16)*x_VE_lim;(7/16)*y_VE_lim];
    obs4_center = [(4/16)*x_VE_lim;(2/16)*y_VE_lim];
    target_center = [(14/16)*x_VE_lim;(8/16)*y_VE_lim];
end 

% for this particular trial 
obs1 = makeCircle(obs1_center, 2);
obs2 = makeCircle(obs2_center, 2);
obs3 = makeCircle(obs3_center, 2);
obs4 = makeCircle(obs4_center, 2);

obs = [obs1;obs2;obs3;obs4];
%% placing target, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_radius = 1;
target = makeCircle(target_center,target_radius);
%% define robot geometric parameters, subject to change %%%%%%%%%%%%%%%%%%%
geometry = [15;15;[x_VE_lim/2;0]]; % L1 L2 base
end 