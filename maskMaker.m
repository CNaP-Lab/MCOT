function [Y,V] = maskMaker(format, maskFile, varargin)
    
    %     Y = obj.mask;
    %     returns a 3d logical of in-mask voxels for the grey matter mask of
    %     the subject associated with the call. Does not work on top-level
    %     (TIPPstudy) objects, or subject-level or below (below it will search parent
    %     objects for the subject-level mask).
    %     [Y,V] = obj.mask;
    %     also returns V, an spm_vol structure for the associated mask.
    %     Y = obj.mask('white');
    %     returns white matter mask instead of grey matter.
    %     Y = obj.mask('csf');
    %     returns CSF instead of grey matter.
    %     Y = obj.mask('custom',{idx1,idx2,...};
    %     returns the values equal to any of the values idx1, idx2, etc. in the
    %     Atlas_wmparc.2.nii HCP/freesurfer parcellation image
    %
    
    
    if format == "HCP"
        r = [1 3000];
        if ~isempty(varargin)
            switch lower(varargin{1})
                case 'white'
                    r = [3000 5000];
                case 'brain'
                    r = [];
                case 'csf'
                    r = {4,43,5,44,14,15,72};
                case 'custom'
                    r = varargin{2};
            end
        end
    elseif format == "fMRIprep"
        r = [1 3000];
        if ~isempty(varargin)
            switch lower(varargin{1})
                case 'white'
                    r = {2 7 41 46};
                case 'brain'
                    r = [];
                case 'csf'
                    r = {4,43,5,44,14,15,72, 24};
                case 'custom'
                    r = varargin{2};
            end
        end
    end
    
    
    if isempty(r)
        %brain Mask
        [V,Y] = readVol(maskFile);
        Y = logical(Y);
        
    else
        % parcel mask
        [V,Y] = readVol(maskFile);
        if ~iscell(r)
            Y = Y >= r(1) & Y < r(2);
        else
            Yout = Y == r{1};
            for i = 2:length(r)
                Yout = Yout | Y == r{i};
            end
            Y = Yout;
        end
    end
end
