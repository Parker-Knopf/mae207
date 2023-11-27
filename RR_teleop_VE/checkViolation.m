% check feasible point violations 
function violation  = checkViolation(candidate_position,joint_2_position,d,...
                                     link_quadrant,cond_idx)

    link1_left_constr = joint_2_position(2) - (d.m(1)*joint_2_position(1) + d.b(1));
    link2_left_constr = candidate_position(2) - (d.m(3)*candidate_position(1) + d.b(3));
 
    constr_val = [link1_left_constr link2_left_constr];
    constr_val  = (constr_val > 0);

    % if link1 left collision 
    left_collision = false;
    if (cond_idx(1) == 1 || cond_idx(3) == 1)
        left_collision = true;
    end 

    % if right collision 
    right_collision = false;
    if (cond_idx(2) == 1 || cond_idx(4) == 1)
        right_collision = true;
    end 

    % assume both links are in collision 
    violation_link1 = checkCollision(left_collision, right_collision, link_quadrant(1), constr_val(1));
    violation_link2 = checkCollision(left_collision, right_collision, link_quadrant(2), constr_val(2));

    % check which link is in collision
    if (cond_idx(1) == 0 && cond_idx(2) == 0)
        violation_link1 = false;
    end
    if (cond_idx(3) == 0 && cond_idx(4) == 0)
        violation_link2 = false;
    end

    % is there a collision? 
    violation = violation_link1 | violation_link2;
  
end

function violation_val = checkCollision(left_collision,right_collision,quadrant,constr_val)
   violation_val = false;
   % Q1 left collision, or Q3 right collision 
    if (left_collision && (quadrant == 1)) || (right_collision && (quadrant == 3))
        % toward collision: above link
        if constr_val == 1 
            violation_val = true;
        end
    end 
    % Q1 right collision, or Q3 left collision
    if (left_collision && (quadrant == 3)) || (right_collision && (quadrant == 1))
        % towards collision: below link 
        if constr_val == 0
            violation_val  = true;
        end
    end
    % Q2 left collision, or Q4 right collision
    if (left_collision && (quadrant == 2)) || (right_collision && (quadrant == 4))
        % towards collision: below link 
        if constr_val == 0 
            violation_val = true;
        end
    end 
    % Q2 right collision, or Q4 left collision
    if (left_collision && (quadrant == 4)) || (right_collision && (quadrant == 2))
        % towards collision: above link
        if constr_val == 1 
            violation_val = true;
        end
    end 
end

