This folder contains the code used for simulating the COVID-19 disease spreading using the SIQR model.

The solver is based on the hybrid equation toolbox:
https://it.mathworks.com/matlabcentral/fileexchange/41372-hybrid-equations-toolbox-v2-04.

Folder ./SIQR_1_14 contains the files to simulate the SIQR model for FPSP policies from X=1 working days and Y=1 quarantine days to X=14 working days and Y=14 quarantine days with increments of 1 day.
The main file to execute is "./SIQR_1_14/Main.m". 
Images are generated by "./SIQR_1_14/ImageGeneration_SIQR_1_14.m" and by "./SIQR_mixed/ImageGenerationMixed.m" (see below) after running the main file.

Folder ./SIQR_7_14 contains the files to simulate the SIQR model for FPSP policies from X=1 working days and Y=1 quarantine days to X=98 working days and Y=98 quarantine days with increments of 7 days.
The main file to execute is "./SIQR_7_14/Main.m". 
Images are generated by "./SIQR_7_14/ImageGeneration_SIQR_7_14.m" and by "./SIQR_mixed/ImageGenerationMixed.m" (see below) after running the main file.

Folder "./SIQR_mixed" contains the file "ImageGenerationMixed.m" which is used to create joint images using data both of SIQR_1_14 and SIQR_7_14. It requires both "./SIQR_1_14/Main.m" and "./SIQR_7_14/Main.m" to be ran first.


