function output=Hierarchical_Clustering(name, intmat)

%{
First two sections of this code are necessary for the independent version
of this code but are unecessary for the attached verion that just needs to
read the intensity as intmat ----- no video calls or reading required

Parts of code have been commented out ----- see line 111 for first line of
relevent code
%}
%% Creating video read and write objects
%{
%name = 'ARL Near and Far Analysis\Human Primary\Human Primary AVI\Run 1\Human Primary Control Near Late';
vid = [name '.avi'];
%To change videos also change the name here.
vidObjR = VideoReader(vid);
vidObjW = VideoWriter([vid '_write.avi']);
vidObjW.FrameRate = 1;
open(vidObjW);

% Needed inputs for processing:
frame_rate = vidObjR.FrameRate;
duration = vidObjR.Duration;
total_frames = frame_rate*duration;
fprintf('Total number of frames in the video = %d\n', total_frames);
prompt1 = 'Enter reference frame number: ';
%The reference frame is how we establish the background level of calcium
%signaling. We spend the first 100 frames collecting this data before
%changing the environment to provoke calcium signaling. Using different
%reference frames is one way I performed feature engineering. Since this is
%a relevent part of my process I left the prompt in the final code. For the
%best results, enter the number 10 when asked to enter the reference frame
%number. 
reference_frame = prompt1;
begin_frames = input(prompt1);
selected_frames = begin_frames;
prompt2 = 'Enter ending frame number: ';
%Another way I did feature engineering was to choose different ending
%frames. This is a useful feature for us because the microscopes can drift
%out of focus during prolonged imaging experiments.
%This can mess up the results because we are no longer able to see the
%signaling events. Choosing an end frame before this point lets us look
%only at the useful data. 
%Since this is a high-quality image that stays in focus the whole time,
%type 900 when it asks for the end frame.
end_frames = input(prompt2);
selected_frames = end_frames - begin_frames + 1;
count = 1;

for ii=selected_frames
	%disp(['Reading frame ' num2str(ii) '...']);
    vidObjR.CurrentTime = ii/frame_rate;
    im_frame = readFrame(vidObjR);
    [x_centroid{count}, y_centroid{count}, mean_pixel_vals{count}, std_pixel_vals{count},images{count}] = compute_metrics(im_frame); 
    % only need one image
    count = count + 1;
    currFrame = getframe;   
    writeVideo(vidObjW,currFrame);
end
disp('done');

%}
%% Computing per-frame metrics
%{
mins = [];
entropy_calc = [];
%for ii = [1,1,1,1,1]
for ii = reference_frame
	vidObjR.CurrentTime = ii/frame_rate;
    im_frame = readFrame(vidObjR);

	[I,indices_list] = get_pixel_indices(im_frame);
end
%The goal of the get_pixel_indices program is to binarize the image and
%identify cells. It will do this for each frame in the movie.
%This is one of several seperate codes embedded within this final product.
%For the sake of clarity, and to focus on the machine learning aspects of
%the code rather than these extra image processing steps I have elected to
%keep these embedded codes separate, but stored in the same folder so
%they'll be in the path and can be called when needed.

[I, new_image] =  display_regions(I,indices_list);
%I have also chosen to display the binarized image at this stage to better
%illustrate what this code is doing to identify the cells from the video.


count = 1;
for ii = begin_frames:end_frames-1
	vidObjR.CurrentTime = ii/frame_rate;
    im_frame = readFrame(vidObjR);
    im = rgb2gray(im_frame);
    current_image = adapthisteq(im);
    [mean_pixel_vals{count}] = get_intensities(current_image,indices_list);
    count = count + 1;
end
%The goal of this part of the code is to get the mean intensity of each
%cell in each frame. It does this through the program get_intensities.
%Like the above get_pixel_indices code I've chosen to keep it separate from
%the main code but still within the same file path.
%The output is the mean intensity value of each cell times the number of
%frames 
%}
%%
%{
intmat = zeros (length(mean_pixel_vals),length(mean_pixel_vals{1}));
for count = 1:length(mean_pixel_vals)
    intmat(count,:) = mean_pixel_vals{count};
end
%}

Ncell = length(intmat(1,:));
for x = 1:Ncell   
    j = min(intmat(:,x));
    intmat(:,x )= (intmat(:,x)-j)/j;
end

%The purpose of the above section of code is to normalize the data so that
%the lowest value from each column is subtracted from all the other values
%in the column. The purpose of this is to account for differences in
%baseline intensity between cells.


a = max(intmat);

%n=round(0.1*numel(a));
%[~,idx]=sort(a);
%top=a(idx(end-n+1:end));

b = mean(a); %Default version of the code 
%b = mean(top); %Low activity/Detected events - inhibition of activity
%version

c = 0.4*b;
%c = 0.4*a;

%what if we don't normalize the cells to each other, and instead normalize
%them to themselves? Look at the threshold based only on its own behavior
%and not averaging it out based on other cells? 

