close all; clear all; clc; 

Num_of_Kinects = 1 ; 

for i=1:Num_of_Kinects 
	directory = uigetdir;
	list_skel = dir(strcat(directory,'/*skeleton*'));
	list_skel = sort_dir(list_skel); % sort the data properly
	
	% Find the start and finish indices of the skeleton estimation 
	tmp_start_str_index = strfind(list_skel(1).name, '-') ; 
	start_index = str2num(list_skel(1).name(1:(tmp_start_str_index-1))) ; 
	
	tmp_end_str_index = strfind(list_skel(end).name, '-') ; 
	end_index = str2num(list_skel(end).name(1:(tmp_end_str_index-1))) ; 
	
	%

	pcd_temp = zeros(4,25);
	walkings{i} = zeros(length(list_skel), 26, 3);
	inferred_vector{i} = zeros(length(list_skel), 26);

	for j = 1:length(list_skel)
		pcd_temp = loadskeleton(strcat(directory,'/', list_skel(j).name),0);
		walkings{i}(j, :, :) = (pcd_temp(1:3, :))';
		inferred_vector{i}(j,:) = pcd_temp(4,:);
	end
	
	fileID = fopen([directory, '/meta.txt'],'r');
	formatSpec = '%f';
	timestamps{i} = fscanf(fileID,formatSpec) ;
	timestamps{i} = [timestamps{i}(1); timestamps{i}(2:2:end)]	; % Related to the way meta.txt is organized. Don't mind that. 
	timestamps{i} = (10^(-6))*timestamps{i} ; % Now the units are seconds. 
	timestamps{i} = timestamps{i}((start_index+2):(end_index+2)) ;
end



[walking_merged, sample_times] = Kinects_Merge(walkings, inferred_vector, timestamps) ; 

%% Play with point cloud
play_start = 1;
play_end = length(sample_times)+1 ;
delay = 0.1;

player = pcplayer([(min(min(walking_merged(:,:,1)))-0.5) (max(max(walking_merged(:,:,1)))+0.5)],...
                  [(min(min(walking_merged(:,:,2)))-0.5) (max(max(walking_merged(:,:,2)))+0.5)],...
                  [(min(min(walking_merged(:,:,3)))-0.5) (max(max(walking_merged(:,:,3)))+0.5)], 'MarkerSize', 100);
i = play_start;

while isOpen(player)
    skel = connect_skeleton(squeeze(walking_merged(i,1:25,:)) );
    ptCloud = pointCloud(skel,'Color',[repmat([0 50 255], 25,1);repmat([0 0 125],190,1)]);
    view(player,ptCloud);
    i = i + 1;
    if i == play_end
        i = play_start;
    end
    pause(delay);
end

%% Play with point cloud - Original
play_start = 1;
play_end = size(walkings{1}, 1) +1 ;
delay = 0.1;

player = pcplayer([(min(min(walkings{1}(:,:,1)))-0.5) (max(max(walkings{1}(:,:,1)))+0.5)],...
                  [(min(min(walkings{1}(:,:,2)))-0.5) (max(max(walkings{1}(:,:,2)))+0.5)],...
                  [(min(min(walkings{1}(:,:,3)))-0.5) (max(max(walkings{1}(:,:,3)))+0.5)], 'MarkerSize', 100);
i = play_start;

while isOpen(player)
    skel = connect_skeleton(squeeze(walkings{1}(i,1:25,:)) );
    ptCloud = pointCloud(skel,'Color',[repmat([0 50 255], 25,1);repmat([0 0 125],190,1)]);
    view(player,ptCloud);
    i = i + 1;
    if i == play_end
        i = play_start;
    end
    pause(delay);
end