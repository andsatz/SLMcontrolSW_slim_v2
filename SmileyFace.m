% Code to burn a white circle into a black digital image.
% Write white pixels along the circumference of the circle into an image.
% Create image of size 1200 rows by 2200 columns.

imageSizeX = 600;
imageSizeY = 600;
[columnsInImage rowsInImage] = meshgrid(1:imageSizeX, 1:imageSizeY);

myImage = zeros(imageSizeX, imageSizeY, 'uint8');
% Let's specify the center at (x, y) = (1600, 600) and the radius = 350.
xCenter = imageSizeX/2;
yCenter = imageSizeY/2;
radius = 200;
% Circumference for a circle of radius 350 should be 2*pi*r = 2199 pixels.
% To ensure that we have no gaps in the circle 
% we need to make sure we have at least as many coordinates in vectors x and y 
% as there are around the circumference of the circle.
% Make it double that just to make extra sure there are no gaps in the circle
% by going all 360 degrees (0 - 2*pi) with 4398 points.
theta = linspace(0, 2*pi, round(4 * pi * radius)); % Define angles
% Get x and y vectors for each point along the circumference.
x = radius * cos(theta) + xCenter;
y = radius * sin(theta) + yCenter;
plot(x, y);
axis square;
grid on;

% Write those (x,y) into the image with gray level 255.
for k = 1 : length(x)
    row = round(y(k));
    col = round(x(k));
    myImage(row, col) = 255;
end
% Display the image.  It may appear as though there are gaps in the circle
% due to subsampling for display but examine the image in the variable inspector
% and you'll see there are no gaps/breaks in the circle.

% Plot crosshairs in the overlay at the center
% hold on;
% plot(xCenter, yCenter, 'r+', 'MarkerSize', 100);


% Define parameters of the arc.
xCenter = imageSizeX/2;
yCenter = imageSizeY/2-10; 
radius = 140;
% Define the angle theta as going from 30 to 150 degrees in 100 steps.
theta2 = linspace(30, 150, 100);
% Define x and y using "Degrees" version of sin and cos.
x = [];y = [];

x = radius * cosd(theta2) + xCenter; 
y = radius * sind(theta2) + yCenter; 
% Now plot the points.
plot(x, y, 'b-', 'LineWidth', 2); 
axis equal; 
grid on;
for k = 1 : length(x)
    row = round(y(k));
    col = round(x(k));
    myImage(row, col) = 255;
end
SE = strel('disk',8,8);
myImage = imdilate(myImage,SE);
imshow(myImage);
axis('on', 'image');

centerX = 220;
centerY = 220;
radius = 20;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
myImage(circlePixels) = 255;
imshow(myImage);

centerX = 380;
centerY = 220;
radius = 20;
circlePixels = (rowsInImage - centerY).^2 ...
    + (columnsInImage - centerX).^2 <= radius.^2;
myImage(circlePixels) = 255;
imshow(myImage);
targetPattern = double(myImage);
ITarget = targetPattern;