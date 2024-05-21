function [combined_nuclei_data, combined_data_excluded, combined_table] = combining(all_regionprops)
% Get the field names of the structure
fields = fieldnames(all_regionprops);

% Define the columns of interest
columns_of_interest = [1, 3, 4, 5, 6, 7]; 

% Initialize a cell array to store the data and mean values
data_cell = cell(length(fields), 1);
% Initialize mean_values_cell
mean_values_cell = cell(1, numel(columns_of_interest));
% Initialize combined_nuclei_data
combined_nuclei_data = [];

% For each field
for i = 1:length(fields)
    % Check if the field contains the desired data
    if isfield(all_regionprops.(fields{i}), 'organoid_data')
        % If yes, extract the data and store it in the cell array
        data_cell{i} = all_regionprops.(fields{i}).organoid_data;
        
        % Extract the regionprops data for the current field
        regionprops_data = all_regionprops.(fields{i}).organoid_regionprops;
        
        % Initialize a temporary cell array to store mean values for the current field
        temp_mean_values_cell = cell(1, numel(regionprops_data));
        
        % For each table in regionprops data
        for j = 1:numel(regionprops_data)
            % Exclude the second column
            table_data = regionprops_data{j}(:, columns_of_interest);
            % Append the table to combined_nuclei_data
            combined_nuclei_data = [combined_nuclei_data; table_data];
            % Calculate mean for each column of interest
            temp_mean_values_cell{j} = mean(table_data, 1);
        end
        
        % Store the mean values for the current field in the main mean_values_cell
        mean_values_cell = [mean_values_cell, temp_mean_values_cell];
    end
end

% Concatenate the data from all fields
combined_data = vertcat(data_cell{:});
combined_data_excluded = combined_data(:, [1, 3:end]);

% Concatenate the mean data from all fields
combined_mean_values = cat(1, mean_values_cell{:});


% Rename columns in the tables (combined_mean_values)
new_column_names_combined_data = strcat('Organoid_', combined_data_excluded.Properties.VariableNames);
combined_data_excluded.Properties.VariableNames = new_column_names_combined_data;
new_column_names_combined_mean = strcat('Nuclei_', combined_mean_values.Properties.VariableNames);
combined_mean_values.Properties.VariableNames = new_column_names_combined_mean;

% Join the two tables
combined_table = horzcat(combined_data_excluded, combined_mean_values);
end