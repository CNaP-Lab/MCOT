function [filenameMatrix, maskMatrix, MPs] = filenameParser(parentFolder,inputFormat, rsfcTaskNames, outputFolder)
    % Depending on inputFormat, rsfcTaskNames can be a single name (in the case
    % of fmriprep) or an enumerated list in the case of HCP
    
    outputFolder = [outputFolder filesep 'InternalData'];
    
    %convert cell array to String Array
    if isa(rsfcTaskNames, 'cell')
        for i = 1:length(rsfcTaskNames)
            rsfcStrings(i) = string(rsfcTaskNames{i});
        end
        rsfcTaskNames = rsfcStrings;
    end
    
    %Set Study Directory
    studyDirectory = dir(parentFolder);
    studyDirectory = studyDirectory(~ismember({studyDirectory.name},{'.','..'}));
    
    if strcmp(inputFormat, 'fMRIprep')
        filenameMatrix = cell(length(studyDirectory), 1);
        for i = 1:length(studyDirectory)
            thisSubjFold = studyDirectory(i).name;
            if exist([parentFolder filesep thisSubjFold filesep 'func'], 'dir')
                runFiles = dir([parentFolder filesep thisSubjFold filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '*_bold.nii.gz']);
                for j = length(runFiles)
                    filenameMatrix{i, j} = [parentFolder filesep thisSubjFold filesep 'func' filesep runFiles(j).name];
                end
            elseif ~isempty(dir([parentFolder filesep thisSubjFold filesep 'ses-*'], 'dir'))
                sesDirs = dir([parentFolder filesep thisSubjFold filesep 'ses-*']);
                sesDirs = sesDirs(sesDirs.isdir);
                for j = 1:length(sesDirs)
                    if exist([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func'], 'dir')
                        runFiles = dir([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '*_bold.nii.gz']);
                        for k = length(runFiles)
                            filenameMatrix{i, k} = [parentFolder filesep thisSubjFold filesep sesDirs(j) filesep 'func' filesep runFiles(k).name];
                        end
                    end
                end
            end
        end
        
    elseif strcmp(inputFormat, 'HCP')
        %preallocate filename/MP matrix to dimensions of subject x runs
        filenameMatrix = cell(length(studyDirectory), length(rsfcTaskNames));
        MPs = cell(length(studyDirectory), length(rsfcTaskNames));
        %each subj
        for i = 1:length(studyDirectory)
            thisSubjFold = studyDirectory(i).name;
            %if the subject has a results folder (which it should in HCP
            %format)...
            if exist([parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'Results'],'dir')
                resultsDir = [parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'Results'];
                
                % ---- Intialize Mask Finding variables -----
                brainMaskFound = false;
                brainMaskFile = '';
                parcelMaskFound = false;
                parcelMaskFile = '';
                % --------------------------------------------
                
                %each run
                for j = 1:length(rsfcTaskNames)
                    % if mask file has not yet been identified...
                    if ~brainMaskFound
                        %check to see if mask file exists, zipped or not
                        bmdir = dir([resultsDir filesep char(rsfcTaskNames(j)) filesep 'brainmask_fs.2.nii*']);
                        if ~isempty(bmdir)
                            % if its zipped, unzip to tmp working folder...
                            if contains(bmdir(1).name, {'.gz', '.GZ'}) 
                                newFolderPath = strrep([resultsDir filesep char(rsfcTaskNames(j))], parentFolder, outputFolder);
                                if ~exist([newFolderPath filesep 'brainmask_fs.2.nii'], 'file')
                                    gunzip([resultsDir filesep char(rsfcTaskNames(j)) filesep 'brainmask_fs.2.nii.gz'], newFolderPath);
                                end
                                brainMaskFile = [newFolderPath filesep 'brainmask_fs.2.nii'];
                            else
                                brainMaskFile = [resultsDir filesep char(rsfcTaskNames(j)) filesep 'brainmask_fs.2.nii'];
                            end
                            
                            % so this work isn't repeated on subsequent
                            % loops
                            brainMaskFound = true;
                            
                            % Call to maskMaker() which takes the mask
                            % file, format, and desired mask type, and
                            % returns the mask volume and hdr
                            [brainMask, brainMaskHdr] =  maskMaker("HCP", brainMaskFile);
                            brainMaskHdr.fname = [outputFolder filesep 'brainMask' num2str(studyDirectory(i).name) '.nii'];
                            
                            % write mask file to new nifti and record its
                            % location in the maskMatrix return variable 
                            spm_write_vol(brainMaskHdr, brainMask);
                            maskMatrix{i, 1} = brainMaskHdr.fname;
                        end
                    end
                    % the following logic mirrors the brain mask logic
                    % above - see comments there for details
                    if ~parcelMaskFound
                        parcelDir = dir([parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'ROIs' filesep 'Atlas_wmparc.2.nii*']);
                        if ~isempty(parcelDir)
                            if contains(parcelDir(1).name, {'.gz', '.GZ'}) 
                                newFolderPath = strrep([parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'ROIs'], parentFolder, outputFolder);
                                if ~exist([newFolderPath filesep 'Atlas_wmparc.2.nii'], 'file')
                                    gunzip([parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'ROIs' filesep 'Atlas_wmparc.2.nii.gz'], newFolderPath);
                                end
                                parcelMaskFile = [newFolderPath filesep 'Atlas_wmparc.2.nii'];
                            else
                                parcelMaskFile = [parentFolder filesep thisSubjFold filesep 'MNINonLinear' filesep 'ROIs' filesep 'Atlas_wmparc.2.nii'];
                            end
                            
                            parcelMaskFound = true;
                            
                            [whiteMask, whiteMaskHdr] =  maskMaker("HCP", parcelMaskFile, 'white');
                            whiteMaskHdr.fname = [outputFolder filesep 'whiteMask' num2str(studyDirectory(i).name) '.nii'];
                            spm_write_vol(whiteMaskHdr, whiteMask);
                            maskMatrix{i, 2} = whiteMaskHdr.fname;
                            
                            [csfMask, csfMaskHdr] =  maskMaker("HCP", parcelMaskFile, 'csf');
                            csfMaskHdr.fname = [outputFolder filesep 'csfMask' num2str(studyDirectory(i).name) '.nii'];
                            spm_write_vol(csfMaskHdr, csfMask);
                            maskMatrix{i, 3} = csfMaskHdr.fname;
                        end
                    end
                    
                    % grab the run.
                    runDir = dir([resultsDir filesep char(rsfcTaskNames(j)) filesep char(rsfcTaskNames(j)) '.nii*']);
                    if ~isempty(runDir)
                        filenameMatrix{i, j} = [resultsDir filesep char(rsfcTaskNames(j)) filesep runDir(1).name];
                        Mps = load([resultsDir filesep char(rsfcTaskNames(j)) filesep 'Movement_Regressors.txt']);
                        MPs{i,j} = Mps(:,1:6);
                    end
                end
            else
                error(['no Results folder found for subject ' studyDirectory(i).name])
            end
            
        end
        
    else
        threshOpt
        error('Unrecognized Format input to filenameParser')
    end
    
    
    %unzip and relink run files that need it.  Runs are unzipped to tmp
    %working directory, or held in place.
    for i = 1:size(filenameMatrix, 1)
        for j = 1:size(filenameMatrix, 2)
            if ~isempty(filenameMatrix{i,j})
                [fPath, name, fExt] = fileparts(filenameMatrix{i,j});
                if strcmp(lower(fExt), '.gz')
                    newPath = strrep(fPath, parentFolder, outputFolder);
                    if ~exist(fullfile(newPath, name), 'file')
                        filenameMatrix(i,j) = gunzip(filenameMatrix{i,j}, newPath);
                    else
                        filenameMatrix(i,j) = {fullfile(newPath,name)};
                    end
                end
            end
        end
    end
    
    
    
    
end
