function [FDcutoffs] = loadFDcutoffs()

    FDcutoffs = [0:0.005:5 5.01:0.01:10 10.1:0.1:50  51:1:100 110:10:1000 inf];
    FDcutoffs = FDcutoffs';
    FDcutoffs = flipud(FDcutoffs);
end
