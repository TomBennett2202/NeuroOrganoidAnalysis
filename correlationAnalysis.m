function correlationAnalysis(data, label)
    % Create a folder to store the correlated plots if it doesn't exist
    if ~exist('correlated', 'dir')
        mkdir('correlated');
    end
    
    % Create a folder to store the correlated plots if it doesn't exist
    if ~exist('non-correlated', 'dir')
        mkdir('non-correlated');
    end
    
    % Get variable names for the data
    vars = data.Properties.VariableNames;

     % Check if there is a 7th column (lumen_classification) and exclude it
    if numel(vars) >= 7 && strcmp(vars{7}, 'Organoid_Lumen_Classification')
        vars = vars([1:6, 8:end]);
    end
    
    % Pairwise correlations
    for i = 1:numel(vars)
        for j = i+1:numel(vars)
            % Extract the data as numeric arrays
            x_data = data.(vars{i});
            y_data = data.(vars{j});
    
            % Calculate linear regression
            p = polyfit(x_data, y_data, 1);
            [rho, pval] = corr(x_data, y_data);
    
            % Create a new figure for each scatter plot
            fig = figure('Visible', 'off'); % Set visibility to off
            scatter(x_data, y_data, [], 'filled');
            xlabel(strrep([vars(i)], '_', ' '), 'FontSize', 13);
            ylabel(strrep([vars(j)], '_', ' '), 'FontSize', 13);
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
            if strcmp(label, 'nuclei')
                saveas(fig, fullfile(folder_name, sprintf('%s_vs_%s.png', vars{i}, vars{j})));
            elseif strcmp(label, 'organoid')
                saveas(fig, fullfile(folder_name, sprintf('%s_vs_%s.png', vars{i}, vars{j})));
            end
            
            % Close the figure to release memory
            close(fig);
        end
    end
end