function nucleicorrelation(combined_nuclei_data)
% Create a folder to store the correlated plots if it doesn't exist
if ~exist('correlated', 'dir')
    mkdir('correlated');
end

% Create a folder to store the correlated plots if it doesn't exist
if ~exist('non-correlated', 'dir')
    mkdir('non-correlated');
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
end