%Maybe try really low threshold
%This section of the code does further feature engineering on the intensity
%data with the goal of characterizing signaling events. The way I did this
%was first by finding the maximum intensity value of each cell. I then took
%the mean of that value to see on average, what the maximum intensity is
%across all cells. 
%The purpose of this averaging relies on the assumption
%that max intensity is the same across cells roughly. Averaging will cause
%the threshold to eliminate cells that are not actually signaling and stay
%dark the whole time, but may have slight fluctuations in intensity picked
%up by the machine.

%The next step is to determine the threshold for what
%counts as a "signaling event". There are more events per cell
%than just the one that caused the maximum intensity reading. The threshold
%is another area where we can perform feature engineering-chosing a higher
%or lower percent to use will exclude or include, respectively, more points
%within the cutoff to count as a signal. Based on observations of the
%original movie, previous thresholding experiments done in the lab, and trial and error,
%an appropriate cutoff is 0.4. Any signal that's over 0.4*mean maximum
%intensity counts as a signaling event and anything below that value is
%considered background.
%Since its 40% of the maximum intensity, it should not matter if the cell
%is signaling in the original frame or not. 


%% Identifying signaling events

%Signaling is a binary event-it is either occuring or it is not. To better
%reflect this I'm converting my table values to 0 if the value is below the
%threshold established above or 1 if it is at or above the threshold.
intmat(intmat<c) = 0;
intmat(intmat==c) = 1;
intmat(intmat>c) = 1;

%Allocating the range of the matrices for writing to excel
[m,n] = size(intmat);
firstCol = 'B';
lastCol = xlscol(n+1);
cellRange = [firstCol,num2str(1),':',lastCol,num2str(m)];

%Writing the Binary intensity to excel file
intfilename = [name ' HierarClustering Binary int.xlsx'];
xlswrite(intfilename,intmat,cellRange);
disp('Binary Int done');


%% Formatting the Data 

%I am interested in the number of signaling events per cell. My hypothesis
%is that some cells signal much more than others and have a greater role in
%cell-cell communication coordination. If this hypothesis is true, I expect
%to see several distinct groups in my hierarchical clustering analysis-one
%of cells that are "initiators" who signal a lot and one of cells that are
%"propagators" and do not signal as much.

% The first step do doing this analysis is to find the number of times each
% cell signals by summing the column values in my array. I formatted the
% values to fit into the hierarchical clustering code.
count = sum(intmat);
count = sort(count);
count = count';
%count = rmoutliers(count);
%Next lines are to remove outliers in matlab 2016 version
%isOutlier = abs(count) > -3/(sqrt(2)*erfcinv(3/2))*median(abs(count - median(count)));
%index=find(isOutlier==0); 
%count=count(index)

%% Hierarchical Clustering
%Pairwise distance
Y = pdist(count);

% Link pair of objects that are close to each other
Z = linkage(Y);

%% Create a dendrogram (Graphical representation of the cluster tree)
figure
dendrogram(Z, 'ColorThreshold', 'default');
%title('Clustering Based on Number of Frames Actively Signaling')
ylim([0 150])
%legend({'red = low signaling', 'green = intermediate signaling', 'blue = high signaling'}, 'location', 'northwest')
% There are 3 main groups, lots of cells are in the
% "low group" with a limited number of signaling events. A few cells are in
% an "intermediate" group, and a few cells are in the "high" group, and
% there are subgroups within the "low" group. This fits with the hypothesis
    % that a small number of cells have much higher signaling activity than the
% others and may be the ones "in charge" or "initiating" signaling
%% Verify similarity
% To confirm how well the model is able to describe the data, I have chosen
% to validate my model using a cophenetic correlation coefficient like we
% did in class
%In my example, the value was 0.894, which I consider very promising.
Cop = cophenet(Z, Y); 
fprintf('Cophenetic correlation coefficinet =')
disp(Cop)


%I have further verified my model by running a different video (NTC-BzATP2) through the
%program. The dendrogram had a similar branching pattern. There was a clear
%division between low-signaling cells and high-signaling cells. There was
%less of an "intermediate" signaling group in this example. Overall, I'd
%consider the structure of the dendrograms to be sufficiently similar to
%suggest reproducability and acceptance of the hypothesis. Furthermore,
% the cophenetic correlation coefficient was even higher for this example
% at 0.92 further indicating that this is a good model to analyze the data
% in this way. If you would like to check my validation I've included the
% NTC-BzATP2 video in the folder. To run it, you need to change the two
% instances of "NTC_BzATP" in the "Creating video  readand write objects" section
% of the code to "NTC-BzATP2"

%% histogram
nbins = 16;
%This divides up the data into 18 groups bars, each representing 50
%signaling events
figure
histogram(count, nbins);
xlim([0 length(intmat(:,1))])
% This can tell us if the number of times a cell signals is evenly
% distributed. 
[N] = histcounts(count, nbins);
fprintf('Histogram count: ')
disp(N);
fprintf('Cell count: ')
disp(Ncell)

