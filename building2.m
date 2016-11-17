function g = building2(f,M,N)
% Accepts a list of 2-edge-1-corner and finds potential 4 sided building
% matches
% 2EC matrix is formatted as [line1 line2 x y slope 1 slope2 angle]
tic
% Tuning points
tslope = 0.000001;
dmin = 200;
dmax = round(min([M N])/1.5);
n = length(f);
g = []; % Preallocate a matrix to describe corner points that form a building
% Look through through our points at c0 level
for i = 1:n
    % We'll set the slope in the first column as our 'out' slope
    mo0 = f(i,5);
    mi0 = f(i,6);
    
    % Look through points to find a c1 match
    for ii = 1:n % Look through points to find a c1 match
        % calculate the slope between c0 point and c1 point
        mo1 = cornermatch(f,i,ii,mo0,tslope,dmin,dmax);
        
        % If we find a match we'll go a level deeper and look for c2 points
        if isempty(mo1) ~= 1
            
            % Look through points to find a c2 point
            for iii = 1:n % Look through points to find a c2 point
                
                % calculate slope between our c1 and c2 point
                mo2 = cornermatch(f,ii,iii,mo1,tslope,dmin,dmax);
                
                % If we find a match, go deeper to look for c3
                if isempty(mo2) ~= 1
                    for iiii = 1:n % look through points for a c3 result
                        mo3 = cornermatch(f,iii,iiii,mo2,tslope,dmin,dmax);
                        % If we find a c3 and it connects back to c0 we are
                        % done
                        d3 = sqrt((f(i,3) + f(iii,3))^2 + (f(i,4) + f(iii,4))^2);
                        if isempty(mo3) ~= 1 && abs(mo3 - mi0) <= tslope && d3 >= dmin && d3 <= dmax% c3 IF
                        % If we get this far we have a likely building
                        % match, since we've made a full loop for a 4 sided
                        % building
                        g = [g ; i ii iii iiii];
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
end % Function
