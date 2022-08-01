function subjExtractedTimeSeries = subjExtractedTimeSeriesMaker(filenameMatrix, TR, nTrim, MPs, maskFilenameMatrix, workingDir, continueBool, filterCutoffs, subjIds)
    
    % To Continue from a crashed attempt
    performFirstTimeWork = true;
    
    if continueBool
        try
            load([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat']);
            loadStruct = load([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'],'i','j');
            subjStartItr = loadStruct.i;
            runStartItr = loadStruct.j;
            performFirstTimeWork = left;
        catch
            performFirstTimeWork = true;
        end
    end
    if performFirstTimeWork  % To create a new subjExtractedTimeSeries struct
        
        if exist([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'], 'file')
            movefile([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'],[workingDir filesep 'InternalData' filesep 'old_unused_subjExtractedTimeSeries.mat']);
        end
        
        subjStartItr = 1;
        runStartItr = 1;
        
        %---------------------------------------
        %Preset Variables
        maxLength = 0;
        maxRuns = (size(filenameMatrix, 2));
        alreadySlicedPower = false;
        
        %for each subject:
        for i = 1:size(filenameMatrix,1)
            %establish number of runs variable
            subjExtractedTimeSeries(i).numRuns = 0;
            %for each run
            runIdx = 1;
            for j = 1:size(filenameMatrix,2)
                
                thisFileName = filenameMatrix{i,j};
                
                if isempty(thisFileName)
                    subjExtractedTimeSeries(i).runLength(j, 1) = nan;
                    continue;
                end
                
                [~,runName,~] = fileparts(thisFileName);
                subjExtractedTimeSeries(i).runName{runIdx} = runName;
                runIdx = runIdx + 1;
                
                % This block reslices the template and saves the resliced
                % version in the working directory
                if ~alreadySlicedPower
                    [path, name, ext] = fileparts(which('power264ROIs.nii'));
                    if ~exist([workingDir filesep 'InternalData' filesep name ext], 'file')
                        if ~copyfile([path filesep name ext], [workingDir filesep 'InternalData' filesep name ext])
                            threshOptLog([workingDir filesep 'Logs' filesep 'log.txt' ], 'Unable to copy ROI Template to working directory');
                            error('Unable to copy ROI Template to working directory')
                        end
                    end
                    
                    resliceJob{1}.spm.spatial.coreg.write.ref = {[thisFileName ',1']};
                    resliceJob{1}.spm.spatial.coreg.write.source = {[[workingDir filesep 'InternalData' filesep name ext]  ',1']};
                    resliceJob{1}.spm.spatial.coreg.write.roptions.interp = 0;
                    resliceJob{1}.spm.spatial.coreg.write.roptions.wrap = [0 0 0];
                    resliceJob{1}.spm.spatial.coreg.write.roptions.mask = 0;
                    resliceJob{1}.spm.spatial.coreg.write.roptions.prefix = 'r';
                    spm_jobman('run',{resliceJob});
                    alreadySlicedPower = true;
                end
                
                % Set the length for this run
                thisHdr = readVol(thisFileName);
                subjExtractedTimeSeries(i).runLength(j, 1) = size(thisHdr,1) - nTrim;
                
                % Iterate Max Length of runs if necessary
                if size(thisHdr,1) - nTrim > maxLength
                    maxLength = size(thisHdr,1) - nTrim;
                end
                
                % Add one run for the current subject
                subjExtractedTimeSeries(i).numRuns = subjExtractedTimeSeries(i).numRuns + 1;
                
            end
        end
        
        %% Assemble Struct ----- NaN Fill based on longest data
        for i = 1:length(subjExtractedTimeSeries)
            subjExtractedTimeSeries(i).subjId = subjIds{i};
            subjExtractedTimeSeries(i).CS = nan(maxLength, 1, maxRuns);
            subjExtractedTimeSeries(i).GS = nan(maxLength, 1, maxRuns);
            subjExtractedTimeSeries(i).WS = nan(maxLength, 1, maxRuns);
            subjExtractedTimeSeries(i).fMPs = nan(maxLength, 6, maxRuns);
            subjExtractedTimeSeries(i).lpfDV = nan(maxLength, 1, maxRuns);
            subjExtractedTimeSeries(i).lpfFD = nan(maxLength, 1, maxRuns);
            subjExtractedTimeSeries(i).rts = nan(maxLength, 264, maxRuns);
        end
        
        
        %% Load resliced ROI Mask
        reslicedMaskFile = [workingDir filesep 'InternalData' filesep 'rpower264ROIs.nii'];
        [~,Mask] = readVol(reslicedMaskFile);
    end
    
    for i = subjStartItr:size(filenameMatrix,1)
        setFilters = false;
        for j = runStartItr:size(filenameMatrix,2)
            thisFileName = filenameMatrix{i,j};
            
            %% Make sure run should exist -------------------------------------------------
            if isempty(thisFileName)
                continue;
            end
            
            %% Masks & Signals --------------------------------------------------------
            
            %         [~, Gm] = readVol(maskFilenameMatrix{i, 1});
            %         Gm = Gm{1};
            [~, Bm] = readVol(maskFilenameMatrix{i, 1});
            Bm = logical(Bm);
            [~, WMm] = readVol(maskFilenameMatrix{i, 2});
            WMm = logical(WMm);
            [~, CSFm] = readVol(maskFilenameMatrix{i, 3});
            CSFm = logical(CSFm);

            WMm_eroded = erodemasks_MCOT(WMm);
            CSFm_eroded = erodemasks_MCOT(CSFm);
            
            %% Load and Trim current run ---------------------------------------------------
            [~, vol4D] = readVol(thisFileName);
            %         vol4D = vol4D{1};
            
            if nTrim > size(vol4D, 4)
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error trimming volume.  Number of frames to trim is greater than length of volume.')
                error('Error trimming volume.  Number of frames to trim is greater than length of volume.')
            end
            
            vol4D = vol4D(:,:,:,nTrim+1:end);
            
            
            %% subjExtractedTimeSeries.Filters -----------------------------------------------
            if ~setFilters %only needed for first loop
                lpb = 0.2./((1/TR)/2); %%%%%HARD CODED TO 0.2 Hz LOW PASS FILTER!!!
                fpb = [filterCutoffs(1)./((1/TR)/2) filterCutoffs(2)./((1/TR)/2)];  %%%%%HARD CODED TO .009->0.08 Hz BANDPASS FILTER!!!
                [lB,lA] = butter(2,lpb,'low');
                [fB,fA] = butter(2,fpb);
                
                TIPPfilters.filters.lB = lB;
                TIPPfilters.filters.lA = lA;
                TIPPfilters.filters.fB = fB;
                TIPPfilters.filters.fA = fA;
                
                subjExtractedTimeSeries(i).TIPPfilters = TIPPfilters;
                setFilters = true;
            end
            
            
            %%
            bmIdxs = isnan(Bm);
            Bm(bmIdxs) = 0;
            
            wmIdxs = isnan(WMm);
            WMm(wmIdxs) = 0;
            
            CsfIdxs = isnan(CSFm);
            CSFm(CsfIdxs) = 0;
            
            roiIdxs = isnan(Mask);
            Mask(roiIdxs) = 0;
            
            roidat = reshape(Mask,[],1);
            mastermask = logical(roidat) | Bm(:) | WMm(:) | CSFm(:); % Gm(:) |
            rdat = roidat(mastermask);
            
            %      Gm = Gm(mastermask);
            Bm = Bm(mastermask);
            WMm = WMm(mastermask);
            CSFm = CSFm(mastermask);
            WMm_eroded = WMm_eroded(mastermask);
            CSFm_eroded = CSFm_eroded(mastermask);
            
            %%  Various filtering ----------------------------------------------------------------
            try
                lpfFD = getLPFFD(MPs{i,j},TR);
                subjExtractedTimeSeries(i).lpfFD(1:size(lpfFD,1)-nTrim,1,j) = lpfFD(nTrim + 1:end, :);
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error filtering FD.  Check MPs and TR.')
                error('Error filtering FD.  Check MPs and TR.')
            end
            
            try
                fMPs = getFilteredMPs(MPs{i,j},TR);
                subjExtractedTimeSeries(i).fMPs(1:size(fMPs,1)-nTrim,1:size(fMPs,2),j) = fMPs(nTrim + 1:end, :);
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error filtering MPs.  Check MPs and TR.')
                error('Error filtering MPs.  Check MPs and TR.')
            end
            
            try
                lpfDV = getLPFdvars(vol4D, Bm, TR);
                subjExtractedTimeSeries(i).lpfDV(1:size(lpfDV,1)-nTrim,1,j) = lpfDV(nTrim + 1:end, :);
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error filtering DVars.  Check masks and TR.')
                error('Error filtering DVars.  Check masks and TR.')
            end
            
            %%  ROIs ----------------------------------------------------------------
            try
                volFlat = reshape(vol4D,[],size(vol4D,4)); %vectorize
                maskedFlat = volFlat(mastermask,:); %shrink to mastermask size <- we've already determined these are all the voxels we could need
                maskedFlatbrain = maskedFlat(Bm,:); %Bm is brainmask
                md = mode(round(maskedFlatbrain(maskedFlatbrain>100&~isnan(maskedFlatbrain))));
                if length(md) > 1
                    md = md(1);
                end
                maskedFlat = maskedFlat .* 1000 ./ md; %mode 1000 normalization
                
                intcpt = ones(size(maskedFlat,2),1);
                X = [intcpt (1:size(maskedFlat,2))'./size(maskedFlat,2)]; %design matrix for linear regression that only contains
                % intercept and linear trend terms
                
                roiTS = zeros(size(maskedFlat,2),max(rdat));
                for k = 1:max(rdat)
                    roiTS(:,k) = mean(maskedFlat(rdat==k,:),1);
                end
                
                rts = roiTS - (X*(X\roiTS));
                subjExtractedTimeSeries(i).rts(1:size(rts, 1), :, j) = rts;
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error calculating ROI time series.')
                error('Error calculating ROI time series.')
            end

            GSt = mean(maskedFlat(Bm,:))'; %Global Signal; these are signals we want to have.
            %        GmSt = mean(maskedFlat(Gm,:))'; %gray matter signal
            %             WSt = mean(maskedFlat(WMm,:))'; %white matter signal
            %             CSt = mean(maskedFlat(CSFm,:))'; %CSF signal
            WSt = mean(maskedFlat(WMm_eroded,:))'; %white matter signal
            CSt = mean(maskedFlat(CSFm_eroded,:))'; %CSF signal

            try
                GSt = GSt - (X*(X\GSt));
                subjExtractedTimeSeries(i).GS(1:size(GSt, 1), :, j) = GSt;
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error calculating Global Signal.')
                error('Error calculating Global Signal.')
            end
            
            
            try
                WSt = WSt - (X*(X\WSt));
                subjExtractedTimeSeries(i).WS(1:size(WSt, 1), :, j) = WSt;
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error calculating White Matter Signal.')
                error('Error calculating White Matter Signal.')
            end
            
            try
                CSt = CSt - (X*(X\CSt));
                subjExtractedTimeSeries(i).CS(1:size(CSt, 1), :, j) = CSt;
            catch
                threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Error calculating CSF Signal.')
                error('Error calculating CSF Signal.')
            end
            
            save([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'], 'i', 'j', 'subjExtractedTimeSeries', 'Mask', 'nTrim', '-v7.3', '-nocompression');
            
            
            disp(['Subj ' num2str(i) ', Run ' num2str(j) ' completed'])
        end
        disp(['Subj ' num2str(i) ' completed'])
    end
    
end



