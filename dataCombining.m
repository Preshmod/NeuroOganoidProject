% ---- Combining the extracted data into tables ----

% Get all the field names from the all_data structure (each field corresponds to an image)
fields = fieldnames(all_data);

% Initialize empty tables to hold combined data across all images
Nuclei_Table = table();    % stores nuclei data

Organoid_Table = table();  % stores organoid data


% Loop through each image (field) in the all_data structure
for i = 1:numel(fields)

    
    % Access the nuclei properties for the current image
    nuclei_props = all_data.(fields{i}).nuclei_props;

    % If the data is still in struct format, convert it to a table
    if isstruct(nuclei_props)
        nuclei_props = struct2table(nuclei_props);
    end

    % Append to final Nuclei_Table 
    if ~isempty(nuclei_props)
        Nuclei_Table = [Nuclei_Table; nuclei_props];
    end

    % Access the nuclei properties for the current image
    organoid_props = all_data.(fields{i}).organoid_props;
    
    % Append to final Organoid_Table
    if ~isempty(organoid_props)
        Organoid_Table = [Organoid_Table; organoid_props];
    end

end

% ---- Save tables ----
writetable(Nuclei_Table, 'Regionprops_results/Nuclei_Table.csv');
writetable(Organoid_Table, 'Regionprops_results/Organoid_Table.csv');
