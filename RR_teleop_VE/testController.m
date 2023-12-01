% test the input device 
clc;clear;close all
%% 
figure

% set up controller %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
controllerLibrary = NET.addAssembly([pwd '\SharpDX.XInput.dll']);
myController = SharpDX.XInput.Controller(SharpDX.XInput.UserIndex.One);

% signal processing 
filter_window = 1;

t_stable = 1e3;
t_end = 1e5;

k = 0;
% control loop 
for i = 1:t_end
    State = myController.GetState();
    ButtonStates = ButtonStateParser(State.Gamepad.Buttons); % Put this into a structure

    % get x,y input from joystick%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    rjoystick.x(i) = double(State.Gamepad.RightThumbX);
    rjoystick.y(i) = double(State.Gamepad.RightThumbY);

    % if i < filter_window 
    %     % filtered signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     rjoystick.x(i) = mean(rjoystick.x(1:i));
    %     rjoystick.y(i) = mean(rjoystick.y(1:i));
    % else 
    %     % filtered position signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %     rjoystick.x(i) = mean(rjoystick.x(i-filter_window+1:i));
    %     rjoystick.y(i) = mean(rjoystick.y(i-filter_window+1:i));  
    % end
    clf;
    % plot(1:i,rjoystick.x(1:i),'r-'); hold on
    % plot(1:i,rjoystick.y(1:i),'r--'); 
    % pause(0.001)

    if i >= t_stable % do teleoperation task
        k = k + 1;
        if k == 1
            fprintf("start teleoperation\n");
            % stablized positions
            rjoystick_xstable = rjoystick.x(i);
            rjoystick_ystable = rjoystick.y(i);
        end
        % accounting for joystick offset
        rjoystick_offset.x(k) = rjoystick.x(i) - rjoystick_xstable;
        rjoystick_offset.y(k) = rjoystick.y(i) - rjoystick_ystable;

        % plot(1:k,rjoystick_offset.x(1:k),'b-'); hold on
        plot(1:k,rjoystick_offset.y(1:k),'b--');
        pause(0.001)

    end
end 