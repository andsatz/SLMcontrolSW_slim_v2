clear all 
clc
SLM_attached = 0;
verbose = 0;

%% Parameters initialization

ParametersInitialization

if SLM_attached
    slm = SLM_Hamamatsu(SLMControlGUI_parameters);
end

if size(SLM_size_px,1)~=size(SLM_size_px,2)
    blackBand = zeros(min(SLM_size_px), (max(SLM_size_px)-min(SLM_size_px))/2);
    SLM_size_px = [min(SLM_size_px) min(SLM_size_px)];
end

%% Button: Flat Phase. Calibration for 0th order defocusing
% Calibration with Vale's SW
% 10 - 4.4
% 14 - 6.2
% 15 - 6.5
% 16 - 7
% 17 - 7.6
% 20 - 9

inputCalibrationSlider = 6.3;


flatPhase = lensPhaseModulation(SLM_size_px, inputCalibrationSlider, lambda_um, focalDist_um);
flatPhase = [blackBand, flatPhase, blackBand];

flatPhase_toBeSent = mod (flatPhase, 2*pi)./(2*pi);
imshow(flatPhase,[]);
if SLM_attached
    slm.sendMap(flatPhase_toBeSent);
end

%% Calibration of magnification and angle. Built a grid of points

nPoints = 3;
step = 150;
zoomXY = 0.51;
rotation = 107;
mirroring = 0;

I = zeros(SLM_size_px);
xp = [0:1:(nPoints-1)]*step;
yp = xp;
shift = (xp(end)-xp(1))/2;
shiftX = SLM_size_px(1)/2;
shiftY = SLM_size_px(2)/2;
xp = xp-shift+shiftX;
yp = yp-shift+shiftY;
xy = [];
for xx = 1:length(xp)
    for yy = 1:length(yp)
        xy = [xy; xp(xx) yp(yy)];
    end
end
linearInd = sub2ind(size(I), xy(:,1), xy (:,2));
I(linearInd) = 1;
[tform, Itransformed] = applyGeometricalTransformation3D(zoomXY,1,rotation,0,mirroring,I,1,1);

targetPattern = Itransformed;
blackBand = zeros(min(SLM_size_px), (max(SLM_size_px)-min(SLM_size_px))/2);
targetPattern = [blackBand, targetPattern, blackBand];

ITarget = targetPattern;


%% Load Image and draw target pattern on an image

select_image = 1;

if select_image

    try
    %     cd(handles.SLMControlGUI_parameters.workingDirectory)
        [filename, pathname, ~] = uigetfile({'*.tif','Image files (*.tif)';'*.*','All Files (*.*)'}, 'Pick a file'); %'MultiSelect', 'on');
    catch ME
        errordlg(ME.message,ME.identifier)
        return
    end
    if isnumeric(filename) && strcmp(num2str(filename),'0')
        return
    end
    % Check whether the image is single-channel
    Iorig = imread(fullfile(pathname,filename));
    if size(Iorig,3) > 1
        warndlg('Only single-channel images can be loaded. For two-channel images, please select the correct command from the Load menu.');
        return
    end
    origImageSize = size(Iorig);
    if origImageSize(1) ~= origImageSize(2)
        errordlg('Only square images can be loaded!','Please select a square image or crop it before loading');
    end
    
else
    Iorig = imread('eight.tif');

end

    
if size(Iorig,1) ~= SLM_size_px(2) || size(Iorig,1) ~= SLM_size_px(2)
    I = imresize(Iorig,[min(SLM_size_px) min(SLM_size_px)],'bilinear');
else
    I = Iorig;
end

roiwindow = CROIEditor(I);
% imcontrast

% wait for roi to be assigned
waitfor(roiwindow,'roi');
if ~isvalid(roiwindow)
    disp('you closed the window without applying a ROI, exiting...');
return
end

%% Store in memory the drawn pattern 

% targetPattern = double(imresize(mask,[min(SLM_size_px) min(SLM_size_px)]));
% ITarget = targetPattern;
[mask, labels, n] = roiwindow.getROIData;

figure;imshow(mask,[]);
[tform, Itransformed] = applyGeometricalTransformation3D(zoomXY,1,rotation,0,mirroring,mask,1,1);
Itransformed = imfill(Itransformed, 'holes');
targetPattern = double(imresize(Itransformed,[min(SLM_size_px) min(SLM_size_px)]));
blackBand = zeros(min(SLM_size_px), (max(SLM_size_px)-min(SLM_size_px))/2);
targetPattern = [blackBand, targetPattern, blackBand];

