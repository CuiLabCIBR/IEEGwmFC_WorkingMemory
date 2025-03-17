%% view all gm electrode contact using wbview
clc;clear;close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\cifti-matlab;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220\external\gifti;
folder = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\fig1\gmelectrode_wbview';
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% import surface template gii file
Lsurf_pial_file = fullfile(folder, 'S1200.L.pial_MSMAll.32k_fs_LR.surf.gii');
Rsurf_pial_file = fullfile(folder, 'S1200.R.pial_MSMAll.32k_fs_LR.surf.gii');
Lsurf_pial=gifti(Lsurf_pial_file); Rsurf_pial=gifti(Rsurf_pial_file);
surfMNI_pial = [Lsurf_pial.vertices; Rsurf_pial.vertices];
Lsurf_veryinflated_file = fullfile(folder, 'S1200.L.very_inflated_MSMAll.32k_fs_LR.surf.gii');
Rsurf_veryinflated_file = fullfile(folder, 'S1200.R.very_inflated_MSMAll.32k_fs_LR.surf.gii');
Lsurf_veryinflated=gifti(Lsurf_veryinflated_file); Rsurf_veryinflated=gifti(Rsurf_veryinflated_file);
surfMNI_veryinflated = [Lsurf_veryinflated.vertices; Rsurf_veryinflated.vertices];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% import yeo7atlas dlabel file
yeo7dlabel = cifti_read(fullfile(folder, 'Yeo2011_7Networks_N1000.dlabel.nii'));
cdata = yeo7dlabel.cdata;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create new foci txt file
gmElectrodeFile_L = fullfile(folder, 'gmElectrode_wbview_all_L.txt');
gmElectrodeFile_R = fullfile(folder, 'gmElectrode_wbview_all_R.txt');
delete(gmElectrodeFile_L); delete(gmElectrodeFile_R);
GMPrepFolder= 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\gm_data_afterPrep';
subG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nSub = 1:length(subG)
    subjID = subG{nSub};
    load(fullfile(GMPrepFolder, [subjID, '_electrodeAtlas.mat']));
    for nChan = 1:size(gmGoodChans, 1)
        gmatlas = gmGoodChans{nChan, 2};
        MNI = gmGoodChans{nChan, 4};
        LR = gmGoodChans{nChan, 5};
        % map the channel to surface
        distance = sqrt((MNI(1)-surfMNI_pial(:, 1)).^2+(MNI(2)-surfMNI_pial(:, 2)).^2+(MNI(3)-surfMNI_pial(:, 3)).^2);
        distance(cdata==0) = max(distance);
        [a, b] = min(distance);
        if a > 6
            disp([subjID, ' chan ', num2str(nChan), ' distance is ', num2str(a), ' !!!!']);
        end
        coorn = surfMNI_veryinflated(b, :);
        % edit the left brain gm workbench node file
        if  strcmp(LR, 'Left')
            RGB = [rand(1)*255 rand(1)*255 rand(1)*255];
            atlas = [subjID, gmatlas, 'chan', num2str(nChan)];
            fileID = fopen(gmElectrodeFile_L, 'a+');
            fprintf(fileID,'%s\n', atlas);
            fprintf(fileID,'%1.0f', RGB(1));
            fprintf(fileID,'% 1.0f', RGB(2:3));
            fprintf(fileID,'% 5.2f', coorn(1:2));
            fprintf(fileID,'% 5.2f\n', coorn(3));
            fclose(fileID);
        end
        % edit the right brain gm workbench node file
        if strcmp(LR, 'Right')
            RGB = [rand(1)*255 rand(1)*255 rand(1)*255];
            atlas = [subjID, gmatlas, 'chan', num2str(nChan)];
            fileID = fopen(gmElectrodeFile_R, 'a+');
            fprintf(fileID,'%s\n', atlas);
            fprintf(fileID,'%1.0f', RGB(1));
            fprintf(fileID,'% 1.0f', RGB(2:3));
            fprintf(fileID,'% 5.2f', coorn(1:2));
            fprintf(fileID,'% 5.2f\n', coorn(3));
            fclose(fileID);
        end
    end
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% create foci file
wb_command = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\HCP_workbench_win64\wb_command.exe';
fociL_file = fullfile(folder, 'gmElectrode_wbview_all.L.32k_fs_LR.foci');
fociR_file = fullfile(folder, 'gmElectrode_wbview_all.R.32k_fs_LR.foci');
delete(fociR_file); delete(fociL_file);
cmd = [wb_command ' -foci-create -class foci ' gmElectrodeFile_L ' ' Lsurf_veryinflated_file ' ' fociL_file];
system(cmd)
cmd = [wb_command ' -foci-create -class foci ' gmElectrodeFile_R ' ' Rsurf_veryinflated_file ' ' fociR_file];
system(cmd)