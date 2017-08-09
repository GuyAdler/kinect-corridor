close all; clear variables ;clc; 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Initiallization %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% load
directory = uigetdir; %'211216/20161221-104856-/';

apply_dist = 1; % Set 1 to delete skeleton outside minimum and maximum distance.
max_dist = 3.9467; % Empirical result for VISL corridor, can be modified.
min_dist = 1.6583; % Based on average distance of hips.

%list_dir = dir(strcat(directory,'*152*'));
%directory = strcat(directory,list_dir(dir_num).name);
list_skel = dir(strcat(directory,'/*skeleton*'));

% sort the data properly...
list_skel = sort_dir(list_skel);

pcd_temp = zeros(4,25);
walking = zeros(length(list_skel), 26, 3);

% Get rid of inferred points. 

inferred = zeros(length(list_skel), 26);
to_remove = [];

for i = 1:length(list_skel)
    pcd_temp = loadskeleton(strcat(directory,'/', list_skel(i).name),0);
    skel_dist = getSkeletonDist(pcd_temp(1:3, :));
    if (apply_dist == 1 & (skel_dist > max_dist | skel_dist < min_dist))
        to_remove(end+1) = i;
    else
        walking(i, :, :) = (pcd_temp(1:3, :))';
        inferred(i,:) = pcd_temp(4,:);
    end
end

walking(to_remove,:,:) = [];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% CALLING THE paramaters_estimation_specific for different body parts %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%% Center of Mass %%%%%%%%%

CM = squeeze(walking(:,skeleton.AnkleLeft,:));
[T, avg_h, avg_speed] = parameters_estimation_specific(CM, directory, 'CM - Subject 1') ;