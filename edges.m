% Phase 1 edge detection
%% Clean up
clc
clear all
close all

%% Tuning
T = [0.0 0.27]; % Threshold for edge detection. This is a two element vector to describe high and low thresholds
sigma = 0.8; % Sigma value for gaussian smoothing

%% Running Parameters
% Degrees bins
degrees = [0 45 90 135 180 225 270 315 360];

degrees2 = degrees-22.5;
%% Import Images
I = imread('images/sat9.png');
I = rgb2gray(I);
folder='progress-apr14/';
[M,N] = size(I);
%% Image Prep and cleaning
I2 = imgaussfilt(I,sigma);

%% Edge Detection
walls = edge(I2,'Canny',T);
figure(1)
imshowpair(I,walls,'montage');
str=sprintf('Original Image and Image edges - Smoothing sigma %.2f. Edge detection UL %.2f and LL %.2f',sigma,T(1),T(2));
title(str)
saveas(gcf,strcat(folder,str,'.png'))

% Save Walls image to file

str=sprintf('Edges of image - Smoothing sigma %.2f. Edge detection UL %.2f and LL %.2f.jpg',sigma,T(1),T(2));
imwrite(walls,str)

%% Corner Detection
corners = detectHarrisFeatures(walls,'MinQuality',0.2);

%% Review corners
figure(2)
imshow(I); hold on
plot(corners);
str=sprintf('Real Image with corners - smoothed sigma %.2f. Edge detection UL %.2f and LL %.2f',sigma,T(1),T(2));
title(str)
saveas(gcf,strcat(folder,str,'.png'))

figure(3)
imshow(walls); hold on
plot(corners.selectStrongest(round(length(corners)*0.75)));
str=sprintf('Edges Image with corners -  smoothed sigma %.2f. Edge detection UL %.2f and LL %.2f',sigma,T(1),T(2));
title(str)
saveas(gcf,strcat(folder,str,'.png'))

%% Edge dilation
neighbourhood = ones(3,3);
se = strel(neighbourhood);
walls2 = imdilate(walls,se);
figure(4), imshow(walls2)

%% Burns straight edge detection
[orientation, Gmag, lsr] = burns(I,degrees);
[orientation2, Gmag2, lsr2] = burns(I,degrees2);

%% Voting method - To be built and implemented
% Voting method will compare orientations 1 and 2 and determine the more
% dominant lines.

%% Compute line regions
% This function will 
lines=makelines(lsr,M,N);

%% Line linking
% Line linking can be done to 
