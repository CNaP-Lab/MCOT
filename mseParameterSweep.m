function [totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining] = mseParameterSweep(combatstruct,subjExtractedTimeSeries,useGSR,parameterSweepFileName,TR,continueBool, numOfSecToTrim, minSecDataNeeded)
    
    numROI = size(subjExtractedTimeSeries(1).rts,2);
    numROIpairs = nchoosek(numROI,2);
    
    % Initialize parallel pool here if you want
    useDVgev = true;
    [FDcutoffs,gevDVcutoffs] = loadCombinedCutoffs(useGSR); 
    
    gevDVcutoff = inf;
    FDcutoff = inf;
    useFDgev = false;
    numThresholds = length(FDcutoffs);
    
    numSubjects = length(subjExtractedTimeSeries);
    
    [totalNumFramesRemaining,totalNumFrames,PFR] = deal(nan(numThresholds,numSubjects));
    
    [targetedRs,randomRs,targetedVariance] = deal(nan(numROIpairs,numThresholds));
    
    [meanSamplingVar,meanRunsVar,harmMeanFrames,harmMeanRuns,meanRunsNoSamplingVar,harmMeanFramesMinus3] = ...
        deal(nan(numThresholds,1));
    
    startThreshold = 1;
    loopCounter = 1;
    if ( continueBool == true )
        try
            load(parameterSweepFileName);
            startThreshold = loopCounter;
            disp('Continuing parameter sweep from file : '); pause(eps); drawnow;
            disp(parameterSweepFileName); pause(eps); drawnow;
            disp(['Iteration ' num2str(loopCounter) ' of ' num2str(numThresholds) '.']); pause(eps); drawnow;
        catch err
            disp('No previously generated parameter sweep file.  Starting from first iteration.'); pause(eps); drawnow;
        end
    end
    
    rawCutoff = false;
    for loopCounter = startThreshold:numThresholds
        tic;
        FDcutoff = FDcutoffs(loopCounter);
        gevDVcutoff = gevDVcutoffs(loopCounter);
        disp(['FDcutoff : ' num2str(FDcutoff) '.']); pause(eps); drawnow;
        disp(['gevDVcutoff : ' num2str(gevDVcutoff) '.']); pause(eps); drawnow;
        percentComplete = 100 * (loopCounter-1)/numThresholds;
        disp([num2str(percentComplete) '%' ]); pause(eps); drawnow;
        [targetedSubjRinROIpair,randomSubjRinROIpair,totalNumFramesRemaining(loopCounter,:),totalNumFrames(loopCounter,:), ...
            meanSamplingVar(loopCounter),meanRunsVar(loopCounter),harmMeanFrames(loopCounter),harmMeanRuns(loopCounter),meanRunsNoSamplingVar(loopCounter),harmMeanFramesMinus3(loopCounter)] ...
            = parameterSweepIteration(FDcutoff,gevDVcutoff,useGSR,rawCutoff,useFDgev,useDVgev,TR,numROIpairs,subjExtractedTimeSeries, numOfSecToTrim, minSecDataNeeded);
        
        numFramesRemoved = totalNumFrames(loopCounter,:) - totalNumFramesRemaining(loopCounter,:);
        proportionFramesRemoved = ( numFramesRemoved ) ./ totalNumFrames(loopCounter,:);
        PFR(loopCounter,:) = 100 .* proportionFramesRemoved;
        
        [targetedVariance(:,loopCounter),targetedRs(:,loopCounter),randomRs(:,loopCounter)] = ...
            parameterSweepStatistics(combatstruct,targetedSubjRinROIpair,randomSubjRinROIpair);
        
        toc; pause(eps); drawnow;
        if((loopCounter == 1) || ~(mod(loopCounter,1000)))
            disp(['Saving.  FDcutoff : ' num2str(FDcutoff) '.']); pause(eps); drawnow;
            disp(['Saving.  gevDVcutoff : ' num2str(gevDVcutoff) '.']); pause(eps); drawnow;
            save(parameterSweepFileName,'-v7.3','-nocompression'); pause(eps); drawnow;
            disp('Save complete.'); pause(eps); drawnow;
        end
    end
    
    disp(['Saving.  FDcutoff : ' num2str(FDcutoff) '.']); pause(eps); drawnow;
    disp(['Saving.  gevDVcutoff : ' num2str(gevDVcutoff) '.']); pause(eps); drawnow;
    save(parameterSweepFileName,'-v7.3','-nocompression'); pause(eps); drawnow;
    disp('Save complete.'); pause(eps); drawnow;
    datetime; pause(1); drawnow; pause(1);
end

