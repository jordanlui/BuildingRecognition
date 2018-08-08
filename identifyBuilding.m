function [cornerIDs,corners] = identifyBuilding(buildingcorners,M,N,threshSlope,dmin,dmax)
% Accepts a list of 2-edge-1-corner and finds potential 4 sided building
% matches
% buildingcorners is formatted as [line1 line2 x y slope 1 slope2 angle]
% Output 

% Input parameters:
if nargin < 4
    % tslope 
    threshSlope = 0.01;
    dmin = 50;
    dmax = round(min([M N])/1.5);
end

n = length(buildingcorners);

cornerIDs = []; % Preallocate a matrix to describe corner points that form a building
tic

% Look through through our points at c0 level (first corner)
for i = 1:n
    % Grab slope value
    mo0 = buildingcorners(i,5);
    mi0 = buildingcorners(i,6);
    
    % Look through points to find a c1 match
    for ii = 1:n % Look through points to find a c1 match (second corner)
        % calculate the slope between c0 point and c1 point
        mo1 = cornermatch(buildingcorners,i,ii,mo0,threshSlope,dmin,dmax);
        
        % If we find a match we'll go a level deeper and look for c2 points
        if isempty(mo1) ~= 1
            
            % Look through points to find a c2 point
            for iii = 1:n % Look through points to find a c2 point
                
                % calculate slope between our c1 and c2 point
                mo2 = cornermatch(buildingcorners,ii,iii,mo1,threshSlope,dmin,dmax);
                
                % If we find a match, go deeper to look for c3
                if isempty(mo2) ~= 1
                    for iiii = 1:n % look through points for a c3 result
                        mo3 = cornermatch(buildingcorners,iii,iiii,mo2,threshSlope,dmin,dmax);
                        % If we find a c3 and it connects back to c0 we are
                        % done
                        d3 = sqrt((buildingcorners(i,3) + buildingcorners(iiii,3))^2 + (buildingcorners(i,4) + buildingcorners(iiii,4))^2);
                        if isempty(mo3) ~= 1 && abs(mo3 - mi0) <= threshSlope && d3 >= dmin && d3 <= dmax% c3 IF
                        % If we get this far we have a likely building
                        % match, since we've made a full loop for a 4 sided
                        % building
                        cornerIDs = [cornerIDs ; i ii iii iiii];
                        end % c3 IF
                    end
                end % c2 IF
            end % c2 search
        end % c1 IF
    end % c1 search
    
    % If we go all the way through our points with one set of c0 slops and
    % find nothing, we can check the other slopes. In theory we should only
    % need to check one set since we are planning to close the loop and
    % should find our buildings in any direction
end % c0 search

% Once we have a list of building corners, we can extract the x,y values
% so that they can be plotted in main function
% points{i}.init=1;
if length(cornerIDs) > 0
    for i = 1:size(cornerIDs,1)
        for j = 1:size(cornerIDs,2)
            x(j) = buildingcorners(cornerIDs(i,j),3);
            y(j) = buildingcorners(cornerIDs(i,j),4);
        end
    % Add the first coordinate back in to close the loop
    x(j+1) = buildingcorners(cornerIDs(i,1),3);
    y(j+1) = buildingcorners(cornerIDs(i,1),4);
    corners{i}.x = x;
    corners{i}.y = y;
    end
else
    corners=0;
end
end % Function
