function badchannels = f_IED_badchannel(IEDs, winSize)
%
%
%
%%
    for nT = 1:length(IEDs.time)
        time = IEDs.time{nT};
        IEDsi = IEDs.sampleinfo{nT};
        IEDcp = IEDs.channelPointer{nT};
        chanlabels = IEDs.label;
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        fsample = time(2)-time(1);
        winSize = ceil(winSize/fsample);
        winBegin = 1:winSize:length(time);
        winEnd = winBegin+winSize-1;
        winEnd(winEnd>length(time)) = length(time);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        pointer = zeros(length(chanlabels), length(winBegin));
        for nW = 1:length(winBegin)
            for nI = 1:size(IEDsi, 1)
                IEDbegin = IEDsi(nI, 1);
                IEDend = IEDsi(nI, 2);
                if (IEDbegin>winBegin(nW) && IEDbegin<winEnd(nW)) || (IEDend>winBegin(nW) && IEDend<winEnd(nW))
                    pointer(IEDcp(:, nI)==1, nW) = 1;
                end
            end
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        IEDthd = unique(sum(pointer, 2));
        IEDthd = sort(IEDthd, 'descend');
        bcp = [];% bad channel pinter
        clearsize = [];
        for N = 1:length(IEDthd)
            newpointer = pointer;
            IEDsum = sum(newpointer, 2);
            bcp(:, N) = IEDsum>=IEDthd(N);
            newpointer(bcp(:, N)==1, :) = [];
            a = size(newpointer, 1);
            clearsum = sum(sum(newpointer, 1) == 0);
            clearsize(N) = a*clearsum;
        end
        [~, c] = max(clearsize);
        badchannels{nT} = chanlabels(bcp(:, c)==1);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    badchannelsC = {};
    for nT = 1:nT
        badchannelsC = [badchannelsC; badchannels{nT}];
    end
    badchannels = unique(badchannelsC);
end