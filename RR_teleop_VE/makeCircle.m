%% construct a polyshape object that represents a circle
function circle = makeCircle(center,radius)
    n = 100;
    theta = (0:n-1)*(2*pi/n);
    x = center(1) + radius*cos(theta);
    y = center(2) + radius*sin(theta);
    circle = polyshape(x,y);
end