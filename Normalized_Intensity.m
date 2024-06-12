%file to create normalized intensity over time

clear; clc;
name = 'ARL Near and Far Analysis\Human Primary\Human Primary AVI\Run 2\Human Primary 20nM Far Late';
intfilename = [name 'int.xlsx'];
[intensity,txt,raw] = xlsread(intfilename) ;

Sig = intensity;
Normalsig = Sig;

Ncell=length(Sig(1,:));
Nfrm=length(Sig(:,1));

for x=1:Ncell   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(Sig(:,x));
    Sig(:,x)=(Sig(:,x)-m)/m;
end

figure
plot(Sig)
hold on
plot(mean(Sig,2),'k','LineWidth',3)
title('Intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 
xlim([0 Nfrm])

figure
plot(mean(Sig,2))
title('mean intensity over time')
xlabel('Frames') 
ylabel('Intensity (F/Fo)') 
xlim([0 Nfrm])

for x=1:Nfrm   % normalize signals to delta F/Fo, Fo is the minium value for that cell
    m=min(Normalsig(x,:));
    Normalsig(x,:)=(Normalsig(x,:)-m)/m;
end

figure
plot(Normalsig)
hold on
plot(mean(Normalsig,2),'k','LineWidth',3)
title('Normalized Intenisty over time')
xlabel('Frames') 
ylabel('Intensity ((F/Fo - min)/min)') 
xlim([0 Nfrm])

figure
plot(mean(Normalsig,2))
title('Normalized mean intensity over time')
xlabel('Frames') 
ylabel('Normalized Intensity ((F/Fo - min)/min)') 
xlim([0 Nfrm])

%{
rng=max(max(Normalsig));  %generate heatmap of cell activity, each row is activity of one cell
HeatMap(Normalsig','colormap',jet(1000),'DisplayRange',rng,'Symmetric',false) %1000

PK=zeros(Nfrm,Ncell);
%Npt=40; %500
Npt = 15;
Aucor=zeros(Npt+1,Ncell);
for x=1:Ncell               % find peaks in each trace and setup locations to 1 in PK
    [pks,locs]=findpeaks(Normalsig(:,x),'MinPeakProminence',0.4); %1, set lower for more events
    PK(locs,x)=1;
    if sum(PK(:,x)) > 10 %if excessive events are detected in one cell, the cell is considered null.
       PK(:,x)= 0;
    end
    Aucor(:,x)=autocorr(Normalsig(:,x),Npt);
   
end

PK1=sum(PK,1);
PK1 = PK1';

disp('for loop 2 done');

plt=PK;  %plot indentified events, each column is one cell 
for x=1:Ncell
    plt(:,x)=plt(:,x)+x;
end

figure
plot(plt)
title('Detected Events')
xlabel('Frames') 
ylabel('Cells') 
%}
