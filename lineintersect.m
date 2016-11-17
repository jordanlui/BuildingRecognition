function intersection = lineintersect(linepoints,thresholdintersect)
% Accepts a series of line points and will verify all 
% intersections, noting the particular lines that were involved in the
% intersection as well as the coordinate of intersection. Format of output
% is [line1 line2 x y slope1 slope2]
% Input to this function is object lines, formatted as [b m x1 y1 x2 y2]
% thresholdintersect will allow us to find line intersections even if the
% line segments do not completely intersect.

intersection=[]; % Preallocate the intersection matrix. Columns of this matrix are the row numbers of intersecting lines, as well as the x,y coordinate of the intersection.
n = size(linepoints,1);

% linetest = [1 1 5 5;1 5 5 1;2 5 4 1;1 3 5 3];
for i = 1 : n
    for j = i+1 : n
        x=(linepoints(j,1)-linepoints(i,1))/(linepoints(i,2)-linepoints(j,2)); % Intersection of a line, x = (b2-b1)/(m1-m2)
        if x >= linepoints(i,3) - thresholdintersect && x <= linepoints(i,5) + thresholdintersect % If x is within the upper and lower bounds of the line segment, then we have a valid intersection and will calculate y
            y = linepoints(i,2)*x + linepoints(i,1); % y = mx+b
            intersection = [intersection ; i j x y linepoints(i,2) linepoints(j,2)];
        end    
    end
end
end