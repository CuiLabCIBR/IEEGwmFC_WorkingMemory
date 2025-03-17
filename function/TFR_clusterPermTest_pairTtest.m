function [t_orig, pt_orig, clust_info] = TFR_clusterPermTest_pairTtest(TFRA, TFRB, PermN, pThreshould)
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
        [mx_clust_massNEG(nPerm), mx_clust_massPOS(nPerm)] = pairTtest_cluster_permute(TFRA, TFRB, permuteState1, freqHood, pThreshould);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Compute t-scores of actual observations
    pt_orig = zeros(freqN, timeN); t_orig = zeros(freqN, timeN);
    for nFB = 1:freqN
        for nT = 1:timeN
            A = squeeze(TFRA(nFB, nT, :)); B = squeeze(TFRB(nFB, nT, :));
            [~, pt_orig(nFB, nT), ~, stats] = ttest(A, B, 'Tail', 'both');
            t_orig(nFB, nT) = stats.tstat;
        end
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % compute p-values
    pval=ones(freqN, timeN);
    %positive clusters
    pt_origPOS = pt_orig;
    pt_origPOS(t_orig<0) = 1;
    [clust_ids, n_clust] = find_clusters(pt_origPOS, pThreshould, freqHood);
    clust_info.pos_clust_pval=ones(1, n_clust);
    clust_info.pos_clust_mass=zeros(1, n_clust);
    clust_info.pos_clust_ids=clust_ids;
    for a=1:n_clust
        use_ids=find(clust_ids==a);
        clust_mass=sum(t_orig(use_ids));
        clust_p=mean(mx_clust_massPOS>=clust_mass); 
        pval(use_ids)=clust_p*2;
        clust_info.pos_clust_pval(a)=clust_p;
        clust_info.pos_clust_mass(a)=clust_mass;
    end
    %negative clusters
    pt_origNEG = pt_orig;
    pt_origNEG(t_orig>0) = 1;
    [clust_ids, n_clust] = find_clusters(pt_origNEG, pThreshould, freqHood);
    clust_info.neg_clust_pval=ones(1, n_clust);
    clust_info.neg_clust_mass=zeros(1, n_clust);
    clust_info.neg_clust_ids=clust_ids;
    for a=1:n_clust
        use_ids=find(clust_ids==a);
        clust_mass=sum(t_orig(use_ids));
        clust_p=mean(mx_clust_massNEG<=clust_mass);
        pval(use_ids)=clust_p*2;
        clust_info.neg_clust_pval(a)=clust_p;
        clust_info.neg_clust_mass(a)=clust_mass;
    end
end
%%
function [mx_clust_massNEG, mx_clust_massPOS] = pairTtest_cluster_permute(TFRA, TFRB, permuteState, freqHood, pThreshould)
    freqN = size(TFRA, 1);
    timeN = size(TFRA, 2);
    % pair t-test
    pt = zeros(freqN, timeN);
    tvalue = pt;
    for nFB = 1:size(TFRA, 1)
        for nT = 1:size(TFRA, 2)
            A = squeeze(TFRA(nFB, nT, :)); B = squeeze(TFRB(nFB, nT, :));
            AB = [A, B]; AB= AB(:); 
            An = length(A); Bn = length(B); ABn = An + Bn;
            A = AB(permuteState(1:An)); B = AB(permuteState(An+1:ABn));
            [~, pt(nFB, nT), ~, stats] = ttest(A, B, 'Tail', 'both');
            tvalue(nFB, nT) = stats.tstat;
        end
    end
    % negative clusters
    ptNEG = pt;
    ptNEG(tvalue>0) = 1;
    [clust_ids, n_clust] = find_clusters(ptNEG, pThreshould, freqHood);
    mx_clust_massNEG = find_mx_mass(clust_ids, tvalue, n_clust, -1);
    % postive clusters
    ptPOS = pt;
    ptPOS(tvalue<0) = 1;
    [clust_ids, n_clust] = find_clusters(ptPOS, pThreshould, freqHood);
    mx_clust_massPOS = find_mx_mass(clust_ids, tvalue, n_clust, 1);
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
