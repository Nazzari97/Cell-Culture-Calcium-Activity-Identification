clear; clc;
close all %closes all open figures

%folder = 'E:\Kristen\Live Cell Cornea Steph\BalbC Mice\BalbC 27 week\Data\'; %folder of the files
folder = 'F:\Nicholas\Ex Vivo Mouse Eyes\5-15-24 Retired Breaders NoN\Data and Analysis\Eye 2\';

wingposfilename = 'WingCentroids';
wingintfilename = 'WingMM';
basalposfilename = 'BasalCentroids';
basalintfilename = 'BasalMM';

%wingposfilename = 'Mar 28 Eye 3 wing\Mar28CentralEye3WingCentroids'; %name of the wing centroid file 
%wingintfilename = 'Mar 28 Eye 3 wing\Mar28CentralEye3WingMM'; %name of the wing intensity (MM = multi measure) file
%basalposfilename = 'Mar 28 Eye 3 Basal\Mar28CentralEye3BasalCentroid'; %name of the basal centroid file 
%basalintfilename = 'Mar 28 Eye 3 Basal\Mar28CentralEye3BasalMM'; %name of the basal intensity (MM = multi measure) file

%- amount of cells sould match cell count in centroids file. Centorid file
%the excel sheet should be configured in x position in A, y position in B,
%and cells in the numbered col down
%In the intensity file the cells are the letter row and the time point is
%the numbered down col - the cell intensity in col A should match the cell in
%row 1

wingposfilename = [folder wingposfilename '.xlsx'] ;
wingintfilename = [folder wingintfilename '.xlsx'] ;

basalposfilename = [folder basalposfilename '.xlsx'] ;
basalintfilename = [folder basalintfilename '.xlsx'] ;

%%Percent values
percent = 0.3; 
%ex-vivo - 30 percent of the average max intensity of all cells has been found
%to work best with tissue compared to the 40 percent of cell culture

