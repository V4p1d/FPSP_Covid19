% This files generates the heatmaps and the time series for the SIQR_7_14
% it needs /SIQR/SIQR_7_14/Main.m to be run first

% loading the workspace from /SIQR/SIQR_7_14/Main.m
load('workspace_7_14')

%% Heatmap of the peak values

figure(2)
h = heatmap(0:DayStep:MaxDaysOfWork,0:DayStep:MaxDaysOfQuarantine,100*peak'./N);
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak value of the infected population [% of 10 million]')

figure(3)
h = heatmap(0:DayStep:MaxDaysOfWork,0:DayStep:MaxDaysOfQuarantine,peakTime');
ylabel('Quarantine Days [Day]')
xlabel('Work Days [Day]')
title('Peak times')



%% Single time series can be plotted as follows:
figure(4);hold on
plot(Time{2,6},getb(Sol{2,6}')'/N)

