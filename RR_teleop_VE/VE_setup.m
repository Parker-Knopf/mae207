%% VE setup for teleop
%% boundaries of the VE, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
x_VE_lim = 50;
y_VE_lim = 50; 
%% placing static obstacles, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%
obs1_center = [(1/3)*x_VE_lim;(2/3)*y_VE_lim];
obs1_radius = 5;
obs1 = makeCircle(obs1_center,obs1_radius);

obs2_center = [(1/3)*x_VE_lim;(1/3)*y_VE_lim];
obs2_radius = 5;
obs2 = makeCircle(obs2_center,obs2_radius);

obs3_center = [(2/3)*x_VE_lim;(1/2)*y_VE_lim];
obs3_radius = 5;
obs3 = makeCircle(obs3_center,obs3_radius);

obs = [obs1;obs2;obs3];
%% placing target, subject to change %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
target_center = [(1/3)*x_VE_lim;(1/2)*y_VE_lim];
target_radius = 1;
target = makeCircle(target_center,target_radius);
%% define robot geometric parameters, subject to change %%%%%%%%%%%%%%%%%%%
geometry = [20;20;[x_VE_lim/2;0]]; % L1 L2 base