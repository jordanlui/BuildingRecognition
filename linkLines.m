function g = linkLines(f,tlateral,tangle,toverlap,tunderlap)
% The function links smaller lines that are parallel and
% nearly superimposed, or have very small gaps between them

% Parameters
if nargin < 5
    tlateral = 10; % Threshold maximum spacing between endpoints of lines
    tangle = 10; % Threshold angle difference between lines
    toverlap = 0.6; % Threshold degree of overlap over length 2
    tunderlap = 0.6; % Threshold degree of underlap over length 1
end

n = length(f);
newn = n;
priorn = 0;
g=[];
g2=[];
matchedlines = [];
loopcount=0;
tic

while priorn ~= newn
    for i = 1:n
        if isempty(find(i == matchedlines,1)) == 1
            for j = 1:n
                if isempty(find(j == matchedlines,1)) == 1 && j ~=i
                    % Calculate our line connectivity criteria
                    lateral = min([sqrt((f(i,3) - f(j,3))^2 + (f(i,4) - f(j,4))^2),sqrt((f(i,3) - f(j,5))^2 + (f(i,4) - f(j,6))^2),sqrt((f(i,5) - f(j,3))^2 + (f(i,6) - f(j,4))^2),sqrt((f(i,5) - f(j,5))^2 + (f(i,6) - f(j,6))^2)]);
                    angle = (atan(f(i,2)) - atan(f(j,2)))*180/pi;
                    overlap = abs(f(j,3) - f(i,5)) / sqrt((f(j,3) - f(j,5))^2 + (f(j,4) - f(j,6))^2);
                    underlap = abs(f(j,3) - f(i,5)) / sqrt((f(i,3) - f(i,5))^2 + (f(i,4) - f(i,6))^2);
                    
                    % Conditional to check if we meet enough of the line
                    % connectivity criteria
                    if abs(lateral) <= tlateral && abs(angle) <= tangle && (overlap <= toverlap || underlap <= tunderlap)
                        % sprintf('Lines %i and %i should be joined',i,j)
                        % If we determine that we have a match, we add
                        % the matched lines to a list.
                        matchedlines = [matchedlines ; i ; j];
                        
                        % We determine the new end point of the line as the further
                        % of Line 1 and Line 2's endpoints
                        if f(i,5) >=  f(j,5)
                            newx = f(i,5);
                            newy = f(i,6);
                        else
                            newx = f(j,5);
                            newy = f(j,6);
                        end
                        % [b,m] = linefit([f(i,3);newx],[f(i,4);newy]);
                        % We then determine the slope and y-intercept of
                        % new line
                        m = (newy - f(i,4)) / (newx - f(i,3));
                        b = f(i,4) - m * f(i,3);
                        % Write these values to a matrix
                        g = [g ; b, m, f(i,3) , f(i,4) , newx , newy];
                    end
                end
            end
        end

    end

    % Once we have completely processed the list of lines, we will see if we
    % need to loop around and complete the sequence again to identify more
    priorn=newn;
    newn = n - length(matchedlines);
    loopcount = loopcount + 1;
    % Loop converges if we fail to find more lines to match. At this point
    % the prior n and new n values will be the same.
end

% sprintf('Number of matched lines is %i. Process time is %.2f. Took %i iterations.',length(matchedlines),toc,loopcount)
% tic

% Add the unmatched lines and the new matched lines into a new matrix and
% output. Make sure we omit lines that have been matched. So if we make x
% new lines we will have n-x lines total after processing.

for i = 1:n
    if isempty(find(i == matchedlines,1)) == 1
        g2 = [g2 ; f(i,:)];
    end
end

% Then append the new found lines to the remaining lines
g2 = [g2 ; g];
g=g2;
% Re-sort the rows
g = sortrows(g,3);
% sprintf('Time to format output new values is %.2f',toc)
end