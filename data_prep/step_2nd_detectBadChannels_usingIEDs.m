clc; clear; close all;
bids = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS';
taskG = {'0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nSub = 1:length(subjG)
    subjID = subjG{nSub};
    channellabel_IEDs = {};
    for nTask = 1:length(taskG)
        taskName =  taskG{nTask};
        load(fullfile(bids, subjID, 'ieeg', [subjID, '_task-', taskName, '_run-1_ieeg.mat']));
        load(fullfile(bids, subjID, 'ieeg', [subjID, '_task-', taskName, '_run-1_IEDs.mat']));
        channellabel_IEDs(:, nTask) = IEDs.label;
        trialLength = 2.5;
        switch taskName
            case '0back'
                IEDpointerAllTask{nTask} = constructIEDpointer(nb0Data, TRIG, IEDs);
            case '1back'
                IEDpointerAllTask{nTask} = constructIEDpointer(nb1Data, TRIG, IEDs);
            case '2back'
                IEDpointerAllTask{nTask} = constructIEDpointer(nb2Data, TRIG, IEDs);
        end
    end
    %% all task all trial
    IEDpointer2 = [];
    for nTask = 1:3
        for nTrial = 1:3
            IEDpointer2 = [IEDpointer2, IEDpointerAllTask{nTask}{nTrial}];
        end
    end
    %% find bad channel
    IEDpointer2 = IEDpointer2>0;
    IEDpointer2_IEDsum_aT = sum(IEDpointer2, 2);
    IEDthd = unique(IEDpointer2_IEDsum_aT);
    survivalTL = zeros(1, length(IEDthd));
    for nThd = 1:length(IEDthd)
        IEDpointer3 = IEDpointer2;
        IEDpointer3(IEDpointer2_IEDsum_aT>IEDthd(nThd), :) = [];
        IEDpointer3_IEDsum_aC = sum(IEDpointer3, 1);
        IEDpointer4 = IEDpointer3;
        IEDpointer4(:, IEDpointer3_IEDsum_aC>0) = [];
        survivalTL(nThd) = length(IEDpointer4(:));
    end
    % good channel labels
    [a, b] = max(survivalTL);
    IEDpointer3 = IEDpointer2;
    badChanPointer = IEDpointer2_IEDsum_aT>IEDthd(b);
    badChanLabels = channellabel_IEDs(badChanPointer, 1);
    goodChanLabels = channellabel_IEDs(~badChanPointer, 1);
    disp(subjID);
    disp(['number of good channels is: ', num2str(length(goodChanLabels))]);
    disp(['number of bad channels is: ', num2str(length(badChanLabels))]);
    % good trial pointer
    IEDpointer3(badChanPointer, :) = [];
    IEDpointer3_IEDsum_aC = sum(IEDpointer3, 1);
    goodTrialPointer = IEDpointer3_IEDsum_aC==0;
    goodTrialsPointer_0back = goodTrialPointer(1:120);
    goodTrialsPointer_1back = goodTrialPointer(121:240);
    goodTrialsPointer_2back = goodTrialPointer(241:360);
    disp(['0-back the number of good trials is: ', num2str(sum(goodTrialsPointer_0back))]);
    disp(['1-back the number of good trials is: ', num2str(sum(goodTrialsPointer_1back))]);
    disp(['2-back the number of good trials is: ', num2str(sum(goodTrialsPointer_2back))]);
    %% find good trial in resting
    load(fullfile(bids, subjID, 'ieeg', [subjID, '_task-resting_run-1_ieeg.mat']));
    load(fullfile(bids, subjID, 'ieeg', [subjID, '_task-resting_run-1_IEDs.mat']));
    channellabel_IEDs(:, 4) = IEDs.label;
    time = rsData.time{1};
    fsample = rsData.fsample;
    winBegin = ceil(10*fsample):ceil(trialLength*fsample):length(time)-ceil(12.5*fsample);
    winBeginTime  = time(winBegin);
    IEDpointer4 = zeros(length(IEDs.label), length(winBeginTime));
    for nWin = 1:length(winBeginTime)
        wBT = winBeginTime(nWin);
        wBE = wBT+2.5;
        for nIED = 1:size(IEDs.sampleinfo{1}, 1)
            IEDsampleinfo = IEDs.sampleinfo{1}(nIED, :);
            IEDbeginTime = IEDs.time{1}(IEDsampleinfo(2));
            if IEDbeginTime>wBT && IEDbeginTime <wBE
                IEDpointer4(:, nWin) = IEDpointer4(:, nWin) + IEDs.channelPointer{1}(:, nIED);
            end
        end
    end
    IEDpointer4(badChanPointer, :) = [];
    IEDpointer4_IEDsum_aC = sum(IEDpointer4, 1);
    goodTrialsPointer_resting = IEDpointer4_IEDsum_aC==0;
    disp(['resting the number of good trials is: ', num2str(sum(goodTrialsPointer_resting))]);
    %% save file
    saveFolder = fullfile(bids, subjID, 'ieeg');
    saveName = [subjID, '_denoise-rmIED_goodChannels_goodTrials.mat'];
    save(fullfile(saveFolder, saveName), 'goodChanLabels', 'goodTrialsPointer_resting', 'goodTrialsPointer_0back', ...
        'goodTrialsPointer_1back', 'goodTrialsPointer_2back');
end
%% subfunction
function IEDpointerAllTask = constructIEDpointer(Data, TRIG, IEDs)
    for nTrial = 1:length(Data.trial)
        time = Data.time{nTrial};
        winBeginTime  = time(diff(TRIG{nTrial})>0);
        IEDpointer = zeros(length(IEDs.label), length(winBeginTime));
        for nWin = 1:length(winBeginTime)
            wBT = winBeginTime(nWin);
            wBE = wBT+2.5;
            for nIED = 1:size(IEDs.sampleinfo{nTrial}, 1)
                IEDsampleinfo = IEDs.sampleinfo{nTrial}(nIED, :);
                IEDbeginTime = IEDs.time{nTrial}(IEDsampleinfo(2));
                if IEDbeginTime>wBT && IEDbeginTime <wBE
                    IEDpointer(:, nWin) = IEDpointer(:, nWin) + IEDs.channelPointer{nTrial}(:, nIED);
                end
            end
        end
        IEDpointerAllTask{nTrial} = IEDpointer;
    end
end