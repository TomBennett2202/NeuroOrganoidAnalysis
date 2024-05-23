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

% Load magnification data from the CSV file
magnification_data = readtable('/Users/tombennett/Desktop/magnifications.csv');

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

        relabeled_organoid_mask = relabelMask(organoid_mask);
        
        % Read the corresponding nuclei mask image
        nuclei_mask = imread(fullfile(nuclei_directory, organoid_mask_files(i).name));

        % Read the corresponding original image
        current_image = imread(fullfile(organoid_directory, organoid_image_files(i).name));

        % Store the region properties for the entire organoid mask under the file name field
        all_regionprops.(filename).image = current_image;
        
        % Extract the number of organoids
        numOrganoids = max(relabeled_organoid_mask(:));

        % Find magnification for the current image
        magnification_idx = strcmp(magnification_data.Filename, filename);
        magnification = magnification_data.Magnification(magnification_idx);

        % Initialize a cell array to store region properties for each organoid in this file
        regionprops_cell = cell(1, 0);

        numNuclei = [];

        lumen_organoids = lumenSelection(current_image, relabeled_organoid_mask);

        % Loop through each organoid
        for j = 1:numOrganoids   
            % Check for overlap between the current organoid mask and nuclei
            overlapping_pixels = nuclei_mask & (relabeled_organoid_mask == j);
   
            overlapping_nuclei = uint16(nuclei_mask) .* uint16(overlapping_pixels);
    
            nonoverlapping_nuclei = nuclei_mask .* uint16(imcomplement(overlapping_pixels));
    
            % If there are overlapping pixels, relabel them
            if any(overlapping_pixels(:))
                nucleus_positions = [];
                relabeled_nuclei_combined = zeros(size(nuclei_mask));
                for label = unique(overlapping_nuclei(:))'
                    if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))
                        % Threshold the nucleus individually
                        nucleus_thresholded = overlapping_nuclei == label;
                        
                        % Label the thresholded nucleus with small
                        % objects removed
                        labeled_nucleus = bwlabel(bwareaopen(nucleus_thresholded, 3));
                
                        % Increment the labels so that they restart from 1 for each organoid
                        labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));

                        % Add the relabeled nucleus to the combined image
                        relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;
                        
                    end
                end
                % Calculate centroid of the organoid
                organoid_props = regionprops(relabeled_organoid_mask == j, 'Centroid', 'MinorAxisLength');
                organoid_centroid = organoid_props.Centroid;
                organoid_minor_axis = organoid_props.MinorAxisLength / 2;

                % Calculate region properties for the current organoid mask
                regionprops_data = regionprops('table', relabeled_nuclei_combined, imadjust(current_image(:,:,3)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');

                % Calculate distances between nucleus centroids and organoid centroid
                distance_to_centroid = sqrt(sum((regionprops_data.Centroid - organoid_centroid).^2, 2));

                % Normalize the distance by dividing it by the radius of the organoid
                normalized_distance = distance_to_centroid / organoid_minor_axis;
    
                % Add distances column to the regionprops data table
                regionprops_data.Distance_From_Centroid = normalized_distance;

                % Convert area and distance measurements to micrometers
                conversion_factor = 1 / magnification; 
                regionprops_data.Area = regionprops_data.Area * conversion_factor^2; 
                regionprops_data.Distance_From_Centroid = regionprops_data.Distance_From_Centroid * conversion_factor;
    
                % Store the region properties for the current organoid
                regionprops_cell{j} = regionprops_data;
            end

            numNuclei = [numNuclei; max(relabeled_nuclei_combined(:))];
        end

        % Calculate region properties for the entire organoid mask
        organoid_data = regionprops('table', relabeled_organoid_mask, imadjust(current_image(:,:,2)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');

        % Convert area measurements to micrometers
        organoid_data.Area = organoid_data.Area * conversion_factor^2;

        organoid_data.Number_Of_Nuclei = numNuclei;

        % Add lumen classification
        organoid_data.Lumen_Classification = ismember(1:numOrganoids, lumen_organoids)';

        % Store the region properties for the entire organoid mask under the file name field
        all_regionprops.(filename).organoid_data = organoid_data;
        % Store the region properties cell array in the structure under the file name field
        all_regionprops.(filename).organoid_regionprops = regionprops_cell;
    end
end


[combined_nuclei_data, combined_data_excluded, combined_table] = combining(all_regionprops);

correlationAnalysis(combined_nuclei_data, 'nuclei');

correlationAnalysis(combined_data_excluded, 'organoid');

organoidvsnucleicorrelation(combined_table);
% 
% 
% performPCA(combined_nuclei_data, 'nuclei');
% 
% performPCA(combined_data_excluded, 'organoid');
% 
% performPCA(combined_table, 'both');

% Display the image with the outlines of the organoids



% 
% 
% 
% 
% % Pairwise correlations for combined_nuclei_data
% for i = 1:numel(organoid_vars)
%     for j = 1:numel(nuclei_vars)
%         % Extract the data as numeric arrays
%         x_data = combined_table.(organoid_vars{i});
%         y_data = combined_table.(nuclei_vars{j});
% 
%         % Calculate linear regression
%         p = polyfit(x_data, y_data, 1);
%         [rho, pval] = corr(x_data, y_data);
% 
%         % Only plot if p-value is less than 0.05
%         if pval < 0.05
% 
%             % Run evalclusters for the pairwise columns
%             result = evalclusters([x_data, y_data], 'kmeans', 'silhouette', 'KList', 1:10);
%             % Check if OptimalK is not equal to 10
%             if result.OptimalK ~= 10
%                 % Perform K-Means Clustering with the optimal number of clusters
%                 [idx, centroids] = kmeans([x_data, y_data], result.OptimalK);
%                 % Visualize the clusters
%                 % Plot the data points with different colors representing different clusters
%                 figure;
%                 scatter(x_data, y_data, [], idx, 'filled');
%                 hold on;
%                 xlabel(strrep([organoid_vars(i)], '_', ' '));
%                 ylabel(strrep([nuclei_vars(j)], '_', ' '));
%                 x_values = linspace(min(x_data), max(x_data), 100);
%                 y_values = polyval(p, x_values);
%                 % Add a colorbar to show cluster assignments
%                 colorbar;
%                 % Plot the regression line
%                 hold on;
%                 plot(x_values, y_values, 'r', 'LineWidth', 2);
%                 hold off;
%                 % Add title with correlation coefficient (rho) and p-value
%                 title(sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval));
%             end
%         end
%     end
% end
% 
% % Get variable names for nuclei
% nuclei_vars = combined_nuclei_data.Properties.VariableNames;
% 
% % Pairwise correlations for combined_nuclei_data
% for i = 1:numel(nuclei_vars)
%     for j = i+1:numel(nuclei_vars)
%         % Extract the data as numeric arrays from combined_nuclei_data
%         x_data = combined_nuclei_data.(nuclei_vars{i});
%         y_data = combined_nuclei_data.(nuclei_vars{j});
% 
%         % Calculate linear regression
%         p = polyfit(x_data, y_data, 1);
%         [rho, pval] = corr(x_data, y_data);
% 
%         % Only plot if p-value is less than 0.05
%         if pval < 0.05
%             % Run evalclusters for the pairwise columns
%             result = evalclusters([x_data, y_data], 'kmeans', 'silhouette', 'KList', 1:10);
%             % Check if OptimalK is not equal to 10
%             if result.OptimalK ~= 10
%                 % Perform K-Means Clustering with the optimal number of clusters
%                 [idx, centroids] = kmeans([x_data, y_data], result.OptimalK);
%                 % Plot the data points with different colors representing different clusters
%                 figure;
%                 scatter(x_data, y_data, [], idx, 'filled');
%                 hold on;
%                 xlabel(strrep([nuclei_vars(i)], '_', ' '));
%                 ylabel(strrep([nuclei_vars(j)], '_', ' '));
%                 x_values = linspace(min(x_data), max(x_data), 100);
%                 y_values = polyval(p, x_values);
%                 % Add a colorbar to show cluster assignments
%                 colorbar;
%                 % Plot the regression line
%                 hold on;
%                 plot(x_values, y_values, 'r', 'LineWidth', 2);
%                 hold off;
%                 % Add title with correlation coefficient (rho) and p-value
%                 title(sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval));
%             end
%         end
%     end
% end
% 
% % Get variable names for organoids
% organoid_vars = combined_data_excluded.Properties.VariableNames;
% 
% 
% % Pairwise correlations for combined_data_excluded
% for i = 1:numel(organoid_vars)
%     for j = i+1:numel(organoid_vars)
%         % Extract the data as numeric arrays from combined_data_excluded
%         x_data = combined_data_excluded.(organoid_vars{i});
%         y_data = combined_data_excluded.(organoid_vars{j});
% 
%         % Calculate linear regression
%         p = polyfit(x_data, y_data, 1);
%         [rho, pval] = corr(x_data, y_data);
% 
%         % Only plot if p-value is less than 0.05
%         if pval < 0.05
%             % Run evalclusters for the pairwise columns
%             result = evalclusters([x_data, y_data], 'kmeans', 'silhouette', 'KList', 1:10);
%             % Check if OptimalK is not equal to 10
%             if result.OptimalK ~= 10
%                 % Perform K-Means Clustering with the optimal number of clusters
%                 [idx, centroids] = kmeans([x_data, y_data], result.OptimalK);
%                 % Plot the data points with different colors representing different clusters
%                 figure;
%                 scatter(x_data, y_data, [], idx, 'filled');
%                 hold on;
%                 xlabel(strrep([organoid_vars(i)], '_', ' '));
%                 ylabel(strrep([organoid_vars(j)], '_', ' '));
%                 x_values = linspace(min(x_data), max(x_data), 100);
%                 y_values = polyval(p, x_values);
%                 % Add a colorbar to show cluster assignments
%                 colorbar;
%                 % Plot the regression line
%                 hold on;
%                 plot(x_values, y_values, 'r', 'LineWidth', 2);
%                 hold off;
%                 % Add title with correlation coefficient (rho) and p-value
%                 title(sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval));
%             end
%         end
%     end
% end
