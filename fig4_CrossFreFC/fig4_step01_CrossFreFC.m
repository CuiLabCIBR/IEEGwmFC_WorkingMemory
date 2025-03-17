
function fig4_step01_CrossFreFC(subjID)

    taskG = {'resting','0back','1back','2back'};
    TFRFolder = 'github_replication/fig2_whiteMatter_timeFrequency/s7_cleanCorrectTFRsignals';
    CHFolder = 'github_replication/fig2_whiteMatter_timeFrequency/s0_data_afterPrep';
    savepath_org ='github_replication/fig4_CrossFreFC/s01_CrossFre';
    mkdir(savepath_org);

    for nTask = 1:length(taskG)
        taskName = taskG{nTask};
        load(fullfile(TFRFolder, subjID, [subjID,'_task-',taskName, '_CCTFRsignals.mat']));%wmTRCC
        %% useful channel of ROI
        load(fullfile(CHFolder,[subjID,'_electrodeAtlas']));%wmGoodChans
        WMchanInfo = wmTFRCC.chanLabel';
        for i = 1:length(WMchanInfo)
            idx = find(strcmpi(wmGoodChans(:,1),WMchanInfo{i,1}));
            WMchanInfo(i,2:5) = wmGoodChans(idx,2:5); clear idx;
        end 
        clear wmGoodChans;

        idx = find(strcmpi(WMchanInfo(:,2),'InfFrontalB')|strcmpi(WMchanInfo(:,2),'MidFrontalB')|strcmpi(WMchanInfo(:,2),'AntCoronaR')|strcmpi(WMchanInfo(:,2),'SupCoronaR') ...
            |strcmpi(WMchanInfo(:,2),'SupParietalB')|strcmpi(WMchanInfo(:,2),'SpleniumCorpusC')|strcmpi(WMchanInfo(:,2),'TemporalB'));
%% calculate FC of WM channel
        if (~isempty(idx)) & (length(idx)>1)
            wmGoodChans_used = WMchanInfo(idx,:); 
            clear WMchanInfo;
            signals = wmTFRCC.TFRsignals(:,:,:,idx);  clear idx; %144*500*trials*channel_used
            if size(signals,3)>80
                signals = signals(:,:,1:80,:);
            end
            signals_low = signals(1:54,:,:,:); %low frequency 4-30Hz
            signals_high = signals(54:144,:,:,:);  %high frequency 30-120Hz
            freq = wmTFRCC.freq;

            FCspearman = zeros(size(signals_low,1),size(signals_high,1),size(signals,4), size(signals,4),size(signals,3));
            for nTrial = 1:size(signals, 3)
                for i = 1:size(signals_low,1)
                    for j = 1:size(signals_high,1)
                        A = squeeze(signals_low(i, :, nTrial, :));
                        B = squeeze(signals_high(j, :, nTrial, :));
                        % spearman correlation FC
                        r_spearman = corr(A,B,'type', 'Spearman'); 
                        FCspearman(i,j,:, :, nTrial) = r_spearman;
                    end
                end
            end
            present1 = squeeze(mean(FCspearman,5,'omitnan'));
            present2 = squeeze(mean(FCspearman,[1,2,5],'omitnan'));
            FCspearman_whole_orig{1, nTask} = FCspearman;
            FCspearman_whole{1, nTask} = present1;
            FCspearman_whole_mean{1, nTask} = present2;
            clear present1 present2 FCspearman;
    end
%% save data

    mkdir(fullfile(savepath_org, subjID))
    saveName = [subjID, '_WM_FC_Alltrials.mat'];
    save(fullfile(savepath_org,subjID, saveName), 'FCspearman_whole_orig','FCspearman_whole','FCspearman_whole_mean','wmGoodChans_used');
end