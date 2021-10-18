function [tform, varargout] = applyGeometricalTransformation3D(zoomXY, zoomZ, rotationAngle, offsetZ, mirroring, varargin)
% Apply a 3D affine geometrical transformation to either point coordinates
% or an image
% -----------
% Determine whether the input is [Nx3] --> point coordinates, or [NxM] -->
% image/ROI mask
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
inputMatrix = varargin{1};
umPerPixel = varargin{2};
if size(inputMatrix,2) == 3 % the inputMatrix has only 3 columns --> point coordinates in um (transformation parameters are the same on the 2 axes)
    % Apply transformation
    tform = affine3d(A);
    [xpPrime, ypPrime, zpPrime] = transformPointsForward(tform, inputMatrix(:,1), inputMatrix(:,2), inputMatrix(:,3));  
    varargout{1} = [xpPrime, ypPrime, zpPrime];
elseif size(inputMatrix,2) > 3 % the inputMatrix has more than 3 columns --> image (we have to distinguish whether the phase mask is square or rectangular)
    [rowIdx, colIdx, intensities] = find(inputMatrix); % only 2D points
    
    tform = affine3d(A);
%     if size(inputMatrix,1) ~= size(inputMatrix,2)
%         [xyUm_effective] = convert2DPixelsToUm([rowIdx, colIdx],umPerPixel,flip(size(inputMatrix)));
%         % transform point coordinates
%         [xTrans, yTrans, ~] = transformPointsForward(tform, xyUm_effective(:,1), -xyUm_effective(:,2), zeros(length(rowIdx),1));
%         [rowColPixel, ~] = convert2DUmToPixel([xTrans, -yTrans],umPerPixel,flip(size(inputMatrix)));
%     else
        [xTrans, yTrans, ~] = transformPointsForward(tform, colIdx-size(inputMatrix,2)/2, size(inputMatrix,1)/2-rowIdx, zeros(length(rowIdx),1));
        rowColPixel(:,1) = round(size(inputMatrix,1)/2-yTrans);
        rowColPixel(:,2) = round(xTrans+size(inputMatrix,2)/2);
%     end
    Itransformed = zeros(size(inputMatrix));
    constrainedIdx = (rowColPixel(:,1)>0 & rowColPixel(:,1)<=size(inputMatrix,1)) & (rowColPixel(:,2)>0 & rowColPixel(:,2)<=size(inputMatrix,2));
    rowColPixel_within(:,1) = rowColPixel(constrainedIdx,1);
    rowColPixel_within(:,2) = rowColPixel(constrainedIdx,2);
    Itransformed(sub2ind(size(inputMatrix), rowColPixel_within(:,1), rowColPixel_within(:,2))) = intensities(constrainedIdx);

    varargout{1} = Itransformed;
end