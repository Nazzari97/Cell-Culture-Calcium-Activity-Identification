clear; clc;
close all %closes all open figures
%name = 'ARL Near and Far Analysis\Human Primary\Human Primary AVI\Run 3\Human Primary 50nM Far Late';
%name = 'W2croppedtotal';
%folder = 'ARL 2023\HDia ARL 2023\Hum Dia P7 AVI Run 6\';
%folder = 'Eye Analysis 2023\NoN young mice\'
folder = '';
name ='3-5-24 TRPV4 15um';

name = [folder name];
vid = [name '.avi'];
vidObjR = VideoReader(vid);
vidObjW = VideoWriter([vid '_write.avi']);
vidObjW.FrameRate = 1;
open(vidObjW);

%%Percent values
percent = 0.4;
%percent = 1.4; %runs with inhibitor

%NBPK skp value - base value is 4 - 
%skp is the number of frames to look at the cross correlations (i.e. how many frames to plot after an "event"

skp = 4;

% Default useing 85 pixels calculate distance between cells if dis< 85 pixel then flag as neighbor and set to 1
NxtCeldis=85; %85 value works best for cell culture - miight need to altered for wing cells and basal cells
%NxtCeldis=85*2; %pixel; value for wings cells - maybe doubled what the
%default is from cell culture 
%NxtCeldis=85*.5; pixel value for basal cells - mayubed halfed or
%quartered what is default for cell culture
%% Needed inputs for processing
frame_rate = vidObjR.FrameRate;
duration = vidObjR.Duration;
total_frames = frame_rate*duration;
fprintf('Total number of frames in the video = %d\n', total_frames);
begin_frames = 1; %Enter starting frame number
reference_frame = begin_frames + 29; %Enter reference frame number:
end_frames = total_frames - 1; %Enter ending frame number --- if you want total amount of frames
%end_frames = 110; %%if want something execpt total vid uncomment and add number


%%%%from the for loop in get_marked_frames_modified
vidObjR.CurrentTime = reference_frame/frame_rate;
im_frame = readFrame(vidObjR);
[x_centroid{1}, y_centroid{1}, mean_pixel_vals{1}, std_pixel_vals{1},images{1}] = compute_metrics(im_frame); 
writeVideo(vidObjW,1);
close(vidObjW);



%{
selected_frames = reference_frame;
%selected_frames = end_frames - begin_frames + 1;
count = 1;

vidObjR.CurrentTime = selected_frames/frame_rate;
im_frame = readFrame(vidObjR);
[x_centroid{count}, y_centroid{count}, mean_pixel_vals{count}, std_pixel_vals{count},images{count}] = compute_metrics(im_frame); 
% only need one image
currFrame = getframe;   
writeVideo(vidObjW,currFrame);

disp('done');
%}

% Extracting position from centroid cells
xdata = x_centroid{1}';
ydata = y_centroid{1}';
posdata = [xdata,ydata];


posfilename = [name 'pos.xlsx'];
xlswrite(posfilename,posdata);
disp('Pos done');

%% Computing per-frame metrics

mins = [];
entropy_calc = [];

[I,indices_list] = get_pixel_indices(im_frame);
[I, new_image] =  display_regions(I,indices_list);

count = 1;
for ii = begin_frames:end_frames
	vidObjR.CurrentTime = ii/frame_rate;
    im_frame = readFrame(vidObjR);
    im = rgb2gray(im_frame);
    current_image = adapthisteq(im);
    [mean_pixel_vals{count}] = get_intensities(current_image,indices_list);
    count = count + 1;
end

%%
intmat = zeros (length(mean_pixel_vals),length(mean_pixel_vals{1}));
for count = 1:length(mean_pixel_vals)
    intmat(count,:) = mean_pixel_vals{count};
end
%Allocating the range of the matrices for writing to excel
[m,n] = size(intmat);
firstCol = 'B';
lastCol = xlscol(n+1);
cellRange = [firstCol,num2str(1),':',lastCol,num2str(m)];

%Writing the intensity to excel file
intfilename = [name 'int.xlsx'];
xlswrite(intfilename,intmat,cellRange);
disp('Int done');

%%
%Calling PKcorr function

[position,txt,raw] = xlsread(posfilename) ;
[intensity,txt,raw] = xlsread(intfilename) ;
Pkcorr(intensity,position,percent,skp,NxtCeldis,name); 
%heatmap, detected events, and returned values and NBPKdata excel file
%NBPKdata produces the individual cell total peak (totpk), nearby peaks
%(NBPK) and the probability a signal was nearby signal (prbNB)

%Pkcorr2(intensity,position,percent,skp); 
%plot event triggered average traces of neighbors and 
%plot event triggered average traces of that cell and 
%comparison between two graph

Pkcorr3(intensity,position,skp); 
%intensity graphs, peak graphs, detected events over time



%%
%addation of the hierarchiacal clustering code developed by K. Segars 
%Outputs a dendrogram, a histogram, and a Cophenetic correlation coefficinet
%representing the cells that have different signaling phenotypes
%For Cophenetic correlation coefficinet the closer the otput is to 1 the
%better - .90s are what you want and .80s can be tolerated

Hierarchical_Clustering(name, intmat);

%Hierarchical_Clustering_Independent for the independent version of the
%code --- for more control over the defined frames of intrest and etc. Use
%the independent version for the publication graphs because it produces
%graphs and values with a higher correlation coefficient --- could not
%figure out the exact cause of why independent version of code produced
%better values and grahs then the attahed 
