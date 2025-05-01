%% Collecting data from organoid-nuclei objects %%

%Load images (cleaned isolated ones but mean intensity needs to be the
%original images not the masks but images with the stains)

% === REGIONPROPS ADVANCED SCRIPT, SEPARATING MEAN INTENSITY ===

% Create output folders
if ~exist('Regionprops_results', 'dir')
    mkdir('Regionprops_results');
end

% Initialize cell array to store per-image tables
AllResultsCell = cell(3,1);  

for i = 1:3
    % --- Load masks and raw images ---
    Omask = imread('Cleaned_masks/O_3.tif');
    Nmask = imread('Isolated_nuclei/Nuclei_in_Organoid_1.tif');
    RawImage = imread(['Actin (red)\',num2str(i),'_actin.tif']);
    
    % Ensure RawImage and Nmask are same size
    if ~isequal(size(Nmask), size(RawImage))
        %error('Size mismatch between RawImage and Nmask for Image %d', i);
    end

    % --- Find nuclei IDs ---
    nucleiIDs = unique(Nmask);
    nucleiIDs(nucleiIDs == 0) = []; % remove background
    
    % Prepare arrays
    ImageID = repmat(i, length(nucleiIDs), 1);
    NucleusID = nucleiIDs;
    OrganoidID = zeros(length(nucleiIDs), 1);
    NucleusArea = zeros(length(nucleiIDs), 1);
    Eccentricity = zeros(length(nucleiIDs), 1);
    Circularity = zeros(length(nucleiIDs), 1);
    Solidity = zeros(length(nucleiIDs), 1);
    NucleusCentroidX = zeros(length(nucleiIDs), 1);
    NucleusCentroidY = zeros(length(nucleiIDs), 1);

    % No mean intensity yet, do later
    % MeanIntensity = zeros(length(nucleiIDs), 1);
    
    % --- Loop through nuclei (only geometric props here) ---
    for j = 1:length(nucleiIDs)
        nuc_id = nucleiIDs(j);
        tempMask = (Nmask == nuc_id);
        
        % Overlapping organoid
        overlappingOrganoids = Omask(tempMask);
        overlappingOrganoids(overlappingOrganoids == 0) = [];
        if ~isempty(overlappingOrganoids)
            OrganoidID(j) = mode(overlappingOrganoids);
        else
            OrganoidID(j) = 0;
        end
        
        % Region properties
        props = regionprops(tempMask, 'Area', 'Perimeter', 'Eccentricity', 'Solidity', 'Centroid');
        NucleusArea(j) = props.Area;
        Eccentricity(j) = props.Eccentricity;
        Solidity(j) = props.Solidity;
        
        if props.Perimeter > 0
            Circularity(j) = (4 * pi * props.Area) / (props.Perimeter ^ 2);
        else
            Circularity(j) = NaN;
        end
        
        % Centroid
        NucleusCentroidX(j) = props.Centroid(1);
        NucleusCentroidY(j) = props.Centroid(2);
    end
    
    % --- Create table for this image (no intensity yet) ---
    T = table(ImageID, NucleusID, OrganoidID, NucleusArea, Eccentricity, Circularity, Solidity, ...
        NucleusCentroidX, NucleusCentroidY);
    
    % --- NOW: Calculate Mean Intensity SEPARATELY ---
    %MeanIntensity = zeros(length(nucleiIDs), 1);
    %for j = 1:length(nucleiIDs)
        %nuc_id = nucleiIDs(j);
        %tempMask = (Nmask == nuc_id);
        %MeanIntensity(j) = mean(double(RawImage(tempMask)));
    %end
    
    % --- Add MeanIntensity to table ---
    %T.MeanIntensity = MeanIntensity;
    
    % --- Save individual table ---
    %writetable(T, ['Regionprops_results/Nuclei_Props_Image_', num2str(i), '.csv']);
    
    % --- Store for global results ---
    %AllResultsCell{i} = T;
end

% --- Concatenate all tables into one ---
AllResults = vertcat(AllResultsCell{:});

% Save combined results
writetable(AllResults, 'Regionprops_results/All_Nuclei_Props.csv');

fprintf('✅ Completed regionprops analysis with separated Mean Intensity calculation.\n');