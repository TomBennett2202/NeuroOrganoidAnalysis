addpath('~/Downloads/bfmatlab/');


% % % % % % % % % Import files


% Organoid mask files
organoid_directory = '/Users/tombennett/Desktop/organoid_training';
organoid_mask_files = dir(fullfile(organoid_directory, '*.png'));

% Nuclei mask files
nuclei_directory = '/Users/tombennett/Desktop/Nuclei_training';
nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));

% Original image files
organoid_image_files = dir(fullfile(organoid_directory, '*.jpg'));


% Initialize a structure to store region properties for each file
all_regionprops = struct();

% Loop through each file in the directory
for i = 1:numel(organoid_mask_files)
    % Check if the current item is a file (not a directory)
    if ~organoid_mask_files(i).isdir
        % Get the file name without extension
        [~, filename, ~] = fileparts(organoid_mask_files(i).name);
        
        % Read the organoid mask image
        organoid_mask = imread(fullfile(organoid_directory, organoid_mask_files(i).name));
        
        % Read the corresponding nuclei mask image
        nuclei_mask = imread(fullfile(nuclei_directory, organoid_mask_files(i).name));

        % Read the corresponding original image
        current_image = imread(fullfile(organoid_directory, organoid_image_files(i).name));

        % Store the region properties for the entire organoid mask under the file name field
        all_regionprops.(filename).image = current_image;
        
        % Extract the number of organoids
        numOrganoids = max(organoid_mask(:));

        % Initialize a cell array to store region properties for each organoid in this file
        regionprops_cell = cell(1, 0);
        
        % Initialize a counter for labeling organoids
        organoid_counter = 0;

        % Initialize a new mask to accumulate all organoids
        new_organoid_mask = zeros(size(organoid_mask));

        % Loop through each organoid
        for j = 1:numOrganoids
        
            % Remove objects touching the border
            cleared_current_organoid_mask = imclearborder(organoid_mask == j);
        
            if ~all(cleared_current_organoid_mask(:) == 0) 
                organoid_counter = organoid_counter + 1;
                
                % Relabel the current organoid mask
                relabeled_organoid_mask = bwlabel(cleared_current_organoid_mask);
                
                % Update the new mask with the relabeled organoid
                new_organoid_mask(relabeled_organoid_mask > 0) = organoid_counter;

                % Check for overlap between the current organoid mask and nuclei
                overlapping_pixels = nuclei_mask & cleared_current_organoid_mask;
       
                overlapping_nuclei = uint16(nuclei_mask) .* uint16(overlapping_pixels);
        
                nonoverlapping_nuclei = nuclei_mask .* uint16(imcomplement(overlapping_pixels));
        
                % If there are overlapping pixels, calculate region properties
                if any(overlapping_pixels(:))
                    nucleus_intensities = [];
                    relabeled_nuclei_combined = zeros(size(nuclei_mask));
                    for label = unique(overlapping_nuclei(:))'
                        if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))
                            % Threshold the nucleus individually
                            nucleus_thresholded = overlapping_nuclei == label;

                            % Remove small objects (less than 3 pixels)
                            nucleus_thresholded = bwareaopen(nucleus_thresholded, 3);
                            
                            % Label the thresholded nucleus
                            labeled_nucleus = bwlabel(nucleus_thresholded);
                    
                            % Increment the labels so that they restart from 1 for each organoid
                            labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));

                    
                            % Add the relabeled nucleus to the combined image
                            relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;
                            
                            % Calculate mean intensity of the nucleus
                            nucleus_intensity = mean(current_image(nucleus_thresholded));
                            nucleus_intensities = [nucleus_intensities; nucleus_intensity];
                        end
                    end
                    % Calculate region properties for the current organoid mask
                    regionprops_data = regionprops('table', relabeled_nuclei_combined, 'all');
        
                    % Add mean intensity column to the regionprops data table
                    regionprops_data.MeanIntensity = nucleus_intensities;
        
                    % Store the region properties for the current organoid
                    regionprops_cell{organoid_counter} = regionprops_data;
                end
            end
        end

        % Calculate region properties for the entire organoid mask
        organoid_data = regionprops('table', new_organoid_mask, 'all');
        
        % Store the region properties for the entire organoid mask under the file name field
        all_regionprops.(filename).organoid_data = organoid_data;
        % Store the region properties cell array in the structure under the file name field
        all_regionprops.(filename).organoid_regionprops = regionprops_cell;
    end
end


