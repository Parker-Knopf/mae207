% check feasible point violations 
function violation  = checkViolation(candidate_position,joint_2_position,d,...
                                     joint_values,cond_idx,link_shape)
    theta1 = joint_values(1);
    violation = false; 
    
    link1_x = link_shape(1).Vertices(:,1);
    link1_y = link_shape(1).Vertices(:,2);
   
    link2_x = link_shape(2).Vertices(:,1);
    link2_y = link_shape(2).Vertices(:,2);

    k1 = convhull(link1_x, link1_y);
    k2 = convhull(link2_x, link2_y);

    link1_left_constr = joint_2_position(2) - (d.m(1)*joint_2_position(1) + d.b(1));
    link2_left_constr = candidate_position(2) - (d.m(3)*candidate_position(1) + d.b(3));
    link1_right_constr = joint_2_position(2) - (d.m(2)*joint_2_position(1) + d.b(2));
    link2_right_constr = candidate_position(2) - (d.m(4)*candidate_position(1) + d.b(4));

    % account for thickness
    in = inpolygon(candidate_position(1),candidate_position(2),...
                   [link1_x(k1)' link2_x(k2)'],[link1_y(k1)' link2_y(k2)']);
    violation_thickness = false;
    if in ~= 0
        violation_thickness = true;
    end 
 
    constr_val = [link1_left_constr link1_right_constr link2_left_constr link2_right_constr];
    constr_val  = (constr_val > 0);

    quadrant = checkQuadrant(theta1);

    % if left collision
    if (cond_idx(1) || cond_idx(3))
        % if links are in quadrant 1
        if quadrant == 1
            % towards collision: above L1L, below L2L
            if constr_val(1) || ~constr_val(3)
                violation  = true;
            end
            % if links are in quadrant 2
        elseif quadrant ==2
            % towards collision: below L1L, below L2L
            if ~constr_val(1) || ~constr_val(3)
                violation = true;
            end
            % if links are in quadrant 3
        elseif quadrant == 3
            % towards collision: below L1L, above L2L
            if ~constr_val(1) || constr_val(3)
                violation = true;
            end
            % if links are in quadrant 4
        elseif quadrant == 4
            % towards collision: above L1L, above L2L
            if constr_val(1) || constr_val(3)
                violation = true;
            end
        end
    end

    % if right collision, need to account for a thickness vector!
    if (cond_idx(2) || cond_idx(4))
        % if links are in quadrant 1
        if quadrant == 1
            % towards collision: below L1R, above L2R
            if constr_val(2) == 0 || constr_val(4) == 1
                violation  = true;
            end
            % if links are in quadrant 2
        elseif quadrant == 2
            % towards collision: above L1R, above L2R
            if constr_val(2) || constr_val(4)
                violation = true;
            end
            % if links are in quadrant 3
        elseif quadrant == 3
            % towards collision: above L1R, below L2R
            if constr_val(2) || ~constr_val(4)
                violation = true;
            end
            % if links are in quadrant 4
        elseif quadrant == 4
            % towards collision: below L1R, below L2R
            if ~constr_val(2) || ~constr_val(4)
                violation = true;
            end
        end
    end
    violation  = violation | violation_thickness;
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

