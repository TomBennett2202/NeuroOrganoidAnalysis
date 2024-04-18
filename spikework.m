addpath('~/Downloads/bfmatlab/');


% % % % % % % % % Import files


% % Loop through organoid mask files
% organoid_directory = '/Users/tombennett/Desktop/organoid_training';
% organoid_mask_files = dir(fullfile(organoid_directory, '*.png'));
% 
% % Import nuclei mask
% nuclei_directory = '/Users/tombennett/Desktop/Nuclei_training';
% nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));
% 
% % Loop through each file in the directory
% for i = 1:numel(organoid_mask_files)
%     % Check if the current item is a file (not a directory)
%     if ~organoid_mask_files(i).isdir
%         % Get the file name without extension
%         [~, filename, ~] = fileparts(organoid_mask_files(i).name);
% 
%         % Read the organoid mask image
%         organoid_mask = imread(fullfile(organoid_directory, organoid_mask_files(i).name));
% 
%         % Read the corresponding nuclei mask image
%         nuclei_mask = imread(fullfile(nuclei_directory, organoid_mask_files(i).name));
% 
%         % Extract the number of organoids
%         numOrganoids = max(organoid_mask(:));
% 
%         % Initialize a cell array to store overlapping nuclei for each organoid
%         overlappingNuclei = cell(1, numOrganoids);
% 
%         % Calculate region properties for the organoid mask
%         organoid_data = regionprops(organoid_mask, 'all')
% 
%         % Loop through each organoid
%         for j = 1:numOrganoids
%             % Check for overlap between the current organoid mask and nuclei
%             overlapping_pixels = nuclei_mask & (organoid_mask == j);
% 
%             % If there are overlapping pixels, store the nucleus mask
%             if any(overlapping_pixels(:))
%                 % Store overlapping nuclei for the current organoid
%                 overlappingNuclei{j} = overlapping_pixels;
%                 % Calculate region properties for the overlapping nuclei mask
%                 nuclei_data = regionprops(overlapping_pixels, 'all');
%             end
%         end
%     end
% end



% Loop through organoid mask files
organoid_directory = '/Users/tombennett/Desktop/organoid_training';
organoid_mask_files = dir(fullfile(organoid_directory, '*.png'));

% Import nuclei mask
nuclei_directory = '/Users/tombennett/Desktop/Nuclei_training';
nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));

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
        
        % Extract the number of organoids
        numOrganoids = max(organoid_mask(:));
        
        % Initialize a cell array to store region properties for each organoid in this file
        regionprops_cell = cell(1, numOrganoids);
        
        % Calculate region properties for the entire organoid mask
        organoid_data = regionprops('table', organoid_mask, 'all');
        
        % Store the region properties for the entire organoid mask under the file name field
        all_regionprops.(filename).organoid_data = organoid_data;
        
        % Loop through each organoid
        for j = 1:numOrganoids
            % Check for overlap between the current organoid mask and nuclei
            overlapping_pixels = nuclei_mask & (organoid_mask == j);
            
            % If there are overlapping pixels, calculate region properties
            if any(overlapping_pixels(:))
                % Calculate region properties for the current organoid mask
                regionprops_cell{j} = regionprops('table', overlapping_pixels, 'all');
            end
        end
        
        % Store the region properties cell array in the structure under the file name field
        all_regionprops.(filename).organoid_regionprops = regionprops_cell;
    end
end





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


