function [lpffdCensoredVolumes] = lpfFDcensoredVolumes(MPs,TR,LPF_FD_Threshold)
% This function returns a logical vector denoting which volumes are
%   targeted for removal using GEV-DV based on input time series, a gray
%   matter mask in the same space as the input time series, the TR (for
%   low-pass filtering), and a GEV-DV d parameter desired by the user.
%
% 	Inputs
% I.    timeSeries: The time series data to be used to calculate LPF-DV. 
%   This should be either in the form of a 4D matrix of voxel time series 
%   or as a 2D matrix of greyordinate time series. If voxel time series, 
%   then time should be the 4th dimension, as is the default when reading a 
%   nifti using niftiread. If greyordinate time series, then time should be 
%   the 1st non-singleton dimension (e.g., it can be either 
%   1 x 1 x 1 x 1 x time x greyordinate, or time x greyordinate).
% II.   brainMask: The grey matter mask to be used when calculating LPF-DV. 
%   If timeSeries was passed in as voxel time series, then brainMask should 
%   be a boolean 3D matrix of voxels in the same space as timeSeries. If 
%   timeSeries was passed in as greyordinate time series, then brainMask 
%   should be a boolean row vector of greyordinates to use.
% III.  TR: The repetition time (TR) of the time series data, in units of 
%   seconds (e.g., 0.72).
% IV.   DV_GEV_d: The GEV-DV d parameter desired by the user for 
%   run-adaptive volume censoring of LPF-DV.
%
% 	Outputs
% I.    lpfdvCensoredVolumes: A boolean column vector whether a frame is 
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

    %Make sure our MPs are the right dimension.  We want it Time x 6, for 6
    %MPs.
    MPs = squeeze(MPs);
    if(size(MPs,2) ~= 6) %If there are not 6 columns in the data...
        if(size(MPs,1) == 6) %If there are 6 rows in the data...
            MPs = MPs'; %Transpose
        else
            error('MP is not in a usable format.  Must be of nvols rows and 6 columns'); %Otherwise the user has to fix this
        end
    end
    
    %Mask so we only get brain voxels

    lpfFD = getLPFFD(MPs,TR);
    
    lpffdCensoredVolumes = logical(lpfFD > LPF_FD_Threshold);
    
end


function [lpfFD] = getLPFFD(MPs,TR)
    
    filteredMPs = getFilteredMPs(MPs,TR);  %Filter with 0.2 Hz LPF
    
    diffMPs = abs([zeros(1,6); diff(filteredMPs,1,1)]); %Absolute value of derivative by backwards difference
    
    translationSum = sum(diffMPs(1:3),2); %sum across columns
    rotationSum = sum(diffMPs(4:6) .* 2 .* pi .* 50 ./ 360,2); %Convert rotation to translation on a 50mm diameter sphere
    
    lpfFD = sum([translationSum,rotationSum],2);
    
end

function [filteredMPs] = getFilteredMPs(MPs,TR)
    pb = 0.2./((1/TR)/2); %0.2 Hz LOW PASS FILTER
    [B,A] = butter(2,pb,'low'); %Make butterworth filter
    filteredMPs = filtfilt(B,A,MPs); % zero phase filtering
    
end
