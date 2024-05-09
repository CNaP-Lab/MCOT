function [optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper(workingDir, varargin)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    %mseParameterSweep needs:
    % numRunsDataNeededPerSubject,minSecDataNeededPerSubject,minNumContiguousDataSeconds
    numPreprocWorkers = 4;
    numParamSweepWorkers = 28;
    filepath = fileparts(mfilename('fullpath'));
    dirsToPath = {'spm12', ...
        'MCOT_resources', ...
        'Multiband_fMRI_Volume_Censoring_Toolkit'};
    addpath(filepath);
    for i = 1:length(dirsToPath)
        dirToAdd = fullfile(filepath,dirsToPath{i});
        addpath(dirToAdd);
    end

    %% Create the working directory file heirarchy.

    if ~exist(workingDir, 'dir')
        mkdir(workingDir);
    end


    if ~exist([workingDir filesep 'InternalData'], 'dir')
        mkdir([workingDir filesep 'InternalData']);
    end

    if ~exist([workingDir filesep 'Outputs'], 'dir')
        mkdir([workingDir filesep 'Outputs']);
    end

    if ~exist([workingDir filesep 'Logs'], 'dir')
        mkdir([workingDir filesep 'Logs']);
    end

    pause(eps); drawnow; cd(workingDir); pause(eps); drawnow;

    currentStepFileName = [workingDir filesep 'InternalData' filesep 'currentStep' '.mat'];

    %% Argument decoding and Variable Instantiation

    pathToDefaults = which('mcotDefaults.mat');
    load(pathToDefaults, 'filterCutoffs','format','minSecDataNeeded', 'nTrim', 'numOfSecToTrim');
    imageSpace = '';


    continueBool = false;
    removeSubjIndexFromContinue = false;
    forceParamSweep = false;
    StopAfterPostProcessing = false; %PNT edit: this is false unless you add it as a varargin
    useTaskBlockDataVector = false;
    numArgIn = length(varargin);
    currentArgNumber = 1;
    while (currentArgNumber <= numArgIn)
        lowerStringCurrentArg = lower(string(varargin{currentArgNumber}));
        isNameValuePair = true;
        switch(lowerStringCurrentArg)
            case lower("forceParamSweep")
                forceParamSweep = varargin{currentArgNumber + 1};
            case lower("numRunsDataNeededPerSubject")
                numRunsDataNeededPerSubject = varargin{currentArgNumber + 1};
            case lower("minSecDataNeededPerSubject")
                minSecDataNeededPerSubject = varargin{currentArgNumber + 1};
            case lower("minNumContiguousDataSeconds")
                minNumContiguousDataSeconds = varargin{currentArgNumber + 1};
            case "motionparameters"
                MPs = varargin{currentArgNumber + 1};
            case "tr"
                TR = varargin{currentArgNumber + 1};
            case "combatstruct"
                combatstruct = varargin{currentArgNumber + 1};
                combatTest = which('combat');
                if (isempty(combatTest))
                    error('ComBat is not on the path!');
                end
            case "filenamematrix"
                filenameMatrix = varargin{currentArgNumber + 1};
            case "maskmatrix"
                maskMatrix = varargin{currentArgNumber + 1};
            case "usegsr"
                useGSR = varargin{currentArgNumber + 1};
            case "ntrim"
                nTrim = varargin{currentArgNumber + 1};
            case "format"
                format = varargin{currentArgNumber + 1};
            case "continue"
                continueBool = true;
                isNameValuePair = false;
            case "sourcedirectory"
                sourceDir = varargin{currentArgNumber + 1};
            case "runnames"
                rsfcTaskNames = varargin{currentArgNumber + 1};
            case "minimumsecondsdataperrun"
                minSecDataNeeded = varargin{currentArgNumber + 1};
            case "filtercutoffs"
                filterCutoffs = varargin{currentArgNumber + 1};
            case "sectrimpostbpf"
                numOfSecToTrim = varargin{currentArgNumber + 1};
            case "imagespace"
                imageSpace = varargin{currentArgNumber + 1};
                % edit on 11/28/22 by PNT: Allows for user to
                % specify specific subj IDs to process from a larger
                % study directory
            case "subjids"
                optionalSubjIDlist = varargin{currentArgNumber + 1};
                subjIds = varargin{currentArgNumber + 1};
            case "badvolsfile" % path to eye closure file (PNT 11/28/22)
                eyeClosureFile = varargin{currentArgNumber + 1};
            case "stopafterpostprocessing"
                StopAfterPostProcessing = varargin{currentArgNumber + 1};
                if (StopAfterPostProcessing)
                    warning('stopafterpostprocessing enabled.'); pause(1); drawnow;
                end
            case "numparamsweepworkers"
                numParamSweepWorkers = varargin{currentArgNumber + 1};
            case "removesubjindexfromcontinue"
                removeSubjIndexFromContinue = true;
                indexToRemoveSubj = varargin{currentArgNumber + 1};
            case lower("taskBlockDataVector")
                useTaskBlockDataVector = true;
                taskBlockDataStructPath = varargin{currentArgNumber + 1};
            otherwise
                error("Unrecognized input argument")
        end
        if (isNameValuePair)
            numToAdd = 2;
        else
            numToAdd = 1;
        end
        currentArgNumber = currentArgNumber + numToAdd;
    end

    disp('Read all arguments')



    %% Argument Validation --------- this needs another pass after the GUI is made so we can nail down variables

    if continueBool
        try
            loadedCurrentStepData = load(currentStepFileName, 'subjExtractedCompleted', ...
                'paramSweepCompleted_noGSR','paramSweepCompleted_withGSR', ...
                'maxBiasCompleted_noGSR','maxBiasCompleted_withGSR');
            subjExtractedCompleted = loadedCurrentStepData.subjExtractedCompleted;
            paramSweepCompleted_noGSR = loadedCurrentStepData.paramSweepCompleted_noGSR;
            maxBiasCompleted_noGSR = loadedCurrentStepData.maxBiasCompleted_noGSR;
            paramSweepCompleted_withGSR = loadedCurrentStepData.paramSweepCompleted_withGSR;
            maxBiasCompleted_withGSR = loadedCurrentStepData.maxBiasCompleted_withGSR;
            loadedInternalData = load([workingDir filesep 'InternalData' filesep 'inputFlags.mat'], 'varargin');
            varargin = loadedInternalData.varargin;
            % Reparse input values from previous run
            numArgIn = length(varargin);
            currentArgNumber = 1;
            while (currentArgNumber <= numArgIn)
                lowerStringCurrentArg = lower(string(varargin{currentArgNumber}));
                isNameValuePair = true;
                switch(lowerStringCurrentArg)
                    case lower("numRunsDataNeededPerSubject")
                        numRunsDataNeededPerSubject = varargin{currentArgNumber + 1};
                    case lower("minSecDataNeededPerSubject")
                        minSecDataNeededPerSubject = varargin{currentArgNumber + 1};
                    case lower("minNumContiguousDataSeconds")
                        minNumContiguousDataSeconds = varargin{currentArgNumber + 1};
                    case "motionparameters"
                        MPs = varargin{currentArgNumber + 1};
                    case "tr"
                        TR = varargin{currentArgNumber + 1};
                    case "filenamematrix"
                        filenameMatrix = varargin{currentArgNumber + 1};
                    case "maskmatrix"
                        maskMatrix = varargin{currentArgNumber + 1};
                    case "usegsr"
                        useGSR = varargin{currentArgNumber + 1};
                    case "ntrim"
                        nTrim = varargin{currentArgNumber + 1};
                    case "format"
                        format = varargin{currentArgNumber + 1};
                    case "continue"
                        continueBool = true;
                        isNameValuePair = false;
                    case "sourcedirectory"
                        sourceDir = varargin{currentArgNumber + 1};
                    case "runnames"
                        rsfcTaskNames = varargin{currentArgNumber + 1};
                    case "minimumsecondsdataperrun"
                        minSecDataNeeded = varargin{currentArgNumber + 1};
                    case "filtercutoffs"
                        filterCutoffs = varargin{currentArgNumber + 1};
                    case "sectrimpostbpf"
                        numOfSecToTrim = varargin{currentArgNumber + 1};
                    case "imagespace"
                        imageSpace = varargin{currentArgNumber + 1};
                        % edit on 11/28/22 by PNT: Allows for user to
                        % specify specific subj IDs to process from a larger
                        % study directory
                    case "subjids"
                        optionalSubjIDlist = varargin{currentArgNumber+1};
                        subjIds = varargin{currentArgNumber+1};
                    case "badvolsfile" % path to eye closure file (PNT 11/28/22)
                        eyeClosureFile = varargin{currentArgNumber + 1};
                        % case "combatstruct"
                        %     combatstruct = varargin{currentArgNumber + 1};
                        %     combatTest = which('combat');
                        %     if (isempty(combatTest))
                        %         error('ComBat is not on the path!');
                        %     end
                    otherwise
                        %error("Unrecognized input argument")
                end
                if (isNameValuePair)
                    numToAdd = 2;
                else
                    numToAdd = 1;
                end
                currentArgNumber = currentArgNumber + numToAdd;
            end
            continueBool = true;
        catch
            threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'],'Tried to continue from previous run but no data found.');
            error('Tried to continue from previous run but no data found.')
        end
    else
        [subjExtractedCompleted, ...
            paramSweepCompleted_noGSR, ...
            maxBiasCompleted_noGSR, ...
            paramSweepCompleted_withGSR, ...
            maxBiasCompleted_withGSR] = deal(false);
        save([workingDir filesep 'InternalData' filesep 'inputFlags.mat'], 'varargin','-v7.3','-nocompression');
        save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', 'paramSweepCompleted_withGSR', 'maxBiasCompleted_withGSR', 'paramSweepCompleted_noGSR', 'maxBiasCompleted_noGSR', '-v7.3', '-nocompression');
    end

    if subjExtractedCompleted
        try
            subjExtractedCompleted = false;
            load([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'], 'subjExtractedTimeSeries');
            subjExtractedCompleted = true;
            disp('Loaded subjExtractedTimeSeries.mat')
            if(removeSubjIndexFromContinue)
                subjExtractedTimeSeries(indexToRemoveSubj) = [];
            end
        catch err
            disp('Could not load subjExtractedTimeSeries.mat. Regenerating instead.');
        end
    end

    if ~subjExtractedCompleted
        delete(gcp('nocreate'));
        clusterParPool(numPreprocWorkers);
        %% Parse supported directory structures to automatically calc filenames, masks, and MPs

        if ~strcmp(format, 'custom')
            if exist('optionalSubjIDlist','var')
                [filenameMatrix, maskMatrix, MPs, subjIds] = filenameParser(sourceDir, format, rsfcTaskNames, workingDir, optionalSubjIDlist, imageSpace);
            else
                [filenameMatrix, maskMatrix, MPs, subjIds] = filenameParser(sourceDir, format, rsfcTaskNames, workingDir, {}, imageSpace);
            end
            disp('Files parsed')
        end



        %% Validate Provided Files
        if ~fileValidator(filenameMatrix, maskMatrix)
            threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Filename or Mask Files could not be validated.  Make sure all files provided are nifti format, uncompressed, and accessible to the current user');
            error('Filename or Mask Files could not be validated.  Make sure all files provided are nifti format, uncompressed, and accessible to the current user')
        end

        disp('Files validated')



        %% SubjExtractedTimeSeries
        subjExtractedTimeSeries = subjExtractedTimeSeriesMaker(filenameMatrix, TR, nTrim, MPs, maskMatrix, workingDir, continueBool, filterCutoffs, subjIds);
        save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', '-append', '-v7.3', '-nocompression');
        disp('Filtering completed. ROI Time Series calculated.')


        %% Bad Volumes set from Eye closures (PNT 11/28/22)
        if exist('eyeClosureFile','var')
            subjExtractedTimeSeries = getBadVols(eyeClosureFile,TR,subjExtractedTimeSeries);
            disp('Bad Volumes Flagged.')
        end



        framwiseMotionVectorOutputDir = fullfile(workingDir,'Outputs','Framewise_Motion_Vectors');
        save_LPFFD_GEVDV(subjExtractedTimeSeries,framwiseMotionVectorOutputDir);
        disp(['Saved LPF-FD, GEVDV, and filtered MPs in: ' framwiseMotionVectorOutputDir]); drawnow;

        subjExtractedCompleted = true;
        save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', '-append', '-v7.3', '-nocompression');

    end
    % PNT: put this outside of SETScompleted conditional so it always runs
    % just to make sure
    if exist('eyeClosureFile','var')
        subjExtractedTimeSeries = getBadVols(eyeClosureFile,TR,subjExtractedTimeSeries);
        disp('Bad Volumes Flagged.')
    end



    framwiseMotionVectorOutputDir = fullfile(workingDir,'Outputs','Framewise_Motion_Vectors');
    save_LPFFD_GEVDV(subjExtractedTimeSeries,framwiseMotionVectorOutputDir);
    disp(['Saved LPF-FD, GEVDV, and filtered MPs in: ' framwiseMotionVectorOutputDir]); drawnow;
    %% Checker
    % Cleans up subjextractedtimeseries to remove all NaN or 0 runs, saves
    % memory too
    % warns the user that this is happening, and saves it to some log file
    %     inside function?  Something like this disp(['WARNING: Removed xx ROIs from run # ' num2str(j) of subj yy' due to all 0s or all NaNs in an ROI time series.']);
    % User needs to know:
    %   When an ROI time series hs all 0s or NaNs, and whether the run is
    %   kept (run is only removed if all ROIs are all 0/NaN).


    if(StopAfterPostProcessing)
        warning('Stopping after post-processing and before parameter sweep.'); pause(1); drawnow;
        return;
    end

    for useGSRiterator = 1:-1:0
        parameterSweepFileName = [workingDir filesep 'InternalData' filesep 'paramSweep' '_-_GS' num2str(useGSRiterator) '.mat'];
        paramSweepReturnsFileName = [workingDir filesep 'InternalData' filesep 'paramSweepReturns' '_-_GS' num2str(useGSRiterator) '.mat'];


        maxBiasFileName = [workingDir filesep 'InternalData' filesep 'maxBias' '_-_GS' num2str(useGSRiterator) '.mat'];

        outputsFileName = [workingDir filesep 'Outputs' filesep 'Outputs' '_-_GS' num2str(useGSRiterator) '.mat'];

        useGSR = logical(useGSRiterator);

        if (~useGSR)
            paramSweepCompleted = paramSweepCompleted_noGSR;
            maxBiasCompleted = maxBiasCompleted_noGSR;
        else
            paramSweepCompleted = paramSweepCompleted_withGSR;
            maxBiasCompleted = maxBiasCompleted_withGSR;
        end

        paramSweepFilesExist = exist(parameterSweepFileName,'file') && exist(paramSweepReturnsFileName,'file');
        maxBiasFilesExist = exist(maxBiasFileName,'file');
        outputFilesExist = exist(outputsFileName,'file');

        if (~paramSweepFilesExist)
            paramSweepCompleted = false;
        end

        if(~paramSweepFilesExist || ~maxBiasFilesExist)
            maxBiasCompleted = false;
        end

        %% Optional: Add task on blocks struct to subjExtractedTimeSeries
        if ( useTaskBlockDataVector )
            subjTaskBlockData = load(taskBlockDataStructPath);
            %taskBlockData has a struct array, taskOnBlockBySubj, 
            % with the fields:
            % subjID and taskOnVecsByRun
            subjTaskBlockData = subjTaskBlockData.taskOnBlockBySubj; %Pull it out of the inner struct
            numTaskBlockData = length(subjTaskBlockData);
            numSubjExtractedTimeSeries = length(subjExtractedTimeSeries);
            % in subjExtractedTimeSeries, subject IDs are subjId.
            SETSsubjIDs = {subjExtractedTimeSeries.subjId};
            taskOnBlockSubjIDs = {subjTaskBlockData.subjID};
            [~,SETSlocs,~] = intersect(taskOnBlockSubjIDs,SETSsubjIDs);

            %Make sure subject IDs match
            if (numTaskBlockData ~= numSubjExtractedTimeSeries)
                disp('fMRI Subject IDs:'); pause(eps); drawnow;
                disp(SETSsubjIDs); pause(eps); drawnow;
                disp('Task block Subject IDs:'); pause(eps); drawnow;
                disp(taskOnBlockSubjIDs); pause(eps); drawnow;
                error('Mismatch between number of items in task block data and number subjects in fMRI data.');
            end
            if(numel(SETSlocs) ~= numTaskBlockData)
                disp('fMRI Subject IDs:'); pause(eps); drawnow;
                disp(SETSsubjIDs); pause(eps); drawnow;
                disp('Task block Subject IDs:'); pause(eps); drawnow;
                disp(taskOnBlockSubjIDs); pause(eps); drawnow;
                error('Mismatch in subject IDs between task block data and fMRI data');
            end

            %Sort task on blocks to match SETS
            subjTaskBlockData = subjTaskBlockData(SETSlocs);
            
            %Load into SETS
            for i = 1:numSubjExtractedTimeSeries
                thisSubjTaskBlockDataMatrix = nan(size(subjExtractedTimeSeries(i).GS)); % frame x 1 x runs
                thisSubjTaskBlockData = subjTaskBlockData(i);
                numTaskBlockRuns = length(thisSubjTaskBlockData.taskOnVecsByRun);
                for j = 1:numTaskBlockRuns
                    thisRunTaskOnVecs = thisSubjTaskBlockData.taskOnVecsByRun(j);
                    thisRunNum = thisRunTaskOnVecs.runNum;
                    taskOnBlocksVectorLength = length(thisRunTaskOnVecs.taskOnBlocksVector);
                    fMRInumFrames = subjExtractedTimeSeries(i).runLength(thisRunNum);
                    if (taskOnBlocksVectorLength ~= fMRInumFrames)
                        error('Mismatch between task on blocks vector and number of volumes in fMRI data.');
                    end
                    thisSubjTaskBlockDataMatrix(1:taskOnBlocksVectorLength,1,thisRunNum) = ...
                        thisRunTaskOnVecs.taskOnBlocksVector();
                end
                subjExtractedTimeSeries(i).taskBlockData = thisSubjTaskBlockDataMatrix; % frame x 1 x runs
            end

        end

        %% Parameter sweep
        if (~paramSweepCompleted) || (forceParamSweep)
            if(forceParamSweep)
                continueBool = false;
            end
            delete(gcp('nocreate'));
            clusterParPool(numParamSweepWorkers);
            if exist('combatstruct','var')
                [totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining] = ...
                    mseParameterSweep(subjExtractedTimeSeries,useGSR,parameterSweepFileName, ...
                    TR, continueBool, numOfSecToTrim, minSecDataNeeded,...
                    numRunsDataNeededPerSubject,minSecDataNeededPerSubject,minNumContiguousDataSeconds, ...
                    combatstruct);
            else
                [totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining] = ...
                    mseParameterSweep(subjExtractedTimeSeries,useGSR,parameterSweepFileName, ...
                    TR, continueBool, numOfSecToTrim, minSecDataNeeded,...
                    numRunsDataNeededPerSubject,minSecDataNeededPerSubject,minNumContiguousDataSeconds);
            end
            save(paramSweepReturnsFileName, 'totalNumFrames','targetedVariance','targetedRs','randomRs','FDcutoffs','gevDVcutoffs', 'totalNumFramesRemaining', '-v7.3', '-nocompression');
            if (~useGSR)
                paramSweepCompleted_noGSR = true;
                maxBiasCompleted_noGSR = false;
            else
                paramSweepCompleted_withGSR = true;
                maxBiasCompleted_withGSR = false;
            end
            maxBiasCompleted = false;
            save(currentStepFileName, 'paramSweepCompleted_noGSR','paramSweepCompleted_withGSR', '-append','-v7.3', '-nocompression');
            disp('Parameter sweep completed')
        else
            load(paramSweepReturnsFileName);
            disp('Loaded paramSweepReturns.mat')
        end

        %% Max bias calculation
        if (~(maxBiasCompleted && paramSweepCompleted)) || (forceParamSweep)
            delete(gcp('nocreate'));
            clusterParPool(numParamSweepWorkers);
            maxBias = maxBiasCalculation(totalNumFramesRemaining,totalNumFrames,targetedRs,randomRs);
            save(maxBiasFileName, 'maxBias', '-v7.3', '-nocompression');
            if (~useGSR)
                maxBiasCompleted_noGSR = true;
            else
                maxBiasCompleted_withGSR = true;
            end
            save(currentStepFileName, 'maxBiasCompleted_noGSR','maxBiasCompleted_withGSR', '-append','-v7.3','-nocompression'); %Always save current step AFTER saving data
            disp('Max bias calculation completed')
        else
            load(maxBiasFileName);
            disp('Loaded maxBias.mat')
        end

        %% MSE calculation and MSE optimum
        [optimalDV, optimalFD, optimalPCT, minMSE] = mseCalculation(maxBias,totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining,[workingDir filesep 'InternalData'],useGSR); %JCW 09/27/2023

        disp('MSE calculation completed. saving outputs')

        save(outputsFileName, 'optimalDV', 'optimalFD', 'optimalPCT', 'minMSE','-v7.3','-nocompression');
        disp('outputs saved - returning')
    end
    delete(gcp('nocreate'));
end


