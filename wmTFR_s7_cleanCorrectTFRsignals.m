%% extract clean and correct trial TFR signal of each subject and each channel
clc; clear; close all;
datafolder = 's2_channelTFR_redefineTrials';
taskG = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foi1 = 4:0.25:13; foi2 = 13:1:120; foi = unique([foi1, foi2]);
fsample = 250;
for nSub = 1:length(subjG)
    subID = subjG{nSub};
    chanLength = length(dir(fullfile(datafolder, subID, [subID, '_task-resting_chan-*_channelTFR.mat'])));
    for nTask = 1:length(taskG)
        taskName = taskG{nTask};
        % find IED-clean and correct trial
        load(fullfile('s0_taskInfo', [subID, '_event.mat']));
        load(fullfile('s0_IEDInfo', [subID, '_denoise-rmIED_goodChannels_goodTrials.mat']));
        switch taskName
            case 'resting'
                correctIndex = ones(length(goodTrialsPointer_resting(:)), 1);
                correctIndex = correctIndex(:)+goodTrialsPointer_resting(:);
            case '0back'
                correctIndex = nb0task.respcorr;
                correctIndex = correctIndex(:)+goodTrialsPointer_0back(:);
            case '1back'
                correctIndex = nb1task.respcorr;
                correctIndex = correctIndex(:)+goodTrialsPointer_1back(:);
            case '2back'
                correctIndex = nb2task.respcorr;
                correctIndex = correctIndex(:)+goodTrialsPointer_2back(:);
        end
        correctIndex = correctIndex==2;
        TFRsignalsCC = []; chanlabel = {};
        TFRsignalsCC = single(TFRsignalsCC);
        for nChan = 1:chanLength
            TFRdir = dir(fullfile(datafolder, subID, [subID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat']));
            load(fullfile(TFRdir.folder, TFRdir.name));
            disp(['Channel label is: ', subID, '-' coi]);
            chanlabel{nChan} = coi;
            TFRsignals = TFRtrials.trial;
            % extract clean and correct TFR signals
            trialN = 0;
            for nTrial = 1:length(correctIndex)
                if correctIndex(nTrial) == 1
                    A = TFRsignals{nTrial};
                    A = movmean(A, 0.1*fsample, 2);
                    A = A(:, 0.5*fsample+1:end);
                    if sum(isnan(A(:)))==0
                        trialN = trialN + 1;
                        A = single(A);
                        TFRsignalsCC(:, :, trialN, nChan) = A;
                    end
                end
            end
        end
        %% save clean and correct TFR signals
        wmTFRCC.TFRsignals = TFRsignalsCC;
        wmTFRCC.dim = {'freq', 'time', 'trial', 'channel'};
        wmTFRCC.freq = foi;
        wmTFRCC.time = [0, 2];
        wmTFRCC.fsample = fsample;
        wmTFRCC.chanLabel = chanlabel;
        wmTFRCC.task = taskName;
        savename = [subID, '_task-', taskName, '_CCTFRsignals.mat'];
        savefolder = fullfile('s7_cleanCorrectTFRsignals', subID);
        mkdir(savefolder);
        save(fullfile(savefolder, savename), 'wmTFRCC', '-v7.3');
    end
end