function motorNum = promptUser() 

senseCount = 4;
motorNum = 0;

% States
states = ["M1", "M2", "M3", "M4", "Z1", "Z2", "Z3", "Z4"];

%display menu of options 
menu(senseCount)
state = input("Enter your action: ", 's'); % user selects option
senseNum = str2num(state(end));

if ismember(state, states)
    if ismember(state, states(1:senseCount))
        motorNum = senseNum; 
    elseif ismember(state, states(senseCount+1:2*senseCount))
        zeroSense(senseNum-1)
    end
else
    disp("------")
    disp("Not a state try agian...")
    disp("------")
end

end