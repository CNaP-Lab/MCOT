function [combinedResults] = combinedMSE_OptimalThresholds(matFileList)
    %COMBINEDMSE_OPTIMALTHRESHOLDS this function accepts a variable number of
    % mseCalculationWorkspace.mat files from multiple study groups and finds
    % combined optimal FD and DV thresholds, as well as evaluate how many
    % subjects were removed from the study

    % matFileList = cell array of paths to mat files

    combinedFD = [];
    combinedDV = [];
    numSubjsRemainingMat = [];
    groups = struct();
    numGroups = length(matFileList);
    for i = 1:length(matFileList)
        groups(i).Group = load(matFileList{i},'plotFD','plotGEVDV','plotPCT','plotMSE','mean_deltaMSE_overN',...
            'numSubjectsRemaining','FDcutoffs','gevDVcutoffs'); %last 2 are assumed to be the same for each dataset

        numIterations = length(groups(i).Group.numSubjectsRemaining);
        if (i == 1)
            numSubjsRemainingMat = nan(numGroups,numIterations);
            firstNumIterations = numIterations;
        else
            if (numIterations ~= firstNumIterations)
                error('Iteration length mismatch.');
            end
        end

        numSubjsRemainingMat(i,:) = groups(i).Group.numSubjectsRemaining;

        combinedFD = [combinedFD groups(i).Group.plotFD'];
        combinedDV = [combinedDV groups(i).Group.plotGEVDV'];

    end

    uniqueCombinedFD = unique(combinedFD);
    uniqueCombinedDV = unique(combinedDV);

    MSEbyGroup = nan(length(matFileList),length(uniqueCombinedFD));

    for i = 1:length(groups)
        [~,idxFD,idxMSE] = intersect(uniqueCombinedFD,groups(i).Group.plotFD','stable');
        MSEbyGroup(i,idxFD) = groups(i).Group.plotMSE(idxMSE);
    end

    combinedMSE = nansum(MSEbyGroup);

    [minMSE,minIndex] = min(combinedMSE);
    optimalFD = uniqueCombinedFD(minIndex);
    optimalDV = uniqueCombinedDV(minIndex);

    combinedResults.minMSE = minMSE;
    combinedResults.optimalFD = optimalFD;
    combinedResults.optimalDV = optimalDV;

    [~,optFDidx] = min(abs(groups(1).Group.FDcutoffs - optimalFD));
    [~,optDVidx] = min(abs(groups(1).Group.gevDVcutoffs - optimalDV));

    numSubjectsRemovedByGroupFD = [];
    numSubjectsRemovedByGroupDV = [];

    for i = 1:length(groups)
        numRemainingFD = groups(i).Group.numSubjectsRemaining(optFDidx);
        numRemainingDV = groups(i).Group.numSubjectsRemaining(optDVidx);
        numSubjectsRemovedByGroupFD(i) = groups(i).Group.numSubjectsRemaining(1)-groups(i).Group.numSubjectsRemaining(optFDidx);
        numSubjectsRemovedByGroupDV(i) = groups(i).Group.numSubjectsRemaining(1)-groups(i).Group.numSubjectsRemaining(optDVidx);
    end

    combinedResults.numSubjectsRemovedByGroupFD = numSubjectsRemovedByGroupFD;
    combinedResults.numSubjectsRemovedByGroupDV = numSubjectsRemovedByGroupDV;



end

