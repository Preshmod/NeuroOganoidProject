% Main image analysis code

% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

cd("Actin (red)");
files=dir("*.tif");
cd(filedir);

% Loading the Organoid Masks
for i=1:numel(files)
    Omask = imread(['Organoid_masks/',num2str(i),'_actin_cp_masks.png']);
    imshow(imadjust(Omask));
    pause;

    % Loading the Nuclei Masks
    Nmask = imread(['Nuclei_Masks\',num2str(i),'_dapi_cp_masks.png']);
    imshow(imadjust(Nmask));
    pause;

    % Convert to label if the mask is binary
    if islogical(Omask)
        Omask = bwlabel(Omask);
    end
    if islogical(Nmask)
        Nmask = bwlabel(Nmask);
    end
end

for i=1:numel(files)
    Omask = imread(['Organoid_masks/',num2str(i),'_actin_cp_masks.png']);

    % Loading the Nuclei Masks
    Nmask = imread(['Nuclei_Masks\',num2str(i),'_dapi_cp_masks.png']);

    % Calling the function to clear the border
    CleanOM = removeBorder(Omask);
    CleanNM = removeBorder(Nmask);  %add the function within the loop%

    % Saving the new cleaned masks
    imwrite(uint16(CleanOM), ['Cleaned_masks/O_', num2str(i), '.tif']);
    imwrite(uint16(CleanNM), ['Cleaned_masks/N_', num2str(i), '.tif']);
end



















