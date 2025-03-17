function [nb0task, nb1task, nb2task] = eventSort(nbackpsydat)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % extract interesting infomation from psychopy file
    nb0n = 0; nb1n = 0; nb2n = 0;
    for nTrial = 1:length(nbackpsydat.Task_img)
        taskimg = nbackpsydat.Task_img(nTrial); 
        if taskimg == 0 && ~isnan(nbackpsydat.Trial(nTrial))
            nb0n = nb0n + 1;
            nb0task.trial(nb0n,1) = nbackpsydat.Trial(nTrial);
            nb0task.ans(nb0n,1) = nbackpsydat.Ans(nTrial);
            nb0task.respkeys(nb0n,1) = nbackpsydat.key_respkeys(nTrial);
            nb0task.respcorr(nb0n,1) = nbackpsydat.key_respcorr(nTrial);
            nb0task.task_begin(nb0n,1) = nbackpsydat.Trial_textstarted(nTrial);
            nb0task.resprt(nb0n,1) = nbackpsydat.key_resprt(nTrial);
        elseif taskimg == 1 && ~isnan(nbackpsydat.Trial(nTrial))
            nb1n = nb1n + 1;
            nb1task.trial(nb1n,1) = nbackpsydat.Trial(nTrial);
            nb1task.ans(nb1n,1) = nbackpsydat.Ans(nTrial);
            nb1task.respkeys(nb1n,1) = nbackpsydat.key_respkeys(nTrial);
            nb1task.respcorr(nb1n,1) = nbackpsydat.key_respcorr(nTrial);
            nb1task.task_begin(nb1n,1) = nbackpsydat.Trial_textstarted(nTrial);
            nb1task.resprt(nb1n,1) = nbackpsydat.key_resprt(nTrial);
        elseif taskimg == 2 && ~isnan(nbackpsydat.Trial(nTrial))
            nb2n = nb2n + 1;
            nb2task.trial(nb2n,1) = nbackpsydat.Trial(nTrial);
            nb2task.ans(nb2n,1) = nbackpsydat.Ans(nTrial);
            nb2task.respkeys(nb2n,1) = nbackpsydat.key_respkeys(nTrial);
            nb2task.respcorr(nb2n,1) = nbackpsydat.key_respcorr(nTrial);
            nb2task.task_begin(nb2n,1) = nbackpsydat.Trial_textstarted(nTrial);
            nb2task.resprt(nb2n,1) = nbackpsydat.key_resprt(nTrial);
        end
    end
    nb0task = struct2table(nb0task);
    nb1task = struct2table(nb1task);
    nb2task = struct2table(nb2task);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % set outlier trial as bad
    % 0-back
    A = [find(nb0task.resprt<0.1); find(nb0task.resprt>2)];
    nb0task.respcorr(A) = 0;
    nb0task.resprt(A) = nan;
    A = find(nb0task.resprt>mean(nb0task.resprt, 'omitnan')+3*std(nb0task.resprt, 'omitnan'));
    nb0task.respcorr(A) = 0;
    nb0task.resprt(A) = nan;
    A = find(nb0task.resprt<mean(nb0task.resprt, 'omitnan')-3*std(nb0task.resprt, 'omitnan'));
    nb0task.respcorr(A) = 0;
    nb0task.resprt(A) = nan;
    % 1-back
    A = [find(nb1task.resprt<0.1); find(nb1task.resprt>2)];
    nb1task.respcorr(A) = 0;
    nb1task.resprt(A) = nan;
    nb1task.respcorr([1, 41, 81]) = 0;
    nb1task.resprt([1, 41, 81]) = nan;
    A = find(nb1task.resprt>mean(nb1task.resprt, 'omitnan')+3*std(nb1task.resprt, 'omitnan'));
    nb1task.respcorr(A) = 0;
    nb1task.resprt(A) = nan;
    A = find(nb1task.resprt<mean(nb1task.resprt, 'omitnan')-3*std(nb1task.resprt, 'omitnan'));
    nb1task.respcorr(A) = 0;
    nb1task.resprt(A) = nan;
    % 2-back
    A = [find(nb2task.resprt<0.1); find(nb2task.resprt>2)];
    nb2task.respcorr(A) = 0;
    nb2task.resprt(A) = nan;
    nb2task.respcorr([1, 2, 41, 42, 81, 82]) = 0;
    nb2task.resprt([1, 2, 41, 42, 81, 82]) = nan;
    A = find(nb2task.resprt>mean(nb2task.resprt, 'omitnan')+3*std(nb2task.resprt, 'omitnan'));
    nb2task.respcorr(A) = 0;
    nb2task.resprt(A) = nan;
    A = find(nb2task.resprt<mean(nb2task.resprt, 'omitnan')-3*std(nb2task.resprt, 'omitnan'));
    nb2task.respcorr(A) = 0;
    nb2task.resprt(A) = nan;
end

