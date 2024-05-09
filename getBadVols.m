function subjExtractedTimeSeries = getBadVols(eyeClosureFile,TR,subjExtractedTimeSeries)
    %SETBADVOLS This function identifies indices of "bad volumes" as determined
    %by eye closure onsets

    % EDIT BY PNT 06/23/23: implemented cleaning and merging eye closures

    %Rules:
    % 1. In SBU data, if the eye closure is less than OR EQUAL TO to three seconds , remove it
    % Less than or equal because we round down start time and round up end
    % times, so 2.9 would become 3 in our data, and 3.1 would become 4.
    % In NYSPI data, it is less than 3 seconds, because it is counting up.
    % Using the subject ID to tell - subject IDs starting with
    % 50000 or more are presumed to be SBU!
    % 2. If eye closures end and start less than 30 seconds apart, combine them
    % Adapted from PNT code by JCW 05/05/2024
    isSBUlowerThreshold = 50000;
    isSBUupperThreshold = inf;

    [inputsourcepath,inputfilename,fileext] = fileparts(eyeClosureFile); %#ok<ASGLU>
    outputfilename = [inputfilename '_cleaned'];
    outputsourcepath = fullfile(inputsourcepath,'eyeClosures');
    if(~exist(outputsourcepath,'dir'))
        mkdir(outputsourcepath); pause(eps); drawnow;
    end
    outputQCfile = fullfile(outputsourcepath,[outputfilename fileext]);

    Kdata_eyeClosureCleanup(eyeClosureFile,outputQCfile,isSBUlowerThreshold,isSBUupperThreshold); pause(eps); drawnow;


    fid = fopen(outputQCfile);
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


        %neil added for TR - subjIds should theoretically be
        %subjList_mx or optionalSubjIDlist or subjIds (outer->inner)
        ii = find(strcmp({subjExtractedTimeSeries.subjId}, thisSubj));

        % gets volume timings
        vtimes = 0:size(subjExtractedTimeSeries(thisSubjIdx).CS,1)-1;
        vtimes = vtimes.*TR(ii);

        thisTimeStamp = timeStamps{i};
        [t1,t2] = strtok(thisTimeStamp,'-');
        t2(1) = [];
        [tim,tis] = strtok(t1,':');
        t1 = str2num(tim)*60 + str2num(tis(2:end));
        [tim,tis] = strtok(t2,':');
        t2 = str2num(tim)*60 + str2num(tis(2:end));

        % find bad indices in volume timings
        badIndices = find(vtimes > t1-TR(ii) & t2+TR(ii) > vtimes);

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

