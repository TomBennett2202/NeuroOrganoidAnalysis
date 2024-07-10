% Get the field names of the structure
fields = fieldnames(all_regionprops);

% Define the columns of interest
columns_of_interest = [1, 3, 4, 5, 6, 7, 8]; 

% Initialize a cell array to store the data and mean values
data_cell = cell(length(fields), 1);
% Initialize mean_values_cell
mean_values_cell = cell(1, numel(columns_of_interest));
% Initialize combined_nuclei_data
combined_nuclei_data = [];

% For each field
for i = 1:length(fields)
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

% Concatenate the data from all fields
combined_organoid_data = vertcat(data_cell{:});
combined_organoid_data = combined_organoid_data(:, [1, 3:end]);

% Concatenate the mean data from all fields
combined_mean_values = cat(1, mean_values_cell{:});


% Rename columns in the tables (combined_mean_values)
new_column_names_combined_organoid_data = strcat('Organoid_', combined_organoid_data.Properties.VariableNames);
combined_organoid_data.Properties.VariableNames = new_column_names_combined_organoid_data;
new_column_names_combined_mean = strcat('Nuclei_', combined_mean_values.Properties.VariableNames);
combined_mean_values.Properties.VariableNames = new_column_names_combined_mean;
new_column_names_combined_nuclei = strcat('Nuclei_', combined_nuclei_data.Properties.VariableNames(1:6));
combined_nuclei_data.Properties.VariableNames = [new_column_names_combined_nuclei, 'Organoid_Lumen_Classification'];

% Join the two tables
combined_table = horzcat(combined_organoid_data, combined_mean_values(:, 1:6));
