# BuildingRecognition
Automatic Recognition of Buildings in Satellite Imagery
This project automatically detects buildings in satellite images. It uses the Burns Edge Detection algorithm to detect edges of buildings.

## Usage
``result = searchBuildings(I,angleDev,thresholdIntersect,thresholdArea,tlateral,tangle,toverlap,tunderlap,threshSlope,dMin,dMax)``

Inputs params are:

angleDev              Angle deviation between lines to form corners

thresholdIntersect    Threshold on line intersection

thresholdArea         Minimum area for a line support region

tlateral              Max lateral distance between lines

tangle                Max angle between lines

toverlap              Max overlap fraction

tunderlap             Max underlap fraction

threshSlope           Threshold slope between corner's vectors

dMin                  Min Distance

dMax                  Max distance


## Example images of algorithm

Algorithm uses Burns algorithm to improve edge detection in a rasterized image. Example of initial corner and edge detection is shown below. 

![alt tag](output/1_edges_corners.png?raw=true "Image Title")

Algorithm eliminates detects all small line segments, groups similar line segments into larger lines. Intsersections of lines at specified angles consistute potential building corners.

![alt tag](output/2_line_reduction.png?raw=true "Image Title")

Algorithm reviews the lines and corners and eliminates redundant edges

![alt tag](output/3_building_pred.png?raw=true "Image Title")

A building shape is found. Further work needed to improve the algorihm's detection rate.

## Description of Algorithm Method

### Image pre filtering
Image is pre-processed with Gaussian smoothing to remove some image noise.
### Burns Edge Detection
Burns edge detection is run to look for gradients in image that indicate edges. This algorithm sorts the lines into â€œgradient binsâ€? based on the angle of the line. The algorithm then identifies the most dominant lines based on size
### Compute Line regions
Line regions are constructed into lines based on a least squares fit of a line of all points in that region
### Link lines that are similar or close
Lines are then compared and linked if they are sufficiently close in lateral distance, angle, overlap, and underlap
### Line intersection detection
Resulting line segments are then compared to extract all possible line intersections. Note that a tolerance is required here since some line segments do not completely overlap at the building corner point.
### Identify building corners
From these line intersections, building corners are determined as those which intersect at an angle close to 90 degrees. Note this 90 degrees tolerance can change drastically based on the acquisition angle of the imaging satellite. The result of this stage is a series of x,y points where a building corner has been identified, as well as information on the two walls that intersect it.
### Building Hypothesis
Algorithm looks at all possible building corners and identifies sets which close a loop.
