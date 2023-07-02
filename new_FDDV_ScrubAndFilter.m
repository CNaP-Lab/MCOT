function [rscr,random_Rscr,numFramesRemaining,numFramesScrubbed,totalNumFrames,random_rscrMatrix] = ...
        new_FDDV_ScrubAndFilter(rts,fMPs,GS,WS,CS,FDvector,FDgevCutoff,DVvector,DVgevCutoff,useFDgev,useDVgev,fA,fB,useGSR,numROIpairs,TR, numOfSecToTrim, minSecDataNeeded, ...
        varargin)

    numOfVolumesToTrim = ceil(numOfSecToTrim/TR);

    numRandomTimeSeries = 10;
    random_rscrMatrix = nan(numROIpairs,numRandomTimeSeries);

    if (~isempty(varargin) && ~isempty(varargin{1}))
        inputBadVector = varargin{1};
        useInputBadVector = true;
        numRandomTimeSeries = 0;
    else
        useInputBadVector = false;
    end

    % NOTE: RETURNS ALL CORRELATIONS AS Z TRANFORMED
    rng('shuffle');
    % time*dim
    validTimePoints = ~isnan(FDvector);
    rts = squeeze(rts);
    if( isempty(rts) || (sum(validTimePoints) == 0) || all(all(isnan(rts))) )
        [totalNumFrames,numFramesRemaining,numFramesScrubbed] = deal(0);
        [rscr,random_Rscr] = deal(NaN);
        return;
    else %Get rid of trailing NaNs...
        rts = rts(validTimePoints,:); %frames, ROI pairs
        fMPs = fMPs(validTimePoints,:);
        GS = GS(validTimePoints);
        WS = WS(validTimePoints);
        CS = CS(validTimePoints);
        FDvector = FDvector(validTimePoints);
        DVvector = DVvector(validTimePoints);
    end
    fMPs = squeeze(fMPs);
    GS = squeeze(GS);
    WS = squeeze(WS);
    CS = squeeze(CS);
    FDvector = squeeze(FDvector);
    DVvector = squeeze(DVvector);
    rmvec = [1:numOfVolumesToTrim (size(GS,1)-(numOfVolumesToTrim-1)):(size(GS,1))];

    if (~useInputBadVector)
        if(useFDgev)
            FDcutoff = critFind_GEV(FDvector,FDgevCutoff);
        else
            FDcutoff = FDgevCutoff;
        end
        FDbadVector = (FDvector >= FDcutoff);
        if(useDVgev)
            DVcutoff = critFind_GEV(DVvector,DVgevCutoff);
        else
            DVcutoff = DVgevCutoff;
        end
        DVbadVector = (DVvector >= DVcutoff);

        FDbadVector(rmvec) = false;
        DVbadVector(rmvec) = false;
        badVector = FDbadVector|DVbadVector;
    else
        %Disable targeted censoring methods
        badVector = [zeros(numOfVolumesToTrim,1); inputBadVector; zeros(numOfVolumesToTrim,1)];
    end



    badVector(isnan(GS)|isnan(WS)|isnan(CS)) = true;
    GSscr  = filtfilt(fB,fA,tsInterp(GS,badVector));
    WSscr  = filtfilt(fB,fA,tsInterp(WS,badVector));
    CSscr  = filtfilt(fB,fA,tsInterp(CS,badVector));

    numFrames = size(rts,1);
    numFramesAfterScrubbing = numFrames - 2*numOfVolumesToTrim;
    numROIs = size(rts,2);
    rtsSCR = nan(numFramesAfterScrubbing,numROIs);

    for i=1:numROIs
        try
            rtsSCRfiltered = filtfilt(fB,fA,tsInterp(rts(:,i),badVector));
            rtsSCR(:,i) = rtsSCRfiltered( (numOfVolumesToTrim+1) : (end-numOfVolumesToTrim) );
        catch err
            rtsSCR(:,i) = nan(numFramesAfterScrubbing,1);
        end
    end

    %Remove first and last numOfVolumesToTrim frames
    GSscr(rmvec) = [];
    WSscr(rmvec) = [];
    CSscr(rmvec) = [];
    fMPs(rmvec,:) = [];
    badVector(rmvec) = [];

    %%%linear detrend and mean center
    intcpt = ones(size(rtsSCR,1),1);
    Xdt = [intcpt (1:size(rtsSCR,1))'./size(rtsSCR,1)];
    rtsSCR = rtsSCR - (Xdt*(Xdt\rtsSCR));
    GSscr = GSscr - (Xdt*(Xdt\GSscr));
    WSscr = WSscr - (Xdt*(Xdt\WSscr));
    CSscr = CSscr - (Xdt*(Xdt\CSscr));


    [rscr,numFramesRemaining,numFramesScrubbed,totalNumFrames] = getROIpairCorrelations(rtsSCR,GSscr,WSscr,CSscr,fMPs,badVector,useGSR,numROIpairs,TR, minSecDataNeeded);

    noDataLeft = all(isnan(rscr(:)));
    if (~noDataLeft)
        for j=1:numRandomTimeSeries
            randomBadVector = [zeros(numOfVolumesToTrim,1);randPermContiguous(badVector);zeros(numOfVolumesToTrim,1)];

            randomBadVector(isnan(GS)|isnan(WS)|isnan(CS)) = true;
            GS_randomSCR  = filtfilt(fB,fA,tsInterp(GS,randomBadVector));
            WS_randomSCR  = filtfilt(fB,fA,tsInterp(WS,randomBadVector));
            CS_randomSCR  = filtfilt(fB,fA,tsInterp(CS,randomBadVector));

            rts_randomSCR = nan(numFramesAfterScrubbing,numROIs);

            for i=1:numROIs
                try
                    rtsTempCol = rts(:,i);
                    randomRTSscrFiltered = filtfilt(fB,fA,tsInterp(rtsTempCol,randomBadVector));
                    rts_randomSCR(:,i) = randomRTSscrFiltered( (numOfVolumesToTrim+1) : (end-numOfVolumesToTrim) );
                catch err
                    rts_randomSCR(:,i) = nan(numFramesAfterScrubbing,1);
                end
            end

            %Remove first and last numOfVolumesToTrim frames
            GS_randomSCR(rmvec) = [];
            WS_randomSCR(rmvec) = [];
            CS_randomSCR(rmvec) = [];
            randomBadVector(rmvec) = [];

            %rts_randomSCR(rmvec,:) = [];

            %%%linear detrend and mean center
            intcpt = ones(size(rts_randomSCR,1),1);
            Xdt = [intcpt (1:size(rts_randomSCR,1))'./size(rts_randomSCR,1)];
            rts_randomSCR = rts_randomSCR - (Xdt*(Xdt\rts_randomSCR));
            GS_randomSCR = GS_randomSCR - (Xdt*(Xdt\GS_randomSCR));
            WS_randomSCR = WS_randomSCR - (Xdt*(Xdt\WS_randomSCR));
            CS_randomSCR = CS_randomSCR - (Xdt*(Xdt\CS_randomSCR));

            %         rts_randomSCRmatrix(:,:,j) = rts_randomSCR;
            %         GS_randomSCRmatrix(:,:,j) = GS_randomSCR;
            %         WS_randomSCRmatrix(:,:,j) = WS_randomSCR;
            %         CS_randomSCRmatrix(:,:,j) = CS_randomSCR;

            random_rscrMatrix(:,j) = getROIpairCorrelations(rts_randomSCR,GS_randomSCR,WS_randomSCR,CS_randomSCR,fMPs,randomBadVector,useGSR,numROIpairs,TR, minSecDataNeeded);
        end
    end

    random_Rscr = mean(random_rscrMatrix,2); %Mean over rows

end

function [crit] = critFind_GEV(inpt,DVgevCutoff)

    if(DVgevCutoff <= 0 || DVgevCutoff == inf)
        crit = inf;
    else
        if (size(inpt,1) == 1)
            inpt = inpt';
        end
        inpt = inpt(abs(inpt) > 0); %Remove case with 0 FD, first element
        options = statset('MaxFunEvals',1E6,'MaxIter',1E6);

        gev = fitdist(inpt,'GeneralizedExtremeValue','Options',options);

        gevx = linspace(min(inpt),max(inpt),10^5);
        gevsum = gev.cdf(gevx);

        a = 0.3;
        b = DVgevCutoff;

        target = 1 - (gev.k + a)/b;

        [~,minIndex] = min(abs(gevsum - target));

        crit = gevx(minIndex);
    end

end
