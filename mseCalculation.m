function [optimalDV, optimalFD, optimalPCT, minMSE] = mseCalculation(maxBias,totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining, pathToInternalDataFolder,useGSR)
    %Calculation of delta MSE-RSFC per Section 2.3.2
    
    subjTotalNumFrames = sum(totalNumFrames,2);
    framesRemaining = sum(totalNumFramesRemaining,2);
    numFramesRemoved = subjTotalNumFrames - framesRemaining;
    percentFramesRemoved = 100.*numFramesRemoved./subjTotalNumFrames;
    
    meanRinROIpair = targetedRs - randomRs;
    numSubjectsRemaining = sum(totalNumFramesRemaining>0,2)';

    [uniquePct, uniqueIndex] = unique(percentFramesRemoved);
    uniqueROIpairR = abs(meanRinROIpair(:,uniqueIndex));
    uniqueMeanVarR = targetedVariance(:,uniqueIndex); 
    uniqueNumSubjectsRemaining = numSubjectsRemaining(uniqueIndex);
    uniqueFDCutoffs = FDcutoffs(uniqueIndex);
    uniqueGEVDVcutoffs = gevDVcutoffs(uniqueIndex);
    
    % Changing check for any NaNs to check for all NaNs
    notIsNaN = ~all(isnan(uniqueROIpairR));
    uniquePctNoNaN = uniquePct(notIsNaN);
    uniqueMeanVarRnoNaN = uniqueMeanVarR(:,notIsNaN);
    uniqueNumSubjectsRemainingNoNaN = uniqueNumSubjectsRemaining(notIsNaN);
    uniqueFDCutoffsnoNaN = uniqueFDCutoffs(notIsNaN);
    uniqueGEVDVcutoffsnoNaN = uniqueGEVDVcutoffs(notIsNaN);
    uniqueROIpairRnoNaN = uniqueROIpairR(:,notIsNaN);
    
    squaredMaxBias = maxBias.^2; %Col vector
    deltaSquaredBias = maxBias.^2 - (maxBias - uniqueROIpairRnoNaN).^2; %Note col is ROI pair, row is percent

    initialNumSubjects = max(uniqueNumSubjectsRemainingNoNaN);
    
    originalMSEoverN = (squaredMaxBias + uniqueMeanVarRnoNaN(:,1))./initialNumSubjects;
    calcIntermediate = ( (squaredMaxBias - deltaSquaredBias) + uniqueMeanVarRnoNaN ); 
    newMSEoverN = calcIntermediate./uniqueNumSubjectsRemainingNoNaN;
    delta_MSEoverN = newMSEoverN - originalMSEoverN;
    
    % Changing mean to nanmean
    mean_deltaMSE_overN = nanmean(delta_MSEoverN,1);


    maxPct = 80;

    plotPCT = uniquePctNoNaN(uniquePctNoNaN<maxPct);
    plotPCT = plotPCT(2:end);
    plotFD = uniqueFDCutoffsnoNaN(uniquePctNoNaN<maxPct);
    plotFD = plotFD(2:end);
    plotMSE = mean_deltaMSE_overN(uniquePctNoNaN<maxPct);
    plotMSE = plotMSE(2:end);
    plotGEVDV = uniqueGEVDVcutoffsnoNaN(uniquePctNoNaN<maxPct);
    plotGEVDV = plotGEVDV(2:end);

    [minMSE,minIndex] = min(plotMSE);
    optimalFD = plotFD(minIndex);
    optimalPCT = plotPCT(minIndex);
    optimalDV = plotGEVDV(minIndex);
    
    save([pathToInternalDataFolder filesep 'mseCalculationWorkspace_GS' num2str(useGSR) '.mat'], '-nocompression', '-v7.3'); %JCW 09/27/2023
end

