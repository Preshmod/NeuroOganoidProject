% Extraction of different nuclei classes 


 % ---- Determening paths and setting folders ----

currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

cd("Dapi (blue stains)\");
files=dir("*.tif");
cd(filedir);

% ---- Loading Dapi Images and Nuclei Masks ---

% Loop through each file in the directory
for i = 1:numel(files)

    % Loop through each Nuclei Raw Images and Masks 
    Nuclei_mask = imread(['Nuclei_Masks\',num2str(i),'_dapi_cp_masks.png']);
    
    % Calling the function to clear nuclei from the border
    Nuclei_mask = removeBorder(Nuclei_mask);
    
    % Read the corresponding original image
    Nuclei_images = imread(['Dapi (blue stains)\',num2str(i),'_dapi.tif']);

    
% ---- Calling function to extract nuclei classes for each images ----

    % Extract and save dividing nuclei
    nucleiExtraction(Nuclei_images, Nuclei_mask, 'dividing');
    
    % Extract and save interphase nuclei
    nucleiExtraction(Nuclei_images, Nuclei_mask, 'interphase');
    
    % Extract and save miscellaneous nuclei
    nucleiExtraction(Nuclei_images, Nuclei_mask, 'miscellaneous');
         
end