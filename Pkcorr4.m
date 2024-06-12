 function output=Pkcorr(Sig,Pos,skp)

% Imput: 
% Sig= is an array of cell signals each column is one cell, rows are time points, 
% Pos= 2-D array of x, y positions of each cell. order of cell positions needs to be
% the order of cells in columns of Sig. column 1 = X, Column 2= y. 
% skp= is the number of frames that will be measured after each event to
% find neighboring evens, and plot the activity trigger average of the
% active cell and its neighbor. Note: The last skp frames of the data are
% disregarded. 

Ncell=length(Sig(1,:));
Nfrm=length(Sig(:,1));


disp('begin PkcorrINT, creating intensity graphs');

for x=1:Ncell   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(Sig(:,x));
    Sig(:,x)=(Sig(:,x)-m)/m;
end

rng=max(max(Sig));  %generate heatmap of cell activity, each row is activity of one cell
%HeatMap(Sig','colormap',jet(1000),'DisplayRange',rng,'Symmetric',false); %1000

figure
plot(Sig)
hold on
plot(mean(Sig,2),'k','LineWidth',3)
title('Intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 
xlim([0 Nfrm])
ylim([0 3])

figure
plot(mean(Sig,2),'k','LineWidth',3)
title('mean intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 
xlim([0 Nfrm])

%{
PK=zeros(Nfrm,Ncell);
%Npt=40; %500
Npt = 15;
Aucor=zeros(Npt+1,Ncell);
for x=1:Ncell               % find peaks in each trace and setup locations to 1 in PK
    [pks,locs]=findpeaks(Sig(:,x),'MinPeakProminence',0.4); %1, set lower for more events
    PK(locs,x)=1;
    if sum(PK(:,x)) > 10 %if excessive events are detected in one cell, the cell is considered null.
       PK(:,x)= 0;
    end
    Aucor(:,x)=autocorr(Sig(:,x),Npt);
end

figure
PK1=sum(PK,2);
plot(PK1,'r','LineWidth',1)
title('sum Peaks per time');
%}
disp('PKcorrINT done');