rootDir = dir('/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/QCplots_HCP_4.2_for_final');
rootDir(1:2) = [];

for i = 1:length(rootDir)
    try
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_1','RSFC_fMRI_1.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_2','RSFC_fMRI_2.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_3','RSFC_fMRI_3.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_4','RSFC_fMRI_4.nii.gz'));
    catch
        continue
    end
end

rootDir = dir('/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/SBU_K');
rootDir(1:2) = [];

for i = 1:length(rootDir)
    try
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_1','RSFC_fMRI_1.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_2','RSFC_fMRI_2.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_3','RSFC_fMRI_3.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RSFC_fMRI_4','RSFC_fMRI_4.nii.gz'));
    catch
        continue
    end
end

rootDir = dir('/gpfs/projects/VanSnellenbergGroup/K_Preprocessed_Data/NYSPI_K');
rootDir(1:2) = [];

for i = 1:length(rootDir)
    try
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RS_fMRI_1','RS_fMRI_1.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RS_fMRI_2','RS_fMRI_2.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RS_fMRI_3','RS_fMRI_3.nii.gz'));
        gunzip(fullfile(rootDir(i).folder,rootDir(i).name,'MNINonLinear','Results','RS_fMRI_4','RS_fMRI_4.nii.gz'));
    catch
        continue
    end
end