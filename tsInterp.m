function [ts] = tsInterp(ts,rmv)

% [ts] = tsInterp(ts,rmv)
% rmv is a logical vector of length = size(ts,1). Function will output a
% version of ts that replaces values in ts (columnwise if it is a matrix)
% in rows where rmv is true, via linear interpolation between the closest
% points in ts where rmv is false.

tofix = [find(diff([0; rmv; 0]) == 1) find(diff([0; rmv; 0]) == -1)-1];

if ~isempty(tofix) && ~(tofix(1,1)==1 && tofix(1,2)==size(ts,1))
    for k = 1:size(ts,2)
        for q = 1:size(tofix,1)
            if tofix(q,1)==1
                ts(1:tofix(q,2),k) = ts(tofix(q,2)+1,k);
            elseif tofix(q,2)==size(ts,1)
                ts(tofix(q,1):end,k) = ts(tofix(q,1)-1,k);
            else
                for r = tofix(q,1):tofix(q,2)
                    ts(r,k) = ts(r-1,k) - (ts(tofix(q,1)-1,k) - ts(tofix(q,2)+1,k)) ./ (tofix(q,2)-tofix(q,1) + 2);
                end
            end
        end
    end
end



end