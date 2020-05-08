% This files generates the heatmaps and the time series for the SIQR_1_14
% it needs /SIQR/SIQR_1_14/Main.m to be run first

% loading the workspace from /SIQR/SIQR_1_14/Main.m
load('workspace_1_14')


%% Generating the heatmap of the peak values

figure(2)
h = heatmap(0:DayStep:MaxDaysOfQuarantine,0:DayStep:MaxDaysOfWork,100*peak./N);
xlabel('Quarantine Days [Day]')
ylabel('Work Days [Day]')
title('Peak value of the infected population [% of 10 million]')

figure(3)
h = heatmap(0:DayStep:MaxDaysOfQuarantine,0:DayStep:MaxDaysOfWork,peakTime);
xlabel('Quarantine Days [Day]')
ylabel('Work Days [Day]')
title('Peak times')
 

%% Single time series can be plotted as follows:
figure(4);hold on
plot(Time{2,6},getb(Sol{2,6}')'/N)

