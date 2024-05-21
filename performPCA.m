function performPCA(data, dataType)
    % Perform PCA
    data_array = table2array(data);
    [coeff, score, latent, ~, explained] = pca(data_array);
    
    % Extract principal components
    PC1 = score(:, 1);
    PC2 = score(:, 2);
    PC3 = score(:, 3);
    
   % Scatter plot for PC1 vs PC2
    figure;
    scatter(PC1, PC2);
    xlabel(sprintf('Principal Component 1 (%.2f%% variance)', explained(1)));
    
    % Display PC2 only if variance contribution is greater than a threshold
    if explained(2) > 0.01
        ylabel(sprintf('Principal Component 2 (%.2f%% variance)', explained(2)));
    else
        ylabel(sprintf('Principal Component 2 (> 0.01%% variance)'));
    end

    title_str = dataType;
    if strcmp(dataType, 'both')
        title_str = 'Organoid and Nuclei';
    elseif strcmp(dataType, 'organoid')
        title_str = 'Organoid';
    elseif strcmp(dataType, 'nuclei')
        title_str = 'Nuclei';
    end
    title(sprintf('%s Principal Component Analysis Scatter Plot', title_str));
    
    % Scatter plot for PC1 vs PC2 vs PC3
    figure;
    scatter3(PC1, PC2, PC3);
    xlabel(sprintf('Principal Component 1 (%.2f%% variance)', explained(1)));

    % Display PC2 only if variance contribution is greater than a threshold
    if explained(2) > 0.01
        ylabel(sprintf('Principal Component 2 (%.2f%% variance)', explained(2)));
    else
        ylabel(sprintf('Principal Component 2 (> 0.01%% variance)'));
    end 

    % Display PC3 only if variance contribution is greater than a threshold
    if explained(3) > 0.01
        zlabel(sprintf('Principal Component 3 (%.2f%% variance)', explained(3)));
    else
        zlabel(sprintf('Principal Component 3 (> 0.01%% variance)'));
    end    
    
    title(sprintf('%s Principal Component Analysis 3D Scatter Plot', title_str));
    
end
