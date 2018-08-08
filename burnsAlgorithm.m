function [orientation, Gmag, lsr] = burnsAlgorithm(f,degrees,thresholdArea)
% Burns algorithm, which extracts straight line segments out of an image.
% Partition Pixels into bins based on gradient value (45 degree bins). A
% 3x3 window is used for the gradient. 

% Built under guidance of Burns Algorithm (Extracting Straight Lines 1986). 
% Code written by Jordan Lui 2016

%% Initialize
f = double((f));
[M,N] = size(f);
g = zeros(M,N);
orientation = zeros(M,N);
errorcount = 0;


%% Algorithm
% Determine the gradient magnitude and direction with prewitt method
[Gmag, Gdir] = imgradient(f,'prewitt');
Gdir = Gdir + 180;
for k = 1:length(degrees)-1
    orientation(find(Gdir>=degrees(k) & Gdir < degrees(k+1))) = k;
end

% Any undetermined gradient values are a result of the shift in the
% degrees, and should belong in bin 1.
orientation(find(orientation==0)) = 1;

% Run connected component algorithm
% Default is 4-connectivity, and areas smaller than thresholdArea are ignored
lsr=linesupportregion(orientation,thresholdArea);

end