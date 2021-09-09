function [lpfFD] = getLPFFD(MPs,TR)

filteredMPs = getFilteredMPs(MPs,TR);  %Filter with 0.2 Hz LPF

diffMPs = abs([zeros(1,6); diff(filteredMPs,1,1)]); %Absolute value of derivative by backwards difference

translationSum = sum(diffMPs(:,1:3),2); %sum across columns
rotationSum = sum(diffMPs(:,4:6) .* 2 .* pi .* 50 ./ 360,2); %Convert rotation to translation on a 50mm diameter sphere

lpfFD = sum([translationSum,rotationSum],2);

end