%%
function[sCentroidX, sCentroidY, sPixelValsMean, sPixelValsStd, sArea] = compute_metrics(imFrame)

%%

im = rgb2gray(imFrame);

%%
I = adapthisteq(im);

%%
Ib = imbinarize(I,'adaptive');

%%
BWdfill = imfill(Ib, 'holes');

%%
s = regionprops(BWdfill,I,'Area','Centroid','PixelValues');

%%
count = 0;
for i=1:size(s,1)
    if(s(i).Area > 100)
        count = count + 1;
        sArea(count) = s(i).Area;
        sCentroidX(count) = s(i).Centroid(1);
        sCentroidY(count) = s(i).Centroid(2);
        sPixelValsMean(count) = mean(s(i).PixelValues);
        sPixelValsStd(count) = std(double(s(i).PixelValues));

    end
end

%% These are the numbers printing the intensities (sPixelValsmean)
%{
text_str = cell(count,1);
for ii=1:count
   text_str{ii} = num2str(ii,'%d');
   %text_str{ii} = [num2str(sPixelValsMean(ii),'%0.1f')];
   position(ii,1) = sCentroidX(ii);
   position(ii,2) = sCentroidY(ii);

end

RGB = insertText(I,position,text_str);
figure;

imshow(RGB);
%}
%RGB = insertMarker(I,position,'color','red','size',10);
%figure;
%imshow(RGB);
