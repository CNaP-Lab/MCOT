function [] = Continue_MCOT_K_Analyses(runNumber)
    dbstop error; pause(eps); drawnow;
    %convert into set, subjtype, site.  3 sites, 2 subj types, 2 sets.
    %Total = 2*2*3 = 12.
    %Inputs start at 1, end at 12.
    %Site, subj, and set numbers start at 1
    convertA = dec2base(runNumber-1,3,3);
    siteNumber = str2double(convertA(end)) + 1
    convertB = base2dec(convertA(1:end-1),3);
    convertC = dec2base(convertB,2,2);
    subjTypeNumber = str2double(convertC(end)) + 1
    setTypeNumber = str2double(convertC(end-1)) + 1

    %if (siteNumber == 3)
    numParamSweepWorkers = 28;
    %else
    %   numParamSweepWorkers = 28;
    %end

    restoredefaultpath; pause(eps); drawnow;
    addpath(genpath('/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/MCOT/Code')); pause(eps); drawnow;

    rootHomeDir = '/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/MCOT/HomeDir_091423_Reprocess';

    sourceDirs = { ...
        '/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/SBU_K', ...
        '/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/QCplots_HCP_4.2_for_final', ...
        '/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/NYSPI_K'};

    badVolsFilePath = '/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/MCOT/Code/ALL_FINAL_K01_RDoC_EYE_CLOSURES_2023-07-06.txt';

    MCOTsetup.RSonly.HC.SBU.subjList = {'50022','50023','50026','50028','50046','50077','50081','50088',...
        '50091','50095','50097','50100','50105','50121','50122','50126','50158','50190',...
        '50199','50208','50216','50246','50266','50270','50284'};
    MCOTsetup.RSonly.SCZ.SBU.subjList = {'50002_1','50003','50005','50006','50007_1','50008','50009','50012_1','50017',...
        '50018','50019','50041','50049','50053','50059_1','50068','50070','50073','50074_1','50076_1','50078_1',...
        '50090_1','50107','50112_1','50117','50124_1','50129_1','50132_1','50136_1','50140_1','50146_1','50156_1','50159',...
        '50161','50164','50165','50168_1','50173','50175','50178','50247','50272','50295','50300','50301',...
        '50314'};
    %MCOTsetup.RSonly.SCZ.SBU.subjList = {'50002_1','50003','50005','50006','50007_1','50008','50009',
    %'50012_1','50017','50018','50019','50053','50074_1','50076_1','50112_1','50124_1','50140_1',
    %'50156_1','50168_1','50041','50049','50059_1','50068','50070','50073','50078_1','50090_1','50107',
    %'50117','50129_1','50132_1','50136_1','50146_1','50159','50161','50164','50165','50173','50175',
    %'50178','50247','50272','50295','50300','50301','50314'};
    MCOTsetup.RSonly.HC.NYSPI.subjList = {'1437','1491','2280','2450',...
        '2546','2791','2839','2875','2891','2933','2934','2945','2958','2985','3012','3045','3074',...
        '3089','3092','3126','3162','3163','3174','3193','3194','3316','3322','3325','3327','3333','3337'};
    MCOTsetup.RSonly.SCZ.NYSPI.subjList = {'194_3','2264','2284','2588','2782','2812','2849','2939','2942','2948','3000','3002','3007',...
        '3025','3056','3057','3085','3098','3133','3151','3170','3171','3181','3182','3189','3218','3244',...
        '3264','3288','3299','3300','3307','3308','3311','3312','3314','3350','3352'};
    %MCOTsetup.RSonly.SCZ.NYSPI.subjList = {'194_3','2264','2284','2588','2782','2812','2839','2849','2939','2942','2948','3000','3002','3007','3025','3056','3057','3085','3098','3133','3151','3170','3171','3181','3182','3189','3218','3244','3264','3288','3299','3300','3307','3308','3311','3312','3314','3350','3352'};

    MCOTsetup.RSTL.HC.SBU.subjList = {'50023','50026','50046','50077','50081','50095','50097','50100','50105',...
        '50121','50122','50126','50158','50190','50199','50208','50216','50246','50266','50270',...
        '50284'};
    MCOTsetup.RSTL.SCZ.SBU.subjList = {'50002_1','50003','50005','50007_1','50008','50009','50012_1','50017',...
        '50018','50019','50049','50068','50074_1','50076_1','50078_1','50090_1','50107','50112_1',...
        '50117','50124_1','50129_1','50132_1','50136_1','50140_1','50146_1','50156_1','50168_1','50178','50247',...
        '50272','50295','50300','50301','50314'};
    %MCOTsetup.RSTL.SCZ.SBU.subjList = {'50002_1','50003','50005','50006','50007_1','50008','50009','50012_1','50017','50018','50019','50053',
    %'50074_1','50076_1','50112_1','50124_1','50140_1','50156_1','50168_1','50049','50068','50090_1','50107','50117',
    %'50129_1','50132_1','50136_1','50146_1','50178','50247','50272','50295','50300','50301','50314'};
    MCOTsetup.RSTL.HC.NYSPI.subjList = {'1437','2280','2450','2791','2875','2933','2934','2945','2958','2985','3012','3045',...
        '3074','3089','3092','3126','3162','3163','3193','3194','3316','3322','3325','3327','3333','3337'};
    MCOTsetup.RSTL.SCZ.NYSPI.subjList = {'194_3','2284','2588','2782','2812','2849','3057',...
        '3085','3098','3133','3151','3170','3181','3182','3244','3264','3299','3300','3308','3311',...
        '3312','3314','3350'};
    %MCOTsetup.RSTL.SCZ.NYSPI.subjList = {'194_3','2264','2284','2588','2782','2812','2839','2849','2948','3056','3057','3085','3098','3133','3151','3170','3171','3181','3182','3244','3264','3299','3300','3307','3308','3311','3312','3314','3350'};

    failed_TL_QC = {};

    tinSubj = {};
    ntrimNYSPI = 7;
    ntrimSBU = 0;
    TRnyspi = 0.85;
    TRsbu = 0.80;

    %Build struct for less confusion
    MCOTsetNames = fieldnames(MCOTsetup);
    for i = 1:length(MCOTsetNames)
        thisSetName = MCOTsetNames{i};
        thisSet = MCOTsetup.(thisSetName);
        subjTypeNames = fieldnames(thisSet);
        for j = 1:length(subjTypeNames)
            thisSubjTypeName = subjTypeNames{j};
            thisSubjType = thisSet.(thisSubjTypeName);
            siteNames = fieldnames(thisSubjType);
            for k = 1:length(siteNames)
                thisSiteName = siteNames{k};
                thisSite = thisSubjType.(thisSiteName);
                thisNumSubjs = length(thisSite.subjList);
                if(strcmp(thisSiteName,'NYSPI'))
                    MCOTsetup.(thisSetName).(thisSubjTypeName).(thisSiteName).ntrim = repmat(ntrimNYSPI,1,thisNumSubjs);
                    MCOTsetup.(thisSetName).(thisSubjTypeName).(thisSiteName).TR = repmat(TRnyspi,1,thisNumSubjs);
                elseif(strcmp(thisSiteName,'SBU'))
                    MCOTsetup.(thisSetName).(thisSubjTypeName).(thisSiteName).ntrim = repmat(ntrimSBU,1,thisNumSubjs);          %#ok<RPMT0>
                    MCOTsetup.(thisSetName).(thisSubjTypeName).(thisSiteName).TR = repmat(TRsbu,1,thisNumSubjs);
                end

                MCOTsetup.(thisSetName).(thisSubjTypeName).(thisSiteName).workingDir = ...
                    fullfile(rootHomeDir,thisSetName,thisSubjTypeName,thisSiteName);

            end

            %Combine for both sites.
            MCOTsetup.(thisSetName).(thisSubjTypeName).bothSites.subjList = ...
                [MCOTsetup.(thisSetName).(thisSubjTypeName).SBU.subjList, ...
                MCOTsetup.(thisSetName).(thisSubjTypeName).NYSPI.subjList];

            MCOTsetup.(thisSetName).(thisSubjTypeName).bothSites.ntrim = ...
                [MCOTsetup.(thisSetName).(thisSubjTypeName).SBU.ntrim, ...
                MCOTsetup.(thisSetName).(thisSubjTypeName).NYSPI.ntrim];

            MCOTsetup.(thisSetName).(thisSubjTypeName).bothSites.TR = ...
                [MCOTsetup.(thisSetName).(thisSubjTypeName).SBU.TR, ...
                MCOTsetup.(thisSetName).(thisSubjTypeName).NYSPI.TR];

            MCOTsetup.(thisSetName).(thisSubjTypeName).bothSites.workingDir = ...
                fullfile(rootHomeDir,thisSetName,thisSubjTypeName,'bothSites');

        end
    end

    runNames = {'RSFC_fMRI_1','RSFC_fMRI_2','RSFC_fMRI_3','RSFC_fMRI_4','RS_fMRI_1','RS_fMRI_2','RS_fMRI_3','RS_fMRI_4'};
    filterCutoffs = [0.009 0.08]
    secTrimPostBPF = 22
    minSecData = ceil(60 * 1.5) % 1.5min to seconds
    numRunsDataNeededPerSubject = 2
    minSecDataNeededPerSubject = ceil(5 * 60) % 5min to seconds
    minNumContiguousDataSeconds = 8 %8 seconds
    format = 'HCP'

    %Now get the set, subject type, and site that we are working on

    MCOTsetNames = fieldnames(MCOTsetup);
    thisSetName = MCOTsetNames{setTypeNumber};
    thisSet = MCOTsetup.(thisSetName);
    subjTypeNames = fieldnames(thisSet);
    thisSubjTypeName = subjTypeNames{subjTypeNumber};
    thisSubjType = thisSet.(thisSubjTypeName);
    siteNames = fieldnames(thisSubjType);
    thisSiteName = siteNames{siteNumber};
    thisSite = thisSubjType.(thisSiteName);

    workingDir = thisSite.workingDir
    TR = thisSite.TR
    ntrim = thisSite.ntrim
    subjList = thisSite.subjList

    % Split strings in x at the first occurrence of '_'
    subjList_split = cellfun(@(s) strtok(s, '_'), subjList, 'UniformOutput', false);
    if (strcmpi(thisSetName,'RSTL'))
        indexToRemoveSubj = ismember(subjList_split, failed_TL_QC);
    elseif (strcmpi(thisSetName,'RSonly'))
        indexToRemoveSubj = ismember(subjList_split, tinSubj);
    end
    %indexToRemoveSubj = ismember(subjList_split, failed_TL_QC);
    subjList(indexToRemoveSubj) = [];
    TR(indexToRemoveSubj) = [];
    ntrim(indexToRemoveSubj) = [];
    if (sum(indexToRemoveSubj)>0)
        error('Check if this is ok.');
    end

    if (~strcmpi(thisSiteName,'bothSites'))
        mCotWrapper(workingDir,'sourcedirectory',sourceDirs,'runnames',runNames,'filtercutoffs',filterCutoffs,...
            'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'badvolsfile',badVolsFilePath,...
            'subjids',subjList,'format',format, ...
            "numParamSweepWorkers", numParamSweepWorkers,...
            'numRunsDataNeededPerSubject',numRunsDataNeededPerSubject ,...
            'minSecDataNeededPerSubject',minSecDataNeededPerSubject , ...
            'minNumContiguousDataSeconds', minNumContiguousDataSeconds, ...
            "removeSubjIndexFromContinue",indexToRemoveSubj, ...
            "forceParamSweep", true, ...
            "continue");
    else
        combatstruct = setupCombatStruct(thisSetName,thisSubjTypeName);
        %         if runNumber~=6 && runNumber~=12 %blame phil for this
        %             combatstruct.batch(indexToRemoveSubj,:) = [];
        %             combatstruct.mod(indexToRemoveSubj,:) = [];
        %         end
        % if (strcmpi(thisSetName,'RSTL')) %Disable continue for RSTL for now...
        %     mCotWrapper(workingDir,'sourcedirectory',sourceDirs,'runnames',runNames,'filtercutoffs',filterCutoffs,...
        %         'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'badvolsfile',badVolsFilePath,...
        %         'subjids',subjList,'format',format,"combatstruct",combatstruct, ...
        %         "numParamSweepWorkers", numParamSweepWorkers);  %Note new option, StopAfterPostProcessing.  It means what you think it means.  Only necessary before we have our mod arrays for ComBat.
        % else
        mCotWrapper(workingDir,'sourcedirectory',sourceDirs,'runnames',runNames,'filtercutoffs',filterCutoffs,...
            'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'badvolsfile',badVolsFilePath,...
            'subjids',subjList,'format',format,...
            "combatstruct",combatstruct, ...
            "numParamSweepWorkers", numParamSweepWorkers, ...
            'numRunsDataNeededPerSubject',numRunsDataNeededPerSubject ,...
            'minSecDataNeededPerSubject',minSecDataNeededPerSubject , ...
            'minNumContiguousDataSeconds', minNumContiguousDataSeconds, ...
            "forceParamSweep", true, ...
            "removeSubjIndexFromContinue",indexToRemoveSubj,"continue");  %Note new option, StopAfterPostProcessing.  It means what you think it means.  Only necessary before we have our mod arrays for ComBat.
        % end
    end
