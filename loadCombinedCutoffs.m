function [FDcutoffs,gevDVcutoffs] = loadCombinedCutoffs(useGSR)
    
    OGgevDVcutoffs = loadGEVdvCutoffs();
    ogFDcutoffs = loadFDcutoffs();
    
    
    FullSampleLPFFDnoGSR = 3.3866;
    FullSampleGEVDVdNoGSR = 1.3859;
    
    FullSampleLPFFDwithGSR = 1433.6;
    FullSampleGEVDVdWithGSR = 1.3000;
    
    DVtoFDnoGSR = FullSampleLPFFDnoGSR ./ FullSampleGEVDVdNoGSR;
    FDtoDVnoGSR = FullSampleGEVDVdNoGSR ./ FullSampleLPFFDnoGSR;
    
    DVtoFDwithGSR = FullSampleLPFFDwithGSR ./ FullSampleGEVDVdWithGSR;
    FDtoDVwithGSR = FullSampleGEVDVdWithGSR ./ FullSampleLPFFDwithGSR;
    
    FDcutoffsFromGEVdvNoGSR = DVtoFDnoGSR .* OGgevDVcutoffs;
    FDcutoffsFromGEVdvWithGSR = DVtoFDwithGSR .* OGgevDVcutoffs;
    
    allFDcutoffs = [ogFDcutoffs;FDcutoffsFromGEVdvNoGSR;FDcutoffsFromGEVdvWithGSR];
    FDcutoffs = sort(unique(allFDcutoffs),'descend');
    if (~useGSR)
        gevDVcutoffs = FDtoDVnoGSR .* FDcutoffs;
    else
        gevDVcutoffs = FDtoDVwithGSR .* FDcutoffs;
    end
    
end
