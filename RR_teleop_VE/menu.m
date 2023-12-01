function menu(num)
    disp("Menu Options:");
    for (i = 1:num)
        fprintf("M%d: Move Sense %d\n", i, i);
    end
    for (i = 1:num)
        fprintf("Z%d: Zero Sense %d\n", i, i);
    end
    disp("E: Exit after zeroing the last motor");
    
end
