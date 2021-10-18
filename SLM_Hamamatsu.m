classdef SLM_Hamamatsu < handle
    properties
        actualPhase     % contains the last image sent
        active
        imageWritten
    end
    properties(Access = private)
        lambda
        slm_resolution
        global_lut_file
        bit_depth
        lut_path          % path containing LUTs
        pixelRange
    end
    
    methods
        %% Constructor
        function obj = SLM_Hamamatsu(varargin)
            % Parameter initialization
            if nargin > 0 && isstruct(varargin{1}) % at least one parameter is passed and it is a structure
                parameters = varargin{1};
                if isfield(parameters, 'bit_depth')
                    obj.bit_depth = parameters.bit_depth;
                else
                    obj.bit_depth = 8;
                end
                if isfield(parameters, 'SLM_size')
                    obj.slm_resolution = parameters.SLM_size;
                else
                    obj.slm_resolution = [800 600];
                end
                if isfield(parameters, 'SLM_LUTpath')
                    obj.lut_path = parameters.SLM_LUTpath;
                else
                    obj.lut_path = 'C:\Users\Public\Valentina\SLMControlGUI_v2.9_room1_20190131\SLMControlGUI\Hamamatsu';
                end
                if isfield(parameters, 'SLM_globalLUTfilename')
                    obj.global_lut_file = [obj.lut_path,filesep,parameters.SLM_globalLUTfilename];
                else
                    obj.global_lut_file = [obj.lut_path,filesep,'lut.txt'];
                end
                if isfield(parameters, 'lambda')
                    obj.lambda = parameters.lambda;
                else
                    obj.lambda = 1064;
                end
            else % no input parameter is passed
                disp('Default parameters set.');
                obj.bit_depth = 8;
                obj.slm_resolution = [800 600];
                obj.lut_path = 'C:\Users\Public\Valentina\SLMControlGUI_v2.9_room1_20190131\SLMControlGUI\Hamamatsu';
                obj.global_lut_file = [obj.lut_path,filesep,'lut.txt']; 
                obj.lambda = 1064;
            end
            lutTable = importdata(obj.global_lut_file);
%             obj.pixelRange = lutTable(lutTable(:,1)==obj.lambda*1e+3,2);
            obj.pixelRange = lutTable(lutTable(:,1)==obj.lambda,2);
            zeroPhase = zeros(obj.slm_resolution(2),obj.slm_resolution(1),'uint8'); % all zeros
            try
                fullscreen(zeroPhase,2)                
            catch ME
                obj.active = 0;
                obj.actualPhase = [];
                obj.imageWritten = 0;
                errordlg(ME.message,ME.identifier);
                return
            end
            obj.active = 1;
            obj.imageWritten = 1;
            obj.actualPhase = zeros(obj.slm_resolution(2),obj.slm_resolution(1),'uint8');
        end
        
        function obj = sendMap(obj, phaseMask)
            if min(min(phaseMask))<0 || max(max(phaseMask))>1
                errordlg('Input phase mask should be constrained between 0 and 1');
                return
            end
            if (obj.active==1)
                if obj.bit_depth == 8
                    phaseMaskScaled = uint8(round(phaseMask.*obj.pixelRange));
                elseif obj.bit_depth == 16
                    phaseMaskScaled = uint16(round(phaseMask.*obj.pixelRange));
                end
                try
                    fullscreen(phaseMaskScaled,2);
                    flag = 1;
                catch ME
                    flag = 0;
                    errordlg(ME.message,ME.identifier);
                end
                if flag
                    obj.actualPhase = phaseMask;
                    obj.imageWritten = 1;
                    disp('Image was successfully written to SLM.');
                else
                    obj.actualPhase = [];
                    obj.imageWritten = 0;
                    disp('An error occurred: image was NOT successfully written to SLM.');
                end
            else
                obj.actualPhase = [];
                obj.imageWritten = 0;
                disp('Image was NOT sent to SLM because the associated device was not successfully activated.');
                return
            end
        end
        
        function delete(obj)
            closescreen();
        end
        
    end
    
end