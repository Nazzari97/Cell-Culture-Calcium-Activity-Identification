# Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing

Usage Requies 2016a MatLab for HeatMap generation - rest of code can be updated to work with newer versions of MatLab

Depending on usage of calcium activity and wounding, cell culture models can be analyzed using the get_marked_frames_modified_combined_with_main_driver_Bounds.m scripts
Ex Vivo tissue should be analyzed with GMFCWMDB_Pre_made_Int_and_Pos.m using prior created excel files of the centroid data and intensity over time
	our lab generated both data sets using the ROI tools in ImageJ and the Measure and Multimeasure tools within the ROI manager

When using get_marked_frames_modified_combined_with_main_driver_Bounds.m
	Using a photo editor software to convert image set/video file into a .avi
 	Name the Folder var with the files folder
  	Name the name var with the files name with the .avi removed 
   	Run code

When using the GMFCWMDB_Pre_made_Int_and_Pos.m
	User is importing excel files generated from data directly instead of allowing the script to identify cells and pull intensity data itself
 	This is done during instances of poor identification of cells from the Code such as with tissue and ex vivo analysis
  	The user has to create the intensity file and centroid file themselves, 
   		This lab has used ImageJ/FUJI for this processes taking advantage of the Region of Intrest (ROI) tool 
     		and the measure and multimeasure tools within the ROI manager
       		Position data was created with centroid data
	 	Intesity data was created with mean gray value
   			Intensity data has to be generated only using the Calcium indicator Channel
       		This creates data sets that can be generated and copied into microsoft excel
	 		make sure to remove the cell count variables in the first collum in the centroid data
    			and make sure to remove the time point data from the intensity data generated in multimeasure
       Name the Folder var with the files folder
       Name the position data var using a string witht the file type extension removed - posfilename
       Name the intensity data var using a string witht the file type extension removed - intfilename
       the var 'name' is used for the creation of data sets via the code to create a basic for these file name
       Run code

Explination for some var that user might want to change

Skp - is the amount of frames checked for nearby signaling activty/propagation of calciunm events - it is set to four frames by default

percent - the percentage of the Max Mean intensity required for an intensity change to reach before it is classified as a detected event
	The defualt for cell culture is 40% (.4)
 	The fefualt for ex vivo/tissue is 30% (.3)

NxtCeldis - the max pixel distance required between centroids for cells to be classified as nearby
	ex if distance between two centorids is beyond this value - they are not nearby each other 
 		and similar temporal relation between cellular activity cannot be due to propagation
   	If those same two centroids where within the distance/pixel value they are nearby each other
    		and the similar temporal cellular activity could be due to propagation of signal

Values returned by Pkcorr

 	mnsig - mean signaing of all identified cell
	totPK - total signaling
	NBPK - total nearby signaling --- cell to cell communication?
	prbNB - probability a signal was nearby signal
	rate - rate of signaling by identified cells

 What is Hierarchical_Clustering.m

  	This code anlyizes the total active time of identifed cells and determines if they have low or high activity and everything in between
   	This code returns a dendrogram and a Histogram graphs to display these differences
    	The code also generated binerized intensity files generated from the intensity files created or inputed into the code

What is BasalandWingNBPKAnalysis.m

	this code is used to analyze the propagation of calcium signaling events between different layers of tissue epithelium/different videos taken from the same tissue at different z layers
 	this code works in a similiar manner to GMFCWMDB_Pre_made_Int_and_Pos and Pkorr, it required premade centorid and intensity excel files
  	it then uses that centroid data and intensity data to determine if cells had detetected events and propaged events within their layers
   	then it compared those two data sets with the centorid data between layers/files to determine if there was propaged events between the two different data sets
    	this used altered NxtCeldis values becuase of the different sizes of cells used by this lab, Wing cells are larger and have a large NxtCeldis value, 
     	while basal cells are smaller then have a smaller NxtCeldis then defualt values described above

      	var that have to be inputed are:	
      		folder = '';
		wingposfilename = '';
 		wingintfilename = '';
  		basalposfilename = '';
		basalintfilename = '';
 	
  	outputs are as stated:
   		wingNcell	Number of wing cells
		totwingPK	total wing cell cellular signaling
		wingNBPK	Number of wing cell total nearby activity - signaling propagation within data set

		basalNcell	number of basal cells
  		totbasalPK	number of basal cell signaling
   		basalNBPK	number of basal cell signal propagation 

       		WtBNBPK		Wing to Basal NBPK
	 	BtWNBPK		Basal to Wing NBPK
   		TotalNBPK	Total cross layer/data set NBPK
    		



Orginal Read Me for Use of get_marked_frames_modified.m and main_driver_Bounds.m

		Scripts have been combined into get_marked_frames_modified_combined_with_main_driver_Bounds.m 
		this version only requies the .avi file to be uplopaded once rather then twice across two seperate scripts
		
		Need to have get_marked_frames_modified.m and main_driver_Bounds.m open within a 2016a MatLab.
		
		Within get_marked_frames_modified.m change vid variable to name of avi file.
			avi file is of desired cell image/time series
			series is seperated into its channels
			only Ca signaling channel is required
			save file as a avi file - can be edit so it only reads certain bits of series
				edit video/series before placeed into code - causes issues during process if not done this way
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
