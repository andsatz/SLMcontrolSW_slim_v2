%%Parameters initialization

SLM_size_px = [800,600]; %[horizontal,vertical]
lambda_um = 0.92;
focalDist_um = 12.5e3;

% SLMsize_px = [512,512];
refractiveIndex = 1.33;
objNA = 0.8;
xyzp = [0,0,0;0,2,0;2,1,0];
weight = [1,1,1];
illuminationWavelength = 920e-9;
algo_type = 'G';
abl = 0;

%%Parameters checks
SLMControlGUI_parameters = struct(...
    ...% Meadowlark 512x512 is controlled through PCIe 16-bit
    ...'SLM_control_type','PCIe_16bit',... 
    ...'SLM_LUTpath','C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\LUT Files',... % should be a valid path, included in MATLAB path
    ...'SLM_globalLUTfilename','slm4073_at1064_P8.lut',...% should be a valid filename
    ...'SLM_SDKpath','C:\Program Files\Meadowlark Optics\Blink OverDrive Plus\SDK',...% should be a valid path, included in MATLAB path
    ...'SLM_size',[512 512],...
    ...'SLM_layout','square',...
    ...% Overdrive parameters (only for Meadowlark)
    ...'SLM_overdriveActive',0,...
    ...'SLM_regionalLUTfilename','slm4073_regional.txt',...% should be a valid filename
    ...'SLM_maxTransients',20,...% max 20
    ...
    ...% Hamamatsu X10468-07 is controlled through DVI
    'SLM_control_type','DVI',...
    'SLM_LUTpath','C:\Users\Public\Valentina\SLMControlGUI_v2.9_room1_20190131\SLMControlGUI\Hamamatsu',... % should be a valid path, included in MATLAB path
    'SLM_globalLUTfilename','lut.txt',...% should be a valid filename
    'SLM_size',[800 600]);

