function IEDs = f_IED_detection(Data, BPFreq, winSize, Threshold, timeLThd, intervalLThd)
%
%
%
%%
    % Initial setting
    fsample = Data.fsample;
    chanLabel = Data.label;

    % Perform Bandpass filtering 
    disp(['****IED Detection Step 1: Bandpass Filtering ', num2str(BPFreq(1)), '-', num2str(BPFreq(2)), 'Hz', ' Using Fieldtrip Toolbox.']); 
    disp(['****', char(datetime('now'))]); % Display the current date and time 
    Data = f_filter_bandpass(Data, BPFreq);
    
    % Calculate Envelope and Threshold curver
    disp('****IED Detection Step 2: Calculate Envelope of iEEG Signal.'); 
    disp(['****', char(datetime('now'))]); % Display the current date and time  
    % Computes the envelope of the filtered iEEG signal.
    iEEGEnvelope = f_envelope(Data);
    iEEGTrial = Data.trial;
    iEEGtime = Data.time;
    clear Data;

    % 
    disp('****IED Detection Step 3: Calculate threshould curve and find Event above Threshold');
    disp(['****', char(datetime('now'))]); % Display the current date and time
    % Computes the threshold curve for IED detection and construct IED pointer.
    sampleinfoEachChannel = f_IED_sampleinfo(iEEGEnvelope, winSize, Threshold);
    clear iEEGEnvelope;
    
    % find wholw IEDs of each channe;
    disp('****IED Detection Step 4: Find whole IEDs.');
    disp(['****', char(datetime('now'))]); % Display the current date and time
    trialCount = size(sampleinfoEachChannel, 2);
    chanCount = size(chanLabel, 1);
    for nTrial = 1:trialCount
        for nChan = 1:chanCount
            if size(sampleinfoEachChannel{nChan, nTrial})>0
                disp(['****Find IEDs of Trial - ', num2str(nTrial), ' of channel - ', num2str(nChan)]);
                disp(['****', char(datetime('now'))]); % Display the current date and time
                signalChannel = iEEGTrial{nTrial}(nChan, :);
                sampleinfoEachChannel{nChan, nTrial} = f_wholeWave(signalChannel, sampleinfoEachChannel{nChan, nTrial});
            end
        end
    end
    
    
    % find IED event of whole brain
    disp('****IED Detection Step 5: Find whole IEDs.');
    disp(['****', char(datetime('now'))]); % Display the current date and time
    timeLThd = ceil(timeLThd*fsample);% convert second to sample
    intervalLThd = ceil(intervalLThd*fsample);
    IEDs.time = iEEGtime;
    IEDs.label = chanLabel;
    for nTrial = 1:trialCount
        pointer = zeros(chanCount, length(IEDs.time{nTrial}));
        channelPointer = zeros(chanCount, 1);
        for nChan = 1:chanCount
            sampleinfo = sampleinfoEachChannel{nChan, nTrial};
            for nEvent = 1:size(sampleinfo, 1)
                pointer(nChan, sampleinfo(nEvent, 1):sampleinfo(nEvent, 2)) = 1;
            end
        end
        pointerSum = sum(pointer, 1)>1;
        [eventBegin, eventEnd, ~] = f_eventDetection(pointerSum, timeLThd, intervalLThd);
        for nEvent = 1:length(eventBegin)
            channelPointer(:, nEvent) = sum(pointer(:, eventBegin(nEvent):eventEnd(nEvent)), 2)>1;
        end
        IEDs.sampleinfo{nTrial} = [eventBegin(:), eventEnd(:)];
        IEDs.channelPointer{nTrial} = channelPointer;
    end

    %
    disp('****Finish IED Detection!');
    disp(['****', char(datetime('now'))]); % Display the current date and time
end



