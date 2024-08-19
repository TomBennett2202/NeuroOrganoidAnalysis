% This section captures user-clicked points and adds the corresponding organoid 
% indices to a list.

figure;
imshow(current_image);
hold on;
visboundaries(relabeled_organoid_mask, 'Color', 'r');

% Use getpts to get coordinates for organoids with a lumen
title('Click on organoids containing lumen, then press Enter.', 'FontSize', 15);
[x, y] = getpts;

lumen_organoids = [];

% Iterate through each clicked point
for point_number = 1:numel(x)

    clicked_point = [x(point_number), y(point_number)];

    % Get organoid for the point
    lumen_organoid_idx = relabeled_organoid_mask(round(clicked_point(2)), round(clicked_point(1)));
    
    % Check it is not background
    if lumen_organoid_idx > 0
        lumen_organoids = [lumen_organoids; lumen_organoid_idx];
    end

end