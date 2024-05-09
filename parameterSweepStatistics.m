function [targetedVariance,targetedRs,randomRs] = parameterSweepStatistics(targetedSubjRinROIpair,randomSubjRinROIpair,varargin)
    %Calculates statistics from parameter sweep.
    if ~isempty(varargin)
        combatstruct = varargin{1};
        doComBat = true;
    else
        doComBat = false;
    end
    
    
    %combat operations
    
    %To model biological covariates, a model matrix that will be used to fit coefficients in the linear regression framework has to be provided. To build such a model matrix, continuous variables can be used as they are as columns in the model matrix. For categorical variables, a chosen reference group has to be omitted in the model matrix for identifiability as the intercept will be already included in the ComBat model.
    % age is continuous. sex is categorical, for example.
    
    
    
    
    %     batch = [1 1 1 2 2]; %Batch variable for the scanner id
    %     mod=[];
    %     targetedSubjRinROIpair_harmonized = combat(targetedSubjRinROIpair, batch, mod, 0);
    %
    %     randomSubjRinROIpair_harmonized = combat(randomSubjRinROIpair, batch, mod, 0);
    
    %CHECK IF combatstruct.mod has any rows that are all the same value in
    %the subjects with remaining data.
    
    %Find missing data
    nanInTargeted = all(isnan(targetedSubjRinROIpair),1);
    nanInRandom = all(isnan(randomSubjRinROIpair ),1);
    
    nanInSubject = nanInTargeted | nanInRandom;
    
    targetedSubjRinROIpair_noNan = targetedSubjRinROIpair(:,~nanInSubject);
    randomSubjRinROIpair_noNan = randomSubjRinROIpair(:,~nanInSubject);
    
    
    if (doComBat)

        combatTest = which('combat');
        if (isempty(combatTest))
            error('ComBat is not on the path!');
        end

        modMatrix = combatstruct.mod(~nanInSubject,:);
        batchVec = combatstruct.batch(~nanInSubject);
        
        % Check if we are left with only one batch, because that would be
        % not great to give to combat
        [uniqueVals,IA,IC] = unique(batchVec);
        numSites = numel(uniqueVals);
        
        if (numSites > 1)
            numCols = size(modMatrix,2);
            removeCol = false(1,numCols);
            for i = 1:numCols
                thisCol = modMatrix(:,i);
                uniqueVals = unique(thisCol);
                numUnique = numel(uniqueVals);
                if (numUnique < 2)
                    removeCol(i) = true;
                end
            end
            modMatrix(:,removeCol) = [];
            
            modMatrixWithBatch = [batchVec,modMatrix];
            
            compareMatrix = eye(size(modMatrixWithBatch));
            
            differenceMatrix = compareMatrix - rref(modMatrixWithBatch);
            redundantCol = any(differenceMatrix,1);
            notRedundantCol = ~redundantCol;
            
            noRedundantModMatrixWithBatch = modMatrixWithBatch(: , notRedundantCol);
            
            noRedundantModMatrix = noRedundantModMatrixWithBatch(: , 2:end);
            
            % now gotta remove columns that are confounded with batch
            
            
            colSumsByGroup = nan(length(unique(IC)),size(noRedundantModMatrix,2));
            
            for idx = 1:size(colSumsByGroup)
                thisGroupsMatrix = noRedundantModMatrix(IC==idx,:);
                colSumsByGroup(idx,:) = any(thisGroupsMatrix);
            end
            
            % get columns where one site has no predictors
            noPredictorForAGivenSite = any(colSumsByGroup==0);
            notnoPredictorForAGivenSite = ~noPredictorForAGivenSite;
            noRedundantModMatrix = noRedundantModMatrix(:,notnoPredictorForAGivenSite);
            % wrap combat in a try catch at this point, so if it fails it
            % just gives us non-combat R's
            try
                targetedSubjRinROIpair_noNan_afterCombat = combat(targetedSubjRinROIpair_noNan, batchVec, noRedundantModMatrix, combatstruct.method);
                randomSubjRinROIpair_noNan_afterCombat = combat(randomSubjRinROIpair_noNan, batchVec, noRedundantModMatrix, combatstruct.method);
                
                targetedSubjRinROIpair_noNan = targetedSubjRinROIpair_noNan_afterCombat;
                randomSubjRinROIpair_noNan = randomSubjRinROIpair_noNan_afterCombat;
            catch err1
                disp(err1); pause(eps); drawnow;
                try
                    targetedSubjRinROIpair_noNan_afterCombat = combat(targetedSubjRinROIpair_noNan, batchVec, [], combatstruct.method);
                    randomSubjRinROIpair_noNan_afterCombat = combat(randomSubjRinROIpair_noNan, batchVec, [], combatstruct.method);
                    
                    targetedSubjRinROIpair_noNan = targetedSubjRinROIpair_noNan_afterCombat;
                    randomSubjRinROIpair_noNan = randomSubjRinROIpair_noNan_afterCombat;
                catch err2
                    disp(err2); pause(eps); drawnow;
                    errMessageCompare = 'Undefined function ''combat'' for input arguments of type ''double''.';
                    thisErrMessage = err2.message;
                    functionNotOnPath = strcmpi(errMessageCompare,thisErrMessage);
                    if (~functionNotOnPath)
                        disp('Combat Failure. Skipping Combat for this iteration...'); pause(eps); drawnow;
                        % this should just skip combat and continue the function
                    else
                        error('ComBat is not on the path!');
                    end
                    
                end
            end
        end
    end
    
    % Average Rs across subjects
    targetedRs = nanmean(targetedSubjRinROIpair_noNan,2);
    randomRs = nanmean(randomSubjRinROIpair_noNan,2);
    
    targetedVariance = var(targetedSubjRinROIpair_noNan,0,2,'omitnan'); %Variance across subjects
    disp('finished parametersweepstatistics');
end
