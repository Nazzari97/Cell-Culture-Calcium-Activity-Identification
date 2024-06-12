# Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing

This is MATLAB script created and used via the Trinkaus-Randall Lab at Boston University for the analysis of epithelial cellular calcium signaling during wound healing.

# Citation

If you find this package useful please cite our most relevant paper.

	Hierarchical_Clustering.m and BasalandWingNBPKAnalysis.m are introduced into a paper in the review stage - this ReadMe will be updated once it has been published
 
 	Prior versions of the code and processes have been used within these articles:
  
  	Azzari NA, Segars KL, Rapaka S, Kushimi L, Rich CB, Trinkaus-Randall V. Aberrations in Cell Signaling Quantified in Diabetic Murine Globes after Injury. Cells. 2023 Dec 21;13(1):26. doi: 10.3390/cells13010026. PMID: 38201230; PMCID: PMC10778404.

 	Segars KL, Azzari NA, Gomez S, Machen C, Rich CB, Trinkaus-Randall V. Age Dependent Changes in Corneal Epithelial Cell Signaling. Front Cell Dev Biol. 2022 May 5;10:886721. doi: 10.3389/fcell.2022.886721. PMID: 35602595; PMCID: PMC9117764.

	Lee Y, Kim MT, Rhodes G, Sack K, Son SJ, Rich CB, Kolachalama VB, Gabel CV, Trinkaus-Randall V. Sustained Ca2+ mobilizations: A quantitative approach to predict their importance in cell-cell communication and wound healing. PLoS One. 2019 Apr 24;14(4):e0213422. doi: 10.1371/journal.pone.0213422. PMID: 31017899; PMCID: PMC6481807.

 	Lee YK, Segars KL, Trinkaus-Randall V. Multiple Imaging Modalities for Cell-Cell Communication via Calcium Mobilizations in Corneal Epithelial Cells. Methods Mol Biol. 2021;2346:11-20. doi: 10.1007/7651_2020_329. PMID: 33159251; PMCID: PMC8787922.


# General Overview of the Code

This script was created to analyze videos and recordings of cellular calcium signaling activity during the wound response within cells grown in cell culture.

The code first loads an .avi file into MATLAB and uses pixel intensities to identify cells. 

![image](https://github.com/Nazzari97/Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing/assets/172518839/81a791b2-3848-46be-ad24-779572833aa4)

The image on the left is the reference frame used to create cell identification, the image on the right is the reference frame with an overlaid mask displaying identified cells

This mask and cell location are used to generate centroid data and intensity over time data. 

The code interprets the intensity over time using the Heatmap function from 2016a MATLAB.

![image](https://github.com/Nazzari97/Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing/assets/172518839/41bfc463-4d99-49de-b1c7-359db1ab60b2)

This data is interpreted to find where intensity increases reach a threshold determined by the mean max intensity of cells.
When the threshold is reached an intensity, change is classified as a peak or a detected event. 

Detected event data is used to generate a Detected Events Graph.

![image](https://github.com/Nazzari97/Cell-Culture-Calcium-Activity-Identification-During-Wound-Healing/assets/172518839/3e785ee3-e906-434b-af87-988867d9a7b6)

The peak data, intensity data, and centroid data is used to generated various other graphs and return relevant data for the analysis of cellular calcium activity.

# Usage and Code Details


Usage Requires 2016a MATLAB for Heatmap generation - rest of code can be updated to work with newer versions of MATLAB

Place all files into a single folder and either start MATLAB from there or enter functions into MATLAB path

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
   
	   		This lab has used ImageJ/FUJI for this process taking advantage of the Region of Interest (ROI) tool 
	     		and the measure and multi measure tools within the ROI manager
	       		Position data was created with centroid data
		 	Intensity data was created with mean gray value
	   			Intensity data has to be generated only using the Calcium indicator Channel
	       		This creates data sets that can be generated and copied into Microsoft excel
		 		make sure to remove the cell count variables in the first column in the centroid data
	    			and make sure to remove the time point data from the intensity data generated in multi measure
	
       Name the Folder var with the files folder.
       Name the position data var using a string with the file type extension removed - posfilename.
       Name the intensity data var using a string with the file type extension removed - intfilename.
       the var 'name' is used for the creation of data sets via the code to create a basic for these file name.
       Run code.

Explanation for some var that user might want to change

	Skp - is the number of frames checked for nearby signaling activity/propagation of calcium events - it is set to four frames by default
	
	percent - the percentage of the Max Mean intensity required for an intensity change to reach before it is classified as a detected event
		The default for cell culture is 40% (.4)
	 	The default for ex vivo/tissue is 30% (.3)
	
	NxtCeldis - the max pixel distance required between centroids for cells to be classified as nearby
		ex if distance between two centroids is beyond this value - they are not nearby each other 
	 		and similar temporal relation between cellular activity cannot be due to propagation
	   	If those same two centroids where within the distance/pixel value they are nearby each other
	    		and the similar temporal cellular activity could be due to propagation of signal

Values returned by Pkcorr

 	mnsig - mean signaling of all identified cell
	totPK - total signaling
	NBPK - total nearby signaling --- cell to cell communication?
	prbNB - probability a signal was nearby signal
	rate - rate of signaling by identified cells

 What is Hierarchical_Clustering.m

  	This code analyzes the total active time of identified cells and determines if they have low or high activity and everything in between
   	This code returns a dendrogram and a Histogram graphs to display these differences
    	The code also generated binarized intensity files generated from the intensity files created or inputted into the code

What is BasalandWingNBPKAnalysis.m

	this code is used to analyze the propagation of calcium signaling events between different layers of tissue epithelium/different videos taken from the same tissue at different z layers
 	this code works in a similar manner to GMFCWMDB_Pre_made_Int_and_Pos and Pkcorr, it required premade centroid and intensity excel files
  	it then uses that centroid data and intensity data to determine if cells had detected events and propagated events within their layers
   	then it compared those two data sets with the centroid data between layers/files to determine if there was propagated events between the two different data sets
    	this used altered NxtCeldis values because of the different sizes of cells used by this lab, Wing cells are larger and have a large NxtCeldis value, 
     	while basal cells are smaller then have a smaller NxtCeldis then default values described above

      	var that have to be inputted are:	
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
    		



Original Read Me for Use of get_marked_frames_modified.m and main_driver_Bounds.m

		Scripts have been combined into get_marked_frames_modified_combined_with_main_driver_Bounds.m 
		this version only requires the .avi file to be uploaded once rather than twice across two separate scripts
		
		Need to have get_marked_frames_modified.m and main_driver_Bounds.m open within a 2016a MATLAB.
		
		Within get_marked_frames_modified.m change vid variable to name of .avi file.
			.avi file is of desired cell image/time series
			series is separated into its channels
			only Ca signaling channel is required
			save file as an .avi file - can be edit so it only reads certain bits of series
				edit video/series before placed into code - causes issues during process if not done this way
			name variable vid in line 2 as name of desired .avi file
			make sure .avi file is within MATLAB pathway
			pick start frame ----- 1
			create pos excel graph with code
			
		Within main_driver_bounds.m variable name on line 10 us = 'name of avi'
			run code
			frame_rate is one
			start_frame is one
			end_frame is total frames - 1
				i.e. total is 900 frames enter 899 frames
			name int excel file being created
			recall pos excel file from get_marked_frames_modified

		
		Save the cell identified figure 
		Save the hot spot/intensity graphs
		other graphs/figures are unnecessary for data analysis


END
