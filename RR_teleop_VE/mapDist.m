function [dMap] = mapDist(d, dMax, t)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    hMax = 25; %[mm] maximum height displacement should be Rc = 25 mm
    
    %sampling 
    if rem(t,5) ~= 0
        dMap = Hmax - (Hmax/dMax)*d;
    else
        dMap = 0;
    end


    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end

end

