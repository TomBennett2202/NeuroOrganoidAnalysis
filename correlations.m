function correlations(all_regionprops)
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

% Create a folder to store the correlated plots if it doesn't exist
if ~exist('correlated', 'dir')
    mkdir('correlated');
end

% Create a folder to store the correlated plots if it doesn't exist
if ~exist('non-correlated', 'dir')
    mkdir('non-correlated');
end


% Get variable names for organoids and nuclei
organoid_vars = combined_table.Properties.VariableNames(1:6);
nuclei_vars = combined_table.Properties.VariableNames(7:end);

% Pairwise correlations for combined_table
for i = 1:numel(organoid_vars)
    for j = 1:numel(nuclei_vars)
        % Extract the data as numeric arrays
        x_data = combined_table.(organoid_vars{i});
        y_data = combined_table.(nuclei_vars{j});

        % Calculate linear regression
        p = polyfit(x_data, y_data, 1);
        [rho, pval] = corr(x_data, y_data);

        % Create a new figure for each scatter plot
        fig = figure('Visible', 'off'); % Set visibility to off
        scatter(x_data, y_data, [], 'filled');
        xlabel(strrep(organoid_vars{i}, '_', ' '), 'FontSize', 13);
        ylabel(strrep(nuclei_vars{j}, '_', ' '), 'FontSize', 13);
        x_values = linspace(min(x_data), max(x_data), 100);
        y_values = polyval(p, x_values);
        % Plot the regression line
        hold on;
        plot(x_values, y_values, 'r', 'LineWidth', 2);
        hold off;
        
        % Add title with correlation coefficient (rho) and p-value
        title_str = sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval);
        title(title_str);
        
        % Define the file path for saving
        if pval < 0.05
            folder_name = 'correlated';
        else
            folder_name = 'non-correlated';
        end
        
        % Save the figure
        saveas(fig, fullfile(folder_name, sprintf('%s_vs_%s.png', organoid_vars{i}, nuclei_vars{j})));
        
        % Close the figure to release memory
        close(fig);
    end
end

% Get variable names for nuclei
nuclei_vars = combined_nuclei_data.Properties.VariableNames;

% Pairwise correlations for combined_nuclei_data
for i = 1:numel(nuclei_vars)
    for j = i+1:numel(nuclei_vars)
        % Extract the data as numeric arrays from combined_nuclei_data
        x_data = combined_nuclei_data.(nuclei_vars{i});
        y_data = combined_nuclei_data.(nuclei_vars{j});

        % Calculate linear regression
        p = polyfit(x_data, y_data, 1);
        [rho, pval] = corr(x_data, y_data);

        % Create a new figure for each scatter plot
        fig = figure('Visible', 'off'); % Set visibility to off
        scatter(x_data, y_data, [], 'filled');
        xlabel(strrep([nuclei_vars(i)], '_', ' '), 'FontSize', 13);
        ylabel(strrep([nuclei_vars(j)], '_', ' '), 'FontSize', 13);
        x_values = linspace(min(x_data), max(x_data), 100);
        y_values = polyval(p, x_values);
        % Plot the regression line
        hold on;
        plot(x_values, y_values, 'r', 'LineWidth', 2);
        hold off;
        
        % Add title with correlation coefficient (rho) and p-value
        title_str = sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval);
        title(title_str);
        
        % Define the file path for saving
        if pval < 0.05
            folder_name = 'correlated';
        else
            folder_name = 'non-correlated';
        end
        
        % Save the figure
        saveas(fig, fullfile(folder_name, sprintf('Nuclei_%s_vs_Nuclei_%s.png', nuclei_vars{i}, nuclei_vars{j})));
        
        % Close the figure to release memory
        close(fig);
    end
end

% Get variable names for organoids
organoid_vars = combined_data_excluded.Properties.VariableNames;

% Pairwise correlations for combined_data_excluded
for i = 1:numel(organoid_vars)
    for j = i+1:numel(organoid_vars)
        % Extract the data as numeric arrays from combined_data_excluded
        x_data = combined_data_excluded.(organoid_vars{i});
        y_data = combined_data_excluded.(organoid_vars{j});

        % Calculate linear regression
        p = polyfit(x_data, y_data, 1);
        [rho, pval] = corr(x_data, y_data);

        % Create a new figure for each scatter plot
        fig = figure('Visible', 'off'); % Set visibility to off
        scatter(x_data, y_data, [], 'filled');
        xlabel(strrep([organoid_vars(i)], '_', ' '), 'FontSize', 13);
        ylabel(strrep([organoid_vars(j)], '_', ' '), 'FontSize', 13);
        x_values = linspace(min(x_data), max(x_data), 100);
        y_values = polyval(p, x_values);
        % Plot the regression line
        hold on;
        plot(x_values, y_values, 'r', 'LineWidth', 2);
        hold off;
        
        % Add title with correlation coefficient (rho) and p-value
        title_str = sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval);
        title(title_str);
        
        % Define the file path for saving
        if pval < 0.05
            folder_name = 'correlated';
        else
            folder_name = 'non-correlated';
        end
        
        % Save the figure
        saveas(fig, fullfile(folder_name, sprintf('Organoid_%s_vs_Organoid_%s.png', organoid_vars{i}, organoid_vars{j})));
        
        % Close the figure to release memory
        close(fig);
    end
end
