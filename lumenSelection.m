function lumen_organoids = lumenSelection(current_image, relabeled_organoid_mask)
figure;
imshow(current_image);
hold on;
visboundaries(relabeled_organoid_mask, 'Color', 'r');

% Use getpts to manually classify organoids with lumen
disp('Click on organoids containing lumen, then press Enter.');
[x, y] = getpts;

lumen_organoids = [];
for j = 1:numel(x)
    clicked_point = [x(j), y(j)];
    lumen_organoid_idx = relabeled_organoid_mask(round(clicked_point(2)), round(clicked_point(1)));
    if lumen_organoid_idx > 0
        lumen_organoids = [lumen_organoids; lumen_organoid_idx];
    end
end
end