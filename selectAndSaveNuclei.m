function selectAndSaveNuclei(current_image, nuclei_mask, nucleus_type)
    % Display the image and allow the user to manually select nuclei
    figure;
    imshow(current_image(:,:,3));
    hold on;
    title(sprintf('Click on %s nuclei, then press Enter.', nucleus_type), 'FontSize', 15);
    
    [x, y] = getpts; % Get points selected by the user
    
    % Initialise an array to store the indices of selected nuclei
    selected_nuclei_indices = [];
    
    % Loop through the clicked points and determine the corresponding nuclei
    for j = 1:numel(x)

        clicked_point = [x(j), y(j)];

        % Get nucleus index for the point
        nucleus_idx = nuclei_mask(round(clicked_point(2)), round(clicked_point(1)));
        
        % Check it is not background
        if nucleus_idx > 0
            selected_nuclei_indices = [selected_nuclei_indices; nucleus_idx];
        end

    end
    
    % Create the parent folder to save the nuclei images if it doesn't exist
    parent_folder = 'nuclei_training';
    if ~exist(parent_folder, 'dir')
        mkdir(parent_folder);
    end
    
    % Determine the subfolder based on the nucleus type
    switch nucleus_type
        case 'mitotic'
            subfolder = fullfile(parent_folder, 'mitotic_nuclei');
            prefix = 'mitotic_nucleus';

        case 'non_mitotic'
            subfolder = fullfile(parent_folder, 'non_mitotic_nuclei');
            prefix = 'non_mitotic_nucleus';

        case 'miscellaneous'
            subfolder = fullfile(parent_folder, 'miscellaneous');
            prefix = 'miscellaneous';

    end
    
    if ~exist(subfolder, 'dir')
        mkdir(subfolder);
    end
    
    % Get current timestamp
    timestamp = datestr(now, 'yyyymmddTHHMMSS');
    
    % Save each selected nucleus as a separate image
    for j = 1:numel(selected_nuclei_indices)

        % Get the mask for the current nucleus
        nucleus_mask = nuclei_mask == selected_nuclei_indices(j);
        
        % Create a bounding box around the nucleus
        stats = regionprops(nucleus_mask, 'BoundingBox');
        boundingBox = stats.BoundingBox;
    
        % Crop the current image around the bounding box
        cropped_image = imcrop(current_image(:,:,3), boundingBox);
        cropped_mask = imcrop(nucleus_mask, boundingBox);
    
        % Apply the mask to retain only the nucleus
        masked_image = cropped_image .* uint8(cropped_mask);
    
        % Resize the masked image to 22x22 pixels
        resized_image = imresize(masked_image, [22 22]);
        
        % Create the filename for the nucleus image
        nucleus_filename = fullfile(subfolder, sprintf('%s_%s_%d.png', prefix, timestamp, j));
        
        % Save the masked image
        imwrite(resized_image, nucleus_filename);
        
    end
end
