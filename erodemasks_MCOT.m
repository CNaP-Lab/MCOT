function [out] = erodemasks_MCOT(mask)

    structuringElement = strel('cube',3);
    temp = imerode(mask,structuringElement);

    tempNoNaN = temp(~isnan(temp));
    numVoxelsRemaining = nnz(tempNoNaN); %number of nonzero elements
    count = 0;
    %Goal: One fewer erosion than what resulted in more than 1 remaining voxel, up to 4 erosions
    while (count < 4) && (numVoxelsRemaining > 1) 
        out = temp;
        temp = imerode(mask,structuringElement);
        count = count + 1;
        tempNoNaN = temp(~isnan(temp));
        numVoxelsRemaining = nnz(tempNoNaN);
    end

end
