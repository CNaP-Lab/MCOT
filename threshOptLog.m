function threshOptLog(fileName, text)
    fid = fopen(fileName,'a');
    if fid < 3
        warning(['Could not open file ' fileName ' for logging.']);
        return
    end
    svcl = fix(clock);
    fprintf(fid,[datestr(date,'yymmdd') '_' num2str(svcl(4)) ':' num2str(svcl(5)) ':' num2str(svcl(6)) '\t' text '\n']);
    fclose(fid);

end