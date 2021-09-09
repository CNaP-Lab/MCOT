function [averageRscr,averageRandomRscr,totalNumFramesRemaining,totalNumFrames, ...
        subjHarmMeanFrames,subjMeanSamplingVar,subjNumRuns,subjRunsVar,subjMeanRunsNoSamplingVar,subjHarmMeanFramesMinus3] = ...
        new_getSubjectScrubbedROIpairCorrelations(subjExtractedTimeSeries,useGSR,lpfFDcutoff,lpfDVcutoff,numROIpairs,rawCutoff,useFDgev,useDVgev,maxNumRuns,TR, numOfSecToTrim, minSecDataNeeded, ...
        varargin)
    % time*dim*run
    % roiPair*run
    %
    %     WS            1
    %     WSderiv       1
    %     CS            1
    %     CSderiv       1
    %     fMPs          6
    %     fMPs.^2       6
    %     fMPderiv      6
    %     fMPderiv.^2	6
    %
    %     GS            1
    %     GSderiv		1
    %
    %     24 + 4 =      28
    %
    %     NoGSR:        28
    %     WithGSR:      30
    %
    if(useGSR)
        regressorDoF = 30;
    else
        regressorDoF = 28;
    end
    
    numRuns = size(subjExtractedTimeSeries.rts,3);
    
    if(~isempty(varargin)) %should be 4x1 cell of bad vectors
        badVectorCell = varargin{1};
    else
        badVectorCell = cell(numRuns,1);
    end
    
    useGSR = logical(useGSR);
    
    numRandomPerms = 10;
    
    rscr = nan(numROIpairs,numRuns);
    randomRscr = nan(numROIpairs,numRuns);
    
    random_rscrMatrix = nan(numROIpairs,numRandomPerms,numRuns);
    
    numFramesScrubbed = nan(numRuns,1);
    numFramesRemaining = nan(numRuns,1);
    totalRunNumFrames = nan(numRuns,1); % runs x 1
    runMeanFD = nan(numRuns,1);
    runMedianFD = nan(numRuns,1);
    if (rawCutoff == 2)
        FD = subjExtractedTimeSeries.notchFD;
        DV = subjExtractedTimeSeries.notchFilteredDVs;
    elseif (rawCutoff == 1)
        FD = subjExtractedTimeSeries.FD;
        DV = subjExtractedTimeSeries.DV;
    elseif (rawCutoff == 3)
        FD = subjExtractedTimeSeries.powerFD;
        DV = subjExtractedTimeSeries.powerFilteredDVs;
    else
        FD = subjExtractedTimeSeries.lpfFD;
        DV = subjExtractedTimeSeries.lpfDV;
    end
    for j = 1:numRuns
        pause(eps); drawnow;
        
        % This is is going to be edited so that it only removes a run if ALL
        % ROI time series are all 0's, as opposed to if any time series are all 0's.
        %if( all(all(isnan(subjExtractedTimeSeries.rts(:,:,j)))) || ...
        %       any(all(subjExtractedTimeSeries.rts(:,:,j)==0,1)) ) %Check for any time series with NaNs or all 0's
        if( all(all(isnan(subjExtractedTimeSeries.rts(:,:,j)))) || ...
                all(all(subjExtractedTimeSeries.rts(:,:,j)==0,1)) ) %Check if all time series have NaNs or all 0's
            runRscr = nan(numROIpairs,1);
            runRandomRscr = nan(size(runRscr));
            run_random_rscrMatrix = nan(numROIpairs,numRandomPerms);
            runNumFramesRemaining = 0;
            runNumFramesScrubbed = 0;
            totalRunNumFrames(j) = 0;
            disp(['WARNING: Removed run # ' num2str(j) ' due to all 0s or all NaNs in an ROI time series.']);
            
        else
            % Adding this: if any ROI time series are all 0's, replace
            % those 0s with NaNs.
            thisRTS = subjExtractedTimeSeries.rts(:,:,j); %Get this run's ROI time series
            rtsIsAllZero = all(thisRTS == 0,1); %Get columns with all 0's in them
            thisRTS(:,rtsIsAllZero) = NaN; %Replace any column with all 0's with a column of NaNs
            
            thisRunBadVector = badVectorCell{j};
            [runRscr,runRandomRscr,runNumFramesRemaining,runNumFramesScrubbed,totalRunNumFrames(j),run_random_rscrMatrix] = ...
                new_FDDV_ScrubAndFilter(thisRTS, subjExtractedTimeSeries.fMPs(:,:,j), subjExtractedTimeSeries.GS(:,:,j), ...
                subjExtractedTimeSeries.WS(:,:,j),subjExtractedTimeSeries.CS(:,:,j), ...
                FD(:,:,j),lpfFDcutoff, DV(:,:,j), lpfDVcutoff, useFDgev, useDVgev, ...
                subjExtractedTimeSeries.TIPPfilters.filters.fA,subjExtractedTimeSeries.TIPPfilters.filters.fB,useGSR,numROIpairs, TR, numOfSecToTrim, minSecDataNeeded, thisRunBadVector);
            runMeanFD(j) = nan; %mean(subjExtractedTimeSeries.FD(:,:,j));
            runMedianFD(j) = nan; %median(subjExtractedTimeSeries.FD(:,:,j));
        end
        
        % This is going to be edited so that it only removed a run is ALL
        % ROI pair correlations are all NaNs, rather than any.
        if( all(isnan(runRscr)) )
            runRscr = nan(size(runRscr));
            runRandomRscr = nan(size(runRscr));
            run_random_rscrMatrix = nan(size(run_random_rscrMatrix));
            runNumFramesScrubbed = totalRunNumFrames(j);
            runNumFramesRemaining = 0;
        end
        
        rscr(:,j) = runRscr;
        randomRscr(:,j) = runRandomRscr;
        random_rscrMatrix(:,:,j) = run_random_rscrMatrix;
        numFramesRemaining(j) = runNumFramesRemaining;
        numFramesScrubbed(j) = runNumFramesScrubbed;
    end
    
    %Average over runs
    totalNumFrames = nansum(totalRunNumFrames);
    totalNumFramesRemaining = nansum(numFramesRemaining);
    averageRscr = nanmean(rscr,2);
    averageRandomRscr = nanmean(randomRscr,2);
    %Do not average random_rscrMatrix
    
    subjNumRuns = sum(numFramesRemaining>0); % Number of runs with more than 1 frame remaining
    
    subjHarmMeanFrames = harmmean(numFramesRemaining(numFramesRemaining>0),'omitnan'); %Harmonic mean across runs
    subjHarmMeanFramesMinus3 = harmmean( (numFramesRemaining(numFramesRemaining>0) - regressorDoF - 3) ,'omitnan');
    runSamplingVar = 1 ./ (numFramesRemaining(numFramesRemaining>0) - regressorDoF - 3);
    subjMeanSamplingVar = mean(runSamplingVar,'omitnan'); %Across runs
    
    %Variance with N=1 causes weight to be
    %forced to 1, i.e. non-Bessel's Corrected, making variance 0.  This is
    %not desired.
    if (subjNumRuns > 1)
        subjRunsVarInROIpair = var(rscr,0,2,'omitnan'); %2 = across runs
        subjRunsNoSamplingVarInROIpair = var(rscr,0,2,'omitnan');
    elseif (subjNumRuns == 1)
        subjRunsVarInROIpair = subjMeanSamplingVar;
        subjRunsNoSamplingVarInROIpair = NaN;
    elseif (subjNumRuns < 1) % Might was well do this explicitly here.
        subjRunsVarInROIpair = NaN;
        subjRunsNoSamplingVarInROIpair = NaN;
    end
    
    subjRunsVar = mean(subjRunsVarInROIpair,'omitnan'); %Average across ROI pairs
    subjMeanRunsNoSamplingVar = mean(subjRunsNoSamplingVarInROIpair,'omitnan');
    
end

