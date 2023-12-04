function [dMap] = mapDist(d, dMax)
%UNTITLED Summary of this function goes here
%   this function will map the raw distance values fr
    hMax = 25; %[mm] maximum height displacement should be Rc = 25 mm
    % Hmax = leverR; % cam radius lenght --> needs to be passed into the
    % function
    h = hMax - (hMax/dMax)*d;
    dMap = hMax - (hMax/dMax)*d;

    % implementing tapping
    % i is the time and should be passed into the function
    % zone1 = dMax/2;
    % zone2 = dMax;  
    % if d < zone1 && d > 0
    %     % set amplitude and frequency for zone 1
    %     A = 3;
    %     w = 3;
    % elseif d>zone1 && d < zone2
    %     % set amplitude and frequency for zone 2
    %     A = 1; 
    %     w = 1;
    % end
    % 
    % % can also try to make A and w directly dependent on d or h instead of
    % % checking zones
    % % A = h/(hMax/3); % max amplitude will be 3
    % % w = h/(hMax/6); % max frequency will be 6
    % 
    % dMap = A*sin(w*t)+h;

    if d == 0 % whatever being passed in outside threshold
        dMap = 0;
    end

    if dMap > hMax
        dMap = hMax;
    end

end

