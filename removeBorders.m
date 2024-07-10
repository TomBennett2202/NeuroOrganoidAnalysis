% This function removes objects that are touching the borders

function Mask3 = removeBorders(mask)
    Mask2 = mask;
    Mask2(ismember(mask, union(mask(:, [1 end]), mask([1 end], :)))) = 0;
    Mask3 = Mask2 * 0;
    A = unique(Mask2);
    for i = 2:numel(unique(Mask2))
        temp = mask * 0;
        temp(Mask2(:,:)== A(i)) = 1;
        I = imbinarize(temp);
        I = bwareaopen(I,20);
        Mask3(I(:,:) == 1) = i-1;
    end
end