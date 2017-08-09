% This file is quite an old one that we used to create the transformation between two adjacent 
% cameras. It compares similar frames and calculates transformations between corresponding frames.
% In total, we have as many transformation as we have frames.
% Outliers (the transformations farthest from the mean of all transformations) are discarded, and 
% out of the more-or-less unanimous transformations left, a random one is chosen.
% We have stopped using this file as it was inferior to comparing the point clouds first in
% CloudCompare and then registering with ICP, but we have left it here for possible future usage in
% automatic synchronization of cameras.

close all; clear variables; clc;
%%
camera{1} = uigetdir;
camera{2} = uigetdir;
formatSpec = '%f';
% The initial transformation is very important. In this hallway problem,
% ICP does not work properly without some initial translation vector.
Initial_transformation = affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; -0.3 -0.6 -3.8 1]);

[timestamps{1}, ~, ~] = LoadTimestamps(camera{1}, 1, 0)
[timestamps{2}, ~, ~] = LoadTimestamps(camera{2}, 1, 0)

%%
% We know that the last frames are most likely closest to each other, up to
% a few milliseconds of difference. So we decrease the difference to make
% the times closer.
if (timestamps{1}(end) > timestamps{2}(end))
    timestamps{1} = timestamps{1} - (timestamps{1}(end) - timestamps{2}(end));
else
    timestamps{2} = timestamps{2} - (timestamps{2}(end) - timestamps{1}(end));
end

%%
list_frames{1} = dir(strcat(camera{1},'/*color*'));
list_frames{2} = dir(strcat(camera{2},'/*color*'));
list_frames{1} = sort_dir(list_frames{1});
list_frames{2} = sort_dir(list_frames{2});

%For Transformation matching purposes, each frame from the shorter list is
%matched with the closest fit (temporally) from the longer list.
shorter = (length(timestamps{2}) < length(timestamps{1})) + 1;
longer = (length(timestamps{2}) >= length(timestamps{1})) + 1;
list_trans = zeros(length(timestamps{shorter}),4,4); % The transformations are a 4X4 matrix.
gridSize = 0.1;

for i = 1:length(timestamps{shorter})
    if (i == 1)
        diff_vec = [abs(timestamps{shorter}(i)-timestamps{longer}(i)), ...
            abs(timestamps{shorter}(i+1)-timestamps{longer}(i+1))];
        closest = find(diff_vec == min(diff_vec));
    elseif (i == length(timestamps{shorter}))
        diff_vec = [abs(timestamps{shorter}(i-1)-timestamps{longer}(i-1)), ...
            abs(timestamps{shorter}(i)-timestamps{longer}(i))];
        closest = i + find(diff_vec == min(diff_vec)) - 2;
    else
        diff_vec = [abs(timestamps{shorter}(i-1)-timestamps{longer}(i-1)), ...
            abs(timestamps{shorter}(i)-timestamps{longer}(i)), ...
            abs(timestamps{shorter}(i+1)-timestamps{longer}(i+1))];
        closest = i + find(diff_vec == min(diff_vec)) - 2;
    end
    
    data_shorter = loadpcd(strcat(camera{shorter},'/', list_frames{shorter}(i).name));
    data_longer  = loadpcd(strcat(camera{longer},'/', list_frames{longer}(closest).name));
    
    pcd_shorter = pointCloud(data_shorter(1:3,:)','Color',data_shorter(4:6,:)');
    pcd_longer = pointCloud(data_longer(1:3,:)','Color',data_longer(4:6,:)');

    downsample_short = pcdownsample(pcd_shorter, 'gridAverage', gridSize);
    downsample_long = pcdownsample(pcd_longer, 'gridAverage', gridSize);

    transformation = pcregrigid(downsample_short, downsample_long, 'Metric', 'pointToPoint','Extrapolate',true, ...
        'InitialTransform', Initial_transformation);
    list_trans(i,:,:) = transformation.T;
end

%%
% The goal here is to pick some "average" trasformation. Calculating an
% average of all transformations is difficult and there are some
% conspicuous outliers. We remove the outliers and then pick a
% transformation in random out of those that remain.

for i = 1:4
    for j = 1:3
        elements = list_trans(:,i,j);
        t_mean = mean(elements);
        stdev = std(elements);
        outliers = [find((elements-t_mean) > 1.5*stdev)' find((elements-t_mean) < -1.5*stdev)'];
        list_trans(outliers,:,:) = [];
    end
end

tform = affine3d(squeeze(list_trans(randi([1 size(list_trans,1)]),:,:)));

%%
split_dir1 = strsplit(camera{1},'\');
split_dir2 = strsplit(camera{2},'\');
filename = strcat(split_dir1(end-1),'\',split_dir1(end),'-',split_dir2(end),'-tform.mat');
save(filename{1},'tform');