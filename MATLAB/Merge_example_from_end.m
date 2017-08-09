close all; clear variables; clc; 

Num_of_Kinects = 3 ; 

%max_dist(1) = 3.9467; % Empirical result for VISL corridor, can be modified.
%min_dist(2) = 1.6583; % Based on average distance of hips.
%min_dist(2) = 2.5;
%max_dist(2) = 8 ;

max_dist(1) = 4 ; 
max_dist(2) = 4 ; 
max_dist(3) = 4 ;
min_dist(1) = 2 ; 
min_dist(2) = 2 ; 
min_dist(3) = 2 ; 

load('080317\tform2t1.mat');
load('080317\tform3t2.mat');
mat = tform2t1.T ; 
mat2 = tform3t2.T ;

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
	
	to_remove = [];

	for j = 1:length(list_skel)
		pcd_temp = loadskeleton(strcat(directory,'/', list_skel(j).name),0);
		skel_dist = getSkeletonDist(pcd_temp(1:3, :));
		if (skel_dist > max_dist(i) | skel_dist < min_dist(i))
			to_remove(end+1) = j;
		else
			walkings{i}(j, :, :) = (pcd_temp(1:3, :))';
			if i==2
				for l=1:26
					temp = [squeeze(walkings{i}(j,l,:))',1]*mat ; 
					walkings{i}(j,l,:) = temp(1:3) ; 
				end
			end
			if i==3
				for l=1:26
					temp = [squeeze(walkings{i}(j,l,:))',1]*mat2 ; 
					temp = temp*mat ; 
					walkings{i}(j,l,:) = temp(1:3) ; 
				end
			end
			inferred_vector{i}(j,:) = pcd_temp(4,:);
		end
	end
	
	walkings{i}(to_remove,:,:) = [];
	inferred_vector{i}(to_remove,:) = [] ;
	
	fileID = fopen([directory, '/meta.txt'],'r');
	formatSpec = '%f';
	timestamps{i} = fscanf(fileID,formatSpec) ;
	timestamps{i} = [timestamps{i}(1); timestamps{i}(2:2:end)]	; % Related to the way meta.txt is organized. Don't mind that. 
	timestamps{i} = (10^(-6))*timestamps{i} ; % Now the units are seconds. 
	
	end_times{i} = timestamps{i}(end) ; 
	
	timestamps{i} = timestamps{i}((start_index+2):(end_index+2)) ;
	timestamps{i}(to_remove) = [] ;
	
	if i==1 
		max_dists{1} = max_dist ; min_dists{1} = min_dist ;
	elseif i==2 
		max_dists{2} = max_dist + norm(mat(4,1:3)) ; min_dists{2} = min_dist + norm(mat(4,1:3));
	end
end



[walking_merged, sample_times] = Kinects_Merge_from_end(walkings, inferred_vector, timestamps, end_times) ; 

%% Play with point cloud

play_points_simple(walking_merged) ; 
