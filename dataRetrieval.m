% Retrieve and store data related to organoids and their associated nuclei

all_regionprops = struct();

% Initialize a cell array to store region properties for each organoid in this file
regionprops_cell = cell(1, 0);

numNuclei = [];

% Extract the number of organoids
numOrganoids = max(relabeled_organoid_mask(:));

% Loop through each organoid
for j = 1:numOrganoids 
    
    % Identify overlapping nuclei with the current organoid
    overlapping_pixels = nuclei_mask & (relabeled_organoid_mask == j);
    
    overlapping_nuclei = uint16(nuclei_mask) .* uint16(overlapping_pixels);
    
    nonoverlapping_nuclei = nuclei_mask .* uint16(imcomplement(overlapping_pixels));
    
    % If there are overlapping pixels, relabel them
    if any(overlapping_pixels(:))
        nucleus_positions = [];
        relabeled_nuclei_combined = zeros(size(nuclei_mask));

        for label = unique(overlapping_nuclei(:))'

            if label ~= 0 && ~any(label == nonoverlapping_nuclei(:))

                % Threshold the nucleus individually
                nucleus_thresholded = overlapping_nuclei == label;
                
                % Label the thresholded nucleus with small objects removed
                labeled_nucleus = bwlabel(bwareaopen(nucleus_thresholded, 3));
        
                % Increment the labels so that they restart from 1 for each organoid
                labeled_nucleus(labeled_nucleus > 0) = labeled_nucleus(labeled_nucleus > 0) + max(relabeled_nuclei_combined(:));
    
                % Add the relabeled nucleus to the combined image
                relabeled_nuclei_combined = relabeled_nuclei_combined + labeled_nucleus;
                
            end
        end
    end

    % Calculate centroid of the organoid
    organoid_props = regionprops(relabeled_organoid_mask == j, 'Centroid', 'MinorAxisLength');
    organoid_centroid = organoid_props.Centroid;
    organoid_minor_axis = organoid_props.MinorAxisLength / 2;

    % Calculate region properties for the current organoid mask
    regionprops_data = regionprops('table', relabeled_nuclei_combined, imadjust(current_image(:,:,3)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');

    % Calculate distances between nucleus centroids and organoid centroid
    distance_to_centroid = sqrt(sum((regionprops_data.Centroid - organoid_centroid).^2, 2));

    % Normalize the distance by dividing it by the radius of the organoid
    normalized_distance = distance_to_centroid / organoid_minor_axis;

    % Add distances column to the regionprops data table
    regionprops_data.Distance_From_Centroid = normalized_distance;

    % Convert area and distance measurements to micrometers
    conversion_factor = 1 / magnification; 
    regionprops_data.Area = regionprops_data.Area * conversion_factor^2; 
    regionprops_data.Distance_From_Centroid = regionprops_data.Distance_From_Centroid * conversion_factor;
    

    % Add lumen classification for nuclei data
    regionprops_data.Lumen_Classification = repmat(ismember(j, lumen_organoids)', height(regionprops_data), 1);

    % Add mitotic classification for nuclei data
    % regionprops_data.Mitotic_Classification = ismember(1:height(regionprops_data), mitotic_nuclei_indices');

    % Store the region properties for the current organoid
    regionprops_cell{j} = regionprops_data;
    
    numNuclei = [numNuclei; max(relabeled_nuclei_combined(:))];

end

% Calculate region properties for the entire organoid mask
organoid_data = regionprops('table', relabeled_organoid_mask, imadjust(current_image(:,:,2)), 'Area', 'Centroid', 'Eccentricity', 'Circularity', 'Solidity', 'MeanIntensity');

% Convert area measurements to micrometers
organoid_data.Area = organoid_data.Area * conversion_factor^2;

organoid_data.Number_Of_Nuclei = numNuclei;

% Add lumen classification for organoid data
organoid_data.Lumen_Classification = ismember(1:numOrganoids, lumen_organoids)';

% Store the region properties for the entire organoid mask under the file name field
all_regionprops.(filename).organoid_data = organoid_data;
% Store the region properties cell array in the structure under the file name field
all_regionprops.(filename).organoid_regionprops = regionprops_cell;
