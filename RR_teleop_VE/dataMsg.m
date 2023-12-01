function msg = dataMsg(senseVals)
    sep = "|";
    msg = strjoin([num2str(senseVals(1)), sep, num2str(senseVals(2)), sep, num2str(senseVals(3)), sep, num2str(senseVals(4))], "");
end
