function [dMap] = mapDist(d, dMax)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    Hmax = 25; %[mm] maximum height displacement should be Rc = 25 mm
    dMap = Hmax - (Hmax/dMax)*d;
    disp(d)
    

    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end
end

