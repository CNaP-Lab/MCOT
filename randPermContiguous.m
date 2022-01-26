function [permutedVector] = randPermContiguous(inputVector)
    %Generates a random permutation of a binary vector, maintaining sizes of clusters of 1's.
    %That is, if the input vector is [ 0 1 1 1 0 0 1 1 0 1 0 0 0 0 0 0 0 0 0 ...], 
    %the output will have one cluster of three 1's, one cluster of two 1's,
    %and one cluser of one 1, all in random locations, and not directly
    %adjacent to one another.
    
    if(~isrow(inputVector))
        inputVector = inputVector';
    end
    
    permutedVector = zeros(size(inputVector));
    diffVector = logical([1 abs(diff(inputVector))]);
    numClusters = sum(diffVector);
    clusterMatrix = zeros(numClusters,2);
    clusterMatrix(:,1) = inputVector(diffVector); %Cluster value = col1
    clusterMatrix(:,2) = diff([ find(diffVector) (length(diffVector)+1) ]); %Cluster size = col2
    
    multiZerosIndexVector = find(~clusterMatrix(:,1) & (clusterMatrix(:,2) > 1));
    for i = length(multiZerosIndexVector):-1:1
        zeroIndex = multiZerosIndexVector(i);
        numExtraZeros = clusterMatrix(zeroIndex,2) - 2;
        clusterMatrix(zeroIndex,2) = 1;
        toAdd = [1 0; 0 1];
        for j = 1:numExtraZeros
            toAdd = [toAdd; 1 0; 0 1];
        end
        if (zeroIndex ~= size(clusterMatrix,1))
            clusterMatrix = [clusterMatrix(1:zeroIndex,:);toAdd;clusterMatrix(zeroIndex+1:end,:)];
        else
            clusterMatrix = [clusterMatrix(1:zeroIndex,:);toAdd];
        end
        toAdd = [];
    end
    
    matrixBadIndexVector = find(clusterMatrix(:,1));
    randPermIndexVector = randperm(length(matrixBadIndexVector));
    randPermBadIndexVector = matrixBadIndexVector(randPermIndexVector);
    
    permutedClusterMatrix = clusterMatrix;
    permutedClusterMatrix(matrixBadIndexVector,:) = clusterMatrix(randPermBadIndexVector,:);
    
    vectorIndex = 1;
    for i = 1:size(permutedClusterMatrix,1)
        nextVectorIndex = vectorIndex + permutedClusterMatrix(i,2) - 1;
        permutedVector(vectorIndex:nextVectorIndex) = permutedClusterMatrix(i,1);
        vectorIndex = nextVectorIndex + 1;
    end
   
    permutedVector = permutedVector';
end
