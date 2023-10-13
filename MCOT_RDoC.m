% these are the MCOT calls for the RDoC dataset
sourceDir = {'/mnt/jxvs2_02/Jae/sbu_kdata_done','/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/QCplots_HCP_4.2_for_final/'};
runnames = {'RSFC_fMRI_1','RSFC_fMRI_2','RSFC_fMRI_3','RSFC_fMRI_4', 'rfMRI_REST1_LR','rfMRI_REST1_RL','rfMRI_REST2_LR','rfMRI_REST2_RL'};
badVolsFile = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/EyeClosuresRS_JCW_2022-11-29.txt';
filterCutoffs = [0.009 0.08];
TR = [0.72 0.72 0.72 0.72 0.72];

ntrim = 0;
secTrimPostBPF = 22; %default
minSecData = 60; %default
format = 'HCP';

%% combat stuff

%To model biological covariates, a model matrix that will be used to fit coefficients in the linear regression framework has to be provided. To build such a model matrix, continuous variables can be used as they are as columns in the model matrix. For categorical variables, a chosen reference group has to be omitted in the model matrix for identifiability as the intercept will be already included in the ComBat model.
% age is continuous. sex is categorical, for example. 

%set flag to true if using combat or false if not using combat. 
combatstruct.flag=false;

combatstruct.batch = [1 1 1 2 2]; %Batch variable for the scanner id

age=[32 23 42 23 69]'; 

sex = [1 2 1 2 1]'; % Categorical variable (1 for females, 2 for males)
sex = dummyvar(sex);

disease = {'ad'; 'healthy';'mci';'healthy';'mci'};
disease = categorical(disease);
disease = dummyvar(disease);

% for each variable representing categorical values,
% exclude one column to serve as the reference. 
combatstruct.mod=[age sex(:,2:end) disease(:,2:end)];
% set mod=[] if not adjusting for biological variables

% default method involves using parametric adjustments and is 1. 
% to use non-parametric adustments, set to value 0. 
combatstruct.method=1;

%% mixed
subjList_mx = {'50002_2','50023','50026','50046'};

workingDir_mx = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/MCOT_Kdata/testWorkingDir';
mCotWrapper(workingDir_mx,'sourcedirectory',sourceDir,'runnames',runnames,'filtercutoffs',filterCutoffs,...
    'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'usegsr',false,'badvolsfile',badVolsFile,...
    'subjids',subjList_mx,'format',format)


% %% HCs
% subjList_HC = {'50023','50026','50046','50077','50081','50091','50097',...
%     '50100','50105','50095','50121','50122','50126','50158',...
%     '50208','50190','50216','50199','50246','50266','50270','50284','50022'};
% workingDir_HC = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/MCOT_RDoC/RDoC_HC';
% mCotWrapper(workingDir_HC,'sourcedirectory',sourceDir,'runnames',runnames,'filtercutoffs',filterCutoffs,...
%     'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'usegsr',false,'badvolsfile',badVolsFile,...
%     'subjids',subjList_HC,'format',format,'continue')
% %% SCZ
% subjList_SCZ = {'50012','50068','50078','50092','50112','50124','50129','50074','50076','50132',...
%     '50140','50146','50156','50168','50178','50272','50295',...
%     '50090','50107','50117','50136','50247','50007','50300','50314','50049'};
% workingDir_SCZ = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/MCOT_RDoC/RDoC_SCZ';
% mCotWrapper(workingDir_SCZ,'sourcedirectory',sourceDir,'runnames',runnames,'filtercutoffs',filterCutoffs,...
%     'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'usegsr',false,'badvolsfile',badVolsFile,...
%     'subjids',subjList_SCZ,'format',format,'continue')
% 
% %% TIN
% subjList_TIN = {'50035','50014','50045','50083','50125','50180','50193','50231','50236','50279','50293','50311'};
% workingDir_TIN = '/mnt/jxvs2_01/Thal_Loc_Data/RDoC_Analysis/MCOT_RDoC/RDoC_TIN';
% mCotWrapper(workingDir_TIN,'sourcedirectory',sourceDir,'runnames',runnames,'filtercutoffs',filterCutoffs,...
%     'tr',TR,'ntrim',ntrim,'sectrimpostbpf',secTrimPostBPF,'minimumsecondsdataperrun',minSecData,'usegsr',false,'badvolsfile',badVolsFile,...
%     'subjids',subjList_TIN,'format',format,'continue')
