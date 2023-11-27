% check feasible point violations 
function violation  = checkViolation(candidate_position,joint_2_position,d,...
                                     quadrant,cond_idx)
    violation = false; 

    link1_left_constr = joint_2_position(2) - (d.m(1)*joint_2_position(1) + d.b(1));
    link2_left_constr = candidate_position(2) - (d.m(3)*candidate_position(1) + d.b(3));
 
    constr_val = [link1_left_constr link2_left_constr];
    constr_val  = (constr_val > 0);

    % if left collision
    left_collision = false;
    if (cond_idx(1) || cond_idx(3))
        left_collision = true;
    end 

    % if right collision 
    right_collision = false;
    if (cond_idx(2) || cond_idx(4))
        right_collision = true;
    end 

    % Q1 left collision, or Q3 right collision 
    if (left_collision && (quadrant == 1)) || (right_collision && (quadrant == 3))
        % toward collision: above L1L, below L2L
        if constr_val(1) == 1 || constr_val(2) == 0
            violation = true;
        end
    end 

    % Q2 left collision, or Q4 right collision
    if (left_collision && (quadrant == 2)) || (right_collision && (quadrant == 4))
        % towards collision: below L1L, below L2L
        if constr_val(1) == 0 || constr_val(2) == 0
            violation = true;
        end
    end 

    % Q3 left collision, or Q1 right collision 
    if (left_collision && (quadrant == 3)) || (right_collision && (quadrant == 1))
        % towards collision: below L1L, above L2L
        if constr_val(1) == 0 || constr_val(2) == 1
            violation  = true;
        end
    end 

    % Q4 left collision, or Q2 right collision
    if (left_collision && (quadrant == 4)) || (right_collision && (quadrant == 2))
        % towards collision: above L1L, above L2L
        if constr_val(1) == 1 || constr_val(2) == 1
            violation = true;
        end
    end 
end

