function g = computeCorners(lines,intersection,anglemin,anglemax)
% Examines a list of intersections and identifies the ones with an
% intersect angle that is within specified tolerances. These are 2EC (two
% edge one corner) intersections.
% lines is formatted as [y-intercept slope x1 y1 x2 y2]
% intersection is formatted as [line1 line2 x y slope1 slope2]
% Outputs a matrix that is formatted as [line1 line2 x y slope1 slope2 angle]
g = []; % Preallocate g
for i = 1:size(intersection,1)
    angle = round(abs(tan(lines(intersection(i,1),2) * lines(intersection(i,2),2))*180/pi));
    if angle >= anglemin && angle <= anglemax
        g = [g ; intersection(i,1:6) angle];
    end
end
end