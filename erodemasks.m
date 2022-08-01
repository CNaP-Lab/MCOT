function [out,out2] = erodemasks(obj,maskstr)

    [out,out2] = deal(obj.mask(maskstr));
    [temp,temp2] = deal(erode3d(out));

    tempNoNaN = temp(~isnan(temp));
    numVoxelsRemaining = nnz(tempNoNaN); %number of nonzero elements
    count = 0;
    %Goal: One fewer erosion than what resulted in more than 1 remaining voxel, up to 4 erosions  JCW 07/29/2022
    while (count < 4) && (numVoxelsRemaining > 1) 
        out = temp;
        temp = erode3d(temp);
        count = count + 1;
        tempNoNaN = temp(~isnan(temp));
        numVoxelsRemaining = nnz(tempNoNaN);
    end

    temp = temp2;
    count2 = 0;
    while count2 < count-1
        out2 = temp;
        temp = erode3d(temp);
        count2 = count2 + 1;
    end
end
