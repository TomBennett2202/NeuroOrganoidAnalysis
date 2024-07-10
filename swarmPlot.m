function swarmPlot(data)
    % Create a folder to store the correlated plots if it doesn't exist
    if ~exist('swarm_charts', 'dir')
        mkdir('swarm_charts');
    end

    % Swarm plot for combined_organoid_data
    for i = 1:(size(data, 2) - 1)

        lumen_labels = {'Non-Lumen', 'Lumen'};

        % Get data for each group
        group1 = data.(i)(data.Organoid_Lumen_Classification == 0);
        group2 = data.(i)(data.Organoid_Lumen_Classification == 1);

        % Perform t-test
        [~, p_value] = ttest2(group1, group2);
        
        fig = figure('Visible', 'off');
        
        % Create categorical array for x-axis labels
        x_labels_group1 = repmat({'Non-Lumen'}, length(group1), 1);
        x_labels_group2 = repmat({'Lumen'}, length(group2), 1);

        % Plot each group with its respective color
        swarmchart(categorical(x_labels_group1, lumen_labels), group1, 150, '.', 'blue');
        hold on;
        swarmchart(categorical(x_labels_group2, lumen_labels), group2, 150, '.', 'red');
        hold off;

        xlabel('Lumen Classification', 'FontSize', 20);

        ylabel(strrep(data.Properties.VariableNames{i}, '_', ' '), 'FontSize', 20);

        title(['P-value: ', num2str(p_value)], 'FontSize', 20);  % Annotate with full p-value
        
        saveas(fig, fullfile('swarm_charts', [data.Properties.VariableNames{i}, '.png']));
        
        % Close the figure to release memory
        close(fig);
    end
end
