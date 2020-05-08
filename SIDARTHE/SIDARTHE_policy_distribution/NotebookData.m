% This file generates the workspace files "figure_2_top_peaks.mat" 
% and "figure_2_top_timeseries.mat" used in the folder "/notebooks" 

% This file needs "/SIDARTHE/SIDARTHE_policy_distribution/Main.m" to be
% executed before

save('figure_2_top_peaks.mat','peak','peakTime','MaxDaysOfQuarantine','MaxDaysOfWork',...
    'Interval_i1','Interval_i2','Interval_T1','Interval_T2','DayStep');

selectedSolutions = [[1 13];[2 12];[3 11];[4 10];[5 9];[6 8];[2 26];[4 24];[6 22];[8 20];...
          [10 18];[12 16];[4 52];[8 48];[12 44];[16 40];[20 36];[24 32];[6 78];...
          [12 72];[18 66];[24 60];[30 54];[36 48];[8 104];[16 96];[24 88];[32 80];...
          [40 72];[48 64]];
      
TimeSeries = cell(size(selectedSolutions,1),4);      
for p=1:size(selectedSolutions,1)
    i = selectedSolutions(p,1);
    j = selectedSolutions(p,2);
    TimeSeries{p,1} = i;
    TimeSeries{p,2} = j;
    TimeSeries{p,3} = Time{i+1,j+1}(1:100:end,:);
    TimeSeries{p,4} = Sol{i+1,j+1}(1:100:end,:);
end

save('figure_2_top_timeseries.mat','selectedSolutions','TimeSeries')