function performPCA(data, dataType)
    % Create the directory if it does not exist
    outputFolder = 'pca_graphs';
    if ~exist(outputFolder, 'dir')
        mkdir(outputFolder);
    end
    
    % Determine which columns to include based on dataType
    if strcmp(dataType, 'both') || strcmp(dataType, 'organoid')
        % Use all columns except the last column
        data_array = table2array(data(:, 1:end-1));
    elseif strcmp(dataType, 'nuclei')
        % Use all columns except the last two columns
        data_array = table2array(data(:, 1:end-2));
    else
        error('Invalid dataType. Choose from ''both'', ''organoid'', or ''nuclei''.');
    end

    % Perform PCA
    [coeff, score, latent, ~, explained] = pca(data_array);
    
    % Extract principal components
    PC1 = score(:, 1);
    PC2 = score(:, 2);
    PC3 = score(:, 3);
    
    % Scatter plot for PC1 vs PC2
    fig1 = figure('Visible', 'off');
    scatter(PC1, PC2, 'k', 'filled');
    xlabel(sprintf('Principal Component 1 (%.2f%%)', explained(1)), 'FontSize', 20);
    
    % Display PC2 only if variance contribution is greater than a threshold
    if explained(2) > 0.01
        ylabel(sprintf('Principal Component 2 (%.2f%%)', explained(2)), 'FontSize', 20);
    else
        ylabel(sprintf('Principal Component 2 (> 0.01%%)'), 'FontSize', 20);
    end

    title_str = dataType;
    if strcmp(dataType, 'both')
        title_str = 'Organoid and Nuclei';
    elseif strcmp(dataType, 'organoid')
        title_str = 'Organoid';
    elseif strcmp(dataType, 'nuclei')
        title_str = 'Nuclei';
    end

    % Set tick number font size
    ax = gca;
    ax.FontSize = 20;
    
    % Save the 2D scatter plot as PNG
    scatterPlotFilename = fullfile(outputFolder, sprintf('%s_PCA_2D.png', title_str));
    saveas(fig1, scatterPlotFilename);
    close(fig1); % Close the figure to free up memory
    
    % Scatter plot for PC1 vs PC2 vs PC3
    fig2 = figure('Visible', 'off');
    scatter3(PC1, PC2, PC3, 'k', 'filled');
    xlabel(sprintf('Principal Component 1 (%.2f%%)', explained(1)), 'FontSize', 20);

    % Display PC2 only if variance contribution is greater than a threshold
    if explained(2) > 0.01
        ylabel(sprintf('Principal Component 2 (%.2f%%)', explained(2)), 'FontSize', 30);
    else
        ylabel(sprintf('Principal Component 2 (> 0.01%%)'), 'FontSize', 20);
    end 

    % Display PC3 only if variance contribution is greater than a threshold
    if explained(3) > 0.01
        zlabel(sprintf('Principal Component 3 (%.2f%%)', explained(3)), 'FontSize', 20);
    else
        zlabel(sprintf('Principal Component 3 (> 0.01%%)'), 'FontSize', 20);
    end    
    
    % Set tick number font size
    ax = gca;
    ax.FontSize = 20;
    
    % Save the 3D scatter plot as PNG
    scatter3PlotFilename = fullfile(outputFolder, sprintf('%s_PCA_3D.png', title_str));
    saveas(fig2, scatter3PlotFilename);
    close(fig2); % Close the figure to free up memory
    
end
