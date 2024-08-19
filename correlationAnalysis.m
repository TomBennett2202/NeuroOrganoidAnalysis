function correlationAnalysis(data, label)
    % Create folders to store the correlated and uncorrelated plots if they don't exist
    if ~exist('correlated', 'dir')
        mkdir('correlated');
    end
    if ~exist('uncorrelated', 'dir')
        mkdir('uncorrelated');
    end

    % Get variable names for the data
    vars = data.Properties.VariableNames;

    % Check if there is a 7th and 8th column (lumen_classification and nuclei classification) and exclude it
    if numel(vars) == 8 
        % Exclude the 7th column if there are 8 columns
        vars = vars(1:6);
    elseif numel(vars) == 7
        % Exclude only the 7th column if there are 7 columns
        vars = vars(1:6);
    end

    % Determine variable pairs based on the label
    if strcmp(label, 'combined')
        % Get variable names for organoids and nuclei
        organoid_vars = vars(1:6);
        nuclei_vars = vars(7:12);
        pairs = combvec(1:numel(organoid_vars), 1:numel(nuclei_vars))';
    else
        % Get pairs for the same table
        pairs = combvec(1:numel(vars), 1:numel(vars))';
        % Ensure unique pairs (i < j)
        pairs = pairs(pairs(:,1) < pairs(:,2), :); 
    end

    % Pairwise correlations
    for k = 1:size(pairs, 1)
        i = pairs(k, 1);
        j = pairs(k, 2);

        % Select the appropriate variable names based on the label
        if strcmp(label, 'combined')
            x_var = organoid_vars{i};
            y_var = nuclei_vars{j};
        else
            x_var = vars{i};
            y_var = vars{j};
        end

        % Extract the data as numeric arrays
        x_data = data.(x_var);
        y_data = data.(y_var);

        % Calculate linear regression
        p = polyfit(x_data, y_data, 1);
        [rho, pval] = corr(x_data, y_data);

        % Create a new figure for each scatter plot
        fig = figure('Visible', 'off');
        scatter(x_data, y_data, [], 'filled', 'k');
        xlabel(strrep(x_var, '_', ' '), 'FontSize', 20);
        ylabel(strrep(y_var, '_', ' '), 'FontSize', 20);
        x_values = linspace(min(x_data), max(x_data), 100);
        y_values = polyval(p, x_values);

        % Plot the regression line
        hold on;
        plot(x_values, y_values, 'r', 'LineWidth', 2);
        hold off;

        % Add title with correlation coefficient (rho) and p-value
        title_str = sprintf('Correlation Coefficient (rho) = %.4f, p-value = %.4f', rho, pval);
        title(title_str, 'FontSize', 20);

        % Define the file path for saving
        if pval < 0.05
            folder_name = 'correlated';
        else
            folder_name = 'uncorrelated';
        end

        % Save the figure
        saveas(fig, fullfile(folder_name, sprintf('%s_vs_%s.png', x_var, y_var)));

        % Close the figure to release memory
        close(fig);
    end
end
