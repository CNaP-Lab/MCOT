# MCOT
Multiband Censoring Optimization Tool (MCOT) for Resting-State Functional Connectivity Analyses

This is a MATLAB software package to accompany the article:

Advancing motion denoising of multiband resting-state functional connectivity fMRI data

John C. Williams, MS, Philip N. Tubiolo, BE, Jacob R. Luceno, BS, and Jared X. Van Snellenberg, PhD.

Cognitive Neuroscience and Psychosis (CNaP) Lab / Multi-Modal Translational Imaging (MMTI) Lab

Department of Psychiatry and Behavioral Health, Renaissance School of Medicine at Stony Brook University, Stony Brook, NY, USA.


This software allows a user to get optimal LPF-FD and GEV-DV volume censoring parameters for a specified multiband resting-state fMRI dataset.

This was created with MATLAB 2021a and tested using MATLAB R2020a and R2021a.  

This software requires SPM12 to be on the user path. SPM12 is included as part of this package. It can be obtained externally at https://www.fil.ion.ucl.ac.uk/spm/software/spm12/ .

NOTE TO USER:
--------------
This software may be run using the provided MATLAB Application (installed from MCOT.mlappinstall) or from the MATLAB command window (by running mCotWrapper with the necessary input arguments detailed below) Use of the MATLAB application to run this software will produce identical results to running the software from the MATLAB command window. Tooltips are provided within the application to ensure that the user is guided through providing all necessary arguments.

Installation of this software for use in the MATLAB command window consists of downloading, copying, or moving all functions into a directory accessable to your MATLAB installation. If downloaded as a zip file, all functions should be unzipped to a single folder before use. Unzipping this software is expected to take less than one minute on a normal desktop computer.

Installation of the MATLAB application associated with this software consists of downloading and running MCOT.mlappinstall, which will install the application into the "My Apps" tray of the MATLAB editor.

------------------------------------------------------------------------------------------
mCotWrapper
------------------------------------------------------------------------------------------
Estimate optimal volume censoring parameters for a multiband resting-state fMRI dataset. This function is called by the user if the software is being used from the MATLAB command window or called autonomously from the provided MATLAB application.


------------------------------------------------------------------------------------------
Syntax
------------------------------------------------------------------------------------------

[optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper(workingDirectory,Name,Value)
[optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper(workingDirectory,'continue')

mCotWrapper(workingDirectory,Name,Value) returns the optimal volume censoring parameters LPF-FD and GEV-DV, minimum mean-squared error (MSE), and optimal percentage of volumes censored for a specified multiband resting-state fMRI dataset in a specified workingDirectory. Name-Value pairs are specific to the pipeline used for data reprocessing - either the Human Connectome Project Minimal Precprocessing Pipeline (HCP), fMRIPrep, or a custom user-implemented pipeline (denoted as 'custom'). A summary of all Name-Value pairs is provided below.

mCotWrapper(workingDirectory,'continue') continues the optimization pipeline based on intermediate outputs found in workingDirectory. 

------------------------------------------------------------------------------------------
Input Arguments
------------------------------------------------------------------------------------------

workingDirectory
----------------
Denotes directory in which to save all intermediate and final outputs. If this directory does not yet exist, it will be created.

------------------------------------------------------------------------------------------
Name-Value Pairs
------------------------------------------------------------------------------------------

'format'
--------
(string)
Denotes the preprocessing pipeline used.
Options: 'HCP', 'fMRIPrep', 'custom'


'sourcedirectory'
-----------------
(string)
****'sourcedirectory' does not need to be specified if 'format' = 'custom'****

Directory that contains all fMRI data to be included in the optimization procedure. This directory should be the direct outputs of either HCP of fMRIPrep preprocessing.



'tr'
----
(double)
Repetition time used in the study, specified in seconds.


'useGSR'
--------
(logical)
Denotes whether or not to use global signal regression when performing optimization.
Default: false (no GSR)


'ntrim'
-------
(double)
Number of volumes to remove from the beginning of each resting-state fMRI run to allow for MR signal equilibration.
Default: 0


'runnames'
----------
(char)
****'runnames' does not need to be specified if 'format' = 'custom'****

Specifies the run/task identifiers in each study. Inputs vary by preprocessing pipeline.

For 'format' = 'HCP':
'runnames' will be entered as a cell array of char vectors, as the HCP pipeline allows for custom naming of runs. For example, if a HCP-preprocessed study contains 4 runs per subject, denoted by the filename suffixes '_rs1', '_rs2', '_rs3', and '_rs4', they should be specified as the cell array {'_rs1','_rs2','_rs3','_rs4'}.

For 'format' = 'fMRIPrep':
'runnames will be entered as a single char vector denoting the task name used in the fMRIPrep preprocessing pipeline. For example, if the task name 'RSFC' was used in fMRIPrep, 'runnames' will be specified as 'RSFC' .

'imageSpace'
-------------
*** This argument is ONLY needed for fMRIPrep ***
Specifies the image space used for data normalization during fMRIPrep preprocessing.
Examples include: MNI152NLin2009cAsym, MNI152NLin6Asym
Full list of supported spaces can be found through the fMRIPrep documentation.


'minimumSecondsDataPerRun'
--------------------------
(double)
Specifies the minimum number of seconds of data that each resting-state run must contain after volume censoring before it is removed from the study.
default = 120


'filterCutoffs'
----------------
([lowHz highHz])
Specifies the -3 dB cutoff frequencies of a second-order zero-phase Butterworth band-pass Filter ('lowHz' refers to the lower frequency cutoff, 'highHz' refers to the higher frequency cutoff).
Defaults:
lowHz = 0.009
highHz = 0.08


'secTrimPostBpf'
-----------------
(double)
Specifies the number of seconds of data to remove from the beginning and end of each resting-state run after band-pass filtering is performed to mitigate filter edge effects.
Default: 22



------------The following arguments only need to be specified is 'format' = 'custom'------------


'filenamematrix'
----------------
(cell array)

An N x M array where N is the number of subjects and M is the maximum number of runs per subject. Each entry is a full path to a resting-state fMRI run. Cells can be left empty if a subject is missing runs.


'maskmatrix'
------------
(cell)

An N x 3 cell array, where N is the number of subject. The first column is a full file path to the whole brain mask of each subject. The second column is a full file path to the white matter mask of each subject. The third column is a full file path to the cerebrospinal fluid mask of each subject.


'motionparameters'
------------------
(cell array)

An N x M cell array, where N is the number of subjects and M is the maximum number of runs per subejct. Each entry is a Y x 6 array, where Y is the number of volumes in each resting-state run and each column is a translational or rotational motion parameter. The order of these columns is: x-translation, y-translation, z-translation, roll, pitch, yaw.



------------------------------------------------------------------------------------------
Output Arguments
------------------------------------------------------------------------------------------

'minMSE'
--------
The minimum value of MSE over the range of evaluate volume censoring paramters.



'optimalDV'
-----------
The optimal GEV-DV volume censoring parameter corresponding to minMSE.



'optimalFD'
-----------
The optimal LPF-FD volume censoring paramter corresponding to minMSE.



'optimalPCT'
------------
The percentage of volumes censored from the dataset at minMSE.


------------------------------------------------------------------------------------------
Example Function Calls
------------------------------------------------------------------------------------------
For HCP Preprocessed Data with Default Band-Pass Filtering Parameters:
[optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper('C:\Users\Owner\Desktop\workingDir','sourcedirectory','C:\Users\Owner\Desktop\sourceDir','format','HCP','tr',0.72,'useGSR',false,'ntrim',10,'runnames',{'_rs1','_rs2','_rs3','_rs4'},'minimumSecondsDataPerRun',60,'filterCutoffs',[0.009 0.08],'secTrimPostBpf',22)


For fMRIPrep Preprocessed Data with Default Band-Pass Filtering Parameters:
[optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper('C:\Users\Owner\Desktop\workingDir','sourcedirectory','C:\Users\Owner\Desktop\sourceDir','format','fMRIPrep','tr',0.72,'useGSR',false,'ntrim',10,'runnames','RSFC','minimumSecondsDataPerRun',60,'filterCutoffs',[0.009 0.08],'secTrimPostBpf',22)


For Custom Preprocessed Data with Default Band-Pass Filtering Parameters (and with variables filenamematrix, maskmatrix, and motionparameters loaded into the workspace):
[optimalDV, optimalFD, optimalPCT, minMSE] = mCotWrapper('C:\Users\Owner\Desktop\workingDir','format','custom','filenamematrix',filenamematrix,'maskmatrix',maskmatrix,'motionparameters',motionparameters,'tr',0.72,'useGSR',false,'ntrim',10,'minimumSecondsDataPerRun',60,'filterCutoffs',[0.009 0.08],'secTrimPostBpf',22)



This software is released under the GNU General Public License Version 3. 
