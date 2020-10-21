% This file generates images using data from both /SIQR/SIQR_1_14 
% and /SIQR/SIQR_7_14.
% Therefore, /SIQR/SIQR_1_14/Main.m and /SIQR/SIQR_7_14/Main.m must be run
% first

clear all 

% load 7_14 workspace
load '../SIQR_7_14/workspace_7_14'

Time_7 = Time;
Sol_7 = Sol;
Interval_i1_7 = Interval_i1;
Interval_i2_7 = Interval_i2;

DayStep_7 = DayStep;
MaxDaysOfQuarantine_7 = MaxDaysOfQuarantine;
MaxDaysOfWork_7 = MaxDaysOfWork;

 

% load 1_14 workspace
load '../SIQR_1_14/workspace_1_14'

Time_1 = Time;
Sol_1 = Sol;
Interval_i1_1 = Interval_i1;
Interval_i2_1 = Interval_i2;

DayStep_1 = DayStep;
MaxDaysOfQuarantine_1 = MaxDaysOfQuarantine;
MaxDaysOfWork_1 = MaxDaysOfWork;


% i1 = days on
% i2 = daysoff

%% HeatMaps of 7_14

% This piece of code is needed to find the peak values and times
% after the  FPSP policy is enforced.
 
peak_7 = zeros(length(Interval_i1_7),length(Interval_i2_7));
peakTime_7 = zeros(length(Interval_i1_7),length(Interval_i2_7)); 
for i = Interval_i1_7
    for j = Interval_i2_7
        if i ==1 && j ==1
            continue
        end 
        k = min(find(Time_7{i,j}>Trigger1+Trigger2)); 
        [p,idp] = max(getI(Sol_7{i,j}(k:end,:)'+getQ(Sol_7{i,j}(k:end,:)')));
        peak_7(i,j) = p;
        peakTime_7(i,j) =Time_7{i,j}(k+min(idp));
         
    end
end