end

function [combatstruct] = setupCombatStruct(thisSetName,thisSubjTypeName)
    %% Actually do combined NYSPI+SBU MCOT now
    % For specifying folder of duplicate subjects:
    % SBU_K = '_1'
    % RDoC = '_2'


    if (strcmpi(thisSetName,'RSTL') && strcmpi(thisSubjTypeName,'HC'))
        % SBU comes first
        age = [21,21,31,27,25,27,52,52,23,22,48,18,35,25,39,22,28,24,18,21,19,40,31,26,48,29,32,30,29,31,35,23,37,25,21,27,25,19,19,50,20,38,32,39,44,47,23]';
        isMale = [0,0,1,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,1,1,0,0,0,1,1,1,0,1,1,1,1,0,1,0,1,1,1,1,1,1,0,0,1,1,1,1,1]';
        rHand = [1,1,0.500000000000000,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0.500000000000000,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        ethnHisp = [0,0,0,0,0,0,1,0,1,0,0,0,1,1,0,1,0,0,1,0,0,0,0,1,1,0,0,1,1,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0]';
        smoke = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0]';
        SES = [43,63.5000000000000,38.5000000000000,62,36.5000000000000,48,32,54,45,46,28.5000000000000,26,48,31.5000000000000,43.5000000000000,48,38.5000000000000,27,33,61,61,26.5000000000000,44,40,45.0500000000000,27,43.5000000000000,45,46,39,53,44,53,46.5000000000000,32,61,32,54,54,42,44.2000000000000,17,53,46.5000000000000,27,50,61]';
        panss_gs = [22,16,18,16,27,27,26,16,16,18,16,16,19,29,18,17,21,18,26,26,16,27,16,16,17,16,16,16,16,16,16,16,18,16,16,16,17,16,18,18,18,18,16,19,20,16,18]';
        panss_ps = [7,7,7,7,7,7,11,7,7,7,7,8,9,10,8,7,9,9,8,7,7,9,8,7,7,7,7,7,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,7,7,7]';
        panss_ns = [7,9,7,7,11,13,23,7,8,8,7,9,10,13,7,7,9,13,9,14,13,16,8,16,8,7,8,7,9,9,8,7,9,10,7,9,9,7,9,7,9,7,7,11,9,7,11]';


        race = {'Asian','African American','African American','Caucasian','African American','African American','Caucasian','African American','More than one','Caucasian','African American','Caucasian','More than one','Other/Unknown','African American','Caucasian','Caucasian','Asian','Other/Unknown','Caucasian','Caucasian','African American','African American','African American','Other/Unknown','African American','Caucasian','Other/Unknown','Asian','Caucasian','Caucasian','African American','Asian','African American','Other/Unknown','Other/Unknown','African American','Other/Unknown','Caucasian','African American','Caucasian','African American','Asian','Caucasian','African American','African American','Caucasian'};
        race = categorical(race);
        race = dummyvar(race');

        batch = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        % construct combat design matrix (exclude one column for race as reference)
        mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1

        %
    elseif (strcmpi(thisSetName,'RSTL') && strcmpi(thisSubjTypeName,'SCZ'))
        age = [31,29,21,25,23,34,41,21,60,31,31,35,55,23,27,56,27,26,24,27,43,18,19,42,36,23,18,50,21,34,28,35,22,32,44,58,47,37,39,36,20,40,22,20,22,19,20,22,58,37,36,52,22,25,39,23,27]';
        isMale = [1,1,1,1,1,1,1,1,1,1,1,1,0,0,1,1,0,1,1,0,1,0,0,0,0,0,1,1,1,0,1,1,0,0,1,1,0,1,1,0,0,1,1,1,0,1,1,1,1,0,1,1,1,1,1,1,0]';
        rHand = [1,1,1,0.500000000000000,1,1,1,0.500000000000000,1,1,1,1,1,0,1,1,1,0.500000000000000,0.500000000000000,1,1,1,1,1,1,0.500000000000000,1,1,1,1,1,1,0,0.500000000000000,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        ethnHisp = [0,0,0,1,0,1,0,0,0,0,0,1,0,1,0,0,0,0,1,0,0,1,0,0,0,1,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,1,1,0,1,0]';
        smoke = [0,0,1,0,0,1,1,0,0,0,0,1,1,0,1,0,0,0,0,0,1,0,0,1,0,1,0,1,0,0,0,1,1,1,0,1,0,1,0,1,0,1,1,0,0,0,0,0,0,0,1,0,0,1,1,0,0]';
        SES = [50.5000000000000,40,30.5000000000000,36.5000000000000,45,37,53,54.5000000000000,51.5000000000000,42.5000000000000,27,36.5000000000000,8,29.5000000000000,53,57,32,51,21.5000000000000,38,28.5000000000000,29,66,35,50,41.3000000000000,33,30.9000000000000,39.5000000000000,47,31.5000000000000,27,58,50,33,25,30,61,45,15.1000000000000,32,52,50,46,56,38,70,22.7000000000000,23,27,45,32,66,29.5000000000000,35.4000000000000,18.5000000000000,42]';
        panss_gs = [30,36,29,33,42,26,36,37,36,37,24,34,38,45,52,29,24,29,46,41,53,37,32,43,59,41,51,50,56,38,30,31,38,37,22,42,28,30,30,48,42,25,27,25,55,58,30,43,30,21,26,31,38,16,33,25,24]';
        panss_ps = [19,20,21,7,23,9,24,18,19,23,11,22,22,25,20,20,8,11,20,30,28,20,12,29,24,23,31,29,25,14,11,7,28,19,11,29,10,24,16,18,15,13,13,18,19,29,13,27,7,15,12,17,23,7,29,16,12]';
        panss_ns = [11,14,17,17,10,28,17,9,16,18,23,10,17,20,22,7,11,17,16,10,22,12,11,9,16,11,12,31,26,11,17,22,9,15,9,20,9,17,10,21,19,14,14,23,24,29,17,20,17,13,9,17,16,7,23,13,10]';
        race = {'Caucasian','Caucasian','Caucasian','Other/Unknown','Caucasian','Other/Unknown','Caucasian','Caucasian','African American','Caucasian','African American','Caucasian','African American','Caucasian','African American','More than one','African American','More than one','More than one','African American','Other/Unknown','Caucasian','Caucasian','More than one','Caucasian','More than one','More than one','More than one','Asian','Caucasian','More than one','African American','Caucasian','African American','African American','Caucasian','African American','Asian','African American','African American','African American','African American','More than one','Caucasian','Asian','More than one','African American','Caucasian','African American','African American','African American','African American','More than one','More than one','Caucasian','Other/Unknown','African American'};
        race = categorical(race);
        race = dummyvar(race');

        batch = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        % construct combat design matrix (exclude one column for race as reference)
        %mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns psyratAH psyratD sans cdrs race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1
        mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1

    elseif (strcmpi(thisSetName,'RSonly') && strcmpi(thisSubjTypeName,'HC'))
        age = [23,21,21,19,31,27,25,41,31,27,52,52,23,22,48,18,35,25,39,22,28,24,18,21,19,40,48,31,26,39,48,30,29,25,32,30,29,31,35,23,37,25,21,27,25,19,19,53,50,20,38,32,39,44,47,23]';
        isMale = [1,0,0,0,1,0,1,0,1,1,1,1,1,0,0,0,1,1,0,1,1,1,1,1,0,0,1,0,1,1,1,0,1,0,0,1,1,1,1,0,1,0,1,1,1,1,1,1,1,0,0,1,1,1,1,1]';
        rHand = [1,1,1,1,0.500000000000000,1,1,1,0.500000000000000,1,1,1,1,1,1,1,1,1,1,1,0,1,1,0.500000000000000,1,1,0,1,1,1,1,1,1,1,1,1,1,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        ethnHisp = [0,0,0,0,0,0,0,1,0,0,1,0,1,0,0,0,1,1,0,1,0,0,1,0,0,0,0,0,1,0,1,0,0,0,0,1,1,0,0,0,0,0,1,1,0,1,1,0,0,0,0,0,0,0,0,0]';
        smoke = [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0]';
        SES = [47,43,63.5000000000000,40.5000000000000,38.5000000000000,62,36.5000000000000,41.5000000000000,40,48,32,54,45,46,28.5000000000000,26,48,31.5000000000000,43.5000000000000,48,38.5000000000000,27,33,61,61,26.5000000000000,31,44,40,58,46.4500000000000,58,27,45,43.5000000000000,45,46,39,53,44,53,46.5000000000000,32,61,32,54,54,45,42,43.9500000000000,17,53,46.5000000000000,27,50,61]';
        panss_gs = [18,22,16,20,18,16,27,20,17,27,26,16,16,18,16,16,19,29,18,17,21,18,26,26,16,27,22,16,16,16,17,16,16,16,16,16,16,16,16,16,18,16,16,16,17,16,18,16,18,18,18,16,19,20,16,18]';
        panss_ps = [7,7,7,7,7,7,7,7,9,7,11,7,7,7,7,8,9,10,8,7,9,9,8,7,7,9,7,8,7,7,7,7,7,7,7,7,8,7,7,7,7,7,7,7,7,7,7,7,7,7,7,7,8,7,7,7]';
        panss_ns = [7,7,9,9,7,7,11,7,12,13,23,7,8,8,7,9,10,13,7,7,9,13,9,14,13,16,11,8,16,7,8,9,7,15,8,7,9,9,8,7,9,10,7,9,9,7,9,7,7,9,7,7,11,9,7,11]';
        race = {'African American','Asian','African American','Caucasian','African American','Caucasian','African American','Caucasian','African American','African American','Caucasian','African American','More than one','Caucasian','African American','Caucasian','More than one','Other/Unknown','African American','Caucasian','Caucasian','Asian','Other/Unknown','Caucasian','Caucasian','African American','African American','African American','African American','Caucasian','Other/Unknown','African American','African American','Caucasian','Caucasian','Other/Unknown','Asian','Caucasian','Caucasian','African American','Asian','African American','Other/Unknown','Other/Unknown','African American','Other/Unknown','Caucasian','African American','African American','Caucasian','African American','Asian','Caucasian','African American','African American','Caucasian'};
        race = categorical(race);
        race = dummyvar(race');

        batch = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        % construct combat design matrix (exclude one column for race as reference)
        mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1

    elseif (strcmpi(thisSetName,'RSonly') && strcmpi(thisSubjTypeName,'SCZ'))
        age = [31,29,21,53,25,23,34,41,21,60,31,39,31,49,27,35,27,30,55,23,27,56,27,26,24,27,43,18,19,42,36,23,22,48,52,26,18,25,20,50,21,34,28,35,22,32,44,49,58,47,37,39,36,20,23,24,36,35,19,20,56,20,40,22,20,22,19,19,20,22,31,20,58,37,24,36,52,22,22,25,39,23,27,24]';
        isMale = [1,1,1,1,1,1,1,1,1,1,1,0,1,0,1,1,0,1,0,0,1,1,0,1,1,0,1,0,0,0,0,0,1,0,0,1,1,0,0,1,1,0,1,1,0,0,1,1,1,0,1,1,0,1,1,0,0,0,0,1,1,0,1,1,1,0,1,1,1,1,1,1,1,0,1,1,1,0,1,1,1,1,0,1]';
        rHand = [1,1,1,1,0.500000000000000,1,1,1,0.500000000000000,1,1,1,1,1,0.500000000000000,1,1,0.500000000000000,1,0,1,1,1,0.500000000000000,0.500000000000000,1,1,1,1,1,1,0.500000000000000,1,1,1,1,1,0.500000000000000,1,1,1,1,1,1,0,0.500000000000000,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        ethnHisp = [0,0,0,0,1,0,1,0,0,0,0,0,0,0,0,1,0,0,0,1,0,0,0,0,1,0,0,1,0,0,0,1,0,0,0,1,1,1,0,0,0,0,1,0,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1,0,0,0,1,1,0,0,1,0,0,0,1,0,0,0,0,0,0,1,1,0,1,0,0]';
        smoke = [0,0,1,0,0,0,1,1,0,0,0,1,0,1,1,1,0,1,1,0,1,0,0,0,0,0,1,0,0,1,0,1,0,0,0,1,0,0,0,1,0,0,0,1,1,1,0,0,1,0,1,0,1,1,1,0,0,0,0,0,1,0,1,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1,1,0,0,1]';
        SES = [50.5000000000000,40,30.5000000000000,50,36.5000000000000,45,37,53,54.5000000000000,51.5000000000000,42.5000000000000,24.0500000000000,27,29,43.5000000000000,36.5000000000000,36,11,8,29.5000000000000,53,57,32,51,21.5000000000000,38,28.5000000000000,29,66,35,50,15.8500000000000,62,43,61,13,33,24,52,17.3500000000000,39.5000000000000,47,31.5000000000000,27,58,50,33,58,25,30,61,45,21.8500000000000,37,14.9500000000000,28.5000000000000,32,33,43,17,27,32,52,50,46,56,38,20,70,28.9500000000000,42.5000000000000,45,23,27,46,45.4000000000000,32,46,66,29.5000000000000,15.2500000000000,18.5000000000000,42,41.3500000000000]';
        panss_gs = [30,36,29,29,33,42,26,36,37,36,37,38,24,42,38,34,34,48,38,45,52,29,24,29,46,41,53,37,32,43,59,41,46,23,47,34,51,34,26,50,56,38,30,31,38,37,22,24,42,28,30,30,48,33,47,63,30,32,25,47,36,42,25,27,25,55,55,35,30,49,48,33,30,21,33,26,31,23,38,16,25,25,24,34]';
        panss_ps = [19,20,21,16,7,23,9,24,18,19,23,24,11,23,26,22,21,25,22,25,20,20,8,11,20,30,28,20,12,29,24,23,12,14,16,18,31,23,10,29,25,14,11,7,28,19,11,14,29,10,24,16,18,22,20,29,19,20,16,24,14,15,13,13,18,19,29,14,13,27,23,13,7,15,13,12,17,10,23,7,35,16,12,17]';
        panss_ns = [11,14,17,13,17,10,28,17,9,16,18,12,23,23,31,10,12,11,17,20,22,7,11,17,16,10,22,12,11,9,16,11,27,7,13,21,12,11,7,31,26,11,17,22,9,15,9,9,20,9,17,10,21,16,23.5000000000000,25,9,8,16,23,12,19,14,14,23,24,19,20,17,24,27,20,17,13,14,9,17,9,16,7,18,13,10,11]';
        race = {'Caucasian','Caucasian','Caucasian','Caucasian','Other/Unknown','Caucasian','Other/Unknown','Caucasian','Caucasian','African American','Caucasian','Caucasian','African American','Caucasian','African American','Caucasian','African American','African American','African American','Caucasian','African American','More than one','African American','More than one','More than one','African American','Other/Unknown','Caucasian','Caucasian','More than one','Caucasian','More than one','Asian','Asian','Caucasian','More than one','More than one','More than one','Caucasian','More than one','Asian','Caucasian','More than one','African American','Caucasian','African American','African American','African American','Caucasian','African American','Asian','African American','African American','African American','Other/Unknown','Caucasian','African American','African American','Caucasian','Other/Unknown','African American','African American','African American','More than one','Caucasian','Asian','More than one','Caucasian','African American','Caucasian','Caucasian','Other/Unknown','African American','African American','Asian','African American','African American','Caucasian','More than one','More than one','Caucasian','Other/Unknown','African American','African American'};
        race = categorical(race);
        race = dummyvar(race');

        batch = [2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]';
        % construct combat design matrix (exclude one column for race as reference)
        % mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns psyratAH psyratD sans cdrs race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1
        mod = [age isMale rHand ethnHisp smoke SES panss_gs panss_ps panss_ns race(:,1:end-1)]; %Better to exclude other/unknown instead, changed 2:end to 1:end-1

    else
        %     error('Invalid.');
    end

    % combat struct construction
    combatstruct.flag = true;
    combatstruct.method = 0;

    combatstruct.batch = batch;
    combatstruct.mod = mod;


end
