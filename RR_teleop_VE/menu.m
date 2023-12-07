function menu(num)
    disp("Menu Options:");
    for (i = 1:num)
        fprintf("M%d: Move Sense %d\n", i, i);
    end

    disp("E: Press E to zer0 all motors and exit");
    
end
