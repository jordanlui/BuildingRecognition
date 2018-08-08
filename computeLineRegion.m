function lines = computeLineRegion(lsr,M,N)
% Accepts Line Support Regions and creates the corresponding straight lines
% from this data, outputting the line slope, intercept, and endpoints of
% the lines. 

% Jordan Lui 2016
% Line format is [y-intercept slope x1 y1 x2 y2]
bins = length(lsr); % This corresponds to the number of bins in lsr
lines=[];
for i = 1:bins
    
    [y,x] = ind2sub([M,N],lsr{i});        
    [b, m, x1, y1, x2, y2] = linefit(x,y);
    lines = [lines;b, m, x1, y1, x2, y2];
    
end
end