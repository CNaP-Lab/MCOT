function [] = save_LPFFD_GEVDV(subjExtractedTimeSeries,framwiseMotionVectorOutputDir)
    numSubjects = length(subjExtractedTimeSeries);
    
    if ~exist(framwiseMotionVectorOutputDir, 'dir')
        mkdir(framwiseMotionVectorOutputDir); pause(eps); drawnow;
    end
    
    for i = 1:numSubjects
        thisSubj = subjExtractedTimeSeries(i);
        subjID = thisSubj.subjId;
        subjDirectory = fullfile(framwiseMotionVectorOutputDir,subjID);
        if ~exist(subjDirectory, 'dir')
            mkdir(subjDirectory); pause(eps); drawnow;
        end
        lpfFD = thisSubj.lpfFD;
        lpfDV = thisSubj.lpfDV;
        fMPs = thisSubj.fMPs;
        numRuns = subjExtractedTimeSeries(i).numRuns;
        lpfFDdir = fullfile(subjDirectory,'LPF_FD');
        lpfDVdir = fullfile(subjDirectory,'LPF_DV');
        fMPsDir = fullfile(subjDirectory,'Filtered_MPs');
        if ~exist(lpfFDdir, 'dir')
            mkdir(lpfFDdir); pause(eps); drawnow;
        end
        if ~exist(lpfDVdir, 'dir')
            mkdir(lpfDVdir); pause(eps); drawnow;
        end
        if ~exist(fMPsDir, 'dir')
            mkdir(fMPsDir); pause(eps); drawnow;
        end
        for j = 1:numRuns
            runName = subjExtractedTimeSeries(i).runName{j};
            runString = [runName '.csv'];
            lpfFDfile = fullfile(lpfFDdir,['LPF_FD_' runString]);
            lpfDVfile = fullfile(lpfDVdir,['LPF_DV_' runString]);
            fMPsfile = fullfile(fMPsDir,['fMPs_' runString]);
            thisLPFFD = lpfFD(:,:,j);
            thisLPFDV = lpfDV(:,:,j);
            thisfMPs = fMPs(:,:,j);
            csvwrite(lpfFDfile,thisLPFFD); pause(eps); drawnow;
            csvwrite(lpfDVfile,thisLPFDV); pause(eps); drawnow;
            csvwrite(fMPsfile,thisfMPs); pause(eps); drawnow;
        end
        
    end
end


