peak_7(1,1)=NaN;
peakTime_7(1,1)=NaN; 

  
% plot of the heatmaps
figure(72)
h = heatmap(0:DayStep_7:MaxDaysOfWork_7,0:DayStep_7:MaxDaysOfQuarantine_7,100*peak_7'./N);
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak value of the infected population I+Q [% of 10 million]')

figure(73)
h = heatmap(0:DayStep_7:MaxDaysOfWork_7,0:DayStep_7:MaxDaysOfQuarantine_7,peakTime_7');
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak times')


%% HeatMaps of 7_14

% This piece of code is needed to find the peak values and times
% after the  FPSP policy is enforced.

peak_1 = zeros(length(Interval_i1_1),length(Interval_i2_1));
peakTime_1 = zeros(length(Interval_i1_1),length(Interval_i2_1)); 
for i = Interval_i1_1
    for j = Interval_i2_1
        if i ==1 && j ==1
            continue
        end 
        k = min(find(Time_1{i,j}>Trigger1+Trigger2)); 
        [p,idp] = max(getI(Sol_1{i,j}(k:end,:)'+getQ(Sol_1{i,j}(k:end,:)')));
        peak_1(i,j) = p;
        peakTime_1(i,j) =Time_1{i,j}(k+min(idp));
         
    end
end

peak_1(1,1)=NaN;
peakTime_1(1,1)=NaN; 

  
% plot of the heatmaps
figure(12)
h = heatmap(0:DayStep_1:MaxDaysOfWork_1,0:DayStep_1:MaxDaysOfQuarantine_1,100*peak_1'./N);
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak value of the infected population I+Q [% of 10 million]')

figure(13)
h = heatmap(0:DayStep_1:MaxDaysOfWork_1,0:DayStep_1:MaxDaysOfQuarantine_1,peakTime_1');
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak times')



%% Plot time series corresponding to FPSP (1,6) and (14,49)

i_1 = 2; %1 day work
j_1 = 7; %6 days quarantine

i_7 = 3; %14 day work
j_7 = 8; %49 days quarantine
 
figure(101)
grid
hold on
plot(Time_1{i_1,j_1},100/N*(getI(Sol_1{i_1,j_1}')+getQ(Sol_1{i_1,j_1}'))','LineWidth',3)
hold on
plot(Time_7{i_7,j_7},100/N*(getI(Sol_7{i_7,j_7}')+getQ(Sol_7{i_7,j_7}'))','LineWidth',3) 
 ylim([0 .5])
xlim([0 550])
y1=get(gca,'ylim');
plot([Trigger1 Trigger1],y1, 'r',  'linewidth', 2, 'linestyle', '--')
plot([Trigger1+Trigger2 Trigger1+Trigger2],y1, 'b',  'linewidth', 2, 'linestyle', '--')

legend('(X,Y)=(' +  string((i_1-1)*DayStep_1)+ ',' + string((j_1-1)*DayStep_1) + ') FPSP Policy', ...
    '(X,Y)=(' +  string((i_7-1)*DayStep_7)+ ',' + string((j_7-1)*DayStep_7) + ') FPSP Policy')
xlabel('Days [Day]')
ylabel('Total Infected People I+Q [% of 10 million]')



%% Plot time series corresponding to FPSP (1,6) and (1,3)

i_1 = 2; %1 day work
j_1 = 7; %6 days quarantine

i_12 = 2; %1 day work
j_12 = 4; %3 days quarantine
 
figure(101)
grid
hold on
plot(Time_1{i_1,j_1},100/N*(getI(Sol_1{i_1,j_1}')+getQ(Sol_1{i_1,j_1}'))','LineWidth',3)
hold on
plot(Time_1{i_12,j_12},100/N*(getI(Sol_1{i_12,j_12}')+getQ(Sol_1{i_12,j_12}'))','LineWidth',3) 
 ylim([0 .15])
 xlim([0 800])
y1=get(gca,'ylim');
plot([Trigger1 Trigger1],y1, 'r',  'linewidth', 2, 'linestyle', '--')
plot([Trigger1+Trigger2 Trigger1+Trigger2],y1, 'b',  'linewidth', 2, 'linestyle', '--')

legend('(X,Y)=(' +  string((i_1-1)*DayStep_1)+ ',' + string((j_1-1)*DayStep_1) + ') FPSP Policy', ...
    '(X,Y)=(' +  string((i_12-1)*DayStep_1)+ ',' + string((j_12-1)*DayStep_1) + ') FPSP Policy')
xlabel('Days [Day]')
ylabel('Total Infected People I+Q [% of 10 million]')




%% Plot time series corresponding to FPSP (2,5) and (14,35)

i_1 = 3; %2 days work
j_1 = 6; %5 days quarantine

i_7 = 3; %14 day work
j_7 = 6; %35 days quarantine
 
figure(101)
grid
hold on
plot(Time_1{i_1,j_1},100/N*(getI(Sol_1{i_1,j_1}')+getQ(Sol_1{i_1,j_1}'))','LineWidth',3)
hold on
plot(Time_7{i_7,j_7},100/N*(getI(Sol_7{i_7,j_7}')+getQ(Sol_7{i_7,j_7}'))','LineWidth',3) 
%  ylim([0 1])
xlim([0 1000])
y1=get(gca,'ylim');
plot([Trigger1 Trigger1],y1, 'r',  'linewidth', 2, 'linestyle', '--')
plot([Trigger1+Trigger2 Trigger1+Trigger2],y1, 'b',  'linewidth', 2, 'linestyle', '--')

legend('(X,Y)=(' +  string((i_1-1)*DayStep_1)+ ',' + string((j_1-1)*DayStep_1) + ') FPSP Policy', ...
    '(X,Y)=(' +  string((i_7-1)*DayStep_7)+ ',' + string((j_7-1)*DayStep_7) + ') FPSP Policy')
xlabel('Days [Day]')
ylabel('Total Infected People I+Q [% of 10 million]')



%% Plot of the graph comparing peak values and peak times for different periods and duty cycles

D = [.25 .3;.3 .35;.35 .4];     %duty cycle ranges


Period_Peak_1 = {[],[],[],[]}; 
Period_Peak_7 = {[],[],[],[]}; 


% i1 = days on
% i2 = daysoff
for i=Interval_i1_1
    for j=Interval_i2_1
        
        if i==1 && j==1
            continue;
        end

        DC = (i-1)/(i+j-2);
        
        Period = (i+j-2)*DayStep_1;
        Peak =  (100/N)*peak_1(i,j);
        PTime= peakTime_1(i,j);
        
        for k=1:size(D,1) 
           
            if DC>= D(k,1) && DC<D(k,2)               
                Period_Peak_1{k}=[Period_Peak_1{k};[Period Peak PTime]]; 
                break;
            end
            
        end
        
    end
end



% i1 = days on
% i2 = daysoff
for i=Interval_i1_7
    for j=Interval_i2_7
        
        if i==1 && j==1
            continue;
        end

        DC = (i-1)/(i+j-2);
        
        Period = (i+j-2)*DayStep_7;
        Peak =  (100/N)*peak_7(i,j);
        PTime= peakTime_7(i,j);
        
        for k=1:size(D,1) 
           
            if DC>= D(k,1) && DC<D(k,2)                
                Period_Peak_7{k}=[Period_Peak_7{k};[Period Peak PTime]]; 
                break;
            end
            
        end
        
    end
end


% preparing legends
leg = cell(length(D),1);
legT = cell(length(D),1);

%plotting only a s
for DCn = 1:length(D) 

    Periods_0 = [Period_Peak_1{DCn}(:,1);Period_Peak_7{DCn}(:,1)];
    Peaks_0 = [Period_Peak_1{DCn}(:,2);Period_Peak_7{DCn}(:,2)];
    PeakTimes_0 = [Period_Peak_1{DCn}(:,3);Period_Peak_7{DCn}(:,3)];

    [Periods,Idx] = sort(Periods_0);
    Peaks =Peaks_0(Idx);
    PeakTimes =PeakTimes_0(Idx);

    no_idx = PeakTimes<55;  %filtering stable policies
    Periods_T = Periods;
    Periods_T(no_idx)=[];
    PeakTimes(no_idx)=[];

    figure(200);
    hold on;
    plot(Periods,Peaks,'linewidth',2);

    figure(300);
    hold on;
    plot(Periods_T,PeakTimes,'linewidth',2);

    leg{DCn}='Duty cycle between '+string(100*D(DCn,1))+'% and '+string(100*D(DCn,2))+'%';
    legT{DCn}='Duty cycle between '+string(100*D(DCn,1))+'% and '+string(100*D(DCn,2))+'%';
end
 

figure(200); legend(leg); grid on;
xlim([0,160])
title('Peak of I+Q for different periods and duty cycles');
xlabel('FPSP Period [Day]')
ylabel('Total Infected People I+Q [% of 10 million]')


figure(300); legend(legT); grid on;
xlim([0,160])
title('Peak times of I+Q for different periods and duty cycles');
xlabel('FPSP Period [Day]')
ylabel('Peak times [Day]')

