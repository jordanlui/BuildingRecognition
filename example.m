% Building recognition project
% Jordan Lui

clc
clear
close all


% Inputs params are:
% angleDev              Angle deviation between lines to form corners
% thresholdIntersect    Threshold on line intersection
% thresholdArea         Minimum area for a line support region
% tlateral              Max lateral distance between lines
% tangle                Max angle between lines
% toverlap              Max overlap fraction
% tunderlap             Max underlap fraction
% threshSlope           Threshold slope between corner's vectors
% dMin                  Min Distance
% dMax                  Max distance


searchBuildings(imread('images\img1.png'),10,3,40,10,10,0.6,0.6,0.01,50,350)
