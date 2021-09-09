function [filteredMPs] = getFilteredMPs(MPs,TR)
pb = 0.2./((1/TR)/2); %0.2 Hz LOW PASS FILTER
[B,A] = butter(2,pb,'low'); %Make butterworth filter
filteredMPs = filtfilt(B,A,MPs); % zero phase filtering

end