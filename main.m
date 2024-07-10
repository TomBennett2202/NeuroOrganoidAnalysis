% Main script for quantifying architecture and behaviour of human brain
% organoids

% % % % % % % % % Import files % % % % % % % % % 

% Organoid masks
organoid_directory = 'organoid_masks';
organoid_mask_files = dir(fullfile(organoid_directory, '*.png'));

% Nuclei masks
nuclei_directory = 'nuclei_masks';
nuclei_mask_files = dir(fullfile(nuclei_directory, '*.png'));

% Images
images_directory = 'images';
image_files = dir(fullfile(images_directory, '*.jpg'));

% Load magnification data from the CSV file
magnification_data = readtable('magnifications.csv');

% Lumen classification files
lumen_classification_directory = 'lumen_classification';
lumen_files = dir(fullfile(lumen_classification_directory, '*.csv'));


% % % % % % % % % % % Main % % % % % % % % % % % % 

% Initialize a structure to store data for each file
all_regionprops = struct();

% Loop through each file in the directory
for i = 1:numel(organoid_mask_files)
    % Get the file name
    [~, filename, ~] = fileparts(organoid_mask_files(i).name);
    
    % Read the organoid mask
    organoid_mask = imread(fullfile(organoid_directory, organoid_mask_files(i).name));

    % Remove organoids touching the borders
    relabeled_organoid_mask = removeBorders(organoid_mask);
    
    % Read the nuclei mask
    nuclei_mask = imread(fullfile(nuclei_directory, organoid_mask_files(i).name));

    % Remove nuclei touching the borders
    nuclei_mask = removeBorders(nuclei_mask);

    % Read the original image
    current_image = imread(fullfile(images_directory, image_files(i).name));

    % Find magnification for the current image
    magnification_idx = strcmp(magnification_data.Filename, filename);
    magnification = magnification_data.Magnification(magnification_idx);

    % Load corresponding lumen classification CSV file if available
    if any(strcmp({lumen_files.name}, [filename '.csv']))
        % Load the lumen classification data
        lumen_data = readtable(fullfile(lumen_classification_directory, [filename '.csv']));
        lumen_organoids = lumen_data.lumen_organoids; 
    else
        % Classify which organoids contain a lumen and store in CSV
        lumenSelection;
        writetable(array2table(lumen_organoids), fullfile(lumen_classification_directory, [filename '.csv']));
    end
    
    % Extract data from image
    dataRetrieval;

end

combining;


% % % % % % % % Exploratory Data Analysis and Visualization % % % % % % % %

% % Plot correlation graphs
% correlationAnalysis(combined_nuclei_data, 'nuclei');
% 
% correlationAnalysis(combined_organoid_data, 'organoid');
% 
% correlationAnalysis(combined_table, 'combined');
% 
% % Plot PCA plots
% performPCA(combined_nuclei_data, 'nuclei');
% 
% performPCA(combined_organoid_data, 'organoid');
% 
% performPCA(combined_table, 'both');
% 
% % Plot swarm plots comparing lumen organoids vs without
% swarmPlot(combined_organoid_data);
% 
% swarmPlot(combined_nuclei_data);



