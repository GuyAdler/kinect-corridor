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

%% Floors 

folder1 = uigetdir;
folder2  = uigetdir;
folder3 = uigetdir ; 
for j=1:3
	if j==1 
		folders{j} = folder1 ; 
	elseif j==2 
		folders{j} = folder2 ; 
	else 
		folders{j} = folder3 ; 
	end
end


new_A1 = -0.0183; new_B1 = 0.8722; new_C1 = -0.4888; new_D1 = 2.1563;
floor1 = [new_A1, new_B1, new_C1]/norm([new_A1, new_B1, new_C1]) ;

new_A2 = 0.0072 ; new_B2 = 0.8493 ; new_C2 = -0.5278 ; new_D2 = 2.1581 ; 
floor2 = [new_A2, new_B2, new_C2]/norm([new_A2, new_B2, new_C2]) ;

new_A3 = -0.0060 ; new_B3 = 0.8457 ; new_C3 = -0.5336 ; new_D3 = 2.1603 ;
floor3 = [new_A3, new_B3, new_C3]/norm([new_A3, new_B3, new_C3]) ;

%% rotations 2 to 1

load('transmat_old/tform.mat'); % from ICP
load('transmat_old/tform2.mat'); % from ICP
load('transmat_old/mat_2to1.mat'); % floor vectors method
load('transmat_old/mat_3to2.mat'); % floor vectors method
load('transmat_old/diff_avg1.mat'); % Align from direction of walking
mat = tform.T ; 
mat2 = tform2.T ;

%% rotations 3 to 2

trans_vec_ver = cross(diff_avg1, floor1) ; 
trans_vec_ver = trans_vec_ver/norm(trans_vec_ver) ; 

trans_vec_hor = cross(trans_vec_ver, floor1) ; trans_vec_hor=trans_vec_hor/norm(trans_vec_hor) ; 

%%
walkings = cell(1,Num_of_Kinects);
inferred_vector = cell(1,Num_of_Kinects);
for i=1:Num_of_Kinects 
	directory = folders{i} ; 
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
					
					temp = temp*mat_2to1	;	
					
					temp(1:3) = temp(1:3) + 0.0146*trans_vec_ver ;
				
					walkings{i}(j,l,:) = temp(1:3) ; 
				end
			end
			if i==3
				for l=1:26
					temp = [squeeze(walkings{i}(j,l,:))',1]*mat2 ;
					temp = temp*mat_3to2 ;
					temp = temp*mat ; 
					temp = temp*mat_2to1 ;
					temp(1:3) = temp(1:3) - 0.028*trans_vec_ver ; 
					temp(1:3) = temp(1:3) + 0.042*trans_vec_hor ;
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


%%
[walking_merged, walking_parts_before_cut, walking_parts_after_cut, sample_times, sample_times_parts_before_cut, sample_times_parts_after_cut] = Kinects_merge_with_cut(walkings, inferred_vector, timestamps, end_times, new_A1, new_B1, new_C1, new_D1) ; 
%walking_merged=[walking_merged{3};walking_merged{2};walking_merged{1}];
save('walking_merged_133_17.mat','walking_merged')

walking = walking_merged ; 
CM = squeeze(walking(:,skeleton.CM,:));
[T, avg_h, avg_speed] = parameters_estimation_specific(CM, directory, 'Center of Mass - Subject 1') ;

%% Play with point cloud

play_points_simple(walking_merged) ; 

