function [a, b, LLx, point1, ULx, point2] = linefit(x,y)
% Fits a straight line through a series of points x and y. Retuns the
% slope, y-intercept, as well as the endpoints of the line.
% Equation of line that we are fitting is y = a + bx. Jordan Lui 2016
LLx = min(x);
ULx = max(x);
LLy = min(y);
ULy = max(y);
n=length(x);
meanx = mean(x);
meany = mean(y);
SSxx = sum(x.^2) - n.*meanx.^2;
SSyy = sum(y.^2) - n.*meany.^2;
SSxy = sum(x.*y) - n * meanx * meany;
b = SSxy/SSxx; % slope of the line
a = meany - b*meanx; % y intercept
% r2 = SSxy^2/(SSyy * SSxx); % R2 value, which shouldn't be required for my
% project.
point1 = LLx*b + a;
point2 = ULx*b + a;
end