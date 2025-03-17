clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep;
iEEGPrep_initial;
bids = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS';
taskG = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nSub = 1:length(subjG)
    subjID = subjG{nSub};
    for nTask = 1:length(taskG)
        taskName =  taskG{nTask};
        dataDir = dir(fullfile(bids, '**', [subjID, '_task-', taskName, '_run-1_ieeg.mat']));
        load(fullfile(dataDir.folder, dataDir.name));
        switch taskName
            case 'resting';  Data = rsData;
            case '0back';   Data = nb0Data;
            case '1back';   Data = nb1Data;
            case '2back';   Data = nb2Data;
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Data Preprocessing
        Data = f_detrend_demean(Data);
        BPfreq = [1, 120];
        Data = f_filter_bandpass(Data, BPfreq);
        PLfreq = 50;
        Data = f_filter_powerlinenoise(Data, PLfreq, BPfreq, 1);
        Data = f_filter_powerlinenoise(Data, PLfreq, BPfreq, 2);
        Data = f_filter_powerlinenoise(Data, PLfreq, BPfreq, 3);
        RSfreq = 250;
        Data = f_filter_resample(Data, RSfreq);
        chanGroups = f_chanGroup(Data.label);
        refMethod = 'Laplace';
        Data = f_reref_SEEG(Data, refMethod, chanGroups);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % IED Detection
        BPFreq = [10, 60];
        WinSize = 1;
        Threshold = 3.65;
        timeLThd = 0;
        intervalLThd = 0.15;
        IEDs = f_IED_detection(Data, BPFreq, WinSize, Threshold, timeLThd, intervalLThd);
        % save data file
        saveFolder = fullfile(bids, subjID, 'ieeg');
        saveName = [subjID, '_task-', taskName, '_run-1_IEDs.mat'];
        save(fullfile(saveFolder, saveName), 'IEDs');
    end
end
