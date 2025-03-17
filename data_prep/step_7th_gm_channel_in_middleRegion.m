clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep
iEEGPrep_initial;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
middleRegionAtlas = ft_read_mri('BN_Atlas_246_1mm_for_vmpfc.nii.gz');
anatomy = middleRegionAtlas.anatomy;
anatomy(anatomy>0) = 1;
middleRegionAtlas.anatomy = anatomy;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subIDG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
GMPrepPath = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\gm_data_afterPrep';
for nS = 1:length(subIDG)
    subID = subIDG{nS};
    load(fullfile(GMPrepPath, [subID, '_electrodeAtlas.mat']));
    chanMiddleRegionInfo = gmGoodChans;
    for nChan = 1:size(chanMiddleRegionInfo, 1)
        chanMNI = chanMiddleRegionInfo{nChan, 4};
        chanVoxCoor = floor(inv(middleRegionAtlas.transform)*[chanMNI, 1]');
        chanVoxCoor = chanVoxCoor(1:3);
        x = chanVoxCoor(1)-1:1:chanVoxCoor(1)+1;
        y = chanVoxCoor(2)-1:1:chanVoxCoor(2)+1;
        z = chanVoxCoor(3)-1:1:chanVoxCoor(3)+1;
        [X, Y, Z] = meshgrid(x, y, z);
        for n = 1:length(X(:))
            chanROIdata(n) = middleRegionAtlas.anatomy(X(n), Y(n), Z(n));
        end
        chanROIdata(chanROIdata==0) = [];
        if ~isempty(chanROIdata)
            chanMiddleRegionInfo{nChan, 8} = 1;
        else
            chanMiddleRegionInfo{nChan, 8} = 0;
        end
    end
    savename = [subID, '_electrodeMiddleRegionInfo.mat'];
    save(fullfile(GMPrepPath, savename), 'chanMiddleRegionInfo');
end

