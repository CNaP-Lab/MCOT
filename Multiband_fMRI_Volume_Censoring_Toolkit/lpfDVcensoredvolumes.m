function [lpfdvCensoredVolumes] = lpfDVcensoredvolumes(timeSeries,brainMask,TR,DV_GEV_d)
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

    if (~isa(timeSeries,'double'))
        timeSeries = double(timeSeries); %Convert time series from single to double if this was not done already
    end
    if (~isa(brainMask,'logical'))
        brainMask = logical(brainMask); %Convert grey matter mask to logical if this was not done already
    end
    
    lpfDV = getLPFdvars(timeSeries,brainMask,TR); %Get LPF-DV using the time series data
    runLPFDVthreshold = critFind_GEV(lpfDV,DV_GEV_d); %Get the LPF-FD threshold for this run
    lpfdvCensoredVolumes = logical(lpfDV > runLPFDVthreshold); %Get the vector of censored volumes
    
end

function [lpfDV] = getLPFdvars(timeSeries,brainMask,TR)
    %If it is a cifti, then it will give a time x greyordinates matrix.
    %Otherwise, this will do nothing to a 4D (3 space x 1 time) matrix.
    %Unless, of course, you are feeding in a matrix with a singleton
    %spatial dimension.
    if(ndims(timeSeries) ~= 4) %If this is a cifti with greyordinates or something similar:
        timeSeries = squeeze(timeSeries); %Remove singleton dimensions, should be Time x Greyordinate
    else %If this is 4D data, as intended:
        %filtfilt needs to filter over the first dimension (rows).
        %This means we have to take time - which is currenly the 4th dimension,
        %and put it into rows, so that we can filter over time.
        timeSeries = permute(timeSeries,[4 1 2 3]); %Now t x y z
        brainMask  = permute(brainMask, [4 1 2 3]); %Want the mask to be the same as the time series
        %And now to put it into a format similar to cifti greyordinates:
        %Time x Greyordinate
        timeSeries = reshape(timeSeries,size(timeSeries,1),[]);
        brainMask  = reshape(brainMask,size(brainMask,1),[]);
    end
    
    if(any(isnan(timeSeries(:)))) %If there are any nans anywhere...
        warning('NaNs in time series data. Removing greyordinates with NaNs.'); %Throw a warning
        colsToRemove = any(isnan(timeSeries),2); %Figure out which greyordinates have NaNs
        timeSeries(colsToRemove) = []; %Remove them
        brainMask(colsToRemove) = []; %And remove them from the mask
    end
    
    %Mask time series
    timeSeries = timeSeries(:,brainMask);
    
    %LPF time
    pb = 0.2./((1/TR)/2); %0.2 Hz LOW PASS FILTER
    [B,A] = butter(2,pb,'low'); %Make 2nd order Butterworth low passfilter
    timeSeries = filtfilt(B,A,timeSeries); %Zero phase filtering  
    
    lpfDV = [0;sqrt(mean(diff(timeSeries .* 1000 ./ mode(round(timeSeries(:))),1,1).^2,2))]; %values roughly in % signal change
    
    if any(isnan(lpfDV))
        lpfDV = [0;sqrt(mean(diff(timeSeries .* 1000 ./ mode((timeSeries(:))),1,1).^2,2))];
    end
    
end


function [runLPFDVthreshold] = critFind_GEV(LPFDV,DV_GEV_d)
    
    if(DV_GEV_d <= 0 || DV_GEV_d == inf)
        runLPFDVthreshold = inf;
    else
        if (size(LPFDV,1) == 1)
            LPFDV = LPFDV';
        end
        LPFDV = LPFDV(abs(LPFDV) > 0); %Remove case with 0, first element
        options = statset('MaxFunEvals',1E6,'MaxIter',1E6);
        
        gev = fitdist(LPFDV,'GeneralizedExtremeValue','Options',options);
        
        gevx = linspace(min(LPFDV),max(LPFDV),10^5);
        gevsum = gev.cdf(gevx);
        
        a = 0.3;
        b = DV_GEV_d;
        
        target = 1 - (gev.k + a)/b;
        
        [~,minIndex] = min(abs(gevsum - target));
        
        runLPFDVthreshold = gevx(minIndex);
    end
    
end
