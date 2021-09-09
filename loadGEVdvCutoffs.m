function [GEVdvCutoffs] = loadGEVdvCutoffs()

    GEVdvCutoffs = [inf 0.001:0.001:2 2.005:0.005:5 5.1:0.1:10 10:1:100];
    GEVdvCutoffs = GEVdvCutoffs';
    %GEVdvCutoffs = flipud(GEVdvCutoffs);
end
