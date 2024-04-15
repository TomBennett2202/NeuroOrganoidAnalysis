addpath('~/Downloads/bfmatlab/');


% % % % % % % % % Import files


% Loop through organoid mask files
organoid_directory = '/Users/tombennett/Desktop/organoid_training';
organoid_mask_files = dir(fullfile(organoid_directory, '*.png'));

% Import nuclei mask
nuclei_directory = '/Users/tombennett/Desktop/Nuclei_training';
nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));

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
        
        % Extract the number of organoids
        numOrganoids = max(organoid_mask(:));
        
        % Initialize a cell array to store overlapping nuclei for each organoid
        overlappingNuclei = cell(1, numOrganoids);
        
        % Loop through each organoid
        for j = 1:numOrganoids
            % Check for overlap between the current organoid mask and nuclei
            overlapping_pixels = nuclei_mask & (organoid_mask == j);
            
            % If there are overlapping pixels, store the nucleus mask
            if any(overlapping_pixels(:))
                % Store overlapping nuclei for the current organoid
                overlappingNuclei{j} = overlapping_pixels;
            end
        end
    end
end

% Get data from masks



% 
% organoid_image_files = dir(fullfile(organoid_directory, '*.jpg'));
% 
% % Loop through each file in the directory
% for i = 1:length(organoid_image_files)
%     % Check if the current item is a file (not a directory)
%     if ~organoid_image_files(i).isdir
%         % Get the file name without extension
%         [~, filename, ~] = fileparts(organoid_image_files(i).name);
%         % Extract the prefix of the file name
%         prefix = strtok(filename, '_');
%         % Read the image
%         current_image = imread(fullfile(organoid_directory, organoid_image_files(i).name));
%         % Assign the image to a variable with the prefix of the file name
%         eval(['organoid_' ,prefix, ' = current_image;']);
% 
%     end
% end


