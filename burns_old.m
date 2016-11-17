function [g, errorcount] = burns(f)
% Jordan's first attempt at making a burn's algorithm
% Partition Pixels into bins based on gradient value (45 degree bins). A
% 3x3 window is used for the gradient.
%% Initial stuff
f = double(f);
[M,N] = size(f);
g = zeros(M,N);
g2 = zeros(M,N);
errorcount = 0;
%% Running parameters
% Degrees bins
degrees = [0 45 90 135 180 225 270 315 360] ;
degrees = degrees * pi / 180; % Convert to radians

%% Algorithm
for i = 2:N-1
    for j = 2:M-1
        Gx = f(j+1,i-1) + 2 * f(j+1,i) + f(j+1,i+1) - (f(j-1,i-1) + 2 * f(j-1,i) + f(j-1,i+1));% Horizontal gradient
        Gy = f(j-1,i+1) + 2 * f(j,i+1) + f(j+1,i+1) - (f(j-1,i-1) + 2 * f(j,i-1) + f(j+1,i-1));% Vertical gradient
        G = sqrt(Gx.^2 + Gy.^2);
        g2(j,i) = G;
        theta = atan(Gy/Gx); % Angle in radians
                
        % Partition pixels in Gradient Orientation Bins
        for k = 1:length(degrees)-1
            if degrees(k) <= theta && theta < degrees(k+1)
                g(j,i)= k;
            end
        end
    end
end
% Run connected component algorithm
% Eliminate line support regions smaller than a threshold
% Iterate
% Voting scheme to select preferred lines
% Compute line using least-squares fit
end