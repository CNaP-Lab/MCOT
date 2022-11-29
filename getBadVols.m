function subjExtractedTimeSeries = getBadVols(eyeClosureFile,TR,subjExtractedTimeSeries)
%SETBADVOLS This function identifies indices of "bad volumes" as determined
%by eye closure onsets

        fid = fopen(eyeClosureFile);
        T = textscan(fid,'%s%u8%s','Delimiter',',');
        
        subjIDs = T{1};
        runNums = T{2};
        timeStamps = T{3};
        if ~isfield(subjExtractedTimeSeries,'badVols')
            [subjExtractedTimeSeries.badVols] = deal([]);
        end
        
        for i = 1:length(subjIDs)
            thisSubj = num2str(subjIDs{i});
            thisSubjIdx = find(strcmp({subjExtractedTimeSeries.subjId},thisSubj));
            
            if isempty(thisSubjIdx)
                warning(['Could not find ' thisSubj]);
                continue;
            end
            
            if isempty(subjExtractedTimeSeries(thisSubjIdx).badVols)
                % initialized badVols to size #vols x 1 x numRuns
                subjExtractedTimeSeries(thisSubjIdx).badVols = false(size(subjExtractedTimeSeries(thisSubjIdx).CS));
            end
            
            thisRunNum = runNums(i);
            
            % gets volume timings
            vtimes = 0:size(subjExtractedTimeSeries(thisSubjIdx).CS,1)-1;
            vtimes = vtimes.*TR;
            
            thisTimeStamp = timeStamps{i};
            [t1,t2] = strtok(thisTimeStamp,'-');
            t2(1) = [];
            [tim,tis] = strtok(t1,':');
            t1 = str2num(tim)*60 + str2num(tis(2:end));
            [tim,tis] = strtok(t2,':');
            t2 = str2num(tim)*60 + str2num(tis(2:end));
            
            % find bad indices in volume timings
            badIndices = find(vtimes > t1-TR & t2+TR > vtimes);
            
            % set indices in badVols
            subjExtractedTimeSeries(thisSubjIdx).badVols(badIndices,:,thisRunNum) = true;
            
        end
        
        % set bad vols to nan in timeseries
        for j = 1:length(subjExtractedTimeSeries)
            thisBadVols = subjExtractedTimeSeries(j).badVols;
            
            if ~isempty(thisBadVols)
                subjExtractedTimeSeries(j).CS(thisBadVols) = NaN;
                subjExtractedTimeSeries(j).WS(thisBadVols) = NaN;
                subjExtractedTimeSeries(j).GS(thisBadVols) = NaN;
                rtsBadVols = repmat(thisBadVols,[1 size(subjExtractedTimeSeries(j).rts,2) 1]);
                subjExtractedTimeSeries(j).rts(rtsBadVols) = NaN;
            end
            
        end


end

