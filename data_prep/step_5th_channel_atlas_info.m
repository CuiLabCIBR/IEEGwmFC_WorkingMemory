clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep
iEEGPrep_initial;
BIDS = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS';
templateFolder = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\templateAtlas';
%%%%%%%%%%%%%%%%%%%%
%import yeo7 atlas
GMatlas = ft_read_mri(fullfile(templateFolder, 'Yeo2011_7Networks_N1000.split_components.FSL_MNI152_FreeSurferConformed_1mm.nii.gz'));
startRow = 2;
formatSpec = '%3f%41s%4f%4f%4f%f%[^\n\r]';
fileID = fopen(fullfile(templateFolder,'7Networks_ColorLUT_freeview.txt'),'r');
dataArray = textscan(fileID, formatSpec, 'Delimiter', '', 'WhiteSpace', '', 'TextType', 'string', 'HeaderLines' ,startRow-1, 'ReturnOnError', false, 'EndOfLine', '\r\n');
dataArray{2} = strtrim(dataArray{2});
fclose(fileID);
yeo7NetInfo = table(dataArray{1:end-1}, 'VariableNames', {'data','name','x','y','z','none'});
%%%%%%%%%%%%%%%%%%
% import reorganized white matter atlas
WMatlas = ft_read_mri(fullfile(templateFolder,'ICBM_DTI_81_60p_reorgan_allROI.nii'));
WMatlasLabel = load(fullfile(templateFolder,'ICBM_DTI_81_60p_reorgan_allROI.mat'));
WMatlasLabel = WMatlasLabel.newUniqueWMatlasLabel;
%%%%%%%%%%%%%%%%%%%%
% channel anatomy info of gtay matter
subIDG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nS = 1:length(subIDG)
    subID = subIDG{nS};
    elecfiledir = dir(fullfile(BIDS, subID, '**', [subID,'_electrodes.tsv']));
    elecInfo = ft_read_tsv(fullfile(elecfiledir.folder, elecfiledir.name));
    chanAtlasLabel = cell(size(elecInfo, 1), 4);
    for nChan = 1:size(elecInfo, 1)
        chanName = elecInfo.Channel{nChan};
        chanASEG = elecInfo.ASEG{nChan};
        chanDK = elecInfo.Desikan_Killiany{nChan};
        if contains(chanDK, ' L')
            chanDK  = f_strsplit(chanDK, ' L');
            chanDK = chanDK{1};
        elseif contains(chanDK, ' R')
            chanDK  = f_strsplit(chanDK, ' R');
            chanDK = chanDK{1};
        end
        chanMNI = elecInfo.MNI{nChan};
        chanMNI = str2num(chanMNI);
        chanAtlasLabel{nChan, 1} = chanName;
        chanAtlasLabel{nChan, 2} = chanMNI;
        chanAtlasLabel{nChan, 6} = chanDK;
        if contains(chanASEG, ' L')
            chanAtlasLabel{nChan, 7} = 'Left';
        elseif contains(chanASEG, ' R')
            chanAtlasLabel{nChan, 7} = 'Right';
        end
         chanASEG1 = f_strsplit(chanASEG, ' ');
         chanAtlasLabel{nChan, 8} = chanASEG1{1};
     %%%%%%%%%%%%%%%%%%%%%%%%
     % Edit gray matter channels
        if contains(chanASEG, 'Cortex')
            chanVoxCoor = floor(inv(GMatlas.transform)*[chanMNI, 1]');
            chanVoxCoor = chanVoxCoor(1:3);
            x = chanVoxCoor(1)-1:1:chanVoxCoor(1)+1;
            y = chanVoxCoor(2)-1:1:chanVoxCoor(2)+1;
            z = chanVoxCoor(3)-1:1:chanVoxCoor(3)+1;
            [X, Y, Z] = meshgrid(x, y, z);
            for n = 1:length(X(:))
                chanGM(n) = GMatlas.anatomy(X(n), Y(n), Z(n));
            end
            chanGM(chanGM==0) = [];
            if ~isempty(chanGM)
                CA = tabulate(chanGM);
                [~, index] = max(CA(:, 3));
                Yeo7label = yeo7NetInfo.name(CA(index, 1));
                Yeo7label = f_strsplit(Yeo7label, '_');
                if length(Yeo7label)==4
                    chanAtlasLabel{nChan, 3} = {Yeo7label{3}, Yeo7label{4}, chanDK};
                else
                    chanAtlasLabel{nChan, 3} = {Yeo7label{3}, Yeo7label{3}, chanDK};
                end
                chanAtlasLabel{nChan, 5} = CA(index, 3);
            end
        end
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    % Edit white matter channels
        if contains(chanASEG, 'White')
            chanVoxCoor = floor(inv(WMatlas.transform)*[chanMNI, 1]');
            chanVoxCoor = chanVoxCoor(1:3);
            x = chanVoxCoor(1)-1:1:chanVoxCoor(1)+1;
            y = chanVoxCoor(2)-1:1:chanVoxCoor(2)+1;
            z = chanVoxCoor(3)-1:1:chanVoxCoor(3)+1;
            [X, Y, Z] = meshgrid(x, y, z);
            for n = 1:length(X(:))
                chanWM(n) = WMatlas.anatomy(X(n), Y(n), Z(n));
            end
            chanWM(chanWM==0) = [];
            if ~isempty(chanWM)
                CA = tabulate(chanWM);
                [~, index] = max(CA(:, 3));
                chanAtlasLabel{nChan, 4} = WMatlasLabel{CA(index)};
                chanAtlasLabel{nChan, 5} = CA(index, 3);
            end
        end
    end
%%%%%%%%%%%%%%%%%
% save
 save(fullfile(BIDS, subID, 'ieeg', [subID, '_electrodes.mat']), 'chanAtlasLabel');
end

