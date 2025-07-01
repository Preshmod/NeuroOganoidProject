% Function that extracts individual nuclei then divides into 3 classes

function nucleiExtraction(Nuclei_images, Nuclei_mask, nucleus_type)


% ---- Step 1: User selects nuclei ----

    % Display the image and allow the user to manually select nuclei
    figure;
    imshow(Nuclei_images);
    hold on;
    title(sprintf('Click on %s nuclei, then press Enter.', nucleus_type), 'FontSize', 15);
    
 
    % Get points selected by the user
    %[~, x, y] = impixel();  % Click-based selection
    [x, y] = ginput();
    coordinates = [x(:), y(:)];
    save(sprintf('coords_%s.mat', nucleus_type), 'coordinates');
    close; 

% ---- Step 2: Get nucleus indices for each click ----

    % Initialise an array to store the indices of selected nuclei
    selected_nuclei_indices = [];
   
    % Loop through the clicked points and determine the corresponding nuclei
    for j = 1:numel(x)

        clicked_point = [x(j), y(j)];

        % Get nucleus index for the point
        nucleus_idx = Nuclei_mask(round(clicked_point(2)), round(clicked_point(1)));
        
        % Check it is not background
        if nucleus_idx > 0
            selected_nuclei_indices = [selected_nuclei_indices; nucleus_idx];
        end

    end

% ---- Step 3: Setup output folders ----

    % Create the parent folder to save the nuclei images if it doesn't exist
    parent_folder = 'Training_Dataset';
    if ~exist(parent_folder, 'dir')
        mkdir(parent_folder);
    end
    
    % Determine the subfolder based on the nucleus type
    switch nucleus_type
        case 'dividing'
            subfolder = fullfile(parent_folder, 'dividing_nuclei');
            prefix = 'dividing_nucleus';

        case 'interphase'
            subfolder = fullfile(parent_folder, 'interphase_nuclei');
            prefix = 'interphase_nucleus';

        case 'miscellaneous'
            subfolder = fullfile(parent_folder, 'miscellaneous');
            prefix = 'miscellaneous';

    end
    
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end

% ---- Step 4: Process and save each nucleus ----
    
    % Initialise structure to store all regionprops data
    fullFeatureTable = table();

    % Get current timestamp
    timestamp = datestr(now, 'ddmmyyyyTHHMMSSFFF');
    
    % Save each selected nucleus as a separate image
    for j = 1:numel(selected_nuclei_indices)

        % Get the mask for the current nucleus
        nucleus_mask = Nuclei_mask == selected_nuclei_indices(j);
        
        % Create a bounding box around the nucleus
        props = regionprops(nucleus_mask, 'BoundingBox');
        boundingBox = props.BoundingBox;
    
        % Crop the current image around the bounding box
        cropped_image = imcrop(Nuclei_images, boundingBox);
        cropped_mask = imcrop(nucleus_mask, boundingBox);
    
        % Apply the mask to retain only the nucleus
        masked_image = cropped_image .* uint8(cropped_mask);
    
        % Resize the masked image to 22x22 pixels
        %resized_image = imresize(masked_image, [22 22]);
        
        % Create the filename for the nucleus image
        nucleus_filename = fullfile(subfolder, sprintf('%s_%s_%d.png', prefix, timestamp, j));
        
        % Save the masked image
        imwrite(masked_image, nucleus_filename);

        % Extract regionprops features
        props = regionprops(nucleus_mask, Nuclei_images, ...
            'Area', 'Perimeter', 'Eccentricity', 'MeanIntensity', ...
            'Solidity', 'Extent', 'MajorAxisLength', 'MinorAxisLength', 'Orientation','ConvexArea','EquivDiameter',...
          'PixelValues','MaxIntensity','MinIntensity');
        if isempty(props)
            warning('Regionprops failed for nucleus %d', idx);
            continue;
        end
        for i = 1:length(props)
            pixVals = double(props(i).PixelValues);
            props(i).IntensitySTD = std(pixVals);
            props(i).IntensitySkew = skewness(pixVals);
            props(i).IntensityMean = mean(pixVals);
        end

        
        propTable = struct2table(props, 'AsArray', true);
        propTable.PixelValues = []; 
        propTable.ImageName = {timestamp};
        propTable.Class = {nucleus_type};

        fullFeatureTable = [fullFeatureTable; propTable];   
    end 

     % Save feature table
    
     feature_filename = fullfile(subfolder, sprintf('%s_features.csv', prefix));

     if isfile(feature_filename)
         % Read the existing table
         existingTable = readtable(feature_filename);

         % Append new data
         updatedTable = [existingTable; fullFeatureTable];

         % Overwrite with the combined table
         writetable(updatedTable, feature_filename);
     else
         % First time writing — just save directly
         writetable(fullFeatureTable, feature_filename);
     end
     
end

