function[regions,image,height_split,width_split] = define_bounds(image,x_pos,y_pos,name)
%disp('define_bounds function will create X by X regions to classify points.');
%the_split = input('Enter integer for boundary: ');
height_split = input('Enter the number of boxes desired in the y direction: ');
width_split = input('Enter the number of boxes desired in the x direction: ');
%height_split = 5;

%width_split = 5;
%disp('testing');
close all;
nCells = length(x_pos);
for ii = 1:nCells
    position(ii,1) = x_pos(ii);
    position(ii,2) = y_pos(ii);
end
image = rgb2gray(image);
image = insertMarker(image,position,'circle','color','r','size',10);
figure;

imshow(image);
title([name 'regions ' num2str(height_split) ' by ' num2str(width_split)]);
hold on;
axis on;

%width = length(image(1,:));
% width = 'how many entries in a row of the image?'

[height,width] = size(image);
width = width / 3;
%rect_width = width / the_split
%rect_width = height;
rect_height = height / height_split;
rect_width = width / width_split;


%disp(rect_width);
%disp(rect_height);
%disp(width);
%disp(height);
y_coord = 0;
x_coord = 0;
color = 'r';
count = 1;

count_temp = 1;
for i = 1:width_split
    the_xMax = x_coord + rect_width;
    for ii = 1:height_split
        
        regions(count).xMax = the_xMax;
        regions(count).yMax = y_coord + rect_height;
        regions(count).xMin = x_coord;
        regions(count).yMin = y_coord;
        regions(count).cells = [];
        regions(count).values = [];
        rectangle('Position',[x_coord y_coord rect_width rect_height],...
            'LineStyle','-',...
            'EdgeColor',color);
        center_x = (x_coord + regions(count).xMax)/2;
        center_y = (y_coord + regions(count).yMax)/2;
        text_str(count_temp).center = [center_x, center_y];
        text_str(count_temp).ID = count_temp;
        regions(count).center = [center_x,center_y];
        %//position(count_temp,1) = x_coord;
        %//position(count_temp,2) = y_coord;
        count_temp = count_temp + 1;
        y_coord = y_coord + rect_height;
        count = count + 1;
        color = 'g';
        %break;
    end
    x_coord = x_coord + rect_width;
    y_coord = 0;
    
end
%RGB = insertText(image,position,text_str);
%figure;
%imshow(RGB);

for x=text_str
    center =  x.center;
    the_ID = num2str(x.ID);
    text(center(1),center(2),the_ID,'color','w','fontsize',14);
    
end