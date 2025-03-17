function vox_coor = f_ref2vox(ref_coor, AffainTransform)
% convert the coordinate of reference space to voxel space 
        vox_coor = inv(AffainTransform)*[ref_coor, ones(length(ref_coor(:, 1)),1)]';
        vox_coor = vox_coor';
        vox_coor(:, 4) = [];
        vox_coor = round(vox_coor);
end