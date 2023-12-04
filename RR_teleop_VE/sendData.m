function sendData(type, msg)

%msg is a string of the data value(s)
    package = strjoin(["{", type, ": ", msg, "}"],"");
    disp(package);
    % 
    baud = 115600;
    comun = serialport("COM6", baud);
    writeline(comun, package)
end

