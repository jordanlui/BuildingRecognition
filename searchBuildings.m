function searchBuildings(I,angleDev,thresholdIntersect,thresholdArea,tlateral,tangle,toverlap,tunderlap,threshSlope,dMin,dMax)

% Building recognition in satellite images
% Jordan Lui
% Following code detects buildings in images by finding line edges that
% could represent building edges. Line edges that interset at a roughly 90
% degree angle could represent building corners. Sets of corners that align
% sufficiently well are estimated building locations.
% This work is learned from Saeedi 2014; Two-Edge-Corner Image Features for Registration of Geospatial Images with Large View Variations

% Usage: 
% result = searchBuildings(filePath,angleDev,thresholdIntersect,thresholdArea)

%% Import Images
% Import the image
% I = imread(filePath);
% Convert image to gray scale
I = (rgb2gray(I));
% Get image size
[M,N] = size(I);

%% Tuning and Running Parameters

% Check for variable inputs and set default values if they aren't present
if isempty(angleDev)                angleDev = 15; end      % Angle similarity threshold
if isempty(thresholdIntersect)      thresholdIntersect = 3; end % Intersection threshold
if isempty(thresholdArea)           thresholdArea = 50; end % Minimum area for a line support region
if isempty(tlateral)                tlateral = 10; end % Lateral distance threshold between lines
if isempty(tangle)                  tangle = 10; end % Slope angle delta threshold between lines
if isempty(toverlap)                toverlap = 0.6; end % Overlap percentage threshold
if isempty(tunderlap)               tunderlap = 0.6; end % Underlap percentage threshold
if isempty(threshSlope)             threshSlope = 0.01; end % Underlap percentage threshold
if isempty(dMin)                    dMin = 50; end % Underlap percentage threshold
if isempty(dMax)                    dMax = round( sqrt(M^2 + N^2) ); end % Underlap percentage threshold

if isempty(I)
    disp('No file specified')
    return
end

% Calculated run parameters
% Angle thresholdholds for building corner detection
angleMin = 90 - angleDev;
angleMax = 90 + angleDev;

% Static Runtime params
sigma = 0.8; % Sigma value for gaussian smoothing
filterOrder = 7; % Filter size for the Gaussian smoothing operation

% Degrees bins
degrees = [0 45 90 135 180 225 270 315 360];
degrees2 = degrees-22.5;

% Start at timer
tic; 

%% Image Prep and cleaning

% Gaussian smooth image before we proceed
I2 = imgaussfilt(I,sigma,'FilterSize',filterOrder);

%% Burns straight edge detection
% Burns algorithm for line detection calculates a slope field on all pixel
% values and identifies contiguous regions.

[orientation, Gmag, lsr1] = burnsAlgorithm(I2,degrees,thresholdArea);
[orientation2, Gmag2, lsr2] = burnsAlgorithm(I2,degrees2,thresholdArea);

%% Voting method
% Voting method will compare orientations 1 and 2 and determine the more
% dominant lines. This helps to remove the error associated with the
% arbitrarily set gradient orientation bins.
lsr = burnsEdgeVoting(lsr1,lsr2,M,N);

%% Compute line regions
% This function will take the line regions established from burns algorithm
% and analyze the series of points that define each line region. The
% function will determine the line of best fit using least squares fitting.
% The slope, y-intercept and endpoints of the line are output.
lines = computeLineRegion(lsr,M,N);

%% Line linking
% Line linking can be done to link lines that overlap, decreasing the number of overall lines
linkedLines = linkLines(lines,tlateral,tangle,toverlap,tunderlap);
%% Line Intersection detection
% Compute line intersections.
% Note that we should revise this section of code to extend line segments
% during intersection detection, to help increase rate of detection.

% sprintf('time for edge detection, voting, and line linking was %.2f s',toc)
% intersectionstart = toc;
intersection = computeLineIntersection(linkedLines,thresholdIntersect);
% intersectiontime=toc - intersectionstart;
% sprintf('Line intersection took  %.2f seconds',intersectiontime)

