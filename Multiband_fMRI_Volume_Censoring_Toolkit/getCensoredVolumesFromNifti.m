function [censoredVolumes,lpffdCensoredVolumes,lpfdvCensoredVolumes] = ...
        getCensoredVolumesFromNifti(fileNameDataNifti,fileNameBrainMask3D, ...
        MPs,LPF_FD_Threshold,DV_GEV_d)
% This is a wrapper for getCensoredVolumes that opens a nifti or cifti time 
%   series using niftiread. It is identical, except that instead of taking 
%   in time series and a gray matter mask, it takes in the file name of the 
%   time series and the file name of the gray matter mask. The repetition 
%   time (TR) is obtained from the nifty header. It opens them using 
%   niftiread and calls getCensoredVolumes; the outputs are identical.
%
% Inputs
% I.    fileNameDataNifti4D: The file name of the nifti RSFC time series.
% II.   fileNameBrainMask3D: The file name of the nifti gray matter mask.
% III.  LPF_FD_Threshold: The LPF-FD threshold desired by the user for 
%   LPF-FD volume censoring.
% IV.   DV_GEV_d: The GEV-DV d parameter desired by the user for 
%   run-adaptive volume censoring of LPF-DV.
%
% Outputs
% I.    censoredVolumes: A boolean column vector denoting whether a frame 
%   is targeted for removal (true) or not targeted for removal (false) by 
%   either LPF-FD or GEV-DV. It is produced by a logical “or” operation on 
%   lpffdCensoredVolumes and lpfdvCensoredVolumes. 
% II.   lpffdCensoredVolumes: A boolean column vector whether a frame is 
%   targeted for removal (true) or not targeted for removal (false) by 
%   LPF-FD volume censoring only.
% III.  lpfdvCensoredVolumes: A boolean column vector whether a frame is 
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

    brainMask = double(niftiread(fileNameBrainMask3D)); %Load grey matter mask and convert from single to double
    headerInfo = niftiinfo(fileNameDataNifti); %Load header info to get dimensions
    TR = headerInfo.PixelDimensions(end); %Get TR from header
    timeSeries = logical(niftiread(fileNameDataNifti)); %Load time series and convert to boolean/logical
    
    [censoredVolumes,lpffdCensoredVolumes,lpfdvCensoredVolumes] ... 
        = getCensoredVolumes(timeSeries,brainMask,MPs,TR,LPF_FD_Threshold,DV_GEV_d); %Get thresholds
    
end

