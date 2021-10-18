function [phaseMask] = lensPhaseModulation(SLMsize_Px, calibrationParameter, lambda_um, focalDist_um)
    [Xh, Yh] = meshgrid((1:SLMsize_Px(1))-SLMsize_Px(1)/2, (1:SLMsize_Px(2))-SLMsize_Px(2)/2);
    phaseMask = calibrationParameter * 6000 * (-pi/(lambda_um*focalDist_um^2).*(Xh.^2+Yh.^2)); %6000 parametro empirico
    figure;
    imagesc(phaseMask)   
    phaseMask = mod(phaseMask,2*pi); %varies in [0, 2pi]
    figure;
    imagesc(phaseMask);
end

