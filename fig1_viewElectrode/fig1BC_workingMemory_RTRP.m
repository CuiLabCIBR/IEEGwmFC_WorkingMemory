clc; clear; close all;
BIDS = 'Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\data_prep\BIDS';
subG = {'sub-01', 'sub-02', 'sub-03', 'sub-05', 'sub-06', ...
    'sub-07', 'sub-09', 'sub-10', 'sub-11', 'sub-12', ...
    'sub-13', 'sub-14', 'sub-15', 'sub-16', 'sub-17', ....
    'sub-19', 'sub-20', 'sub-21', 'sub-23', 'sub-24'};
for nSub = 1:length(subG)
    %% loading TFR trials
    subjID = subG{nSub};
    %% find correct trial
    load(fullfile(BIDS, subjID, 'ieeg', [subjID, '_event.mat']));
    Pb(1, nSub) = sum(nb0task.respcorr)./(120-sum(isnan(nb0task.resprt)));
    Pb(2, nSub) = sum(nb1task.respcorr)./(120-sum(isnan(nb1task.resprt)));
    Pb(3, nSub) = sum(nb2task.respcorr)./(120-sum(isnan(nb2task.resprt)));
    RT(1, nSub) = mean(nb0task.resprt, 1, 'omitnan');
    RT(2, nSub) = mean(nb1task.resprt, 1, 'omitnan');
    RT(3, nSub) = mean(nb2task.resprt, 1, 'omitnan');
end
%%
save('PbRT.mat', 'Pb', 'RT');
%%
figure
plot(Pb, 'LineStyle', '-', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'Color', [0, 0, 0]);
xlim([0.5, 3.5]);
xticks([1, 2, 3]);
xticklabels({'0-back', '1-back', '2-back'});
ylabel('Accuracy');
set(gca, 'box', 'off', 'FontName', 'Arial', 'FontSize', 20, 'LineWidth', 2);
figure
plot(RT, 'LineStyle', '-', 'LineWidth', 2, 'Marker', 'o', 'MarkerSize', 3, 'Color', [0, 0, 0]);
xlim([0.5,3.5]);
xticks([1, 2, 3]);
xticklabels({'0-back', '1-back', '2-back'});
ylabel('Raction Time (s)');
set(gca, 'box', 'off', 'FontName', 'Arial', 'FontSize', 20, 'LineWidth', 2);