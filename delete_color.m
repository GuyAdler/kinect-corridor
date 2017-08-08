function no_meta = delete_color(directory, delete_nested)
% DELETE_COLOR This function deletes all #color.pcd files in "directory".
%	If delete_nested = 1, it also deletes all #color.pcd files in all
%	the directories inside "directory".
%	"no_meta" equals 1 if the directory or one of its nested directories has
%	no meta.txt file.

no_meta = 0;
mylist = dir(strcat(directory,'\*color*'));
if isempty(mylist) == 0
    for i = 1:length(mylist)
        delete(strcat(directory,'\',mylist(i).name));
    end
    if isempty(dir(strcat(directory,'\meta.txt')))
        no_meta = 1;
    end
end

if delete_nested == 1
    nameFolds = getSubfolders(directory);
    for i = 1:length(nameFolds)
        no_meta = no_meta | delete_color(strcat(directory,'\',nameFolds{i}), delete_nested);
        if no_meta
            disp(strcat(directory,'\',nameFolds{i}, ' has no meta.txt'));
        end
    end
end