function [] = Kdata_eyeClosureCleanup(inputQCfile,outputQCfile,isSBUlowerThreshold,isSBUupperThreshold)
    % Rules
    % 1. In SBU data, if the eye closure is less than OR EQUAL TO to three seconds , remove it
    % Less than or equal because we round down start time and round up end
    % times, so 2.9 would become 3 in our data, and 3.1 would become 4.
    % In NYSPI data, it is less than 3 seconds, because it is counting up.
    % Using the subject ID to tell - subject IDs starting with
    % 50000 or more are presumed to be SBU!
    % 2. If eye closures end and start less than 30 seconds apart, combine them
    % Adapted from PNT code by JCW 05/05/2023
    fid = fopen(inputQCfile,'rt'); pause(eps); drawnow;

    try

        data = [];
        Line = fgetl(fid);
        lineSpl = strsplit(Line,',');
        data{1,1} = lineSpl{1};
        data{1,2} = lineSpl{2};
        timeSpl = strsplit(lineSpl{3},'-');
        data{1,3} = timeSpl{1};
        data{1,4} = timeSpl{2};
        ct = 2;
        while ischar(Line)
            Line = fgetl(fid);
            try
                lineSpl = strsplit(Line,',');
                data{ct,1} = lineSpl{1};
                data{ct,2} = lineSpl{2};
                data{ct,3} = lineSpl{3};
                timeSpl = strsplit(lineSpl{3},'-');
                data{ct,3} = timeSpl{1};
                data{ct,4} = timeSpl{2};
            catch
                continue
            end
            ct = ct+1;
        end

        %% 1. If the eye closure is three seconds or less, remove it
        numDataRows = size(data,1);
        shortClosureFlags = false(numDataRows,1);
        for i = 1:numDataRows
            thisSubjIDnum = str2double(data{i,1});
            startTime = data{i,3};
            endTime = data{i,4};
            % get them in seconds
            startTimeSpl = strsplit(startTime,':');
            startSec = (str2num(startTimeSpl{1})*60)+str2num(startTimeSpl{2});

            endTimeSpl = strsplit(endTime,':');
            endSec = (str2num(endTimeSpl{1})*60)+str2num(endTimeSpl{2});

            %If SBU, counting down
            isSBU = (thisSubjIDnum >= isSBUlowerThreshold) && (thisSubjIDnum <= isSBUupperThreshold);
            if(isSBU)
                shortClosureFlags(i) = (endSec - startSec) <= 3;
            else 
                %Presume NYSPI, counting up.  Keep eye closures of 3 seconds
                %Because they are not inflated due to rounding.
                shortClosureFlags(i) = (endSec - startSec) < 3;
            end

        end
        % remove short closures
        data(shortClosureFlags,:) = [];

        %% 2. If eye closures end and start less than 30 seconds apart, combine them
        combinedData = [];
        uniqueSubjs = unique(data(:,1));
        for i = 1:length(uniqueSubjs)
            thisSubj = uniqueSubjs{i};
            % get all entries for this subject
            thisSubjEntries = contains(data(:,1),thisSubj);
            thisSubjData = data(thisSubjEntries,:);
            % get num runs
            runs = unique(thisSubjData(:,2));
            for j = 1:length(runs)
                thisRunIdx = contains(thisSubjData(:,2),runs{j});
                thisRunDat = thisSubjData(thisRunIdx,:);
                didSomethingFlag = 1;
                ct = 1;
                while ct < size(thisRunDat,1)
                    startTime = thisRunDat{ct,4}; %start time is end of first closure
                    endTime = thisRunDat{ct+1,3}; %end time is start of next closure
                    % get them in seconds
                    startTimeSpl = strsplit(startTime,':');
                    startSec = (str2num(startTimeSpl{1})*60)+str2num(startTimeSpl{2});
                    endTimeSpl = strsplit(endTime,':');
                    endSec = (str2num(endTimeSpl{1})*60)+str2num(endTimeSpl{2});
                    if endSec - startSec < 30
                        thisRunDat{ct,4} = thisRunDat{ct+1,4};
                        thisRunDat(ct+1,:) = [];
                    else
                        ct = ct+1;
                    end

                end
                if isempty(combinedData)
                    combinedData = thisRunDat;
                else
                    combinedData = [combinedData; thisRunDat];
                end

            end
        end
        fclose(fid); pause(eps); drawnow;
    catch err
        disp(err); pause(eps); drawnow;
        fclose(fid); pause(eps); drawnow;
        error(err);
    end

    %% rebuild text file
    fid = fopen(outputQCfile,'w+'); pause(eps); drawnow;

    try
        for i = 1:size(combinedData,1)
            thisSubjID = combinedData{i,1};
            thisRun = str2num(combinedData{i,2});
            thisTime = [combinedData{i,3} '-' combinedData{i,4}];
            thisStringToPrint = '%s,%d,%s\n';
            fprintf(fid,thisStringToPrint,thisSubjID,thisRun,thisTime); pause(eps); drawnow;
        end
        fclose(fid); pause(eps); drawnow;
    catch err
        disp(err); pause(eps); drawnow;
        fclose(fid); pause(eps); drawnow;
        error(err);
    end
end

