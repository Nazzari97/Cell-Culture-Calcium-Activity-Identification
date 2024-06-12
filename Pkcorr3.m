 function output=Pkcorr(Sig,Pos,percent,skp)

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


disp('begin Pkcorr3, creating intensity and peak graphs');

for x=1:Ncell   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(Sig(:,x));
    Sig(:,x)=(Sig(:,x)-m)/m;
end

rng=max(max(Sig));  %generate heatmap of cell activity, each row is activity of one cell
%HeatMap(Sig','colormap',jet(1000),'DisplayRange',rng,'Symmetric',false); %1000


%figure
%plot(mean(Sig,1))
%title('mean intensity per cell')
%xlabel('Cells') 
%ylabel('Intensity (F/Fo)') 

%figure
%plot(sum(Sig,1))
%title('summed intensity per cell')

%figure
%plot(sum(Sig,2))
%title('summed intensity over time')



highsig = zeros(Nfrm,Ncell);
lowsig = zeros(Nfrm,Ncell);

PK=zeros(Nfrm,Ncell);
highPK=zeros(Nfrm,Ncell);
lowPK=zeros(Nfrm,Ncell);
%Npt=40; %500
Npt = 15;
Aucor=zeros(Npt+1,Ncell);
lowcount = 1;
highcount = 1;
for x=1:Ncell               % find peaks in each trace and setup locations to 1 in PK
    [pks,locs]=findpeaks(Sig(:,x),'MinPeakProminence',percent); %1, set lower for more events
    PK(locs,x)=1;
    if sum(PK(:,x)) < 2;
        lowsig(:,lowcount) = Sig(:,x);
        lowPK(:,lowcount) = PK(:,x);
        lowcount = lowcount + 1;
    end
    if sum(PK(:,x)) > 5;
        highsig(:,highcount) = Sig(:,x);
        highPK(:,highcount) = PK(:,x);
        highcount = highcount + 1;
    end
    if sum(PK(:,x)) > 10 %if excessive events are detected in one cell, the cell is considered null.
       PK(:,x)= 0;
    end
    Aucor(:,x)=autocorr(Sig(:,x),Npt);
end

figure
set(gcf,'position',[50,50,1100,420])
subplot(1,2,1);
plot(Sig)
hold on
plot(mean(Sig,2),'k','LineWidth',3)
title('Intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

subplot(1,2,2);
plot(mean(Sig,2))
title('mean intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

figure
set(gcf,'position',[50,50,1100,420])
subplot(1,2,1);
plot(lowsig)
hold on
plot(mean(lowsig,2),'k','LineWidth',3)
title('lowIntensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

subplot(1,2,2);
plot(mean(lowsig,2))
title('mean lowintensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

figure
set(gcf,'position',[50,50,1100,420])
subplot(1,2,1);
plot(highsig)
hold on
plot(mean(highsig,2),'k','LineWidth',3)
title('highIntensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

subplot(1,2,2);
plot(mean(highsig,2))
title('mean highintensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 

figure
plot(mean(Sig,2))
hold on
plot(mean(highsig,2))
hold on
plot(mean(lowsig,2))
hold off
title('mean intensity over time comparison')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 
legend('Mean Intensity','Mean High Signaling Intensity', 'Mean Low Signaling Intensity')

figure
subplot(2,1,1);
PK1=sum(PK,1);
plot(PK1,'r','LineWidth',1)
title('sum Peaks per cell');

subplot(2,1,2);
PK1=sum(PK,2);
plot(PK1,'r','LineWidth',1)
title('sum Peaks per time');

detectedevents=[];
for x=1:Nfrm
    if x > 1;
        detectedevents(x) = PK1(x) + detectedevents(x-1);
    else
        detectedevents(x) = PK1(x);
    end
end


figure
plot(detectedevents)
title('detected events over time');


%%
%{
figure
PK2=mean(PK);
plot(PK2,'g','LineWidth',3)
title('mean PK');
%}

%disp('for loop 2 done');
%{
plt=PK;  %plot indentified events, each column is one cell 
for x=1:Ncell
    plt(:,x)=plt(:,x)+x;
end

figure
plot(plt)  
title('detected events');
%}

%figure
%sumplt = sum(plt,2);
%sumplt = sumplt - min(sumplt);
%plot(sumplt)  
%title('sum detected events over time');


%{
figure
plt2 = sum(plt)
plot(plt2)  
title('sum detected events');

plt1=PK1;  %plot indentified events, each column is one cell 
for x=1:Ncell
    plt1(:,x)=plt1(:,x)+x;
end
figure
Plt2=plt1;
plot(Plt2,'b','LineWidth',3)
title('Plt from sum PK1');

plt2=PK2;  %plot indentified events, each column is one cell 
for x=1:Ncell
    plt2(:,x)=plt2(:,x)+x;
end
figure
Plt3=plt2;
plot(Plt3,'b','LineWidth',3)
title('Plt from mean PK2');
%}
%{
Dis=zeros(Ncell, Ncell);
NxtCeldis=85;
for r=1:Ncell           % calculate distance between cells if dis< 85 pixel then flag as neighbor and set to 1
    for c=1:Ncell
        x=Pos(r,1)-Pos(c,1);
        y=Pos(r,2)-Pos(c,2);
        if c~=r
            if sqrt((x*x)+(y*y))<NxtCeldis 
            Dis(r,c)=1;
            end
        end   
    end
end

%disp('for loop 3 done');

NBPK=0;
%skp=100;             %skp is the number of frames to look at the cross correlations (i.e. how many frames to plot after an "event"
NBtrc=zeros(1,skp+1);
Autrc=zeros(1,skp+1);
for x=1:Ncell 
    locs=find(PK((1:Nfrm-skp),x));
    NeBrs=find(Dis(:,x));
    for l=1:length(locs)
        if sum(sum(PK((locs(l):locs(l)+skp),NeBrs)))>0
          NBPK=NBPK+1;      %count if NBPK are active after a cell event
        end
        Autrc=cat(1,Autrc,Sig((locs(l):locs(l)+skp),x)');  %build array of autocorrelation activity of the active cell
        for nb=1:length(NeBrs)
            Sig((locs(l):locs(l)+skp),NeBrs(nb))';
            NBtrc=cat(1,NBtrc,Sig((locs(l):locs(l)+skp),NeBrs(nb))'); %build array of autocorrelation activity of the active cell
        end
    end
end



disp('for loop 4 done');

%{

figure  %plot event triggered average traces of neighbors
plot(NBtrc')
hold on
NBtrc=mean(NBtrc);
plot(NBtrc'*10,'r','LineWidth',3)
title('event triggered average trace of neighbors');

figure   %plot event triggered average traces of that cell
plot(Autrc')
hold on
Autrc=mean(Autrc);
plot(Autrc'*10,'k','LineWidth',3)
title('event triggered average trace of that cell');

figure  % plot together 
plot(NBtrc','r','LineWidth',3)
hold on 
plot(Autrc','k','LineWidth',3)

%}

%figure
%plot(Aucor)
%hold on
%Aucor=mean(Aucor');
%plot(Aucor','k','LineWidth',3)
disp('all figures done');

mnsig=mean(mean(Sig))*10;
totPK=sum(sum(PK((1:Nfrm-skp),:)));
NBPK;
prbNB=NBPK/sum(sum(PK((1:Nfrm-skp),:)));
rate=totPK/(Ncell*(Nfrm-skp));

%output=cat(1,NBtrc,Autrc);
%}
disp('all figures done');
disp ('Pkcorr3 done');
    
