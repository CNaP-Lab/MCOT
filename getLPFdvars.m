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

timeSeriesTmp = timeSeries(:);
timeSeriesNoZeros = timeSeriesTmp(timeSeriesTmp~=0);

lpfDV = [0;sqrt(mean(diff(timeSeries .* 1000 ./ mode(round(timeSeriesNoZeros)),1,1).^2,2))]; %values roughly in % signal change

if any(isnan(lpfDV))
    lpfDV = [0;sqrt(mean(diff(timeSeries .* 1000 ./ mode((timeSeriesNoZeros)),1,1).^2,2))];
end

end

