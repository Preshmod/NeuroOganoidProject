% ---- Retrieve and store data from organoid-nuclei objects ----



%             ---- 1. Isolate nuclei per organoid ----

% Gets all organoid labels in the mask & remove background (label 0).
organoidIDs = unique(cleaned_Organoid_Mask);
organoidIDs(organoidIDs == 0) = [];

% Define current image ID and filename
ImageID = i;
filename = ['Image_' num2str(i)];

% Tracks current index in nuclei_data
counter = 1;     

% Tracks unique ID across nuclei 
nuc_id_counter = 1;    

% Preallocate struct array for nuclei data (overestimate size)
nuclei_data(length(organoidIDs)*20) = struct(...   
    'ImageID', [], 'NucleusID', [], 'OrganoidID', [], ...
    'Area', [], 'Eccentricity', [], 'Circularity', [], ...
    'Solidity', [], 'CentroidX', [], 'CentroidY', [], ...
    'MeanIntensity', []);


% Loop through each organoid to isolate and process its associated nuclei
for j = organoidIDs'
    
  
    % Finds which nucleus pixels are overlapping the current organoid j
    overlapping_pixels = cleaned_Nuclei_Mask & (cleaned_Organoid_Mask == j);

    % Extracts the overlapping nuclei within the organoid
    overlapping_nuclei = cleaned_Nuclei_Mask .* uint16(overlapping_pixels);

    % Extracts the rest of the nuclei outside of the organoid
    nonoverlapping_nuclei = cleaned_Nuclei_Mask .* uint16(~overlapping_pixels);
    
    % This occurs if there is any overlapping nucleus
    if any(overlapping_nuclei(:))

        % Temporary mask to add relabeled overlapping nuclei for organoid
        relabeled_nuclei_combined = zeros(size(cleaned_Nuclei_Mask));
        
        % Loop through each unique overlapping nucleus label
        for label = unique(overlapping_nuclei(:))'

            % Skip background and skip if this nucleus also exists outside the organoid
            if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))

                % Create a binary mask for the current nucleus
                nucleus_thresholded = overlapping_nuclei == label;

                % Remove small objects (noise) and label connected components
                labeled_nucleus = bwlabel(bwareaopen(nucleus_thresholded, 3));

                % Offset labels to avoid overwriting previously labeled nuclei
                labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));

                % Add the current labeled nucleus to the combined image
                relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;
            end
        end
        
    end

          % ---- 2. Data Extraction From Organoid and Nuclei ----


% Calculate region properties for the labeled nuclei
nuclei_props = regionprops('table', relabeled_nuclei_combined, Raw_Nuclei,'Area', 'Perimeter', 'Eccentricity', 'Solidity', 'Centroid', 'MeanIntensity');

if ~isempty(nuclei_props)

    % Compute Circularity manually
    perim = nuclei_props.Perimeter;
    area = nuclei_props.Area;
    circ = (4 * pi * area) ./ (perim.^2);

        for k = 1:height(nuclei_props)
            nuclei_data(counter).ImageID = ImageID;
            nuclei_data(counter).NucleusID = nuc_id_counter;
            nuclei_data(counter).OrganoidID = j;
            nuclei_data(counter).Area = area(k);
            nuclei_data(counter).Eccentricity = nuclei_props.Eccentricity(k);
            nuclei_data(counter).Circularity = circ(k);
            nuclei_data(counter).Solidity = nuclei_props.Solidity(k);
            nuclei_data(counter).CentroidX = nuclei_props.Centroid(k,1);
            nuclei_data(counter).CentroidY = nuclei_props.Centroid(k,2);
            nuclei_data(counter).MeanIntensity = nuclei_props.MeanIntensity(k);
            counter = counter + 1;
            nuc_id_counter = nuc_id_counter + 1;
        end
end

end

% Trim unused preallocated space (if any)
nuclei_data = nuclei_data(1:counter-1);

% Convert struct to table before saving
nuclei_table = struct2table(nuclei_data);

% Calculate region properties for the entire organoid 
organoid_props = regionprops('table', cleaned_Organoid_Mask, Raw_Organoids,'Area', 'Perimeter', 'Eccentricity', 'Solidity', 'Centroid', 'MeanIntensity');

% Add OrganoidID and ImageID
organoid_props.OrganoidID = organoidIDs;
organoid_props.ImageID = repmat(current_image_id, height(organoid_props), 1); 

% Split Centroid into X and Y columns if needed
organoid_props.CentroidX = organoid_props.Centroid(:, 1);
organoid_props.CentroidY = organoid_props.Centroid(:, 2);
organoid_props.Centroid = [];  % optional: drop original Centroid column

% Reorder columns to have ImageID and OrganoidID at the start
organoid_props = organoid_props(:, [ ...
    find(strcmp('ImageID', organoid_props.Properties.VariableNames)), ...
    find(strcmp('OrganoidID', organoid_props.Properties.VariableNames)), ...
    setdiff(1:width(organoid_props), [ ...
        find(strcmp('ImageID', organoid_props.Properties.VariableNames)), ...
        find(strcmp('OrganoidID', organoid_props.Properties.VariableNames))]) ...
]);


% Store the region properties for the entire organoid mask under the file name field
all_data.(filename).organoid_props = organoid_props;

% Store the region properties cell array in the structure under the file name field
all_data.(filename).nuclei_props = nuclei_table;




   
 
