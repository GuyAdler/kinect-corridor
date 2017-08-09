% This code loads all the videos in a certain folder, uses the transformations that
% we found to align the skeletons, and then saves them in a format that the DM files
% expect.
% If one of the cameras in a videos did not save a meta.txt file, output the name of
% the camera video.
% Before using this code, you must use "organize_folders" on the parent folder.
%	Change "SkelPoint" in the beginning to pick which skeleton point will be saved.
%	Change "savename" in the beginning to pick the filename at the end.

close all; clear variables; clc; 

find_new_floor = 0;
SkelPoints = [skeleton.CM];

savename = input('Filename to save: ', 's');
n_groups = input('Number of groups: ');

nameVideos = [];
group_lengths = zeros(1,n_groups);
for i = 1:n_groups
    group_folders = sort_videos(uipickfiles);
    nameVideos = [nameVideos group_folders];
    group_lengths(i) = length(group_folders);
end

numVideos = length(nameVideos);

% Inserting an empty string into loadfloor because we are currently only using it to load a known vector.
CorridorFloor = LoadFloor( '', find_new_floor );

%%

walking_merged = cell(1,numVideos);

for Vid = 1:numVideos
	[walking_merged{Vid}, ~] = LoadAndTransformVideo(nameVideos{Vid});
    if ~isempty(walking_merged{Vid})
        walking_merged{Vid} = walking_merged{Vid}(:,SkelPoints,:);
    end
    disp(strcat(nameVideos{Vid}, ' loaded.'));
end

save_struct.walking = walking_merged;
save_struct.lengths = group_lengths;
save_struct.SkelPoints = SkelPoints;

save(strcat(savename, '.mat'),'-struct','save_struct');
disp(['Saved as ' strcat(savename, '.mat')]);