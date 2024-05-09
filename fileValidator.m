function allFilesValid = fileValidator(filenameMatrix,maskMatrix)

allFilesValid = true;

filenameMatrixFlattened = filenameMatrix(:);
maskMatrixFlattened = maskMatrix(:);

for i = 1:size(filenameMatrixFlattened, 1)
    if ~isempty(filenameMatrixFlattened{i})
        [~, ~, ext] = fileparts(filenameMatrixFlattened{i});
        if (~exist(filenameMatrixFlattened{i}, 'file') && ~isempty(filenameMatrixFlattened{i})) ...
                || ~strcmp(lower(ext), '.nii')
            disp('file issue'); pause(eps); drawnow;
            allFilesValid = false;
            break;
        end
    end
end

for i = 1:size(maskMatrixFlattened, 1)
    if ~isempty(maskMatrixFlattened{i})
        [~, ~, ext] = fileparts(maskMatrixFlattened{i});
        if (~exist(maskMatrixFlattened{i}, 'file') && ~isempty(maskMatrixFlattened{i})) ...
                || ~strcmp(lower(ext), '.nii')
            disp('mask issue'); pause(eps); drawnow;
            allFilesValid = false;
            break;
        end
    end
end

end

