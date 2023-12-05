function [dMap] = mapDist(d, dMax, t)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    hMax = 23; %[mm] maximum height displacement should be Rc = 25 mm
    % function
    tSamp = 10; % duty cycle
    dTemp = hMax - (hMax/dMax)*d;
    remainder = rem(t,tSamp);
    pulse = 5; % pulse/tSamp is the pulse
    if remainder < pulse
        dMap = dTemp;
    else
        dMap = 0.25*dTemp;
    end
    
    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end


end

