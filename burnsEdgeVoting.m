function g = burnsEdgeVoting(lsr1,lsr2,M,N)
% Accepts two sets of line support regions from Burns algorithm and uses voting system to
% choose the better sets of lines
% Extract all pixel locations, determine the region ID that it votes for,
% and the size of that region

% Read through each set of LSR and 'write' them out to a vector
% Output format will be [pixel# region1# region2# region1size region2size]

% Initialize
tic
numbin = length(lsr1); % Number of angular bins. Should be same for both LSR1 and LSR2
I = zeros(M*N,6); % Preallocate our data
I(:,1)=1:M*N; % Put the element number in first column. May be able to remove this.
k = 1; % Use this to keep track of the region numbers that we are encountering
acceptancecrit = 0.5; % Acceptance criteria for the voting
region = zeros(1,4);

for i = 1:numbin % Loop through each 
    for j = 1:lsr1{i}.NumObjects
        % Place the value of the bin (1-8) in
        I([lsr1{i}.PixelIdxList{1,j}] + M*N*1) = k; % The value of the region should go in column 2
        I([lsr1{i}.PixelIdxList{1,j}] + M*N*3) = length(lsr1{i}.PixelIdxList{1,j}); % The size of the region should go in column 4
        region(k,2) = length(lsr1{i}.PixelIdxList{1,j}); % Put the value of the LSR area into region matrix
        k = k + 1;
    end
end

% Do the same for LSR2
for i = 1:numbin
    for j = 1:lsr2{i}.NumObjects
        % Place the value of the bin (1-8) in
        I([lsr2{i}.PixelIdxList{1,j}] + M*N*2) = k; % The value of the region should go in column 2
        I([lsr2{i}.PixelIdxList{1,j}] + M*N*4) = length(lsr2{i}.PixelIdxList{1,j}); % The size of the region should go in column 4
        region(k,2) = length(lsr2{i}.PixelIdxList{1,j}); % Put the value of the LSR area into region matrix
        k = k + 1;
    end
end



region(:,1) = [1:k-1];
% Run a for loop to look for pixels that are one or two gradients. Pixels
% in one gradient will vote for that gradient region. Pixels in both
% regions will vote for the region that is larger.
for i = 1:length(I)
    % This for loop first does the pixel voting as mentioned above
    if I(i,2) > 0 && I(i,3) > 0
        if I(i,4) >= I(i,5)
            I(i,6) = I(i,2);
        else
            I(i,6) = I(i,3);
        end
    elseif I(i,2) > 0
        I(i,6) = I(i,2);
    elseif I(i,3) > 0
        I(i,6) = I(i,3);
    end
    
    % Calculate the new areas of the regions
    if I(i,2) > 0 || I(i,3) > 0
        region(I(i,6),3) = region(I(i,6),2) + 1;
    end
end

% Look at the areas of the regions and determine which ones still have over
% 50% of pixels voting for them
% startloop = toc;
for i = 1:length(region)
%     region(i,4) = region(i,3)/region(i,2);
    if region(i,3)/region(i,2) >= acceptancecrit
        region(i,4) = 1;
%     else
%         region(i,5) = -1;
    end

end

% Now that we have determined new Line Support Regions (and rejected
% smaller ones), we can write the regions back into a file.
time1=toc;
regionkeep = region(region(:,4)==1,:);
for i = 1:length(regionkeep)
    % We first look through our regions object to determine which regions
    % we are indeed keeping. Once we locate one, we look in the matrix of
    % pixels to write their coordinates back into a LSR file.
%     if region(i,4) == 1
    g{i} = I(I(:,6) == regionkeep(i,1),1);
%     end

end


% Output function runtime
% sprintf('run time %.2f s',toc-time1)
% sprintf('Burns Edge voting performed in %.2f seconds',toc)

end