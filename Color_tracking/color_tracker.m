% tabula rasa:
clc; clear all;close all;

%% This is to solve Prelab Q1: %%

% Read the image given to you (use function imread())
img=imread('image1.jpg');
% plot the original image (use imshow())
figure('Name','Original Image');
imshow(img)
% convert your image into hsv color space (use function rgb2hsv())
img_hsv=rgb2hsv(img);

img_h=img_hsv(:,:,1);
img_s=img_hsv(:,:,2);
img_v=img_hsv(:,:,3);
% plot the grayscale images of hue, saturation and value of your image seperately (use imshow() again)
figure('Name','HSV');
imshow(img_hsv)
figure('Name','Hue');
imshow(img_h)
figure('Name','Saturation');
imshow(img_s)
figure('Name','Value');
imshow(img_v)

% use the hue image you just plotted to find the hue lower and upper bounds for each color
%%RED
hThresholdLowR = -340/360;
hThresholdHighR = 19/360;
sThresholdLowR = 0.7;
sThresholdHighR = 1;
vThresholdLowR = 0.7;    
vThresholdHighR= 1;   

%%GREEN 0.3300;hThresholdHighG = 0.4250;
hThresholdLowG = 105/360;
hThresholdHighG = 135/360;
sThresholdLowG = 0.7;
sThresholdHighG = 1;
vThresholdLowG = 0.7;    
vThresholdHighG = 1;

%%BLUE
hThresholdLowB = 225/360;
hThresholdHighB = 250/360;
sThresholdLowB = 0.7;
sThresholdHighB = 1;
vThresholdLowB = 0.7;    
vThresholdHighB = 1; 
% use the saturation image you just plotted and find one single lower and upper bound for all your colors

% use these tresholds to create a mask for each color, plot your three masks seperately (for each color you should have a black-white image showing only the blob of that color)
%%RED MASK
 maskR = (img_s >= sThresholdLowR) & (img_s <= sThresholdHighR);
 maskR = maskR & (img_v >= vThresholdLowR) & (img_v <= vThresholdHighR); 
 maskR = maskR & (img_h <= hThresholdHighR);
 maskR = maskR | ((img_h >= -hThresholdLowR) & (img_h <= 1));
 
figure('Name','RED MASK');
imshow(maskR)
maskRP = bwareaopen(maskR, 10000);
figure('Name','Processed red mask');
imshow(maskRP);
 %%GREEN MASK
 maskG = (img_s >= sThresholdLowG) & (img_s <= sThresholdHighG);
 maskG = maskG & (img_v >= vThresholdLowG) & (img_v <= vThresholdHighG);
 maskG = maskG & (img_h>= hThresholdLowG) & (img_h<= hThresholdHighG);
 figure('Name','GREEN MASK');
 imshow(maskG)
 maskGP = bwareaopen(maskG, 10000);
figure('Name','Processed green mask');
imshow(maskGP);
 %%BLUE MASK
 maskB = (img_s >= sThresholdLowB) & (img_s <= sThresholdHighB);
 maskB = maskB & (img_v >= vThresholdLowB) & (img_v <= vThresholdHighB);
 maskB = maskB & (img_h>= hThresholdLowB) & (img_h<= hThresholdHighB);
 figure('Name','BLUE MASK');
 imshow(maskB)
 
maskBP = bwareaopen(maskB, 10000);
figure('Name','Processed blue mask');
imshow(maskBP);

% find the centroid of the three colors using their respective masks ( use function regionprops();  be aware that it can return more than one centroid  )
centroidRed = regionprops(maskRP, 'centroid');
centroidRed_ = cat(1, centroidRed.Centroid);
%centroidR = mean(centroidRed_);
%%
centroidGreen = regionprops(maskGP, 'centroid');
centroidGreen_ = cat(1, centroidGreen.Centroid);
%centroidG = mean(centroidGreen_);
%%
centroidBlue = regionprops(maskBP, 'centroid');
centroidBlue_ = cat(1, centroidBlue.Centroid);
%centroidB = mean(centroidBlue_);


% plot the original image with the center of the centroid (use function insertMarker())

figure
marker_position = [centroidRed_; centroidGreen_; centroidBlue_];
color = {'black'};
img = insertMarker(img,marker_position, 'color', color, 'size', 15);
imshow(img)
title('Tracked locations');


