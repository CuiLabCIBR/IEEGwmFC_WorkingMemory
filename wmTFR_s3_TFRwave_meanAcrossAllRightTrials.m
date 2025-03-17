%% Normalize to resting baseline and calculate mean TFR across all right trials
clc; clear; close all;
datafolder = 'replication\s2_channelTFR_redefineTrials';
taskG = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
foi1 = 4:0.25:13; foi2 = 13:1:120; foi = unique([foi1, foi2]);
fsample = 250;
for nSub = 1:length(subjG)
%% loading TFR trials
    subjID = subjG{nSub};
    chanLength = length(dir(fullfile(datafolder, subjID, [subjID, '_task-resting_chan-*_channelTFR.mat'])));
    TFR = cell(chanLength, 6);
    for nChan = 1:chanLength
        TFRalltask = [];
        for nTask = 1:length(taskG)
            taskName = taskG{nTask};
            TFRdir = dir(fullfile(datafolder, subjID, [subjID, '_task-', taskName, '_chan-', num2str(nChan, '%03d'), '_channelTFR.mat']));
            load(fullfile(TFRdir.folder, TFRdir.name));
            disp(['Channel label is: ', subjID, '-' coi]);
            TFRsignals = TFRtrials.trial;
%% find correct trial
            load(fullfile('s0_taskInfo', [subjID, '_event.mat']));
            load(fullfile('s0_IEDInfo', [subjID, '_denoise-rmIED_goodChannels_goodTrials.mat']));
            switch taskName
                case 'resting'
                    correctIndex = ones(length(TFRsignals), 1);
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
%% mean across trials
            trialN = 0;
            TFRmean = zeros([size(TFRsignals{1}), length(correctIndex)]);
            for nTrial = 1:length(correctIndex)
                if correctIndex(nTrial) == 1
                    A = TFRsignals{nTrial};
                    A = movmean(A, 0.1*fsample, 2);
                    if sum(isnan(A(:)))==0
                        trialN = trialN + 1;
                        TFRmean(:, :, trialN) = A;
                    end
                end
            end
            if trialN<nTrial
                TFRmean(:, :, trialN+1:end) = [];
            end
            TrialNum(nTask) = trialN;
            disp(['Trial num is ', num2str(trialN)]);
            TFRmean = squeeze(mean(TFRmean, 3, "omitnan"));
            TFRalltask = [TFRalltask, TFRmean];
        end
        TFRrest = TFRalltask(:, 1:2.5*fsample);
        TFRrest_Mean = mean(TFRrest, 2, 'omitnan');
        TFRalltask = TFRalltask - TFRrest_Mean;
%% find correct channel atlas
        load(fullfile('s0_data_afterPrep', [subjID, '_electrodeAtlas.mat']));
        for nChan2 = 1:size(wmGoodChans, 1)
           if  strcmpi(wmGoodChans{nChan2, 1}, coi)
               channelLabel = coi;
               disp(channelLabel);
               channelAtlas1 = wmGoodChans{nChan2, 2};
               AtlasP = wmGoodChans{nChan2, 3};
               MNI = wmGoodChans{nChan2, 4};
           end
        end
        load(fullfile('s0_data_afterPrep', [subjID, '_electrodeAtlas_fiberToYeo7.mat']));
        for nChan2 = 1:size(wmChanInfo_fiberToYeo7, 1)
           if  strcmpi(wmChanInfo_fiberToYeo7{nChan2, 1}, coi)
               channelAtlas2 = wmChanInfo_fiberToYeo7{nChan2, 3};
               channelAtlas3 = wmChanInfo_fiberToYeo7{nChan2, 4};
               channelAtlas4 = wmChanInfo_fiberToYeo7{nChan2, 5};
               channelAtlas5 = wmChanInfo_fiberToYeo7{nChan2, 6};
           end
        end
%% save the TFR mean data to a cell 
        TFR{nChan, 1} = TFRalltask;
        TFR{nChan, 2} = [subjID, channelLabel];
        TFR{nChan, 3} = channelAtlas1;
        TFR{nChan, 4} = AtlasP;
        TFR{nChan, 5} = MNI;
        TFR{nChan, 6} = TrialNum;
        TFR{nChan, 7} = channelAtlas2;
        TFR{nChan, 8} = channelAtlas3;
        TFR{nChan, 9} = channelAtlas4;
        TFR{nChan, 10} = channelAtlas5;
%% plot
        close all;
        AX = figure;
        AX.Position = [200, 300, 1500, 600];
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TFRworkingmemory = TFRalltask;
        lims = min(abs(min(TFRworkingmemory(:))), abs(max(TFRworkingmemory(:))));
        clims = [-lims, lims];
        imagesc(TFRworkingmemory, clims);
        axis xy; colorbar; hold on; colormap jet;
        xline([0.5*fsample, 3*fsample, 5.5*fsample, 8*fsample], ...
            'LineStyle', '--', 'LineWidth', 2, 'Color', 'black');
        xline([2.5*fsample, 5*fsample, 7.5*fsample], ...
            'LineStyle', '-', 'LineWidth', 2, 'Color', 'black');
        xticks([1:0.5*fsample:4*2.5*fsample, 4*2.5*fsample]);
        xticklabels({'-0.5', '0', '0.5', '1.0', '1.5', ...
            '-0.5', '0', '0.5', '1.0', '1.5', ...
            '-0.5', '0', '0.5', '1.0', '1.5', ...
            '-0.5', '0', '0.5', '1.0', '1.5', '2'});
        xlabel('Time (s)'); 
        yline([17, 37, 54, 94], 'LineStyle', '--', 'Color', 'black', 'LineWidth', 2);
        yticks([1, 17, 37, 54, 94, 144]);
        yticklabels({'4Hz', '8Hz', '13Hz', '30Hz', '70Hz', '120Hz'});
        set(gca, 'FontName', 'Arial', 'FontSize', 16);
        title([subjID, ' task ', channelLabel, ' ', channelAtlas1, ' ', channelAtlas2, ' ', channelAtlas4]);
        hold off;
        pause(1);
        saveFolder = 'replication\s3_TFRmeanAcrossAllRightTrials';
        mkdir(saveFolder);
        mkdir(fullfile(saveFolder, subjID));
        savefig(fullfile(saveFolder, subjID, [channelAtlas1, '_', channelAtlas2, '_', channelAtlas4, '_chan-', num2str(nChan, '%03d'), '.fig']));
    end
    saveName = ['TFRmean_acrossAllRightTrials_', subjID , '.mat'];
    save(fullfile(saveFolder, saveName), 'TFR');
end
