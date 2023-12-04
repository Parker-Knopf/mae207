function [dMap] = mapDist(d, dMax, t)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    hMax = 25; %[mm] maximum height displacement should be Rc = 25 mm

    %sampling 
    tSamp = 2;
    if rem(t,tSamp) ~= 0 % every time you hit 2 seconds the cam will jump to 0
        dMap = Hmax - (Hmax/dMax)*d;
    else
        dMap = 0;
    end


    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end

end

