%% step 1st: calculate time frequency representation of SEEG signal of white matter 
clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep;
iEEGPrep_initial;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
dataFolder = 's0_data_afterPrep';
taskGroup = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
foi1 = 4:0.25:13;
foi2 = 13:1:120;
foi = unique([foi1, foi2]);
for nSub = 1:length(subjG)
    subjID = subjG{nSub};
    for nTask = 1:length(taskGroup)
        % load iEEG data
        taskName = taskGroup{nTask};
        dataDir = dir(fullfile(dataFolder, [subjID, '*_task-', taskName, '_run-1_ref-CommonAverage_preproc_ieeg.mat']));
        load(fullfile(dataDir.folder, dataDir.name));
        channels = Data.label;
        % calculate the time frequency representation of each channel and each trial
        for nChan = 1:size(channels, 1)
            coi = channels{nChan};
            channelTFR = f_channelTimeFrequency(Data, foi, coi);
            % save the data;
            mkdir(fullfile('replication', 's1_channelTFR'));
            mkdir(fullfile('replication', 's1_channelTFR', subjID));
            saveName = [subjID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat'];
            save(fullfile('replication', 's1_channelTFR', subjID, saveName), 'channelTFR', 'coi');
        end
    end
end 
