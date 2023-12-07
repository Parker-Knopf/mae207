function calibrate(controller)

disp("Calibration...")
%%%%%%%%%%%%%%%%%%%%%%%%%% const %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

filter_window = 1;
threshold = 200;

cont = true;
senseCount = 4;
motorNum = 0;
notPressed = false;

%%%%%%%%%%%%%%%%%%%%%%%%%%% prompt user %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
sendData('S','');
load('calibration_values','hSaved');
while cont    
    % States
    states = ["M1", "M2", "M3", "M4", "E"];
    
    % display menu of options 
    menu(senseCount)
    state = input("Enter your action: ", 's'); % user selects option
    senseNum = str2num(state(end));
    
    if ismember(state, states)
        if ismember(state, states(1:senseCount)) % user wants to control one of the motors
            motorNum = senseNum; 
            notPressed = true;  
        elseif ismember(state, states(end)) % user wants to save motor positions and exit
            for m = 1:senseCount   
                zeroSense(m-1); 
            end
            %notPressed = false;
            save('calibration_values','hSaved');
            break;
        end
    else
        disp("------")
        disp("Not a state try agian...")
        disp("------")
    end

    senseCounts = 0;
    i = 0;

    while notPressed 
%%%%%%%%%%%%%%%%%%%% control loop for calibration %%%%%%%%%%%%%%%%%%%%%%%%
        i = i+1;
        State = controller.GetState();
        ButtonStates = ButtonStateParser(State.Gamepad.Buttons); % Put this into a structure
        
        % get y input from joystick%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        rjoystick.y(i) = double(State.Gamepad.RightThumbY);
        if i < filter_window 
            % filtered signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            rjoystick.y(i) = mean(rjoystick.y(1:i));
        else 
            % filtered position signal %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            rjoystick.y(i) = mean(rjoystick.y(i-filter_window+1:i));  
        end
        
    
        % keep track of counts
        if (rjoystick.y(i) > threshold) 
            senseCounts = senseCounts + 1;   
        elseif (rjoystick.y(i) < - threshold )
            senseCounts = senseCounts - 1;
        end
        
        
        pause(.1); % 0.2 sec
        %fprintf("joystick:%f\n", rjoystick.y(i)); 
        %fprintf("senseCounts:%f\n",senseCounts); 
        scale = .35; % [mm/count] 
        d = scale*senseCounts; % conversion into [mm]
        h = zeros(4,1);
    
        %%%%%%%%% distance to obstacles %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        h(motorNum) = d;  
        %senseVals = d + hSaved(motorNum);

        data = h + hSaved;

        if ButtonStates.A == 1
            notPressed = false;
            hSaved(motorNum) = d;
        end
        
        moveSense(data);
    end

end