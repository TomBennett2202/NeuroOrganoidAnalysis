function Mask3 = relabelMask(organoid_mask)
    Mask2 = organoid_mask;
    Mask2(ismember(organoid_mask, union(organoid_mask(:, [1 end]), organoid_mask([1 end], :)))) = 0;
    Mask3 = Mask2 * 0;
    A = unique(Mask2);
    for i = 2:numel(unique(Mask2))
        temp = organoid_mask * 0;
        temp(Mask2(:,:)== A(i)) = 1;
        I = imbinarize(temp);
        I = bwareaopen(I,20);
        Mask3(I(:,:) == 1) = i-1;
    end
end