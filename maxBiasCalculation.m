function [maxBias] = maxBiasCalculation(totalNumFramesRemaining,totalNumFrames,targetedRs,randomRs)
  
    keepSubj = totalNumFramesRemaining(1,:) > 0;
    
    subjTotalNumFrames = sum(totalNumFrames(:,keepSubj),2);
    framesRemaining = sum(totalNumFramesRemaining(:,keepSubj),2);
    
    numFramesRemoved = subjTotalNumFrames - framesRemaining;
    meanRinROIpair = targetedRs - randomRs;
    
    percentFramesRemoved = 100.*numFramesRemoved./subjTotalNumFrames;
    interpPct = 0:0.01:100;
    [uniquePct, uniqueIndex] = unique(percentFramesRemoved);
    uniqueROIpairR = abs(meanRinROIpair(:,uniqueIndex)); 
    notIsNaN = ~any(isnan(uniqueROIpairR));
    uniquePctNoNaN = uniquePct(notIsNaN);
    interpPctWithinRange = interpPct( (interpPct >= min(uniquePctNoNaN)) & (interpPct <= max(uniquePctNoNaN)) );
    uniqueROIpairRnoNaN = uniqueROIpairR(:,notIsNaN);
    interpROIpairR = abs(interp1(uniquePctNoNaN,uniqueROIpairRnoNaN',interpPctWithinRange ));
    interpPctWithinRange = interpPctWithinRange';
    
    
    numROIpairs = size(interpROIpairR,2);
    ROIrobBiasSlope = nan(numROIpairs,1);
    
    parfor i = 1:size(interpROIpairR,2)
        try
            toFitR = interpROIpairR(:,i);
            ROIrobBiasSlope(i) = robustfit(interpPctWithinRange,toFitR,'bisquare',4.685,'off');
        catch err
            ROIrobBiasSlope(i) = NaN;
        end
        if(~mod(i,1000))
            disp(num2str(100*i/numROIpairs)); pause(eps); drawnow;
        end
    end
    maxBias = ROIrobBiasSlope.*100;
    
end

