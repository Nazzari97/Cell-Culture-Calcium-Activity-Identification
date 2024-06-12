clear; clc;
vid = '';
vidObjR = VideoReader(vid);
vidObjW = VideoWriter([vid '_write.avi']);
vidObjW.FrameRate = 1;
open(vidObjW);

%% Needed inputs for processing

frame_rate = vidObjR.FrameRate;
duration = vidObjR.Duration;
total_frames = frame_rate*duration;
fprintf('Total number of frames in the video = %d\n', total_frames);
prompt1 = 'Enter reference frame number: ';
begin_frames = input(prompt1);
selected_frames = begin_frames;
% prompt2 = 'Enter ending frame number: ';
% end_frames = input(prompt2);
% selected_frames = end_frames - begin_frames + 1;
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

% Extracting position from centroid cells
xdata = x_centroid{1}';
ydata = y_centroid{1}';
posdata = [xdata,ydata];

excel_prompt = 'Enter the filename for the postion excel sheet: ';
posfilename = input(excel_prompt,'s');
posfilename = [posfilename '.xlsx'];
xlswrite(posfilename,posdata);
disp('done');
