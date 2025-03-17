function ref_coor = f_vox2ref(vox_coor, AffainTransform)
% convert the coordinate of voxel space to the reference
        ref_coor = AffainTransform * [vox_coor, ones(length(vox_coor(:,1)),1)]' ;
        ref_coor = ref_coor';
        ref_coor(:, 4) = [];
end