%% perform preprocessing of ieeg file
clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\fieldtrip-20231220
ft_defaults;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function\iEEGPrep
iEEGPrep_initial;
bids = fullfile('Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% bad channel file
subTFR_BadChanels{1} = {'-MF12', '-F12'}; % sub-01
subTFR_BadChanels{2} = {'-TB''11', '-TA11', '-TA12'};
subTFR_BadChanels{3} = {'-p17', '-p18', '-fu''12', '-fu''11', '-th''11', '-th''12'};
subTFR_BadChanels{4} = {};% sub-5
subTFR_BadChanels{5} = {'-B''3', '-B''8', '-F''2', '-F''6', '-F''7', '-F''8'};% sub-6
subTFR_BadChanels{6} = {};
subTFR_BadChanels{7} = {'-PI1', '-PI2', '-PI5', '-B3', '-B4', '-B8', '-B''2', '-B''6', '-B''7'}; % sub-09
subTFR_BadChanels{8} = {};
subTFR_BadChanels{9} = {}; % sub-11
subTFR_BadChanels{10} = {'-B''9', '-FU''11', 'TB11', '-TB''10', '-TB''11', '-TI''9'}; % sub-12
subTFR_BadChanels{11} = {'-b2', '-b3', '-b4'}; % sub-13
subTFR_BadChanels{12} = {'-F''12', '-TA''12', '-B''7', '-B''8', '-B''9'}; % sub-14
subTFR_BadChanels{13} = {'-K11', '-K14', '-K15'}; % sub-15
subTFR_BadChanels{14} = {'-D10', '-D11', '-D12', '-G15', '-G16'}; % sub-16
subTFR_BadChanels{15} = {};% sub-17
subTFR_BadChanels{16} = {};% sub-19
subTFR_BadChanels{17} = {'-mf''12'};% sub-20
subTFR_BadChanels{18} = {};% sub-21
subTFR_BadChanels{19} = {};% sub-23
subTFR_BadChanels{20} = {};% sub-24
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% subject list and task list
taskG = {'resting', '0back', '1back', '2back'};
subG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% constrcut good gm channel list
for nSub = 1:length(subG)
    subID = subG{nSub};
    % import resting state ieeg data
    dataDir = dir(fullfile(bids, '**', [subID, '*_task-resting_run-1_ieeg.mat']));
    load(fullfile(dataDir.folder, dataDir.name));% load raw ieeg file
    % remove bad channels
    if ~isempty(subTFR_BadChanels{nSub})
        cfg = [];
        cfg.channel = [{'all'}, subTFR_BadChanels{nSub}];
        rsData = ft_preprocessing(cfg, rsData);
    end
    % remove IED channels
    load(fullfile(bids, subID, 'ieeg', [subID, '_denoise-rmIED_goodChannels_goodTrials.mat']), 'goodChanLabels');
    cfg = []; 
    cfg.channel = goodChanLabels;
    rsData = ft_preprocessing(cfg, rsData);
    % Find gray matter channel
    load(fullfile(bids, subID, 'ieeg', [subID, '_electrodes.mat']));
    N = 0; gmChans = {};
    for nChan = 1:size(chanAtlasLabel, 1)
        if ~isempty(chanAtlasLabel{nChan, 3})
            N = N + 1;
            gmChans{N,1} = chanAtlasLabel{nChan, 1};
            gmChans{N,2} = chanAtlasLabel{nChan, 3}{1};
            gmChans{N,3} = chanAtlasLabel{nChan, 5};
            gmChans{N,4} = chanAtlasLabel{nChan, 2};
            gmChans{N,5} = chanAtlasLabel{nChan, 7};
            gmChans{N,6} = chanAtlasLabel{nChan, 3}{2};
            gmChans{N,7} = chanAtlasLabel{nChan, 3}{3};
        end
    end
    % construct good gm channel information
    gmGoodChans = {}; N = 0;
    for nC1 = 1:size(gmChans)
        for nC2 = 1:size(rsData.label)
            if strcmpi(gmChans{nC1, 1}, rsData.label{nC2})
                N = N + 1;
                gmGoodChans{N, 1} = rsData.label{nC2};
                gmGoodChans{N, 2} = gmChans{nC1, 2};
                gmGoodChans{N, 3} = gmChans{nC1, 3};
                gmGoodChans{N, 4} = gmChans{nC1, 4};
                gmGoodChans{N, 5} = gmChans{nC1, 5};
                gmGoodChans{N, 6} = gmChans{nC1, 6};
                gmGoodChans{N, 7} = gmChans{nC1, 7};
            end
        end
    end
    saveFolder = 'gm_data_afterPrep';
    mkdir(saveFolder);
    save(fullfile(saveFolder, [subID, '_electrodeAtlas.mat']), 'gmGoodChans');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% ieeg preprocessing
for nSub = 1:length(subG)
    subID = subG{nSub};
    load(fullfile(saveFolder, [subID, '_electrodeAtlas.mat']))
    % perform preprocessing
    for nTask = 1:length(taskG)
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
        cfg.channel = gmGoodChans(:, 1);
        Data = ft_preprocessing(cfg, Data);
        disp([subID, ' number of channel labels: ', num2str(length(Data.label))]);
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
        % save data file
        saveName = [subID, '_task-', taskName, '_run-1_ref-', refMethod, '_preproc_ieeg.mat'];
        save(fullfile(saveFolder, saveName), 'Data', 'TRIG', 'TRIGtime');
    end
    savefig(fullfile(saveFolder, [subID, '_PSD.fig']));
end
