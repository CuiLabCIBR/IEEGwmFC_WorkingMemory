clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function
fsample = 250;
load(fullfile('s5_TFRloadingEffect_allRightTrials', 'TFRsignals_0b1b2b_FrontalCont.mat'), 'TFRsignalsS');
TFRsample_0back = TFRsignalsS(:, 1:2*fsample, :);
TFRsample_2back = TFRsignalsS(:, 4*fsample+1:6*fsample, :);
[t_orig, p_orig, clust_info] = TFR_clusterPermTest_pairTtest(TFRsample_2back, TFRsample_0back, 1000, 0.01);
save(fullfile('s5_TFRloadingEffect_allRightTrials', 'LoadingEffect_clusterPermTest_0b2b_FrontalCont_001.mat'), ...
    "t_orig", "p_orig", "clust_info");
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc; clear; close all;
addpath Z:\xwiEEG_WorkingMemory_zhangshen\github_replication\function
fsample = 250;
load(fullfile('s5_TFRloadingEffect_allRightTrials', 'TFRsignals_0b1b2b_CoreDMN.mat'), 'TFRsignalsS');
TFRsample_0back = TFRsignalsS(:, 1:2*fsample, :);
TFRsample_2back = TFRsignalsS(:, 4*fsample+1:6*fsample, :);
[t_orig, p_orig, clust_info] = TFR_clusterPermTest_pairTtest(TFRsample_2back, TFRsample_0back, 1000, 0.01);
save(fullfile('s5_TFRloadingEffect_allRightTrials', 'LoadingEffect_clusterPermTest_0b2b_CoreDMN_001.mat'), ...
    "t_orig", "p_orig", "clust_info");

