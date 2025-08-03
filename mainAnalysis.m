% Unified Workflow for Image Analysis 


     % ---- Determening paths and setting folders ----

currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

cd("Actin (red)");
files=dir("*.tif");
cd(filedir);

              % ---- MAIN ----

% Initialise a structure to store data
all_data = struct();

% Loop through each Organoid Raw Images and Masks
for i=1:numel(files)
    current_image_id = i;
    Omask = imread(['Organoid_masks/',num2str(i),'_actin_cp_masks.png']);
    Raw_Organoids = imread(['Actin (red)\',num2str(i),'_actin.tif']);

    % Calling the function to clear organoids from the border
    cleaned_Organoid_Mask = removeBorder(Omask);
  
    % Loop through each Nuclei Raw Images and Masks 
    Nmask = imread(['Nuclei_Masks\',num2str(i),'_dapi_cp_masks.png']);
    Raw_Nuclei = imread(['Dapi (blue stains)\',num2str(i),'_dapi.tif']);

    % Calling the function to clear nuclei from the border
    cleaned_Nuclei_Mask = removeBorder(Nmask);
    
    % Isolate nuclei per organoid and extract data from image
    dataRetrieval;

end

% Combines extracted data into two table- Nuclei and Organoid
dataCombining;





















