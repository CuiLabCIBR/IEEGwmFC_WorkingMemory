clc;clear;close all;
TFRFolder = 'github_replication/fig2_whiteMatter_timeFrequency/s7_cleanCorrectTFRsignals';
CHFolder = 'github_replication/fig2_whiteMatter_timeFrequency/s0_data_afterPrep';
savepath_org ='github_replication/fig3_WithinFreFC/s01_WihtinFre';
addpath(genpath('github_replication/function'));
taskG = {'resting', '0back', '1back', '2back'};
subjG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ...
    'sub-19', 'sub-20', 'sub-21','sub-23','sub-24'};


for nSub = 1:length(subjG)
    subjID = subjG{nSub};
    FCspearman_whole = cell(144, 4);
    FCres_whole = cell(144,4);%calculate the correlation matrix regressed the Euclidean distance
    for nTask = 1:length(taskG)
        taskName = taskG{nTask};
        disp(['current is ',subjID,' - ',taskName]);
        load(fullfile(TFRFolder, subjID, [subjID,'_task-',taskName, '_CCTFRsignals.mat']));%wmTRCC
        load(fullfile(CHFolder,[subjID,'_electrodeAtlas']));%wmGoodChans
        WMchanInfo = wmTFRCC.chanLabel';
        for i = 1:length(WMchanInfo)
            idx = find(strcmpi(wmGoodChans(:,1),WMchanInfo{i,1}));
            WMchanInfo(i,2:5) = wmGoodChans(idx,2:5); clear idx;
        end 
        clear wmGoodChans;
        idx = find(strcmpi(WMchanInfo(:,2),'InfFrontalB')|strcmpi(WMchanInfo(:,2),'MidFrontalB')|strcmpi(WMchanInfo(:,2),'AntCoronaR')|strcmpi(WMchanInfo(:,2),'SupCoronaR') ...
            |strcmpi(WMchanInfo(:,2),'SupParietalB')|strcmpi(WMchanInfo(:,2),'SpleniumCorpusC')|strcmpi(WMchanInfo(:,2),'TemporalB'));

        if (~isempty(idx)) & (length(idx)>1)
            wmGoodChans_used = WMchanInfo(idx,:); 
            clear WMchanInfo;
            signals = wmTFRCC.TFRsignals(:,:,:,idx);  clear idx; %144*500*trials*channel_used
            %80 trials are sufficient
            if size(signals,3)>80
                signals = signals(:,:,1:80,:);
            end
            freq = wmTFRCC.freq';
            
            %Euclidean distance matrix
            coor = cell2mat(wmGoodChans_used(:,4));
            for i = 1:size(coor,1)
               for j = 1:size(coor,1)
                   ED(i,j) = norm(coor(i,:)-coor(j,:));
               end
            end
            ED_vector = squareform(ED)';  
            clear i j coor ED;

%% calculate FC of WM channel
            for nFB = 1:size(signals,1)
                FCspearman = zeros(size(signals, 4), size(signals, 4), size(signals, 3));
                FCres = zeros(size(signals, 4), size(signals, 4), size(signals, 3));
                for nTrial = 1:size(signals, 3)
                    A = squeeze(signals(nFB, :, nTrial, :));
                    % spearman correlation FC
                    r_spearman = corr(A, 'type', 'Spearman'); 
                    r_spearman = r_spearman - diag(diag(r_spearman));
                    r_spearman = atanh(r_spearman);
                    FCspearman(:, :, nTrial) = r_spearman;
                    % res correlation FC
                    r_res = corr(A, 'type', 'Spearman'); 
                    r_res = r_res - diag(diag(r_res));
                    r_res_vector = squareform(r_res)'; 
                    [~,~,res] = regress(r_res_vector, [ones(length(r_res_vector),1), ED_vector]);
                    res = squareform(res);
                    FCres(:, :, nTrial) = res;
                end
                FCspearman_whole{nFB, nTask} = FCspearman;
                FCres_whole{nFB, nTask} = FCres;
            end
        end
    end
%% save data

    mkdir(fullfile(savepath_org, subjID))
    saveName = [subjID, '_WM_FC_Alltrials.mat'];
    save(fullfile(savepath_org,subjID, saveName), 'FCspearman_whole','FCres_whole', 'ED_vector','wmGoodChans_used','freq');
end