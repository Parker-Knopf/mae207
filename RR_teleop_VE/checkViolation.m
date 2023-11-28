% check feasible point violations 
function violation  = checkViolation(candidate_position,joint_2_position,d,...
                                     link_quadrant,cond_idx)

    link1_left_constr = joint_2_position(2) - (d.m(1)*joint_2_position(1) + d.b(1));
    link2_left_constr = candidate_position(2) - (d.m(3)*candidate_position(1) + d.b(3));
    link2_top_contr =  candidate_position(2) - (d.m(5)*candidate_position(1) + d.b(5));
 
    constr_val = [link1_left_constr link2_left_constr link2_top_contr];
    constr_val  = (constr_val > 0);

    % if left collision 
    left_collision = false;
    if (cond_idx(1) == 1 || cond_idx(3) == 1)
        left_collision = true;
    end 

    % if right collision 
    right_collision = false;
    if (cond_idx(2) == 1 || cond_idx(4) == 1)
        right_collision = true;
    end 

    % if top collision 
    top_collision = false;
    if (cond_idx(5) == 1)
        top_collision = true;
    end
    
    collision = [left_collision, right_collision, top_collision];
    
    % assume both links are in collision 
    violation_link1 = checkCollision(collision, link_quadrant(1), constr_val(1));
    violation_link2 = checkCollision(collision, link_quadrant(2), constr_val(2));
    violation_link2_top = checkCollision(collision, link_quadrant(2), constr_val(3));

    % check which link is in collision
    if (cond_idx(1) == 0 && cond_idx(2) == 0)
        violation_link1 = false;
    end
    if (cond_idx(3) == 0 && cond_idx(4) == 0)
        violation_link2 = false;
    end
    if (cond_idx(5) == 0)
        violation_link2_top = false;
    end

    % is there a collision? 
    violation = violation_link1 | violation_link2 | violation_link2_top;
  
end

function violation_val = checkCollision(collision,quadrant,constr_val)
   
   violation_val = false;
   left_collision = collision(1);
   right_collision = collision(2);
   top_collision = collision(3);

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
    % Q1, 2 top collision
    if (top_collision && (quadrant == 1)) || (top_collision && (quadrant == 2))
        % towards collision: above link
        if constr_val == 1 
            violation_val = true;
        end
    end
    % Q3, 4 top collision 
    if (top_collision && (quadrant == 3)) || (top_collision && (quadrant == 4))
        % towards collision: below link 
        if constr_val == 0 
            violation_val = true;
        end
    end
end

