function [Data, EventSeries] = f_readbdf(datafile, evtfile)
%F_READBDF
    evt = read_bdf(evtfile);
    evt = evt.event;
    evt = cell2mat(evt);

    cfg = [];
    cfg.dataset = datafile;
    Data = ft_preprocessing(cfg);
    time = Data.time{1};
    
    EventSeries = zeros(size(time));
    for nE = 1:length(evt)
        eventTime = evt(nE).offset_in_sec;
        eventValue = evt(nE).eventvalue;
        if contains(eventValue, 'Trigger')
            eventValue = f_strsplit(eventValue, ':');
            eventValue = str2double(eventValue{2});
            [~, indexMin] = min(abs(time - eventTime));
            EventSeries(indexMin) = eventValue;
        end
    end
end

