function [tform, varargout] = applyGeometricalTransformation3D_slim(zoomXY, zoomZ, rotationAngle, offsetZ, mirroring, inputMatrix, grid)
% Apply a 2D affine geometrical transformation to an image or 
% apply a 3D affine geometrical transformation to a stack of images
%
% varargin{1} = inputMatrix. containing data to be transformed
% -----------

if nargin < 6
    warndlg('The number of input variables must be 6.');
    tform = [];
    return
end
S = [zoomXY   0         0         0; ...
    0         zoomXY    0         0; ...
    0         0         zoomZ     0;
    0         0         0         1];
% Rotate
R = [cos(deg2rad(rotationAngle))    sin(deg2rad(rotationAngle))  0      0;...
     -sin(deg2rad(rotationAngle))   cos(deg2rad(rotationAngle))  0      0;...
    0                               0                            1      0;
    0                               0                            0      1];
% Translate
T = [1  0   0       0;...
     0  1   0       0;...
     0  0   1       0;...
     0  0   offsetZ 1];
% Mirror (reflect around x-axis)
if mirroring    
    M = [1  0   0   0;
         0  -1  0   0;
         0  0   1   0;
         0  0   0   1];
else
    M = eye(4);
end

A = ((S*R)*T)*M;

if length(size(inputMatrix)) == 2
    tform = affine2d(A(1:3,1:3));
else 
    tform = affine3d(A);
end

% If it is a grid of points, it will be easily corrupted by the geometric transform 
if grid
    se = strel('disk',1,4);
    inputMatrix = imdilate(inputMatrix,se);
end

Itransformed = imwarp(inputMatrix,tform, 'interp', 'cubic');

% Restore the grid of points in term of qualiity
if grid
    Itransformed = imbinarize(Itransformed);
    sx = size(Itransformed,1);
    sy = size(Itransformed,2);
    sz = size(Itransformed,3);
    Itransformed = double(reshape(bwmorph(Itransformed(:,:),'shrink',Inf),sx,sy,sz));
end

varargout{1} = Itransformed;