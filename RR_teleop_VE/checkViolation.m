% check feasible point violations 
function violation  = checkViolation(target_x, target_y, tip_position_init,d,joint_values)
    theta1 = joint_values(1);
    violation = false; 
   
    link1_left_constr = (target_y + tip_position_init(2)) - (d.m(1)*(target_x + tip_position_init(1)) + d.b(1));
    link2_left_constr = (target_y + tip_position_init(2)) - (d.m(3)*(target_x + tip_position_init(1)) + d.b(3));
    link1_right_constr = (target_y + tip_position_init(2)) - (d.m(2)*(target_x + tip_position_init(1)) + d.b(2));
    link2_right_constr = (target_y + tip_position_init(2)) - (d.m(4)*(target_x + tip_position_init(1)) + d.b(4));

    constr_val = [link1_left_constr link2_left_constr link1_right_constr link2_right_constr];
    constr_val  = (constr_val > 0);

    quadrant = checkQuadrant(theta1);
    if quadrant == 1
        if any((constr_val - ~logical([0 1 1 0]))~=0)
            violation = true;
        end
    elseif quadrant == 2
        if any((constr_val - ~logical([1 1 0 0]))~=0)
            violation = true;
        end
    elseif quadrant == 3
        if any((constr_val - ~logical([1 0 0 1]))~=0)
            violation = true;
        end
    elseif quadrant == 4
        if any((constr_val - ~logical([0 0 1 1]))~=0)
            violation = true;
        end
    end
end

function quadrant = checkQuadrant(theta)
   % links in Q1,
    if (theta >= 0 && theta < pi/2)
        quadrant = 1;
    % links in Q2, 
    elseif (theta >= pi/2 && theta < pi)
        quadrant = 2;
    % links in Q3, 
    elseif (theta >= pi && theta < 3*pi/2)
        quadrant = 3;
    % links in Q4 
    elseif (theta >= 3*pi/2 && theta <= 2*pi)
        quadrant = 4;
    end 
end
