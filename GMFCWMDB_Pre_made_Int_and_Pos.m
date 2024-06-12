clear; clc;
close all %closes all open figures

%folder = 'E:\Kristen\Live Cell Cornea Steph\BalbC Mice\9-12 week mouse\45 minutes\BalbC Dec 7\Eye3Wings\';
%folder = 'E:\Kristen\Live Cell Cornea Steph\NO Mice\9-12 Week Mouse\45 minutes\NormCorre and Nick Analysis\Kristen Analysis\May 12\';
folder = 'F:\Nicholas\Ex Vivo Mouse Eyes\5-15-24 Retired Breaders NoN\Data and Analysis\';
%folder = 'H:\VTR Lab\Ex Vivo\NON eye 1\';
posfilename = 'Eye 2\CombinedCentroids';
intfilename = 'Eye 2\CombinedMM';

%posfilename = 'Mar14Eye1CentralZ1 Wing Centroids';
%intfilename = 'Mar14Eye1CentralZ1 WingMM';

name = 'Eye 2\Eye 2 Combined Analysis';


name = [folder name];
posfilename = [folder posfilename '.xlsx'] ;
intfilename = [folder intfilename '.xlsx'] ;

%%Percent values
percent = 0.3;
%percent = 0.4;

%NBPK skp value - base value is 4 - 
%skp is the number of frames to look at the cross correlations (i.e. how many frames to plot after an "event"
skp = 4;

% Default useing 85 pixels calculate distance between cells if dis< 85 pixel then flag as neighbor and set to 1
NxtCeldis=85; %85 value works best for cell culture - miight need to altered for wing cells and basal cells
%NxtCeldis=85*2; %pixel; value for wings cells - maybe doubled what the
%default is from cell culture 
%NxtCeldis=85*.5; pixel value for basal cells - mayubed halfed or
%quartered what is default for cell culture

%%
%Calling PKcorr function

[position,txt,raw] = xlsread(posfilename);
[intensity,txt,raw] = xlsread(intfilename);

Pkcorr(intensity,position,percent,skp,NxtCeldis,name); 
%heatmap, detected events, and returned values and NBPKdata excel file
%NBPKdata produces the individual cell total peak (totpk), nearby peaks
%(NBPK) and the probability a signal was nearby signal (prbNB)

%Pkcorr2(intensity,position,percent,skp); 
%plot event triggered average traces of neighbors and 
%plot event triggered average traces of that cell and 
%comparison between two graph

Pkcorr3(intensity,position,percent,skp); 
%intensity graphs, peak graphs, detected events over time

%Pkcorr4(intensity,position,skp); %intensity graphs

%%
%addation of the hierarchiacal clustering code developed by K. Segars 
%Outputs a dendrogram, a histogram, and a Cophenetic correlation coefficinet
%representing the cells that have different signaling phenotypes
%For Cophenetic correlation coefficinet the closer the otput is to 1 the
%better - .90s are what you want and .80s can be tolerated

Hierarchical_Clustering(name, intensity);

%Hierarchical_Clustering_Independent for the independent version of the
%code --- for more control over the defined frames of intrest and etc. Use
%the independent version for the publication graphs because it produces
%graphs and values with a higher correlation coefficient --- could not
%figure out the exact cause of why independent version of code produced
%better values and grahs then the attahed 