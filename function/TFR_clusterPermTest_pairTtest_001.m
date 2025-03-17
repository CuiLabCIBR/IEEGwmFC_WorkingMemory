function [t_origPOS, p_origPOS, t_origNEG, p_origNEG, clust_info] = TFR_clusterPermTest_pairTtest_001(TFRA, TFRB, PermN)
% cluster-based permutation test
%
%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    freqN = size(TFRA, 1);
    timeN = size(TFRA, 2);
    % freq hood
    for nFB1 = 1:freqN
        for nFB2 = 1:freqN
           freqHood(nFB1, nFB2) = abs(nFB1 - nFB2);
        end
    end
    freqHood(freqHood > 1) = 0;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % permute state
    An = size(TFRA, 3); Bn = size(TFRB, 3);
    ABn = An+Bn;
    permuteState = cell(PermN, 1);
    for nPerm = 1:PermN
        permuteState{nPerm} = randperm(ABn);
    end
    % pair t-test after permutation
    mx_clust_massNEG = zeros(PermN, 1);
    mx_clust_massPOS = zeros(PermN, 1);
    parfor nPerm = 1:PermN
        % permute
        disp(['Permutation Num is ', num2str(nPerm)]);
        permuteState1 = permuteState{nPerm};
        [mx_clust_massNEG(nPerm), mx_clust_massPOS(nPerm)] = pairTtest_cluster_permute(TFRA, TFRB, permuteState1, freqN, timeN, An, ABn, freqHood);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Compute t-scores of actual observations
    p_origPOS = zeros(freqN, timeN); t_origPOS = zeros(freqN, timeN);
    p_origNEG = zeros(freqN, timeN); t_origNEG = zeros(freqN, timeN);
    for nFB = 1:freqN
        for nT = 1:timeN
            A = squeeze(TFRA(nFB, nT, :)); B = squeeze(TFRB(nFB, nT, :));
            [~, p_origPOS(nFB, nT), ~, stats] = ttest(A, B, 'Alpha', 0.05, 'Tail', 'right');
            t_origPOS(nFB, nT) = stats.tstat;
            [~, p_origNEG(nFB, nT), ~, stats] = ttest(A, B, 'Alpha', 0.05, 'Tail', 'left');
            t_origNEG(nFB, nT) = stats.tstat;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute p-values
    pval=ones(freqN, timeN);
    %positive clusters
    [clust_ids, n_clust] = find_clusters(p_origPOS, 0.01, freqHood);
    clust_info.pos_clust_pval=ones(1, n_clust);
    clust_info.pos_clust_mass=zeros(1, n_clust);
    clust_info.pos_clust_ids=clust_ids;
    for a=1:n_clust
        use_ids=find(clust_ids==a);
        clust_mass=sum(t_origPOS(use_ids));
        clust_p=mean(mx_clust_massPOS>=clust_mass); 
        pval(use_ids)=clust_p;
        clust_info.pos_clust_pval(a)=clust_p;
        clust_info.pos_clust_mass(a)=clust_mass;
    end
    %negative clusters
    [clust_ids, n_clust] = find_clusters(p_origNEG, 0.01, freqHood);
    clust_info.neg_clust_pval=ones(1, n_clust);
    clust_info.neg_clust_mass=zeros(1, n_clust);
    clust_info.neg_clust_ids=clust_ids;
    for a=1:n_clust
        use_ids=find(clust_ids==a);
        clust_mass=sum(t_origNEG(use_ids));
        clust_p=mean(mx_clust_massNEG<=clust_mass);
        pval(use_ids)=clust_p;
        clust_info.neg_clust_pval(a)=clust_p;
        clust_info.neg_clust_mass(a)=clust_mass;
    end
end
%%
function [mx_clust_massNEG, mx_clust_massPOS] = pairTtest_cluster_permute(TFRA, TFRB, permuteState, freqN, timeN, An, ABn, freqHood)
    % pair t-test
    pt1 = zeros(freqN, timeN);
    tvalue1 = zeros(freqN, timeN);
    pt2 = zeros(freqN, timeN);
    tvalue2 = zeros(freqN, timeN);
    for nFB = 1:freqN
        for nT = 1:timeN
            A = squeeze(TFRA(nFB, nT, :)); B = squeeze(TFRB(nFB, nT, :));
            AB = [A, B];
            A = AB(permuteState(1:An)); B = AB(permuteState(An+1:ABn));
            [~, pt1(nFB, nT), ~, stats] = ttest(A, B, 'Alpha', 0.05, 'Tail', 'left');
            tvalue1(nFB, nT) = stats.tstat;
            [~, pt2(nFB, nT), ~, stats] = ttest(A, B, 'Alpha', 0.05, 'Tail', 'right');
            tvalue2(nFB, nT) = stats.tstat;
        end
    end
    % negative clusters
    [clust_ids, n_clust] = find_clusters(pt1, 0.01, freqHood);
    mx_clust_massNEG = find_mx_mass(clust_ids, tvalue1, n_clust, -1);
    % postive clusters
    [clust_ids, n_clust] = find_clusters(pt2, 0.01, freqHood);
    mx_clust_massPOS = find_mx_mass(clust_ids, tvalue2, n_clust, 1);
end
%%
function mx_clust_mass = find_mx_mass(clust_ids, data_t, n_clust, tail)
    mx_clust_mass=0;
    if n_clust>0
        for z=1:n_clust
            use_ids=(clust_ids==z);
            use_mass(z)=sum(data_t(use_ids));
        end
        if tail<0
            %looking for most negative cluster mass
            mx_clust_mass = min(use_mass);
        elseif tail>0
            %looking for most positive cluster mass
            mx_clust_mass = max(use_mass);
        end
    end
end
