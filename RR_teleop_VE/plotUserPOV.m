% plots limited POV for user 
function [] = plotUserPOV(ax,ax_new,camera_target)
    
   % copy over the visualization from global view 
   ax_new_obj  = copyobj(ax.Children,ax_new);
   grid on;
   axis equal;

   % update camera target based on tip position 
   ax_new.CameraTargetMode = 'manual';
   ax_new.CameraTarget = [camera_target(1),camera_target(2),0];

   % update camera view angle
   ax_new.CameraViewAngle = 0.5;
    
end 