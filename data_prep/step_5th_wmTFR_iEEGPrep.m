clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep
iEEGPrep_initial;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Prep setting
bids = fullfile('Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS');
taskG = {'resting', '0back', '1back', '2back'};
subG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subTFR_BadChanels{1} = {};% sub-01
subTFR_BadChanels{2} = {};
subTFR_BadChanels{3} = {'-p5', '-p6', '-p7','-p8', '-p9', '-p10', '-p11', '-p12', '-p13', '-p14', '-p15', ...
    '-th6', '-th7', '-th8', '-ta5', '-ta6', '-ta9', '-to6', '-to7', '-to10', '-to11', ...
    '-fu''4', '-fu''6', '-fu''7', '-fu''8', '-fu''9', '-fu''10', ...
    '-b4', '-b5', '-b6', '-oh''14', '-oh''15', '-oh''16', '-oh''17', '-oh''18', ...
    '-th''4', '-th''5', '-th''6', '-th''7', '-th''8'};
subTFR_BadChanels{4} = {};% sub-5
subTFR_BadChanels{5} = {};
subTFR_BadChanels{6} = {'-PI6', '-PI7', '-PI8', '-PI9'};% sub-7
subTFR_BadChanels{7} = {'-PC5', '-PC6', '-PC7', '-PC8', '-PC9', '-PC10', '-PC11', '-PC12', '-PC13', '-PC14', '-PI6', '-PI7'}; % sub-9
subTFR_BadChanels{8} = {}; % sub-10
subTFR_BadChanels{9} = {}; % sub-11
subTFR_BadChanels{10} = {}; % sub-12
subTFR_BadChanels{11} = {}; % sub-13
subTFR_BadChanels{12} = {'-TH''7', '-TH''8', '-TH''9', '-TH''10', ...
    '-TA''7', '-TA''8', '-TA''9', '-A''5', '-A''6', '-A''7', '-A''8', '-A''9', '-A''10'}; % sub-14
subTFR_BadChanels{13} = {};% sub-15
subTFR_BadChanels{14} = {};% sub-16
subTFR_BadChanels{15} = {}; % sub-17
subTFR_BadChanels{16} = {}; % sub-19
subTFR_BadChanels{17} = {}; % sub-20
subTFR_BadChanels{18} = {}; % sub-21
subTFR_BadChanels{19} = {}; % sub-23
subTFR_BadChanels{20} = {}; % sub-24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for nSub = 1:length(subG)
    subID = subG{nSub};
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find good channels
    load(fullfile(bids, subID, 'ieeg', [subID, '_electrodes.mat']));
    N = 0; wmChans = {};
    for nChan = 1:size(chanAtlasLabel, 1)
        if ~isempty(chanAtlasLabel{nChan, 4})
            N = N + 1;
            wmChans{N,1} = chanAtlasLabel{nChan, 1};
            wmChans{N,2} = chanAtlasLabel{nChan, 4};
            wmChans{N,3} = chanAtlasLabel{nChan, 5};
            wmChans{N,4} = chanAtlasLabel{nChan, 2};
            wmChans{N,5} = chanAtlasLabel{nChan, 7};
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % remove IED channels
    dataDir = dir(fullfile(bids, '**', [subID, '*_task-resting_run-1_ieeg.mat']));
    load(fullfile(dataDir.folder, dataDir.name));
    load(fullfile(bids, subID, 'ieeg', [subID, '_denoise-rmIED_goodChannels_goodTrials.mat']), 'goodChanLabels');
    cfg = []; 
    cfg.channel = goodChanLabels;
    rsData = ft_preprocessing(cfg, rsData);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %find good channels
    if ~isempty(subTFR_BadChanels{nSub})
        cfg = [];
        cfg.channel = [{'all'}, subTFR_BadChanels{nSub}];
        rsData = ft_preprocessing(cfg, rsData);
    end
    wmGoodChans = {}; N = 0;
    for nC1 = 1:size(wmChans)
        for nC2 = 1:size(rsData.label)
            if strcmpi(wmChans{nC1, 1}, rsData.label{nC2})
                N = N + 1;
                wmGoodChans{N, 1} = rsData.label{nC2};
                wmGoodChans{N, 2} = wmChans{nC1, 2};
                wmGoodChans{N, 3} = wmChans{nC1, 3};
                wmGoodChans{N, 4} = wmChans{nC1, 4};
                wmGoodChans{N, 5} = wmChans{nC1, 5};
            end
        end
    end
    saveFolder = 'wm_data_afterPrep';
    mkdir(saveFolder);
    save(fullfile(saveFolder, [subID, '_electrodeAtlas.mat']), 'wmGoodChans');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % preprocessing
    for nTask = 1:length(taskG)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % select good channels
        taskName =  taskG{nTask};
        TRIG = [];
        dataDir = dir(fullfile(bids, '**', [subID, '*_task-', taskName, '_run-1_ieeg.mat']));
        load(fullfile(dataDir.folder, dataDir.name));
        switch taskName
            case 'resting'; Data = rsData;  clear rsData;
            case '0back';   Data = nb0Data; clear nb0Data;
            case '1back';   Data = nb1Data; clear nb1Data;
            case '2back';   Data = nb2Data; clear nb2Data;
        end
        cfg = []; 
        cfg.channel = wmGoodChans(:, 1);
        Data = ft_preprocessing(cfg, Data);
        disp([subID, ' number of channel labels: ', num2str(length(Data.label))]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % perform detrend, demean, bandpass filtering, remove powerline noise
        freqPSD = f_PSD(Data, 1:1:140);
        PSD1 = log10(freqPSD.powspctrm);
        BPfreq = [1, 120];
        Data = f_filter_bandpass(Data, BPfreq);
        PLfreq = 50;
        Data = f_filter_powerlinenoise(Data, PLfreq, BPfreq, 1);
        freqPSD = f_PSD(Data, 1:1:140);
        PSD2 = log10(freqPSD.powspctrm);
        % Resample
        TRIGtime = Data.time;
        RSfreq = 250;
        Data = f_filter_resample(Data, RSfreq);
        % Reference
        chanGroups = f_chanGroup(Data.label);
        refMethod = 'CommonAverage';
        Data = f_reref_SEEG(Data, refMethod, chanGroups);
        freqPSD = f_PSD(Data, 1:1:120);
        PSD3 = log10(freqPSD.powspctrm);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % plot PSD
        subplot(2, 2, nTask);
        plot(mean(PSD1, 1, "omitnan"));
        hold on;
        plot(mean(PSD2, 1, "omitnan"));
        plot(mean(PSD3, 1, "omitnan"));
        hold off;
        xlabel('Frequency');
        ylabel('PSD');
        title([subID, ' ', taskName]);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save data file
        saveName = [subID, '_task-', taskName, '_run-1_ref-', refMethod, '_preproc_ieeg.mat'];
        save(fullfile(saveFolder, saveName), 'Data', 'TRIG', 'TRIGtime');
    end
    savefig(fullfile(saveFolder, [subID, '_PSD.fig']));
end
