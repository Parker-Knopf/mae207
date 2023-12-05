clear all; close all; clc;

% Constants
senseCount = 4;

% States
states = ["M1", "M2", "M3", "M4", "Z1", "Z2", "Z3", "Z4", "E"];
state = states(1);

% Logic
senseNum = 0;
senseCounts = zeros(4,1);
senseVals = zeros(4,1);

% Serial
baud = 115600;
% serialportlist("available") % Commet out once serial port known and changed on line 86
% return % Commet out once serial port known and changed on line 86

while (state ~= "E")
    menu(senseCount);
    state = input("Enter your action: ", 's');
    senseNum = str2num(state(end));

    if ismember(state, states)
        if ismember(state, states(1:senseCount))
            [senseCounts, senseVals] = moveSense(senseNum, senseCounts, senseVals);
        elseif ismember(state, states(senseCount+1:2*senseCount))
            zeroSense(senseNum-1)
        end
    else
        disp("------")
        disp("Not a state try agian...")
        disp("------")
    end
end

function menu(num)
    disp("HAPTO-PATH SYSTEM DIAGNOSTICS");

    disp("Menu Options:");
    for (i = 1:num)
        fprintf("M%d: Move Sense %d\n", i, i);
    end
    for (i = 1:num)
        fprintf("Z%d: Zero Sense %d\n", i, i);
    end
    disp("E: Exit");
end

function [senseCounts, senseVals] = moveSense(num, senseCounts, senseVals)
    % 28 leftarrow
    % 29 rightarrow
    % 30 uparrow
    % 31 downarrow
    count2h = 5;
    key = 0;
    disp("Enter to Exit");
    while (key ~= 13)
        val = waitforbuttonpress;
        key = double(get(gcf, 'CurrentCharacter'));
        if (key == 28) 
            senseCounts(num) = senseCounts(num) - 1;
        elseif (key == 29)
            senseCounts(num) = senseCounts(num) + 1;
        end
        senseVals(num) = senseCounts(num) / count2h; 
        sendData("D", dataMsg(senseVals))
    end
end

function zeroSense(num)
    sendData("Z", num)
end

function msg = dataMsg(senseVals)
    sep = "|";
    msg = strjoin([num2str(senseVals(1)), sep, num2str(senseVals(2)), sep, num2str(senseVals(3)), sep, num2str(senseVals(4))], "");
end

function sendData(type, msg)
    package = strjoin(["{", type, ": ", msg, "}"], "");
    disp(package);

    baud = 115600;
    comun = serialport("COM3", baud);
    write(comun, package, "string")
    
%     disp(read(comun, 3, "string"))
end
