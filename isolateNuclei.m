                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        % Isolate nuclei on the organoid-by-organoid basis

% Ensure output folder exists
if ~exist('Isolated_nuclei', 'dir')
    mkdir('Isolated_nuclei');
end

% Determening paths and setting folders
currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

cd("Cleaned_Masks\");
files=dir("*.tif");
cd(filedir);

for i=1:numel(files)
    % Load cleaned organoid + nuclei masks
    OMask = imread(['Cleaned_masks/O_',num2str(i),'.tif']);
    NMask = imread(['Cleaned_masks/N_',num2str(i),'.tif']);

                                                                                                                                                                                                                
relabeled_nuclei_final = zeros(size(NMask));

% Gets all organoid labels in the mask & removes background (label 0).
organoidIDs = unique(OMask);
organoidIDs(organoidIDs == 0) = [];
 

for j = organoidIDs'
    
    % Finds which nucleus pixels are overlapping the current organoid j
    overlapping_pixels = NMask & (OMask == j);
    % Seperates them into overlapping and non-overlapping
    overlapping_nuclei = NMask .* uint16(overlapping_pixels);
    nonoverlapping_nuclei = NMask .* uint16(~overlapping_pixels);
    
    if any(overlapping_nuclei(:))
        relabeled_nuclei_combined = zeros(size(NMask));
        
        % Loops through overlapping nuclei and removes any remaining junk,
        % relabels and adds to final image
        for label = unique(overlapping_nuclei(:))'
            if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))
                nucleus_thresholded = overlapping_nuclei == label;
                labeled_nucleus = bwlabel(bwareaopen(nucleus_thresholded, 3));
                labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));
                relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;
            end
        end
          % Save each organoid’s nuclei separately
            imwrite(uint16(relabeled_nuclei_combined), ...
                ['Isolated_nuclei/Nuclei_Image', num2str(i), '_Organoid_', num2str(j), '.tif']);
        
    end
end
fprintf('✅ Isolated nuclei for image %d\n', i);
end


  
        
    
   