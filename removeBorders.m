% This function removes objects that are touching the borders of the input mask.

function Mask3 = removeBorders(mask)
    % Make a copy of the input mask to avoid modifying the original
    Mask2 = mask;
    
    % Find the border pixels and set them to zero
    Mask2(ismember(mask, union(mask(:, [1 end]), mask([1 end], :)))) = 0;
    
    % Initialise the output mask with zeros
    Mask3 = Mask2 * 0;
    
    % Get a list of unique object labels in the modified mask
    A = unique(Mask2);
    
    % Loop through each unique object label, excluding the background
    for i = 2:numel(unique(Mask2))
        % Create a temporary mask for the current object
        temp = mask * 0;
        
        % Isolate the current object in the temporary mask
        temp(Mask2(:,:)== A(i)) = 1;
        
        % Convert the object mask to a binary image
        I = imbinarize(temp);
        
        % Remove small objects (fewer than 10 pixels) from the binary image
        I = bwareaopen(I,10);
        
        % Add the remaining object to the output mask with a new label
        Mask3(I(:,:) == 1) = i-1;
    end
end
