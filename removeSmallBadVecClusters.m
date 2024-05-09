function [removedTooShortDataVec] = removeSmallBadVecClusters(inputVector,minNumDataPoints)

    transposeBack = false;
    if(~isrow(inputVector))
        inputVector = transpose(inputVector);
        transposeBack = true;
    end

    diffVector = logical([1 abs(diff(inputVector))]);
    numClusters = sum(diffVector);
    clusterMatrix = nan(numClusters,5);
    clusterMatrix(:,1) = inputVector(diffVector); %Cluster value = col1
    clusterMatrix(:,2) = diff([ find(diffVector) (length(diffVector)+1) ]); %Cluster size = col2
    startIndex = cumsum(clusterMatrix(:,2)) - clusterMatrix(:,2) + 1; %Cluster start position = col3
    clusterMatrix(:,3) = startIndex;
    endIndex = [clusterMatrix(2:end,3) - 1 ; size(inputVector,2)];
    clusterMatrix(:,4) = endIndex; %Cluster end position = col4
    
    isData = ~logical(clusterMatrix(:,1)); %1 means scrubbed already
    isTooSmall = clusterMatrix(:,2) < minNumDataPoints;
    clusterMatrix(:,5) = isTooSmall;

    clusterMatrix = clusterMatrix(isData&isTooSmall,:); %Put 1s here

    numToFix = size(clusterMatrix,1);
    removedTooShortDataVec = inputVector;
    for i = 1:numToFix
        thisRow = clusterMatrix(i,:);
        idxStart = thisRow(3);
        idxEnd = thisRow(4);
        numData = thisRow(2);
        putIn = true(numData,1);
        removedTooShortDataVec(idxStart:idxEnd) = putIn;
    end

    if(transposeBack)
        removedTooShortDataVec = transpose(removedTooShortDataVec);
    end

end
