function [filenameMatrix, maskMatrix, MPs, subjIds] = filenameParser(parentFolder,inputFormat, rsfcTaskNames, outputFolder, OnlyTheseIDs, varargin)
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
    validFolders = [studyDirectory.isdir];
    studyDirectory = studyDirectory(validFolders);
    
    % edit on 11/28/22 by PNT: see if a subjIDlist was provided and filter
    % the studyDirectory to only have those subjects
    if ~isempty(OnlyTheseIDs)
        SubjIdxs = [];
        subjNames = {studyDirectory.name};
        for idx = 1:length(OnlyTheseIDs)
            foundSubj = find(strcmp(subjNames,OnlyTheseIDs{idx}));
            if ~isempty(foundSubj)
                SubjIdxs(end+1) = foundSubj;
            end
        end
    end
    
    % filter studyDirectory
    studyDirectory = studyDirectory(SubjIdxs);
    
    if strcmp(inputFormat, 'fMRIprep')
        
        %grab space name for fmri prep
        fmriPrepSpace = varargin{1};
        
        rsfcTaskNames = char(rsfcTaskNames);
        
        filenameMatrix = cell(length(studyDirectory), 1);
        subjIds = cell(length(studyDirectory), 1);
        for i = 1:length(studyDirectory)
            thisSubjFold = studyDirectory(i).name;
            subjIds{i} = studyDirectory(i).name;
            % ---- Intialize Mask Finding variables -----
            brainMaskFound = false;
            brainMaskFile = '';
            parcelMaskFound = false;
            parcelMaskFile = '';
            % --------------------------------------------
            
                
            if exist([parentFolder filesep thisSubjFold filesep 'func'], 'dir')
                
                if ~parcelMaskFound
                    %check to see if mask file exists, zipped or not
                    pdir = dir([parentFolder filesep thisSubjFold filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_space-' fmriPrepSpace '_desc-aparcaseg_dseg.nii*']);
                    if ~isempty(pdir)
                        % if its zipped, unzip to tmp working folder...
                        if contains(lower(pdir(1).name), '.gz')
                            zippedFile = [parentFolder filesep thisSubjFold filesep 'func' filesep pdir(1).name];
                            newFolderPath = strrep(zippedFile, parentFolder, outputFolder);
                            unzippedFile = strrep(newFolderPath, '.gz', '');
                            unzippedFile = strrep(unzippedFile, '.GZ', '');
                            [unzipPath,~,~] = fileparts(unzippedFile);
                            if ~exist(unzippedFile, 'file')
                                gunzip(zippedFile, unzipPath);
                            end
                            parcelMaskFile = unzippedFile;
                        else
                            parcelMaskFile = [parentFolder filesep thisSubjFold filesep 'func' filesep pdir(1).name];
                        end
                        
                        % so this work isn't repeated on subsequent
                        % loops
                        parcelMaskFound = true;
                        
                        [whiteMask, whiteMaskHdr] =  maskMaker("fMRIprep", parcelMaskFile, 'white');
                        whiteMaskHdr.fname = [outputFolder filesep 'whiteMask' num2str(studyDirectory(i).name) '.nii'];
                        spm_write_vol(whiteMaskHdr, whiteMask);
                        maskMatrix{i, 2} = whiteMaskHdr.fname;
                        
                        [csfMask, csfMaskHdr] =  maskMaker("fMRIprep", parcelMaskFile, 'csf');
                        csfMaskHdr.fname = [outputFolder filesep 'csfMask' num2str(studyDirectory(i).name) '.nii'];
                        spm_write_vol(csfMaskHdr, csfMask);
                        maskMatrix{i, 3} = csfMaskHdr.fname;
                    end
                end
                
                
                
                        runFiles = dir([parentFolder filesep thisSubjFold filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_space-' fmriPrepSpace '_desc-preproc_bold.nii.gz']);
                        MPfiles = dir([parentFolder filesep thisSubjFold filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_desc-confounds_regressors.json']);
                        for k = 1:length(runFiles)
                            filenameMatrix{i, k} = [parentFolder filesep thisSubjFold filesep 'func' filesep runFiles(k).name];
                            cReg = tdfread([fullfile(parentFolder,thisSubjFold, 'func') filesep MPfiles(k).name]);
                            mReg = [cReg.trans_x cReg.trans_y cReg.trans_z cReg.rot_x cReg.rot_y cReg.rot_z];
                            degReg = mReg(:,4:6).*(180./pi);
                            MPs{i,k} = [mReg(:,1:3) degReg];
                        end
            elseif ~isempty(dir([parentFolder filesep thisSubjFold filesep 'ses-*']))
                sesDirs = dir([parentFolder filesep thisSubjFold filesep 'ses-*']);
                sesDirs = sesDirs(sesDirs.isdir);
                for j = 1:length(sesDirs)
                    if exist([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func'], 'dir')
                        
                        if ~parcelMaskFound
                            %check to see if mask file exists, zipped or not
                            pdir = dir([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_space-' fmriPrepSpace '_desc-aparcaseg_dseg.nii*']);
                            if ~isempty(pdir)
                                % if its zipped, unzip to tmp working folder...
                                if contains(lower(pdir(1).name), '.gz')
                                    zippedFile = [parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep pdir(1).name];
                                    newFolderPath = strrep(zippedFile, parentFolder, outputFolder);
                                    unzippedFile = strrep(newFolderPath, '.gz', '');
                                    unzippedFile = strrep(unzippedFile, '.GZ', '');
                                    [unzipPath,~,~] = fileparts(unzippedFile);
                                    if ~exist(unzippedFile, 'file')
                                        gunzip(zippedFile, unzipPath);
                                    end
                                    parcelMaskFile = unzippedFile;
                                else
                                    parcelMaskFile = [parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep pdir(1).name];
                                end
                                
                                % so this work isn't repeated on subsequent
                                % loops
                                parcelMaskFound = true;
                                
                                [whiteMask, whiteMaskHdr] =  maskMaker("fMRIprep", parcelMaskFile, 'white');
                                whiteMaskHdr.fname = [outputFolder filesep 'whiteMask' num2str(studyDirectory(i).name) '.nii'];
                                spm_write_vol(whiteMaskHdr, whiteMask);
                                maskMatrix{i, 2} = whiteMaskHdr.fname;
                                
                                [csfMask, csfMaskHdr] =  maskMaker("fMRIprep", parcelMaskFile, 'csf');
                                csfMaskHdr.fname = [outputFolder filesep 'csfMask' num2str(studyDirectory(i).name) '.nii'];
                                spm_write_vol(csfMaskHdr, csfMask);
                                maskMatrix{i, 3} = csfMaskHdr.fname;
                            end
                        end
                        
                        
                        
                        runFiles = dir([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_space-' fmriPrepSpace '_desc-preproc_bold.nii.gz']);
                        MPfiles = dir([parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep 'sub-*_ses-*_task-' rsfcTaskNames '_run-*_desc-confounds_regressors.tsv']);
                        for k = 1:length(runFiles)
                            filenameMatrix{i, k} = [parentFolder filesep thisSubjFold filesep sesDirs(j).name filesep 'func' filesep runFiles(k).name];
                            cReg = tdfread([fullfile(parentFolder,thisSubjFold, sesDirs(j).name, 'func') filesep MPfiles(k).name]);
                            mReg = [cReg.trans_x cReg.trans_y cReg.trans_z cReg.rot_x cReg.rot_y cReg.rot_z];
                            degReg = mReg(:,4:6).*(180./pi);
                            MPs{i,k} = [mReg(:,1:3) degReg];
                        end
                    end
                end
            end
            
            if ~brainMaskFound
                %check to see if mask file exists, zipped or not
                pdir = dir([parentFolder filesep thisSubjFold filesep 'anat' filesep 'sub-*_space-' fmriPrepSpace '_desc-brain_mask.nii*']);
                if ~isempty(pdir)
                    % if its zipped, unzip to tmp working folder...
                    if contains(lower(pdir(1).name), '.gz')
                        zippedFile = [parentFolder filesep thisSubjFold filesep 'anat' filesep pdir(1).name];
                        newFolderPath = strrep(zippedFile, parentFolder, outputFolder);
                        unzippedFile = strrep(newFolderPath, '.gz', '');
                        unzippedFile = strrep(unzippedFile, '.GZ', '');
                        [unzipPath,~,~] = fileparts(unzippedFile);
                        if ~exist(unzippedFile, 'file')
                            gunzip(zippedFile, unzipPath);
                        end
                        brainMaskFile = unzippedFile;
                    else
                        brainMaskFile = [parentFolder filesep thisSubjFold filesep 'anat' filesep pdir(1).name];
                    end
                    
                    % so this work isn't repeated on subsequent
                    % loops
                    brainMaskFound = true;
                    
                    copiedBrainFile = strrep(brainMaskFile, parentFolder, outputFolder);
                    if ~exist(copiedBrainFile, 'file')
                        copyfile(brainMaskFile, copiedBrainFile)
                    end
                    
                    [brainPath, brainFile, brainExt] = fileparts(copiedBrainFile);
                    brainMaskFile = fullfile(brainPath, ['reslice_' brainFile brainExt]);
                    
                    
                    if ~exist(brainMaskFile, 'file')
                        slicejob{1}.spm.spatial.coreg.write.ref = {[parcelMaskFile ',1']};
                        slicejob{1}.spm.spatial.coreg.write.source = {[copiedBrainFile ',1']};
                        slicejob{1}.spm.spatial.coreg.write.roptions.interp = 0;
                        slicejob{1}.spm.spatial.coreg.write.roptions.wrap = [0,0,0];
                        slicejob{1}.spm.spatial.coreg.write.roptions.mask = 0;
                        slicejob{1}.spm.spatial.coreg.write.roptions.prefix = 'reslice_';
                        
                        spm_jobman('run',{slicejob(1)});
                    end
                    
                    
                    % Call to maskMaker() which takes the mask
                    % file, format, and desired mask type, and
                    % returns the mask volume and hdr
                    [brainMask, brainMaskHdr] =  maskMaker("fMRIprep", brainMaskFile);
                    brainMaskHdr.fname = [outputFolder filesep 'brainMask' num2str(studyDirectory(i).name) '.nii'];
                    
                    % write mask file to new nifti and record its
                    % location in the maskMatrix return variable
                    spm_write_vol(brainMaskHdr, brainMask);
                    maskMatrix{i, 1} = brainMaskHdr.fname;
                end
            end
            
        end
        
    elseif strcmp(inputFormat, 'HCP')
        %preallocate filename/MP matrix to dimensions of subject x runs
        filenameMatrix = cell(length(studyDirectory), length(rsfcTaskNames));
        MPs = cell(length(studyDirectory), length(rsfcTaskNames));
        subjIds = cell(length(studyDirectory), 1);
        %each subj
        for i = 1:length(studyDirectory)
            thisSubjFold = studyDirectory(i).name;
            subjIds{i} = studyDirectory(i).name;
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
                            if contains(lower(bmdir(1).name), '.gz')
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
                            if contains(lower(parcelDir(1).name), '.gz')
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
