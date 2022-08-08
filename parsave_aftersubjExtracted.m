function parsave_aftersubjExtracted(fname)
%   save(fname,'subjExtractedCompleted','-append', '-v7.3', '-nocompression')
%   save(fname,'aa','bb','cc');
 paramSweepCompleted=false;
 maxBiasCompleted=false;
 subjExtractedCompleted=true;
 save(fname, 'subjExtractedCompleted', 'paramSweepCompleted', 'maxBiasCompleted', '-v7.3', '-nocompression');
  
  % save(fname,'censorscope2','-append','-v7.3')
end