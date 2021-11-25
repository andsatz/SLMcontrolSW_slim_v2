% filePath = 'E:\Acquisitions\prova.tif';
% movie = import_TiffStack(filePath);
% sliceViewer(movie, 'DisplayRangeInteraction', 'On');
clear all
clc

SLM_size_px = [600 600];
nPoints = 3;
step = 150;
zoomXY = 0.5;
rotation = 60;
mirroring = 0;
nPlanes = 3;
zDistance = 10;


%%

grid = 1;

I = zeros([SLM_size_px nPlanes]);
xp = [0:1:(nPoints-1)]*step;
yp = xp;
zp = [0:1:(nPlanes-1)]*zDistance;
shift = (xp(end)-xp(1))/2;
shiftX = SLM_size_px(1)/2;
shiftY = SLM_size_px(2)/2;
shiftZ = zDistance*(nPlanes-1);
xp = xp-shift+shiftX;
yp = yp-shift+shiftY;
zp = zp-shiftZ/2;
xyz = [];
for zz = 1:length(zp)
    for xx = 1:length(xp)
        for yy = 1:length(yp)
            xyz = [xyz; xp(xx) yp(yy) zz];
        end
    end
end

I(xyz(:,1),xyz(:,2),xyz(:,3))=1;

figure;
imshow(I(:,:,1));
axis equal;


%%

grid = 0;
% I = open("maskes.mat");
% I = I.maskes;
I = open("maskes_variousIntensities.mat");
I = I.maskes_variousIntensities;





%%


[tform, Itransformed] = applyGeometricalTransformation3D_slim(zoomXY,1,rotation,0,mirroring,I,grid);
% %Show Itransformed
% if length(size(Itransformed)) == 2
%     figure; imshow(Itransformed,[]);
% else 
%     figure; sliceViewer(Itransformed, 'DisplayRangeInteraction', 'On');
% end

%Adapt Itransformed to SLM size
if size(Itransformed,1)>size(I,1) || size(Itransformed,2)>size(I,2)
    s = SLM_size_px(1)/2;
    dx = -s:s;
    RC0 = ceil(size(Itransformed)/2); % central position
    Itransformed = Itransformed(RC0(1)+dx, RC0(2)+dx, :); 
    if grid
        sz = size(Itransformed,3);
        Itransformed = imbinarize(imresize(Itransformed,SLM_size_px));
        Itransformed = bwmorph(Itransformed(:,:),'shrink',Inf);
        Itransformed = double(reshape(Itransformed, SLM_size_px(1), SLM_size_px(2),sz));
    else
        Itransformed = imresize(Itransformed,SLM_size_px);
    end
    
else
    sx = floor(size(Itransformed,1)/2)*2;
    sy = floor(size(Itransformed,2)/2)*2;
    Itransformed = imresize(Itransformed,[sx sy]);
    difx = (SLM_size_px(1)-sx)/2;
    dify = (SLM_size_px(2)-sy)/2;
    Itransformed = padarray(Itransformed,[difx dify],0);
    Itransformed = imresize(Itransformed,SLM_size_px);
    if grid
        Itransformed = imbinarize(Itransformed);
        sx = size(Itransformed,1);
        sy = size(Itransformed,2);
        sz = size(Itransformed,3);
        Itransformed = double(reshape(bwmorph(Itransformed(:,:),'shrink',Inf),sx,sy,sz));
    end
end

%Show Itransformed
if length(size(Itransformed)) == 2
    figure; imagesc(Itransformed,[]);
else 
    figure; sliceViewer(Itransformed, 'DisplayRangeInteraction', 'On');
end
