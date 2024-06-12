function[I,other_image] = display_regions(I,indices_list)

other_image = I;
for ii = 1:length(indices_list)
	%current_region_pixels = pixel_list{ii};
	region_indices = indices_list{ii};
	for jj=1:length(region_indices)
		index =region_indices(jj);
		other_image(index) = 255;
		%{
		row = current_region_pixels(jj,1);
		col = current_region_pixels(jj,2);
		if col>max_col
			temp{count} = [ii jj];
			count = count + 1;
		end
		current_image(row,col,1) = 255;
		current_image(row,col,2) = 0;
		current_image(row,col,3) = 0;
		%}
	end
end
figure;
imshow(I);

figure;
imshow(other_image)
disp(size(I));
disp(size(other_image));