%NBPK skp value - base value is 4 - 
%skp is the number of frames to look at the cross correlations (i.e. how many frames to plot after an "event"
skp = 4; 
%with a value of 4 stilled used for ex vivo samples it becomes somthing like 36 seconds becasue the 3
%layer z stack makes one frame/time point into 3 taken at different layers,
%normal non z-stack runs have about a 12 seconds interval to see if there
%is singaling progatation ---- might need to increase4 this number for ex
%vivo because of the decreased signaling speed seen in tissue compared to
%the more rapid activity of cell culture

% Default useing 85 pixels calculate distance between cells if dis< 85 pixel then flag as neighbor and set to 1
basalNxtCeldis=85*.5; %basal cells are about half the size of cell culture cells in terms of pixels - so distance was halfed
wingNxtCeldis=85*2; %wing cells are about twice the size in terms of pixels as cell culture cells so distance was doubled

[wingposition,txt,raw] = xlsread(wingposfilename);
[wingintensity,txt,raw] = xlsread(wingintfilename);

[basalposition,txt,raw] = xlsread(basalposfilename);
[basalintensity,txt,raw] = xlsread(basalintfilename);

%% wing cell normalization and variable creation
wingNcell=length(wingintensity(1,:));
wingNfrm=length(wingintensity(:,1));


for x=1:wingNcell   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(wingintensity(:,x));
    wingintensity(:,x)=(wingintensity(:,x)-m)/m;
end

%% basal cell normalization and variable creation
basalNcell=length(basalintensity(1,:));
basalNfrm=length(basalintensity(:,1));


for x=1:basalNcell   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(basalintensity(:,x));
    basalintensity(:,x)=(basalintensity(:,x)-m)/m;
end

%% wing PKs
wingPK=zeros(wingNfrm,wingNcell);
Npt = 15;
Aucor=zeros(Npt+1,wingNcell);
for x=1:wingNcell               % find peaks in each trace and setup locations to 1 in PK
    [pks,winglocs]=findpeaks(wingintensity(:,x),'MinPeakProminence',percent); %1, set lower for more events
    wingPK(winglocs,x)=1;
    if sum(wingPK(:,x)) > 10 %if excessive events are detected in one cell, the cell is considered null.
       wingPK(:,x)= 0;
    end
    Aucor(:,x)=autocorr(wingintensity(:,x),Npt);
   
end

%% basal PKs
basalPK=zeros(basalNfrm,basalNcell);
%Npt=40; %500
Npt = 15;
Aucor=zeros(Npt+1,basalNcell);
for x=1:basalNcell               % find peaks in each trace and setup locations to 1 in PK
    [pks,basallocs]=findpeaks(basalintensity(:,x),'MinPeakProminence',percent); %1, set lower for more events
    basalPK(basallocs,x)=1;
    if sum(basalPK(:,x)) > 10 %if excessive events are detected in one cell, the cell is considered null.
       basalPK(:,x)= 0;
    end
    Aucor(:,x)=autocorr(basalintensity(:,x),Npt);
   
end

%% wing NBPK
wingDis=zeros(wingNcell, wingNcell);
for r=1:wingNcell           % calculate distance between cells if dis< 85*2 pixel then flag as neighbor and set to 1
    for c=1:wingNcell
        x=wingposition(r,1)-wingposition(c,1);
        y=wingposition(r,2)-wingposition(c,2);
        if c~=r %if c does not equal r
            if sqrt((x*x)+(y*y))<wingNxtCeldis 
                wingDis(r,c)=1;
            end
        end   
    end
end

wingNBPK=0;
for x=1:wingNcell 
    winglocs=find(wingPK((1:wingNfrm-skp),x));
    wingNeBrs=find(wingDis(:,x));
    for l=1:length(winglocs)
        if sum(sum(wingPK((winglocs(l):winglocs(l)+skp),wingNeBrs)))>0
          wingNBPK=wingNBPK+1;      %count if NBPK are active after a cell event
        end
    end
end

%% Basal NBPK
basalDis=zeros(basalNcell, basalNcell);
for r=1:basalNcell           % calculate distance between cells if dis< 85/2 pixel then flag as neighbor and set to 1
    for c=1:basalNcell
        x=basalposition(r,1)-basalposition(c,1);
        y=basalposition(r,2)-basalposition(c,2);
        if c~=r %if c does not equal r
            if sqrt((x*x)+(y*y))<basalNxtCeldis 
                basalDis(r,c)=1;
            end
        end   
    end
end


basalNBPK=0;
for x=1:basalNcell 
    basallocs=find(basalPK((1:basalNfrm-skp),x));
    basalNeBrs=find(basalDis(:,x));
    for l=1:length(basallocs)
        if sum(sum(basalPK((basallocs(l):basallocs(l)+skp),basalNeBrs)))>0
          basalNBPK=basalNBPK+1;      %count if NBPK are active after a cell event
        end
    end
end


%% Totpk and NBPK of seperate Analysis
disp('Comparison for layered communication');

%disp('Number of wing cells: ')
wingNcell

totwingPK=sum(sum(wingPK((1:wingNfrm-skp),:))); %total wing signaling
%disp('Number of wing cell total activity: ');
totwingPK

%disp('Number of wing cell total nearby activity: ');
wingNBPK

%disp('Number of basal cells: ');
basalNcell

totbasalPK=sum(sum(basalPK((1:basalNfrm-skp),:))); %total basal signaling
%disp('Number of wing cell total activity: ');
totbasalPK

%disp('Number of basal cell total nearby activity: ');
basalNBPK

%% Comparison finding Wing to Basal (WtBNBPK) and Basal to Wing (BtWNBPK) activity and propagation of acitivty

CompareDis=zeros(wingNcell, basalNcell);
for r=1:wingNcell           % calculate distance between cells if dis< wingNxtCeldis (85*2 pixels) pixel then flag as neighbor and set to 1
    for c=1:basalNcell
        x=wingposition(r,1)-basalposition(c,1); %find x difference between wing and basal cell
        y=wingposition(r,2)-basalposition(c,2); %find y difference between wing and basal cell
        %does not require the if c does not euqal r part of the code becuase r is wing cells and r is basal
        if sqrt((x*x)+(y*y))<wingNxtCeldis %is the hypo of x and y difference under the pixal distance specifed 
                CompareDis(r,c)=1;
        end   
    end
end

%{
compareNBPK=0;
for x=1:wingNcell 
    winglocs=find(wingPK((1:wingNfrm-skp),x));
    compareNeBrs=find(CompareDis(:,x));
    for l=1:length(winglocs)
        if sum(sum(basalPK((winglocs(l):winglocs(l)+skp),compareNeBrs)))>0
          compareNBPK=compareNBPK+1;      %count if NBPK are active after a cell event
        end  
    end
end
%}

WtBNBPK=0;%Wing to Basal Nearby Peaks - wing to basal cross layered communication
BtWNBPK=0; %Basal to Wing Nearby Peaks - basal to wing cross layered communication
TotalNBPK=0; %Total NBPK is the combined total of WtB and BtW showcasing all activity between the wing and basal layers

%NBPK code used above was rewritten to account for the fact we are calling
%forth two differnt centoids and intensity sets - makes it so it runs
%though the count of cells in two sets of for loops and checks for PK at
%every time point - then checks for nearby activity in the other layered
%cell within time + skp time points. 
%Distance was calculated for every wing and basal cell in above for loop
%and keep within the ComareDis matrix - where wing cells are col and basal
%cells are row - if the cells were within the Wing cells desired distance
%then the value was a 1 and if not then 0.

for w=1:wingNcell %for loop of every wing cell into a for loop of every basal cell
    for b=1:basalNcell
        if CompareDis(w,b) > 0; %depending on what two cells are in the loop see if they are nearby cells within 85*2 pixels
            for t=1:wingNfrm-skp %for t though the end of the time points for the wing check for activity using PK values
                if wingPK(t,w) > 0; %checking for PK value at specific wing cells for every t point in the loop
                    if sum(basalPK((t:t+skp),b)) > 0 %checking if the identifed nearby basal cell has activity within 4 frames (32 seconds)
                        WtBNBPK = WtBNBPK + 1; %count if NBPK are active after a cell event
                    end
                end
            end
        end
    end
end

for b=1:basalNcell %for loop of every basal cell into a for loop of every wing cell
    for w=1:wingNcell
        if CompareDis(w,b) > 0; %depending on what two cells are in the loop see if they are nearby cells within 85*2 pixels
            for t=1:basalNfrm-skp %for t though the end of the time points for the basal check for activity using PK values
                if basalPK(t,b) > 0; %checking for PK value at specific basal cells for every t point in the loop
                    if sum(wingPK((t:t+skp),w)) > 0 %checking if the identifed nearby wing cell has activity within 4 frames (32 seconds)
                        BtWNBPK = BtWNBPK + 1; %count if NBPK are active after a cell event
                    end
                end
            end
        end
    end
end


%% Printing Compared values

%disp('Number of nearby events from interlayer propagation: ');
WtBNBPK
BtWNBPK
TotalNBPK = WtBNBPK + BtWNBPK
