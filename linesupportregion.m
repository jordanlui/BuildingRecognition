function g = linesupportregion(f,thresholdarea)
% Accepts a gradient field image and connects components. It will then
% process image and remove regions that are smaller than a threshold,
% nominally 3 pixel area. Jordan Lui 2016
[M,N] = size(f);
LL = min(f(:)); % Smallest bin of f. Should be bin 1
UL = max(f(:)); % Largest bin of f. Should be bin 8.
connectivity = 4; % We are doing 4 pixel connectivity

%% Connectivity
for i = LL:UL
    lsr{i} = bwconncomp(f==i,connectivity);
end
%% Ignore smaller regions
% We will now look through the linear support regions and remove regions
% smaller than the threshold area size. We'll store this in lsr2.
k=1;
for i = LL:UL
    for j = 1:lsr{i}.NumObjects
        if length(lsr{i}.PixelIdxList{1,j}) > thresholdarea
           lsr2{i}.PixelIdxList{1,k} = lsr{i}.PixelIdxList{1,j};
           k=k+1;
        end
    end
    lsr2{i}.NumObjects = k-1;
    k=1;
end
g=lsr2;


end