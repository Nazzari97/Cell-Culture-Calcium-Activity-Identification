function[pixel_values] = display_regions(I,indices_list)

other_image = I;
for ii = 1:length(indices_list)
	
	region_indices = indices_list{ii};
	total = 0;
	region_size = length(region_indices);
	total = zeros(1,region_size);
	for jj=1:region_size
		index =region_indices(jj);
		intensity = I(index);
		total(jj) = intensity;
    end
	mean_intensity = mean(total);
	pixel_values(ii) = mean_intensity;

end