function mitoticPlot(data)
    % Create a folder to store the correlated plots if it doesn't exist
    if ~exist('mitotic_graphs', 'dir')
        mkdir('mitotic_graphs');
    end

    % Identify the index of the 'Organoid_Lumen_Classification' column
    lumen_class_col_idx = find(strcmp(data.Properties.VariableNames, 'Organoid_Lumen_Classification'));

    % Swarm plot
    for i = 1:lumen_class_col_idx - 1
        nucleus_labels = {'Non Mitotic Nuclei', 'Mitotic Nuclei', 'Miscellaneous'};

        % Get data for each group
        group1 = data.(i)(data.Nucleus_Classification == 'non_mitotic_nuclei');
        group2 = data.(i)(data.Nucleus_Classification == 'mitotic_nuclei');
        group3 = data.(i)(data.Nucleus_Classification == 'miscellaneous');

        % Create categorical array for x-axis labels
        x_labels_group1 = repmat({'Non Mitotic Nuclei'}, length(group1), 1);
        x_labels_group2 = repmat({'Mitotic Nuclei'}, length(group2), 1);
        x_labels_group3 = repmat({'Miscellaneous'}, length(group3), 1);

        % Perform ANOVA
        [p_value, ~ , stats] = anova1([group1; group2; group3], [x_labels_group1; x_labels_group2; x_labels_group3], 'off');

        % Perform post-hoc comparisons
        post_hoc_results = multcompare(stats, 'Display', 'off');

        fig = figure('Visible', 'off');

        % Plot each group with its respective color
        swarmchart(categorical(x_labels_group1, nucleus_labels), group1, 150, '.', 'blue');
        hold on;
        swarmchart(categorical(x_labels_group2, nucleus_labels), group2, 150, '.', 'red');
        hold on;
        swarmchart(categorical(x_labels_group3, nucleus_labels), group3, 150, '.', 'green');
        hold off;

        xlabel('Nucleus Classification', 'FontSize', 20);
        ylabel(strrep(data.Properties.VariableNames{i}, '_', ' '), 'FontSize', 20);
        title(['P-value: ', num2str(p_value)], 'FontSize', 20); 
        
        saveas(fig, fullfile('mitotic_graphs', [data.Properties.VariableNames{i}, '.png']));
        
        % Close the figure to release memory
        close(fig);

        % Save post-hoc results to a CSV file
        post_hoc_table = array2table(post_hoc_results, 'VariableNames', {'Group1', 'Group2', 'LowerCI', 'MeanDifference', 'UpperCI', 'PValue'});
        writetable(post_hoc_table, fullfile('mitotic_graphs', [data.Properties.VariableNames{i}, '_posthoc.csv']));
    end
end
