% Phase 1 edge detection
%% Clean up
clc
clear all
close all
tic; % Start at timer
%% Import Images
filename = 'images/sat9lite.png';
% filename = 'images/sat12.jpg';
% filename = 'images/test3.jpg';
I = imread(filename);
I = (rgb2gray(I));
folder='output/'; % This is the output folder
[M,N] = size(I);

%% Tuning and Running Parameters
edgedetectionthreshold = [0.0 0.00]; % Threshold for Canny edge detection. This is a two element vector to describe high and low thresholds
sigma = 0.8; % Sigma value for gaussian smoothing
filter = 7; % Filter size for the Gaussian smoothing operation

% Degrees bins
degrees = [0 45 90 135 180 225 270 315 360];
degrees2 = degrees-22.5;

% Threshold area for burns algorithm
% thresholdarea = 5;
thresholdarea = round(min([M N])/10); % This threshold area dictates the minimum line size that we will consider as a valid lines. Small threshold results in longer processing times but less chance of missing a building wall.

% Angle thresholdholds for building corner detection
anglemin = 80;
anglemax = 105;
thresholdintersect = 3; % We use a tolerance for line intersections

%% Image Prep and cleaning
I2 = imgaussfilt(I,sigma,'FilterSize',filter);
% I2=I;
%% Burns straight edge detection
[orientation, Gmag, lsr1] = burns(I2,degrees,thresholdarea);
[orientation2, Gmag2, lsr2] = burns(I2,degrees2,thresholdarea);

%% Voting method - To be built and implemented
% Voting method will compare orientations 1 and 2 and determine the more
% dominant lines. This helps to remove the error associated with the
% arbitrarily set gradient orientation bins.
lsr = burnsedgevote(lsr1,lsr2,M,N);

%% Compute line regions
% This function will take the line regions established from burns algorithm
% and analyze the series of points that define each line region. The
% function will determine the line of best fit using least squares fitting.
% The slope, y-intercept and endpoints of the line are output.
lines=makelines(lsr,M,N);

%% Line linking
% Line linking can be done to link lines that overlap, decreasing the number of overall lines
% This function is still to be created.
lines = linelinking(lines);
%% Line Intersection detection
% intersection = lineintersect(lines(:,3:end));
% Compute line intersections
% Note that we should revise this section of code to extend line segments
% during intersection detection, to help increase rate of detection.

sprintf('time for edge detection, voting, and line linking was %.2f s',toc)
intersectionstart = toc;
intersection = lineintersect(lines,thresholdintersect);
intersectiontime=toc - intersectionstart;
sprintf('Line intersection took  %.2f seconds',intersectiontime)

%% Identify potential building corners;
% Now that we have line intersections we can look at specific corners where
% walls intersect nearly at 90 degree angles (+/- a tolerance angle), as these would be good
% potential building corners. 
timestart = toc;
buildingcorners = buildingcornercandidate(lines,intersection,anglemin,anglemax);
sprintf('Building corner detection took %.2f s',toc-timestart)

%% Building recognition
% Using the 2EC data we will search for sets of 2EC segments that "line-up"
% Following function will finding sets of 2EC that intersect as a square
timestart = toc;
[g,points] = building(buildingcorners,M,N);
sprintf('Time for building recognition was %.2f s',toc-timestart)

%% Plot building corners and regular line intersections
figure(1)
imshow(I)
hold on
plot(buildingcorners(:,3),buildingcorners(:,4),'bx','MarkerSize',10)
plot(intersection(:,3),intersection(:,4),'g.','MarkerSize',10)
legend('2EC','line intersections')
str=sprintf('Corners %i and intersections %i. Threshold area %i, angles between %i and %i',length(buildingcorners),length(intersection),thresholdarea,anglemin,anglemax);
title(str)
saveas(gcf,strcat(folder,str,'.png'))

%% Plot building corners and lines
figure(2)
imshow(I)
hold on
plot(buildingcorners(:,3),buildingcorners(:,4),'bx','MarkerSize',10)
for i = 1:length(lines)
    plot([lines(i,3) lines(i,5)],[lines(i,4) lines(i,6)],'-')
end
str=sprintf('Corners %i and lines %i. Threshold area %i, angles %i to %i',length(buildingcorners),length(lines),thresholdarea,anglemin,anglemax);
title(str)
saveas(gcf,strcat(folder,str,'.png'))

%% Plot Connected lines on image
% figure(7)
% imshow(I)
% hold on
% lines2=lines;
% % lines2=linelinking(lines);
% intersection2 = lineintersect(lines2,thresholdintersect);
% buildingcorners2 = buildingcornercandidate(lines2,intersection2,anglemin,anglemax);
% plot(buildingcorners2(:,3),buildingcorners2(:,4),'bx','MarkerSize',10)
% plot(intersection2(:,3),intersection2(:,4),'g.','MarkerSize',10)
% for i = 1:length(lines2)
%     plot([lines2(i,3) lines2(i,5)],[lines2(i,4) lines2(i,6)],'-')
% end
% str=sprintf('Joined Lines, threshold area %i, angles between %i and %i, %i lines and %i 2EC segments',thresholdarea,anglemin,anglemax,length(lines2),length(buildingcorners2));
% title(str)
% saveas(gcf,strcat(folder,str,'.png'))


%% Plot buildings on original image
figure(3)
imshow(I)
hold on
for i = 1:length(g)
    plot(points{i}.x,points{i}.y,'-rs','LineWidth',5)
end
str=sprintf('Detected %i Buildings. %i intersections, %i 2EC',length(g),length(intersection),length(buildingcorners));
title(str)
saveas(gcf,strcat(folder,str,'.png'))

%% Wrap up
% Summarize information  
% Timing of script
runningtime = toc;
sprintf('Total run time was %.3f seconds',runningtime)
%% Log results to file
global fid
fid = fopen('log.txt','at');
fprintf(fid, '\n%s    Building recognition on %s. %i buildings. Run time %.2fs. Threshold area %i, angles between %i and %i. Detected %i line intersections, %i 2-Edge-1-Corner segments',char(datetime),filename,length(g),runningtime,thresholdarea,anglemin,anglemax,length(intersection),length(buildingcorners));
fclose('all'); 