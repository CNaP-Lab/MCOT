function [censoredVolumes,lpffdCensoredVolumes,lpfdvCensoredVolumes] ... 
        = getCensoredVolumes(timeSeries,brainMask,MPs,TR,LPF_FD_Threshold,DV_GEV_d)
% This function returns a boolean (logical) vector of censored volumes 
%   using combined LPF-FD and GEV-DV based volume censoring, given a time 
%   series (either as a 4D matrix of voxel time series, or a 2D matrix of 
%   greyordinate time series), a gray matter mask (3D matrix, or 1D with 
%   columns corresponding to greyordinates), a matrix of motion parameters 
%   (MPs), the TR (required for low-pass filtering), and the desired LPF-FD 
%   threshold and DV-GEV d. It calculates the censored volumes using LPF-FD 
%   by calling lpfFDcensoredVolumes and the censored volumes using GEV-DV 
%   by calling lpfDVcensoredvolumes.
%
% Inputs
% I.	timeSeries: The time series data to be used in order to calculate 
%   LPF-DV. This should be either in the form of a 4D matrix of voxel time 
%   series or as a 2D matrix of greyordinate time series. If voxel time 
%   series, then time should be the 4th dimension, as is the default when 
%   reading a nifti using niftiread. If greyordinate time series, then 
%   time should be the 1st non-singleton dimension (e.g., it can be either 
%   1 x 1 x 1 x 1 x time x greyordinate, or time x greyordinate).
% II.	brainMask: The grey matter mask to be used when calculating LPF-DV. 
%   If timeSeries was passed in as voxel time series, then brainMask should 
%   be a boolean 3D matrix of voxels in the same space as timeSeries. If 
%   timeSeries was passed in as greyordinate time series, then brainMask 
%   should be a boolean row vector of greyordinates to use.
% III.	MPs: The motion parameters (MPs) to use when calculating LPF-FD. 
%   Dimension 1 (across rows) should be time x MP, where time is rows and 
%   MP is columns. The first 3 MPs (i.e., MP(:,1:3) ) should be translation 
%   in units of mm. The last 3 MPs (i.e., MP(:,4:6) ) should be rotation 
%   in units of degrees.
% IV.	TR: The repetition time (TR) of the time series data, in units of 
%   seconds (e.g., 0.72).
% V.	LPF_FD_Threshold: The LPF-FD threshold desired by the user for 
%   LPF-FD volume censoring.
% VI.	DV_GEV_d: The GEV-DV d parameter desired by the user for 
%   run-adaptive volume censoring of LPF-DV.
%
% Outputs
% I.	censoredVolumes: A boolean column vector denoting whether a frame 
%   is targeted for removal (true) or not targeted for removal (false) by 
%   either LPF-FD or GEV-DV. It is produced by a logical “or” operation on 
%   lpffdCensoredVolumes and lpfdvCensoredVolumes. 
% II.	lpffdCensoredVolumes: A boolean column vector whether a frame is 
%   targeted for removal (true) or not targeted for removal (false) by 
%   LPF-FD volume censoring only.
% III.	lpfdvCensoredVolumes: A boolean column vector whether a frame is 
%   targeted for removal (true) or not targeted for removal (false) by 
%   GEV-DV volume censoring only.
%
% Author: John C. Williams, MS
%   John.Williams@StonyBrook.edu
% PI: Jared X. Van Snellenberg, PhD
%   Jared.VanSnellenberg@stonybrookmedicine.edu
% Multi-Modal Translational Imaging Laboratory
% Department of Psychiatry and Behavioral Health
% Renaissance School of Medicine at Stony Brook University 
% Stony Brook, NY, USA.
% 

    lpffdCensoredVolumes = lpfFDcensoredVolumes(MPs,TR,LPF_FD_Threshold); %Get volumes censored by FD
    lpfdvCensoredVolumes = lpfDVcensoredvolumes(timeSeries,brainMask,TR,DV_GEV_d); %Get volumes censored by DV
    
    censoredVolumes = logical(lpffdCensoredVolumes | lpfdvCensoredVolumes); %Logical or 
    
end
