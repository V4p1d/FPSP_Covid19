Simulations for the FPSP paper.
These simulations were performed using Matlab 2017b, 2019a, 2019b and 2020a.
The libraries needed to simulate this code can be found at https://it.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-04.
If you want to modify the code, a quick tutorial on the hybrid solver for switched systems can be found at https://www.mathworks.com/videos/hyeq-a-toolbox-for-simulation-of-hybrid-dynamical-systems-81992.html



The models used in these simulations refer to the spread of the Covid19 and were both validated using the data from the Italian outbreak https://github.com/pcm-dpc/COVID-19.

A description of the SIDARTHE can be found at https://www.nature.com/articles/s41591-020-0883-7.
A description of the SIQR can be found at https://www.researchgate.net/publication/339915690_Quantifying_undetected_COVID-19_cases_and_effects_of_containment_measures_in_Italy_Predicting_phase_2_dynamics.


The folders are organised as follows: 

- SIDARTHE\SIDARTHE_Heatmap contains the files needed to generate Figures 5 and 7. Execute the Main file;
- SIDARTHE\SIDARTHE_policy_distribution contains the files needed to generate Figure 2 (lower panels). Execute the main file and then execute peakDistributionImage.m in 
SIDARTHE\SIDARTHE_policy_distribution\ImageCreation;
- SIDARTHE\SIDARTHE_OuterLoop contains the files needed to generate Figures 3. Execute the Main file;