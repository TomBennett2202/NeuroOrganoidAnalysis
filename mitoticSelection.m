function nucleiExtraction(current_image, nuclei_mask)

    % Display the image and allow the user to manually select mitotic nuclei
    figure;
    imshow(current_image(:,:,3));
    hold on;
    title('Click on mitotic nuclei, then press Enter.', 'FontSize', 15);
    
    [x, y] = getpts; % Get points selected by the user
    
    % Initialize an array to store the indices of mitotic nuclei
    mitotic_nuclei_indices = [];
    
    % Loop through the clicked points and determine the corresponding nuclei
    for j = 1:numel(x)
        clicked_point = [x(j), y(j)];
        % Get nucleus index for the point
        mitotic_nucleus_idx = nuclei_mask(round(clicked_point(2)), round(clicked_point(1)));
        % Check it is not background
        if mitotic_nucleus_idx > 0
            mitotic_nuclei_indices = [mitotic_nuclei_indices; mitotic_nucleus_idx];
        end
    end
    
    % Display the image again and allow the user to manually select miscellaneous nuclei
    figure;
    imshow(current_image(:,:,3));
    hold on;
    title('Click on miscellaneous, then press Enter.', 'FontSize', 15);
    
    [x_misc, y_misc] = getpts; % Get points selected by the user
    
    % Initialize an array to store the indices of miscellaneous 
    miscellaneous_indices = [];
    
    % Loop through the clicked points and determine the corresponding nuclei
    for j = 1:numel(x_misc)
        clicked_point = [x_misc(j), y_misc(j)];
        % Get nucleus index for the point
        miscellaneous_idx = nuclei_mask(round(clicked_point(2)), round(clicked_point(1)));
        % Check it is not background
        if miscellaneous_idx > 0
            miscellaneous_indices = [miscellaneous_indices; miscellaneous_idx];
        end
    end
    
    % Create the parent folder to save the nuclei images if it doesn't exist
    parent_folder = 'nuclei_training';
    if ~exist(parent_folder, 'dir')
        mkdir(parent_folder);
    end
    
    % Create subfolders to save the mitotic, non-mitotic, and miscellaneous images
    mitotic_nuclei_folder = fullfile(parent_folder, 'mitotic_nuclei');
    if ~exist(mitotic_nuclei_folder, 'dir')
        mkdir(mitotic_nuclei_folder);
    end
    
    non_mitotic_nuclei_folder = fullfile(parent_folder, 'non_mitotic_nuclei');
    if ~exist(non_mitotic_nuclei_folder, 'dir')
        mkdir(non_mitotic_nuclei_folder);
    end
    
    miscellaneous_folder = fullfile(parent_folder, 'miscellaneous');
    if ~exist(miscellaneous_folder, 'dir')
        mkdir(miscellaneous_folder);
    end
    
    % Save each selected mitotic nucleus as a separate image
    for j = 1:numel(mitotic_nuclei_indices)
        % Get the mask for the current mitotic nucleus
        mitotic_nucleus_mask = nuclei_mask == mitotic_nuclei_indices(j);
        
        % Create a bounding box around the nucleus
        stats = regionprops(mitotic_nucleus_mask, 'BoundingBox');
        boundingBox = stats.BoundingBox;
    
        % Crop the current image around the bounding box
        cropped_image = imcrop(current_image(:,:,3), boundingBox);
        cropped_mask = imcrop(mitotic_nucleus_mask, boundingBox);
    
        % Apply the mask to retain only the nucleus
        masked_image = cropped_image .* uint8(cropped_mask);
    
        % Resize the masked image to 22x22 pixels
        resized_image = imresize(masked_image, [22 22]);
        
        % Create the filename for the mitotic nucleus image
        mitotic_nucleus_filename = fullfile(mitotic_nuclei_folder, sprintf('mitotic_nucleus_%d.png', j));
        
        % Save the masked image
        imwrite(resized_image, mitotic_nucleus_filename);
    end
    
    % Get all unique nuclei indices
    all_nuclei_indices = unique(nuclei_mask(nuclei_mask > 0));
    
    % Identify non-mitotic nuclei
    non_mitotic_nuclei_indices = setdiff(all_nuclei_indices, [mitotic_nuclei_indices; miscellaneous_indices]);
    
    % Save each non-mitotic nucleus as a separate image
    for j = 1:numel(non_mitotic_nuclei_indices)
        % Get the mask for the current non-mitotic nucleus
        non_mitotic_nucleus_mask = nuclei_mask == non_mitotic_nuclei_indices(j);
        
        % Create a bounding box around the nucleus
        stats = regionprops(non_mitotic_nucleus_mask, 'BoundingBox');
        boundingBox = stats.BoundingBox;
    
        % Crop the current image around the bounding box
        cropped_image = imcrop(current_image(:,:,3), boundingBox);
        cropped_mask = imcrop(non_mitotic_nucleus_mask, boundingBox);
    
        % Apply the mask to retain only the nucleus
        masked_image = cropped_image .* uint8(cropped_mask);
    
        % Resize the masked image to 22x22 pixels
        resized_image = imresize(masked_image, [22 22]);
        
        % Create the filename for the non-mitotic nucleus image
        non_mitotic_nucleus_filename = fullfile(non_mitotic_nuclei_folder, sprintf('non_mitotic_nucleus_%d.png', j));
        
        % Save the masked image
        imwrite(resized_image, non_mitotic_nucleus_filename);
    end
    
    % Save each selected miscellaneous as a separate image
    for j = 1:numel(miscellaneous_indices)
        % Get the mask for the current miscellaneous
        miscellaneous_mask = nuclei_mask == miscellaneous_indices(j);
        
        % Create a bounding box around the nucleus
        stats = regionprops(miscellaneous_mask, 'BoundingBox');
        boundingBox = stats.BoundingBox;
    
        % Crop the current image around the bounding box
        cropped_image = imcrop(current_image(:,:,3), boundingBox);
        cropped_mask = imcrop(miscellaneous_mask, boundingBox);
    
        % Apply the mask to retain only the nucleus
        masked_image = cropped_image .* uint8(cropped_mask);
    
        % Resize the masked image to 22x22 pixels
        resized_image = imresize(masked_image, [22 22]);
        
        % Create the filename for the miscellaneous  image
        miscellaneous_filename = fullfile(miscellaneous_folder, sprintf('miscellaneous_%d.png', j));
        
        % Save the masked image
        imwrite(resized_image, miscellaneous_filename);
    end
end
