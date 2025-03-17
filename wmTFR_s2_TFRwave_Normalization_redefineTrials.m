%% Z-score Normalization of TFR signals and redefineTrials using task triger;
clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep;
iEEGPrep_initial;
datafolder = 'replication\s1_channelTFR';
taskG = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nSub = 1:length(subjG)
    %% loading TFR data 
    subjID = subjG{nSub};
    chanLength = length(dir(fullfile(datafolder, subjID, [subjID, '_task-resting_chan-*_channelTFR.mat'])));
    for nChan = 1:chanLength
        TFRsignals_CAT = [];
        for nTask = 1:length(taskG)
            taskName = taskG{nTask};
            dataDir = dir(fullfile(datafolder, subjID, [subjID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat']));
            TFRwave{nTask} = load(fullfile(dataDir.folder, dataDir.name));
            for nTrial = 1:length(TFRwave{nTask}.channelTFR.trial)
                TFRsignals_CAT = [TFRsignals_CAT, TFRwave{nTask}.channelTFR.trial{nTrial}];
            end
        end
        TFRsignals_CAT = log10(TFRsignals_CAT);
        TFRsignals_CATMean = mean(TFRsignals_CAT, 2, 'omitnan');
        TFRsignals_CATStd = std(TFRsignals_CAT, 0, 2, 'omitnan');
    %% normalization
        for nTask = 1:length(TFRwave)
            for nTrial = 1:length(TFRwave{nTask}.channelTFR.trial)
                signals = TFRwave{nTask}.channelTFR.trial{nTrial};
                signals = log10(signals);
                signals = (signals - TFRsignals_CATMean)./TFRsignals_CATStd;
                TFRwave{nTask}.channelTFR.trial{nTrial} = signals;
            end
        end
    %% redefine trials
        for nTask = 1:length(TFRwave)
            taskName = taskG{nTask};
            coi = TFRwave{nTask}.coi;
            trialLength = 2.5;
            trial_0time = 0.5;
            switch taskName
                case 'resting'
                    TFRdata = TFRwave{nTask}.channelTFR;
                    time = TFRdata.time{1};
                    fsample = TFRdata.fsample;
                    winBegin = ceil(10*fsample):ceil(trialLength*fsample):length(time)-ceil(12.5*fsample);
                    TRIG = {zeros(size(time))};
                    TRIG{1}(winBegin) = 1;
                    TRIGtime = {time};
                    TFRtrials = f_redefineTrial(TFRdata, TRIG, TRIGtime, trialLength, trial_0time);
                    savefolder = fullfile('replication\s2_channelTFR_redefineTrials', subjID);
                    mkdir(savefolder);
                    saveName = [subjID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat'];
                    save(fullfile(savefolder, saveName), 'TFRtrials', 'coi');
                case {'0back', '1back', '2back'}
                    % load TRIG and TRIGtime
                    ieegPrepFolder = 's0_data_afterPrep';
                    TRIGdir = dir(fullfile(ieegPrepFolder, [subjID, '_task-', taskName, '_run-1_ref-*_preproc_ieeg.mat']));
                    load(fullfile(TRIGdir.folder, TRIGdir.name), 'TRIG');
                    load(fullfile(TRIGdir.folder, TRIGdir.name), 'TRIGtime');
                    % redefine trials
                    TFRdata = TFRwave{nTask}.channelTFR;
                    trial_0time = 0.5;
                    TFRtrials = f_redefineTrial(TFRdata, TRIG, TRIGtime, trialLength, trial_0time);
                    saveName = [subjID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat'];
                    save(fullfile(savefolder, saveName), 'TFRtrials', 'coi');
            end
        end
        disp(['complete ', subjID, ' channel-', coi]);
    end
end