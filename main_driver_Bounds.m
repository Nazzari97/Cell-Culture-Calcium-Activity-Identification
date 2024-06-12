
clear;clc; close all

%%
% w = warning('query','last');
% % id = w.identifier;
% warning('off',id);
 
%% Creating video read and write objects
name = '';
vid = [name '.avi'];

vidObjR = VideoReader(vid);
vidObjW = VideoWriter([vid '_write.avi']);
vidObjW.FrameRate = 1;
open(vidObjW);

%% Needed inputs for processing
frame_rate = vidObjR.FrameRate;
duration = vidObjR.Duration;
total_frames = frame_rate*duration;
fprintf('Total number of frames in the video = %d\n', total_frames);
prompt0 = 'Enter reference frame: ';
reference_frame = input(prompt0);
prompt1 = 'Enter starting frame number: ';
begin_frames = input(prompt1);
prompt2 = 'Enter ending frame number: ';
end_frames = input(prompt2);
selected_frames = end_frames - begin_frames + 1;

%% Computing per-frame metrics


mins = [];
entropy_calc = [];
%for ii = [1,1,1,1,1]
for ii = reference_frame
	vidObjR.CurrentTime = ii/frame_rate;
    im_frame = readFrame(vidObjR);

	[I,indices_list] = get_pixel_indices(im_frame);
end
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
firstRow = 1;
lastRow = m;
firstCol = 'B';
lastCol = xlscol(n+1);
cellRange = [firstCol,num2str(firstRow),':',lastCol,num2str(lastRow)];

%Writing the intensity to excel file
excel_prompt = 'Enter the filename for the excel sheet you want to save intensity data to: ';
intfilename = input(excel_prompt,'s');
intfilename = [intfilename '.xlsx'];
xlswrite(intfilename,intmat,cellRange);
disp('done');


%Calling PKcorr function
disp('Begin to process PKcorr');
excel_prompt = 'Enter the filename of the postion data excel sheet: ';
%posfilename = 1(excel_prompt,'s');
posfilename = input(excel_prompt,'s');
posfilename = [posfilename '.xlsx'];

[position,txt,raw] = xlsread(posfilename) ;
[intensity,txt,raw] = xlsread(intfilename) ;
Pkcorr(intensity,position,4,name)

Hierarchical_Clustering(name, intmat)
