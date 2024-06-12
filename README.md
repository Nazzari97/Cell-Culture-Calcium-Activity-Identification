# Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing

Depending on usage of calcium activity and wounding, cell culture models can be analyzed using the get_marked_frames_modified_combined_with_main_driver_Bounds.m scripts
Ex Vivo tissue should be analyzed with GMFCWMDB_Pre_made_Int_and_Pos.m




Orginal Read Me for Use of get_marked_frames_modified.m and main_driver_Bounds.m

Scripts have been combined into get_marked_frames_modified_combined_with_main_driver_Bounds.m 
this version only requies the .avi file to be uplopaded once rather then twice across two seperate scripts

Need to have get_marked_frames_modified.m and main_driver_Bounds.m open within a 2016a MatLab.

Within get_marked_frames_modified.m change vid variable to name of avi file.
	avi file is of desired cell image/time series
	series is seperated into its channels
	only Ca signaling channel is required
	save file as a avi file - can be edit so it only reads certain bits of series
		edit video/series before placeed into code - causes jank
	name variable vid in line 2 as name of desired avi file
	make sure avi file is within Matlab pathway
	pick start frame ----- 1
	creat pos xcel graph with code
	
Within main_driver_bounds.m variable name on line 10 us = 'name of avi'
	run code
	frame_rate is one
	start_frame is one
	end_frame is total frams - 1
		i.e. total is 900 frames enter 899 frames
	name int excel file being created
	recall pos excel file from get_marked_frames_modified

Save the cell identified figure 
Save the hot spot/intensity graphys
other graphs/figures are uncessary for data analysis

END