%% Identify potential building corners;
% Now that we have line intersections we can look at specific corners where
% walls intersect nearly at 90 degree angles (+/- a tolerance angle), as these would be good
% potential building corners. 
% Outputs a matrix that is formatted as [line1 line2 x y slope1 slope2 angle]
timestart = toc;
buildingcorners = computeCorners(linkedLines,intersection,angleMin,angleMax);
% sprintf('Building corner detection took %.2f s',toc-timestart)

%% Building recognition
% Using the 2EC data we will search for sets of 2EC segments that "line-up"
% Following function will finding sets of 2EC that intersect as a square
timestart = toc;
% [cornerIDs,corners] = identifyBuilding(buildingcorners,M,N,0.3,50,round(sqrt(M^2 + N^2)));
[cornerIDs,corners] = identifyBuilding(buildingcorners,M,N,threshSlope,dMin,dMax);
% sprintf('Time for building recognition was %.2f s',timestart - toc)

%% Wrap up
% Summarize information  
% Timing of script
runningtime = toc;
sprintf('Total run time was %.3f seconds',runningtime)

%% Plot building corners and regular line intersections
% figure(1)
% imshow(I)
% hold on
% plot(buildingcorners(:,3),buildingcorners(:,4),'bx','MarkerSize',10)
% plot(intersection(:,3),intersection(:,4),'g.','MarkerSize',10)
% legend('2EC','line intersections')
% str=sprintf('Corners %i and intersections %i. Threshold area %i, angles between %i and %i',length(buildingcorners),length(intersection),thresholdArea,angleMin,angleMax);
% title(str)
% saveas(gcf,'cornerLineIntersection.png')

%% Plot building corners and lines
% figure(2)
% imshow(I)
% hold on
% plot(buildingcorners(:,3),buildingcorners(:,4),'bx','MarkerSize',10)
% for i = 1:length(linkedLines)
%     plot([linkedLines(i,3) linkedLines(i,5)],[linkedLines(i,4) linkedLines(i,6)],'-')
% end
% str=sprintf('Corners %i and lines %i. Threshold area %i, angles %i to %i',length(buildingcorners),length(linkedLines),thresholdArea,angleMin,angleMax);
% title(str)
% saveas(gcf,'cornersLines.png')

%% Plot Connected lines on image
% figure(3)
% imshow(I)
% hold on
% lines2=lines;
% % lines2=linelinking(lines);
% intersection2 = lineintersect(lines2,thresholdIntersect);
% buildingcorners2 = buildingcornercandidate(lines2,intersection2,angleMin,angleMax);
% plot(buildingcorners2(:,3),buildingcorners2(:,4),'bx','MarkerSize',10)
% plot(intersection2(:,3),intersection2(:,4),'g.','MarkerSize',10)
% for i = 1:length(lines2)
%     plot([lines2(i,3) lines2(i,5)],[lines2(i,4) lines2(i,6)],'-')
% end
% str=sprintf('Joined Lines, threshold area %i, angles between %i and %i, %i lines and %i 2EC segments',thresholdArea,angleMin,angleMax,length(lines2),length(buildingcorners2));
% title(str)
% saveas(gcf,'connectedLines.png')


%% Plot buildings on original image
figure(4)
imshow(I)
hold on
for i = 1:length(cornerIDs)
    plot(corners{i}.x,corners{i}.y,'-rs','LineWidth',5)
end
str=sprintf('Detected %i Buildings. %i intersections, %i 2EC',length(cornerIDs),length(intersection),length(buildingcorners));
title(str)
disp(str)
saveas(gcf,'output.png')


%% Log results to file
% global fid
% fid = fopen('log.txt','at');
% fprintf(fid, '\n%s    Building recognition on %s. %i buildings. Run time %.2fs. Threshold area %i, angles between %i and %i. Detected %i line intersections, %i 2-Edge-1-Corner segments',char(datetime),filename,length(g),runningtime,thresholdarea,anglemin,anglemax,length(intersection),length(buildingcorners));
% fclose('all'); 

end