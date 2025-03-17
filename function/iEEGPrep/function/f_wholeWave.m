function newEventSampleinfo = f_wholeWave(signal, eventSampleinfo)
%
%
%
%% Obtain the Whole Wave of Event
    EventBegin =  eventSampleinfo(:, 1);
    EventEnd = eventSampleinfo(:, 2);
    waveTroughPointer = f_waveTrough(signal);
    waveTroughIndex = find(waveTroughPointer>0);
    waveLength = ceil(4*max(diff(waveTroughIndex)));
    EventCount = length(EventBegin);
    pointer = zeros(size(signal));
    for nEvent = 1:EventCount
        oldBegin = EventBegin(nEvent);
        oldEnd = EventEnd(nEvent);
        pointer(oldBegin:oldEnd)=1;
        sampleList = oldBegin-waveLength:oldEnd+waveLength;
        sampleList(sampleList<=0) = [];
        sampleList(sampleList>length(waveTroughPointer)) = [];
        waveTroughPointer_soi = waveTroughPointer(sampleList);
        waveTrough_soi = find(waveTroughPointer_soi)+sampleList(1)-1;
        % New Begin of the Event
        C = waveTrough_soi - oldBegin;
        C(C>=0)=[];
        CUT = length(C);
        if CUT>0
            CUT = CUT - 2;
            CUT(CUT<1) = 1;
            newBegin = waveTrough_soi(CUT);
            pointer(newBegin:oldBegin) = 1;
        end
        % New End of the Event
        C = waveTrough_soi - oldEnd;
        C(C>0)=[];
        CUT = length(C)+1;
        CUT = CUT + 2;
        CUT(CUT>length(waveTrough_soi)) = length(waveTrough_soi);
        newEnd = waveTrough_soi(CUT);
        pointer(oldEnd:newEnd) = 1;
    end
    % New Event End and Event Begin
    [NewEventBegin, NewEventEnd] = f_eventDetection(pointer, 0, 0);
    newEventSampleinfo(:, 1) = NewEventBegin;
    newEventSampleinfo(:, 2) = NewEventEnd;
end