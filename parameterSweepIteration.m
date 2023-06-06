function [targetedSubjRinROIpair,randomSubjRinROIpair,totalNumFramesRemaining,totalNumFrames, ...
        meanSamplingVar,meanRunsVar,harmMeanFrames,harmMeanRuns,meanRunsNoSamplingVar,harmMeanFramesMinus3] ...
        = parameterSweepIteration(FDcutoff,gevDVcutoff,useGSR,rawCutoff,useFDgev,useDVgev,TR,numROIpairs,SETS, numOfSecToTrim, minSecDataNeeded)
    %A single iteration (set of parameter values) for a volume censoring
    %parameter sweep.
    
    numSubjects = length(SETS);
    
    thisSubjNumRuns = nan(numSubjects,1);
    for subjectNumber = 1:numSubjects
        thisSubjNumRuns(subjectNumber) = size(SETS(subjectNumber).rts,3);
    end
    maxNumRuns = max(thisSubjNumRuns);
    
    [targetedSubjRinROIpair,randomSubjRinROIpair] = deal(nan(numROIpairs,numSubjects));
    [totalNumFramesRemaining,totalNumFrames] = deal(nan(1,numSubjects));
    
    
    [subjHarmMeanFrames,subjMeanSamplingVar,subjNumRuns,subjRunsVar,subjMeanRunsNoSamplingVar,subjHarmMeanFramesMinus3] ...
        = deal(nan(numSubjects,1));
    
    pause(eps); drawnow;
    parfor subjectNumber = 1:numSubjects
        [thisSubjRscr,thisSubjRandomRscr,totalNumFramesRemaining(subjectNumber),totalNumFrames(subjectNumber), ...
            subjHarmMeanFrames(subjectNumber),subjMeanSamplingVar(subjectNumber),subjNumRuns(subjectNumber), ...
            subjRunsVar(subjectNumber),subjMeanRunsNoSamplingVar(subjectNumber),subjHarmMeanFramesMinus3(subjectNumber)] = ...
            new_getSubjectScrubbedROIpairCorrelations(SETS(subjectNumber),useGSR,FDcutoff, ...
            gevDVcutoff,numROIpairs,rawCutoff,useFDgev,useDVgev,maxNumRuns,TR(subjectNumber), numOfSecToTrim, minSecDataNeeded);
        targetedSubjRinROIpair(:,subjectNumber) = thisSubjRscr;
        randomSubjRinROIpair(:,subjectNumber) = thisSubjRandomRscr;
    end
    
    meanSamplingVar = mean(subjMeanSamplingVar,'omitnan');
    meanRunsVar = mean(subjRunsVar,'omitnan');
    harmMeanFrames = harmmean(subjHarmMeanFrames(subjHarmMeanFrames>0),'omitnan');
    harmMeanRuns = harmmean(subjNumRuns(subjNumRuns>0),'omitnan');
    
    meanRunsNoSamplingVar = mean(subjMeanRunsNoSamplingVar,'omitnan');
    harmMeanFramesMinus3 = harmmean(subjHarmMeanFramesMinus3(subjHarmMeanFrames>0),'omitnan');
    
end
