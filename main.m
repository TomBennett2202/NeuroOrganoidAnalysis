% Main script for quantifying architecture and behaviour of human brain
% organoids

% % % % % % % % % % Import files % % % % % % % % %

% Images
images_directory = 'images';
image_files = dir(fullfile(images_directory, '*.jpg'));

% Organoid masks
organoid_directory = 'organoid_masks';

% Nuclei masks directory
nuclei_directory = 'nuclei_masks';

% Load magnification data from the CSV file
magnification_data = readtable('magnifications.csv');

% Lumen classification files
lumen_classification_directory = 'lumen_classification';


% % % % % % % % % % % Main % % % % % % % % % % % % 

% Initialise a structure to store data
all_data = struct();

% Loop through each file in the directory
for file_number = 1:numel(image_files)
    % Get the file name
    [~, filename, ~] = fileparts(image_files(file_number).name);
    
    % Read the organoid mask
    organoid_mask = imread(fullfile(organoid_directory, [filename, '.png']));

    % Remove organoids touching the borders
    relabeled_organoid_mask = removeBorders(organoid_mask);
    
    % Read the nuclei mask
    nuclei_mask = imread(fullfile(nuclei_directory, [filename, '.png']));

    % Remove nuclei touching the borders
    nuclei_mask = removeBorders(nuclei_mask);

    % Read the image
    current_image = imread(fullfile(images_directory, [filename, '.jpg']));

    % Find magnification for the current image
    magnification_idx = strcmp(magnification_data.Filename, filename);
    magnification = magnification_data.Magnification(magnification_idx);

    % Load corresponding lumen classification CSV file if available
    if exist(fullfile(lumen_classification_directory, [filename '.csv']), 'file')
        % Load the lumen classification data
        lumen_table = readtable(fullfile(lumen_classification_directory, [filename '.csv']));
        lumen_organoids = lumen_table.lumen_organoids; 
    else
        % Classify which organoids contain a lumen and store in CSV
        lumenSelection;
        writetable(array2table(lumen_organoids), fullfile(lumen_classification_directory, [filename '.csv']));
    end
    
    % Extract data from image
    dataRetrieval;

end


combining;


% % % % % % % % Exploratory Data Analysis and Visualisation % % % % % % % %

% % Plot correlation graphs
correlationAnalysis(combined_nuclei_data, 'nuclei');

correlationAnalysis(combined_organoid_data, 'organoid');

correlationAnalysis(average_table, 'combined');

% Plot PCA plots
performPCA(combined_nuclei_data, 'nuclei');

performPCA(combined_organoid_data, 'organoid');

performPCA(average_table, 'both');

% Plot swarm plots comparing lumen organoids vs without
lumenPlot(combined_organoid_data);

lumenPlot(combined_nuclei_data);

% Plot swarm plots comparing mitotic nuclei, non-mitotic nuclei, and
% miscellaneous objects 
mitoticPlot(combined_nuclei_data)
