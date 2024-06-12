function[I,other_list] = get_pixel_indices(imFrame)

im = rgb2gray(imFrame);

%%
I = adapthisteq(im);

%%
Ib = imbinarize(I,'adaptive');
%%
%D = -bwdist(~Ib);
%D(~Ib) = -Inf;
%IbWS = watershed(D);
%IbWS = watershed(Ib);
%%
BWdfill = imfill(Ib, 'holes');

%% watershed edit
%{
D = -bwdist(~BWdfill);
D(~BWdfill) = -Inf;
IbWS = watershed(D);

Ib2 = imbinarize(IbWS,'adaptive');

%s = regionprops(BWdfill,I,'Area','PixelList','PixelIdxList');

s = regionprops(Ib2,I,'Area','PixelList','PixelIdxList');
%^ is for use with watershed - it might work with this configuration based
%on previous runs with code for 5ul Dia runs

%}

%%

s = regionprops(Ib,I,'Area','PixelList','PixelIdxList');

%%

count = 0;
for i=1:size(s,1)
    if(s(i).Area > 100)
    	count = count + 1;
    	%disp(s(i).PixelList)
    	%disp(size(s(i).PixelList))
    	other_list{count} = s(i).PixelIdxList;
    	%pixel_list{count} = s(i).PixelList;

    end
end
