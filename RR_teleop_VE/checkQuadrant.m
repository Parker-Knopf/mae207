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
    else
        disp(theta);
    end 

end