ITarget = targetPattern;
figure;imshow(ITarget,[]);


%% compute GS

%Input beam amplitude
sigma = 200;
% size = min(SLM_size_px);
fontSize = 8;
% singleCircleImage = fspecial('gaussian', size, sigma); 
singleCircleImage = fspecial('gaussian', flip(SLM_size_px), sigma); 
singleCircleImage=singleCircleImage/max(max(singleCircleImage)); % Normalize to 0-1. 
initial_amplitude = singleCircleImage;

%Input beam phase
% initial_phase = (rand(size,size)*(2*pi))-pi;
initial_phase = (rand(flip(SLM_size_px))*(2*pi))-pi;

initial_field = initial_amplitude.*exp(1i*initial_phase);
FT_field = fftshift(fft2(fftshift(initial_field)));

if verbose
    figure;
    subplot(2,3,2); 
    imshow(initial_amplitude, []); 
    title('input amplitude', 'FontSize', fontSize);
    axis off;
    subplot(2,3,3); 
    imshow(initial_phase, []); 
    title('SLM phase', 'FontSize', fontSize);
    axis off;
    subplot(2,3,5); 
    imshow(abs(FT_field).^2,[]);
    axis on;
end



ee = 1;
error = [];
error1 = [];
uniformity = [];
efficiency = [];
maschera = find(ITarget);
% Iterations = 10;
stopError = 1e-3;
numIter = 0;
h = waitbar(0,'Please wait...');
maxNumIter = 200;
    
% for ii = 1:Iterations

while ee > stopError
    ee
    waitbar(numIter / (maxNumIter-1))
% fprintf('Iteration: %d\n', ii) 

FT_phase = angle(FT_field);
FT_amplitude = abs(FT_field);
Iachieved = FT_amplitude.^2;
FT_field_updated = ITarget.*exp(1i*FT_phase);

IFT_field = fftshift(ifft2(fftshift(FT_field_updated)));

IFT_phase = angle(IFT_field);
IFT_amplitude = abs(IFT_field);
IFT_field_updated = initial_amplitude.*exp(1i*IFT_phase);

FT_field = fftshift(fft2(fftshift(IFT_field_updated)));



ee = sqrt( immse( Iachieved(:)./max(Iachieved(:)), ITarget(:)./max(ITarget(:)) ) );
% Python implementation: errors' standard deviation
ee1 = std(Iachieved(:)./max(Iachieved(:))-ITarget(:)./max(ITarget(:)));
error = [error; ee];
error1 = [error1; ee1];
uniformity = [uniformity; 1-((max(Iachieved(maschera))-min(Iachieved(maschera)))/(max(Iachieved(maschera))+min(Iachieved(maschera))))];
efficiency = [efficiency; sum(Iachieved(maschera))/sum(Iachieved(:))];

numIter = numIter+1;
if numIter > maxNumIter-1
        break;
    end

if verbose
    subplot(2,3,5); 
    axis off;
    imshow(abs(FT_field).^2, []);
    title('reconstructed amplitude', 'FontSize', fontSize);
    drawnow;

    subplot(2,3,3); 
    axis off;
    imshow(wrapTo2Pi(angle(IFT_field)), []);
    title('phase to be used', 'FontSize', fontSize);
    drawnow;

    subplot(2,3,6); 
    axis off;
    imshow(wrapTo2Pi(angle(FT_field)), []);
    title('reconstructed phase', 'FontSize', fontSize);
    drawnow;

    subplot(2,3,1); 
    imagesc(mat2rgbCplx(initial_amplitude.*exp(1i*wrapTo2Pi(angle(IFT_field))),max(initial_amplitude),1));
    pbaspect([max(SLM_size_px) min(SLM_size_px) 1]);
    axis off;
    title('field after SLM', 'FontSize', fontSize);
    drawnow;

    subplot(2,3,4); 
    imagesc(mat2rgbCplx((abs(FT_field).^2).*exp(1i*wrapTo2Pi(angle(FT_field))),max((abs(FT_field).^2)),1));
    pbaspect([max(SLM_size_px) min(SLM_size_px) 1]);
    title('field at the sample', 'FontSize', fontSize);
    axis off;
    drawnow;
end


end
close(h)

%% Send phase to SLM
phase = [zeros(length(IFT_field), 100), angle(IFT_field), zeros(length(IFT_field), 100)];
phase = mod (phase+flatPhase, 2*pi)./(2*pi);

if SLM_attached
    slm.sendMap(phase);
end
figure;imshow(phase, []);