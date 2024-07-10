% Nuclei mask files
nuclei_directory = 'nuclei_masks';
nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));

% Original image files
images_directory = 'images';
image_files = dir(fullfile(images_directory, '*.jpg'));

% Loop through each file in the directory
for i = 1:numel(nuclei_mask_files)
    % Get the file name without extension
    [~, filename, ~] = fileparts(nuclei_mask_files(i).name);
    
    % Read the corresponding nuclei mask image
    nuclei_mask = imread(fullfile(nuclei_directory, nuclei_mask_files(i).name));

    % Remove nuclei touching the borders
    nuclei_mask = removeBorders(nuclei_mask);

    % Read the corresponding original image
    current_image = imread(fullfile(images_directory, image_files(i).name));

    % Select and save mitotic nuclei
    selectAndSaveNuclei(current_image, nuclei_mask, 'mitotic');
    
    % Select and save miscellaneous nuclei
    selectAndSaveNuclei(current_image, nuclei_mask, 'miscellaneous');
    
    % Select and save non-mitotic nuclei
    selectAndSaveNuclei(current_image, nuclei_mask, 'non_mitotic');
end
