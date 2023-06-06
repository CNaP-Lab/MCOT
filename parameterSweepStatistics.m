function [targetedVariance,targetedRs,randomRs] = parameterSweepStatistics(combatstruct,targetedSubjRinROIpair,randomSubjRinROIpair)
    %Calculates statistics from parameter sweep.
    
    %combat operations
   
    %To model biological covariates, a model matrix that will be used to fit coefficients in the linear regression framework has to be provided. To build such a model matrix, continuous variables can be used as they are as columns in the model matrix. For categorical variables, a chosen reference group has to be omitted in the model matrix for identifiability as the intercept will be already included in the ComBat model.
    % age is continuous. sex is categorical, for example.

  
    

%     batch = [1 1 1 2 2]; %Batch variable for the scanner id
%     mod=[];
%     targetedSubjRinROIpair_harmonized = combat(targetedSubjRinROIpair, batch, mod, 0);
%     
%     randomSubjRinROIpair_harmonized = combat(randomSubjRinROIpair, batch, mod, 0);

    if combatstruct.flag==true
           targetedSubjRinROIpair = combat(targetedSubjRinROIpair, combatstruct.batch, combatstruct.mod, combatstruct.method);
    
           randomSubjRinROIpair = combat(randomSubjRinROIpair, combatstruct.batch, combatstruct.mod, combatstruct.method);
        
    end

    % Average Rs across subjects
    targetedRs = nanmean(targetedSubjRinROIpair,2);
    randomRs = nanmean(randomSubjRinROIpair,2);

    targetedVariance = var(targetedSubjRinROIpair,0,2,'omitnan'); %Variance across subjects
    disp('finished parametersweepstatistics');
end
