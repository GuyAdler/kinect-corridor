function nameFolds = getSubfolders(folder)
% GETSUBFOLDERS This function receives a folder name and outputs the names
% of all immediate subfolder. Subfolders of subfolders are not included, and
% . and .. (home and parent folder links) are also removed.
    d = dir(folder);
    isub = [d(:).isdir]; %# returns logical vector
    nameFolds = {d(isub).name}';
    nameFolds(ismember(nameFolds,{'.','..'})) = []; % remove the . and .. folders.
end
