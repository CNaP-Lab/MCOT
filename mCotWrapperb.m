function [optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapperb(workingDir, varargin)
    %UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    disp('using the parallel and FIX flag-enabled version');
    startall=tic;
    starttop=tic;

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
    
    
    
    %% Argument decoding and Variable Instantiation
    
    pathToDefaults = which('mcotDefaults.mat');
    load(pathToDefaults, 'filterCutoffs','format','minSecDataNeeded', 'nTrim', 'numOfSecToTrim','useGSR');
    imageSpace = '';
    
    
    continueBool = false;
    parameterSweepFileName = [workingDir filesep 'InternalData' filesep 'paramSweep.mat'];
    
    numArgIn = length(varargin);
    currentArgNumber = 1;
    while (currentArgNumber <= numArgIn)
        lowerStringCurrentArg = lower(string(varargin{currentArgNumber}));
        isNameValuePair = true;
        switch(lowerStringCurrentArg)
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
            case "fixflag"
                fixflag = varargin{currentArgNumber + 1};
            case "numworkers"
                numworkers = varargin{currentArgNumber + 1};   
            case "imagespace"
                imageSpace = varargin{currentArgNumber + 1};
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
            loadedCurrentStepData = load([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', 'paramSweepCompleted', 'maxBiasCompleted');
            subjExtractedCompleted = loadedCurrentStepData.subjExtractedCompleted;
            paramSweepCompleted = loadedCurrentStepData.paramSweepCompleted;
            maxBiasCompleted = loadedCurrentStepData.maxBiasCompleted;
            loadedInternalData = load([workingDir filesep 'InternalData' filesep 'inputFlags.mat'], 'varargin');
            varargin = loadedInternalData.varargin;
            % Reparse input values from previous run
            numArgIn = length(varargin);
            currentArgNumber = 1;
            while (currentArgNumber <= numArgIn)
                lowerStringCurrentArg = lower(string(varargin{currentArgNumber}));
                isNameValuePair = true;
                switch(lowerStringCurrentArg)
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
                    case "fixflag"
                        fixflag = varargin{currentArgNumber + 1};
                    case "numworkers"
                        numworkers = varargin{currentArgNumber + 1};   
                    case "imagespace"
                        imageSpace = varargin{currentArgNumber + 1};
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
            continueBool = true;
        catch
            threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'],'Tried to continue from previous run but no data found.');
            error('Tried to continue from previous run but no data found.')
        end
    else
        subjExtractedCompleted = false;
        paramSweepCompleted = false;
        maxBiasCompleted = false;
        save([workingDir filesep 'InternalData' filesep 'inputFlags.mat'], 'varargin','-v7.3','-nocompression');
        save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', 'paramSweepCompleted', 'maxBiasCompleted', '-v7.3', '-nocompression');
    end
    
    if subjExtractedCompleted
        try
            subjExtractedCompleted = false;
            load([workingDir filesep 'InternalData' filesep 'subjExtractedTimeSeries.mat'], 'subjExtractedTimeSeries');
            subjExtractedCompleted = true;
            disp('Loaded subjExtractedTimeSeries.mat')
        catch err
            disp('Could not load subjExtractedTimeSeries.mat. Regenerating instead.');
        end
    end
    
    if ~subjExtractedCompleted
%% capture the source folder contents; make hold folders for each subject       
%         file1st=tic;

topLevelFolder = sourceDir; % or whatever, such as 'C:\Users\John\Documents\MATLAB\work'
% Get a list of all files and folders in this folder.
files = dir(topLevelFolder);
% Get a logical vector that tells which is a directory.
dirFlags = [files.isdir];
% Extract only those that are directories.
subFolders = files(dirFlags); % A structure with extra info.
% Get only the folder names into a cell array.
subFolderNames = {subFolders(3:end).name}; % Start at 3 to skip . and ..
truesubFolderNames = extractAfter(subFolderNames,"hold");

% foldst=tic;

% for i=1:length(subFolderNames)
%     mkdir(sourceDir,['hold' subFolderNames{i}])
%     movefile([sourceDir filesep subFolderNames{i}],[sourceDir filesep 'hold' subFolderNames{i}]);
% end

% folden=toc(foldst)

%%        %% Parse supported directory structures to automatically calc filenames, masks, and MPs

     framwiseMotionVectorOutputDir = fullfile(workingDir,'Outputs','Framewise_Motion_Vectors');

        parst=tic;
        clusterParPool(numworkers);
        paren=toc(parst)

     
%      file1en=toc(file1st)
    parfor i=1:length(subFolderNames)
        pardost(i)=tic;
        disp(['starting parfor iteration on:' truesubFolderNames{i}])
        try
%         pardo1st(i)=tic;
        if ~strcmp(format, 'custom')
            modsourceDir=[sourceDir filesep 'hold' truesubFolderNames{i}]
            [filenameMatrix, maskMatrix, MPs, subjIds] = filenameParser(modsourceDir, format, rsfcTaskNames, workingDir, imageSpace, fixflag);
            disp('Files parsed')
        else
            filenameMatrix='null';maskMatrix='null';MPs='null';subjIds='null';
        end
            
        
        %% Validate Provided Files
        if ~fileValidator(filenameMatrix, maskMatrix)
            threshOptLog([workingDir filesep 'Logs' filesep 'log.txt'], 'Filename or Mask Files could not be validated.  Make sure all files provided are nifti format, uncompressed, and accessible to the current user');
            error('Filename or Mask Files could not be validated.  Make sure all files provided are nifti format, uncompressed, and accessible to the current user')
        end
        
        disp('Files validated')
        
%        pardo1en(i)=toc(pardo1st(i))
%        disp(['pardo1en--' num2str(pardo1en(i))]);
       
     %%   
        
%         %% SubjExtractedTimeSeries this section is to be parallelized/modified as shown below this section -neil
%         
%         subjExtractedTimeSeries = subjExtractedTimeSeriesMaker(filenameMatrix, TR, nTrim, MPs, maskMatrix, workingDir, continueBool, filterCutoffs, subjIds);
%         save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'subjExtractedCompleted', '-append', '-v7.3', '-nocompression');
%         disp('Filtering completed. ROI Time Series calculated.')
%         
%         framwiseMotionVectorOutputDir = fullfile(workingDir,'Outputs','Framewise_Motion_Vectors');
%         save_LPFFD_GEVDV(subjExtractedTimeSeries,framwiseMotionVectorOutputDir);
%         disp(['Saved LPF-FD, GEVDV, and filtered MPs in: ' framwiseMotionVectorOutputDir]); drawnow;
%         
%         subjExtractedCompleted = true;
        %% my new section -neil
        
%      load('before_mysection.mat');
%      pardost=tic;
%      parfor i=1:length(subjIds)
%       startit(i)=tic;
 
%         pardo2st(i)=tic;
         
%             disp(['doing' cell2mat(subjIds(1))]);
            subjExtractedTimeSeries = subjExtractedTimeSeriesMaker(filenameMatrix(1,:), TR, nTrim, MPs(1,:), maskMatrix(1,:), workingDir, continueBool, filterCutoffs, subjIds(1));
%             aa=[workingDir filesep 'InternalData' filesep 'currentStep.mat'];
%             bb=[workingDir filesep 'InternalData' filesep 'currentStep' cell2mat(subjIds(1)) '.mat'];
%             copyfile_parfor(aa,bb);
%             copyfile aa bb;
%             subjExtractedCompleted = true;
            
            parsave_aftersubjExtracted([workingDir filesep 'InternalData' filesep 'currentStep' cell2mat(subjIds(1)) '.mat']);
            save_LPFFD_GEVDV(subjExtractedTimeSeries,framwiseMotionVectorOutputDir);
       
%        pardo2en(i)=toc(pardo2st(i))
%        disp(['pardo2en--' num2str(pardo2en(i))]);

        catch err
%          disp(['error detected in following iteration:' num2str(i)]);
         disp(['error detected for following subject folder:' subFolderNames{i}]);
         disp(err)
         end
%          endit(i)=toc(startit(i))
%          disp(endit(i));

        pardoen(i)=toc(pardost(i))
        disp(['pardoen--' num2str(pardoen(i))]);
        pause(eps); drawnow;
        disp('after drawnow');
     end

%      disp('Filtering completed. ROI Time Series calculated.')
%         
%      disp(['Saved LPF-FD, GEVDV, and filtered MPs in: ' framwiseMotionVectorOutputDir]); drawnow;
        
     
%      pardoen=toc(pardost)
    end
    
%     %% Checker
%     % Cleans up subjextractedtimeseries to remove all NaN or 0 runs, saves
%     % memory too
%     % warns the user that this is happening, and saves it to some log file
%     %     inside function?  Something like this disp(['WARNING: Removed xx ROIs from run # ' num2str(j) of subj yy' due to all 0s or all NaNs in an ROI time series.']);
%     % User needs to know:
%     %   When an ROI time series hs all 0s or NaNs, and whether the run is
%     %   kept (run is only removed if all ROIs are all 0/NaN).
%     
%     
%     
%     %% Parameter sweep
%     if ~paramSweepCompleted
%         [totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining] = mseParameterSweep(subjExtractedTimeSeries,useGSR,parameterSweepFileName, TR, continueBool, numOfSecToTrim, minSecDataNeeded);
%         paramSweepCompleted = true;
%         save([workingDir filesep 'InternalData' filesep 'paramSweepReturns.mat'], 'totalNumFrames','targetedVariance','targetedRs','randomRs','FDcutoffs','gevDVcutoffs', 'totalNumFramesRemaining', '-v7.3', '-nocompression');
%         save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'paramSweepCompleted', '-append','-v7.3', '-nocompression');
%         disp('Parameter sweep completed')
%     else
%         load([workingDir filesep 'InternalData' filesep 'paramSweepReturns.mat']);
%         disp('Loaded paramSweepReturns.mat')
%     end
%     
%     %% Max bias calculation
%     if ~(maxBiasCompleted && paramSweepCompleted)
%         maxBias = maxBiasCalculation(totalNumFramesRemaining,totalNumFrames,targetedRs,randomRs);
%         maxBiasCompleted = true;
%         save([workingDir filesep 'InternalData' filesep 'maxBias.mat'], 'maxBias', '-v7.3', '-nocompression');
%         save([workingDir filesep 'InternalData' filesep 'currentStep.mat'], 'maxBiasCompleted', '-append','-v7.3','-nocompression'); %Always save current step AFTER saving data
%         disp('Max bias calculation completed')
%     else
%         load([workingDir filesep 'InternalData' filesep 'maxBias.mat']);
%         disp('Loaded maxBias.mat')
%     end
%     
%     %% MSE calculation and MSE optimum
%     [optimalDV, optimalFD, optimalPCT, minMSE] = mseCalculation(maxBias,totalNumFrames,targetedVariance,targetedRs,randomRs,FDcutoffs,gevDVcutoffs, totalNumFramesRemaining,[workingDir filesep 'InternalData']);
%     
%     disp('MSE calculation completed. saving outputs')
%     
%     save([workingDir filesep 'Outputs' filesep 'Outputs.mat'], 'optimalDV', 'optimalFD', 'optimalPCT', 'minMSE','-v7.3','-nocompression');
%     disp('outputs saved - returning')
disp('completed mcotwrapper');
endall=toc(startall)
end


