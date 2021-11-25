function [I_afterGeomTransformation] = adaptImageToSLMSize(I_afterGeomTransformation,I_original,SLM_size_px, grid)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
if size(I_afterGeomTransformation,1)>size(I_original,1) || size(I_afterGeomTransformation,2)>size(I_original,2)
    s = SLM_size_px(1)/2;
    dx = -s:s;
    RC0 = ceil(size(I_afterGeomTransformation)/2); % central position
    I_afterGeomTransformation = I_afterGeomTransformation(RC0(1)+dx, RC0(2)+dx, :); 
    if grid
        sz = size(I_afterGeomTransformation,3);
        I_afterGeomTransformation = imbinarize(imresize(I_afterGeomTransformation,SLM_size_px));
        I_afterGeomTransformation = bwmorph(I_afterGeomTransformation(:,:),'shrink',Inf);
        I_afterGeomTransformation = double(reshape(I_afterGeomTransformation, SLM_size_px(1), SLM_size_px(2),sz));
    else
        I_afterGeomTransformation = imresize(I_afterGeomTransformation,SLM_size_px);
    end
    
else
    sx = floor(size(I_afterGeomTransformation,1)/2)*2;
    sy = floor(size(I_afterGeomTransformation,2)/2)*2;
    I_afterGeomTransformation = imresize(I_afterGeomTransformation,[sx sy]);
    difx = (SLM_size_px(1)-sx)/2;
    dify = (SLM_size_px(2)-sy)/2;
    I_afterGeomTransformation = padarray(I_afterGeomTransformation,[difx dify],0);
    I_afterGeomTransformation = imresize(I_afterGeomTransformation,SLM_size_px);
    if grid
        I_afterGeomTransformation = imbinarize(I_afterGeomTransformation);
        sx = size(I_afterGeomTransformation,1);
        sy = size(I_afterGeomTransformation,2);
        sz = size(I_afterGeomTransformation,3);
        I_afterGeomTransformation = double(reshape(bwmorph(I_afterGeomTransformation(:,:),'shrink',Inf),sx,sy,sz));
    end
end

end

