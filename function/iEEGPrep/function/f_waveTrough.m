function waveTroughPointer = f_waveTrough(signal)
    dfSignal = diff(signal);
    dfSignal(dfSignal>0) = 1; 
    dfSignal(dfSignal<0) = -1;
    ddfSignal = diff(dfSignal);
    waveTrough = find(abs(ddfSignal) > 0) + 1;
    waveTroughPointer  =zeros(size(signal));
    waveTroughPointer(waveTrough) = 1;
end