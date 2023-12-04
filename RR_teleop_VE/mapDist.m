function [dMap] = mapDist(d, dMax, t)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    hMax = 25; %[mm] maximum height displacement should be Rc = 25 mm
    % function
    tSamp = 4;
    if rem(t,tSamp) ~= 0
        dMap = hMax - (hMax/dMax)*d;
    else
        dMap = 0;
    end
    
    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end


end

