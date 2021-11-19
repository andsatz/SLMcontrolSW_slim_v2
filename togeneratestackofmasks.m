Iorig = imread('eight.tif');

if size(Iorig,1) ~= SLM_size_px(2) || size(Iorig,2) ~= SLM_size_px(1)
    I = imresize(Iorig,[SLM_size_px(2) SLM_size_px(1)],'bilinear');
else
    I = Iorig;
end
roiwindow = CROIEditor(I);

% wait for roi to be assigned
waitfor(roiwindow,'roi');
if ~isvalid(roiwindow)
    disp('you closed the window without applying a ROI, exiting...');
return
end
%%
[mask, labels, n] = roiwindow.getROIData;

%%
maskes = mask;
maskes = cat(3, maskes,mask);
%%
figure; sliceViewer(maskes, 'DisplayRangeInteraction', 'On');