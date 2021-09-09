function [ROIpairCorr,numFramesRemaining,numFramesScrubbed,totalNumFrames] = getROIpairCorrelations(rts,GS,WS,CS,fMPs,badVector,useGSR,numROIpairs,TR, minSecDataNeeded)
    % NOTE: RETURNS ALL CORRELATIONS AS Z TRANFORMED
    totalNumFrames = length(badVector);
    numFramesScrubbed = sum(badVector);
    numFramesRemaining = totalNumFrames - numFramesScrubbed;
    
    numSecondsOfDataNeeded = minSecDataNeeded;
    numFramesNeeded = ceil( numSecondsOfDataNeeded / TR);
    
    if( numFramesRemaining < numFramesNeeded ) %If less than 2 minutes of data remaining...
        ROIpairCorr = NaN(numROIpairs,1); %Return NaN
        numFramesScrubbed = totalNumFrames;
        numFramesRemaining = 0;
    else
        GSderiv = [0; diff(GS)];
        WSderiv = [0; diff(WS)];
        CSderiv = [0; diff(CS)];
        fMPderiv = [zeros(1,6); diff(fMPs)];
        
        if(useGSR)
            X = [GS GSderiv ...
                WS WSderiv CS CSderiv fMPs ...
                fMPs.^2 fMPderiv fMPderiv.^2];
        else
            X = ...
                [WS WSderiv CS CSderiv fMPs ...
                fMPs.^2 fMPderiv fMPderiv.^2];
        end
        try
            ROIpairCorr = tril( partialcorr(rts(~badVector,:) , X(~badVector,:)),  -1 );
        catch err
            disp(err);
            ROIpairCorr = NaN(numROIpairs,1); %If partialcorr breaks, return NaN
        end
        fixvec = ROIpairCorr(:) ~= 0;
        ROIpairCorr = ROIpairCorr(fixvec);
        ROIpairCorr = rToZ(ROIpairCorr);
    end
end

