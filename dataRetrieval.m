% Retrieve and store data related to organoids and their associated nuclei

% Load the nucleus trained network
load('trainedNetwork.mat');

% Initialise a cell array to store region properties for each organoid in this file
nuclei_data = cell(1, 0);

% Initialise an empty array to store the number of nuclei wthin each
% organoid
number_of_nuclei = [];

% Extract the number of organoids
number_of_organoids = max(relabeled_organoid_mask(:));

% Loop through each organoid
for j = 1:number_of_organoids 

    % Initialise an empty array to store the nuclei classifications of
    % each organoid
    nucleus_classifications = [];

    % Identify overlapping pixels with the current organoid
    overlapping_pixels = nuclei_mask & (relabeled_organoid_mask == j);
    
    % Identify overlapping nuclei with the current organoid
    overlapping_nuclei = nuclei_mask .* uint16(overlapping_pixels);

    % Identify not overlapping nuclei with the current organoid
    nonoverlapping_nuclei = nuclei_mask .* uint16(imcomplement(overlapping_pixels));
    
    % If there are overlapping nuclei
    if any(overlapping_nuclei(:))
        
        % Initialise an empty image to store the relabelled nuclei
        relabeled_nuclei_combined = zeros(size(nuclei_mask));
        
        % Iterate through each nucleus
        for label = unique(overlapping_nuclei(:))'

            % If the label is not the background and is also not a member
            % of the not overlapping nuclei
            if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))

                % Threshold the nucleus individually
                nucleus_thresholded = overlapping_nuclei == label;
                
                % Label the thresholded nucleus with small objects removed
                labeled_nucleus = bwlabel(bwareaopen(nucleus_thresholded, 3));
        
                % Increment the labels so that they restart from 1 for each organoid
                labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));
    
                % Add the relabeled nucleus to the combined image
                relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;

                % Create a bounding box of the nucleus
                stats = regionprops(nucleus_thresholded, 'BoundingBox');
                boundingBox = stats.BoundingBox;

                % Crop the image around the bounding box
                cropped_image = imcrop(current_image(:,:,3), boundingBox);
                cropped_mask = imcrop(nucleus_thresholded, boundingBox);

                % Apply the mask to retain only the nucleus
                masked_image = cropped_image .* uint8(cropped_mask);

                % Resize the masked image to 22x22 pixels
                resized_image = imresize(masked_image, [22 22]);

                % Classify the nucleus
                predictedClass = classify(net, resized_image);

                % Store classifications in the classification array
                nucleus_classifications = [nucleus_classifications; predictedClass];
                
            end
        end
    end

    % Calculate region properties for the the nuclei within the current organoid
    regionprops_data = regionprops('table', relabeled_nuclei_combined, imadjust(current_image(:,:,3)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');
    
    % Rename 'MeanIntensity' to 'Mean_Intensity'
    regionprops_data = renamevars(regionprops_data, 'MeanIntensity', 'Mean_Intensity');

    % Get the centroid of the organoid
    organoid_props = regionprops(relabeled_organoid_mask == j, 'Centroid', 'MinorAxisLength');
    organoid_centroid = organoid_props.Centroid;

    % Calculate distances between nucleus centroid and organoid centroid
    distance_to_centroid = sqrt(sum((regionprops_data.Centroid - organoid_centroid).^2, 2));

    % Normalise the distance by dividing it by the radius of the organoid
    organoid_minor_axis = organoid_props.MinorAxisLength / 2;
    normalised_distance = distance_to_centroid / organoid_minor_axis;

    % Convert area and distance measurements to micrometers
    conversion_factor = 1 / magnification; 
    regionprops_data.Area = regionprops_data.Area * conversion_factor^2; 
    regionprops_data.Distance_From_Centroid = normalised_distance * conversion_factor;

    % Add lumen classification for nuclei data
    regionprops_data.Lumen_Classification = repmat(ismember(j, lumen_organoids)', height(regionprops_data), 1);

    % Add nucleus classification to region properties
    regionprops_data.Nucleus_Classification = nucleus_classifications;

    % Store the region properties for the current organoid
    nuclei_data{j} = regionprops_data;
    
    % Get number of nuclei for the current organoid
    number_of_nuclei = [number_of_nuclei; max(relabeled_nuclei_combined(:))];

end

% Calculate region properties for the entire organoid mask
organoid_data = regionprops('table', relabeled_organoid_mask, imadjust(current_image(:,:,2)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');

% Rename 'MeanIntensity' to 'Mean_Intensity'
organoid_data = renamevars(organoid_data, 'MeanIntensity', 'Mean_Intensity');

% Convert area measurements to micrometers
organoid_data.Area = organoid_data.Area * conversion_factor^2;

% Store number of nuclei in organoid data
organoid_data.Number_Of_Nuclei = number_of_nuclei;

% Add lumen classification for organoid data
organoid_data.Lumen_Classification = ismember(1:number_of_organoids, lumen_organoids)';

% Store the region properties for the entire organoid mask under the file name field
all_data.(filename).organoid_data = organoid_data;

% Store the region properties cell array in the structure under the file name field
all_data.(filename).nuclei_data = nuclei_data;
