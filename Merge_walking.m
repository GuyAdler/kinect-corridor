close all; clear variables; clc; 

%% Parameters for convenience 
Num_of_Kinects = 3 ; % current code works for 3 or less. 

plot_flag = 0 ; % 1 if we want to plot the DFT and such at the end. (Plots CM)

play_flag = 1 ; % 1 if we want to play the 
play_speed = 1 ; % 1 for current speed (0.1 sec delay), and in general speed = current_speed*play_speed. 

walking_to_use = 2 ; % Which walking to use during the play and plot. 1 - the merged one. 2 - with colors after the cut. 3 - with colors before the cut. 

find_new_floor = 0 ; % 1 if we want to find new floor vectors, 0 if we use saved ones. 
find_new_transformation = 0 ; % 1 if we want to find a new transformation (currently manually)

save_walking_name = 'walking_merged_143.mat' ; % name of the merged walking we save. 

max_dist = [4,4,4] ; min_dist = [2,2,2] ; % distances from camera at which we dispose of bad points. 


%% Choose walkings 

folders{1} = uigetdir;
folders{2}  = uigetdir;
folders{3} = uigetdir ; 

%% Find floors 

if find_new_floor == 0 
	new_A1 = -0.0183; new_B1 = 0.8722; new_C1 = -0.4888; new_D1 = 2.1563;
	floor1 = [new_A1, new_B1, new_C1]/norm([new_A1, new_B1, new_C1]) ;

	new_A2 = 0.0072 ; new_B2 = 0.8493 ; new_C2 = -0.5278 ; new_D2 = 2.1581 ; 
	floor2 = [new_A2, new_B2, new_C2]/norm([new_A2, new_B2, new_C2]) ;

	new_A3 = -0.0060 ; new_B3 = 0.8457 ; new_C3 = -0.5336 ; new_D3 = 2.1603 ;
	floor3 = [new_A3, new_B3, new_C3]/norm([new_A3, new_B3, new_C3]) ;
else 
	floor_vec1 = loadfloor(folders{1});
	A1 = floor_vec1(1); B1 = floor_vec1(2); C1 = floor_vec1(3); D1 = floor_vec1(4);
	CM1 = load_walking(folders{1}) ; CM1 = squeeze(CM1(:,skeleton.CM,:));
	angle_of_rotation1 = Find_floor_rotation_angle(A1,B1,C1,D1,CM1, 'Center of Mass');
	i = 1:(size(CM1,1)-1);	diff_avg1 = mean(CM1(i+1,:) - CM1(i,:));
	[new_A1, new_B1, new_C1, new_D1] = fix_floor(A1,B1,C1,D1, angle_of_rotation1, diff_avg1/norm(diff_avg1)) ;
	floor1 = [new_A1, new_B1, new_C1]/norm([new_A1, new_B1, new_C1]) ;
	
	floor_vec2 = loadfloor(folders{2});
	A2 = floor_vec2(1); B2 = floor_vec2(2); C2 = floor_vec2(3); D2 = floor_vec2(4);
	CM2 = load_walking(folders{2}) ; CM2 = squeeze(CM2(:,skeleton.CM,:));
	angle_of_rotation2 = Find_floor_rotation_angle(A2,B2,C2,D2,CM2, 'Center of Mass');
	i = 1:(size(CM2,1)-1);	diff_avg2 = mean(CM2(i+1,:) - CM2(i,:));
	[new_A2, new_B2, new_C2, new_D2] = fix_floor(A2,B2,C2,D2, angle_of_rotation2, diff_avg2/norm(diff_avg2)) ;
	floor2 = [new_A2, new_B2, new_C2]/norm([new_A2, new_B2, new_C2]) ;
	
	floor_vec3 = loadfloor(folders{3});
	A3 = floor_vec3(1); B3 = floor_vec3(2); C3 = floor_vec3(3); D3 = floor_vec3(4);
	CM3 = load_walking(folders{3}) ; CM3 = squeeze(CM3(:,skeleton.CM,:));
	angle_of_rotation3 = Find_floor_rotation_angle(A3,B3,C3,D3,CM3, 'Center of Mass');
	i = 1:(size(CM3,1)-1);	diff_avg3 = mean(CM3(i+1,:) - CM3(i,:));
	[new_A3, new_B3, new_C3, new_D3] = fix_floor(A3,B3,C3,D3, angle_of_rotation3, diff_avg3/norm(diff_avg3)) ;
	floor3 = [new_A3, new_B3, new_C3]/norm([new_A3, new_B3, new_C3]) ;
end

%% Find transformation - currently with the aid of ICP. Next time there is a need to transform - we can rewrite it without one. 

load('transmat_old/tform.mat');  % DELETE NEXT TIME WE SYNC FROM THE START
load('transmat_old/tform2.mat');
mat = tform.T ; 
mat2 = tform2.T ;


if find_new_transformation == 0 
	%% rotations 2 to 1
	load('transmat_old/mat_2to1.mat');
	load('transmat_old/mat_3to2.mat');
	load('transmat_old/mat_2to1_floor.mat')
	load('transmat_old/mat_3to2_floor.mat')
	load('transmat_old/diff_avg1.mat'); 
else 
	
	% Finding diff_avg1 
	CM1 = load_walking(folders{1}) ; CM1 = squeeze(CM1(:,skeleton.CM,:));
	angle_of_rotation1 = Find_floor_rotation_angle(new_A1,new_B1,new_C1,new_D1,CM1, 'Center of Mass');
	i = 1:(size(CM1,1)-1);
	diff_avg1 = mean(CM1(i+1,:) - CM1(i,:));
	
	% Defining the horizontal and vertical axis on the floor
	trans_vec_ver = cross(diff_avg1, floor1) ; 
	trans_vec_ver = trans_vec_ver/norm(trans_vec_ver) ; 
	trans_vec_hor = cross(trans_vec_ver, floor1) ; trans_vec_hor=trans_vec_hor/norm(trans_vec_hor) ;
	
	% Transformations from 2 to 1 
	floor2_in1 = floor2*tform.T(1:3,1:3) ;
	angle_2to1 = acos(floor1*floor2_in1') ; 
	cross_2to1 = cross(floor1, floor2_in1) ; cross_2to1=cross_2to1/norm(cross_2to1) ; 
	W_2to1 = [0,-cross_2to1(3),cross_2to1(2); cross_2to1(3), 0, -cross_2to1(1); -cross_2to1(2), cross_2to1(1), 0] ; 
	rotmat_2to1 = eye(3) + sin(angle_2to1)*W_2to1 + (2*((sin(angle_2to1/2))^2))*W_2to1^2 ;
	mat_2to1 = zeros(4,4) ; mat_2to1(1:3,1:3) = rotmat_2to1 ; mat_2to1(4,4) = 1 ;  
	mat_2to1(4,1:3) = -0.09*floor1 ; % THIS IS THE HEIGHT
	
	mat_2to1_floor = eye(4) ; mat_2to1_floor(4,1:3) = 0.0146*trans_vec_ver ; % THESE ARE THE X,Y directions

	% Transformations from 3 to 2 
	floor3_in2 = floor3*tform2.T(1:3,1:3) ;
	angle_3to2 = acos(floor2*floor3_in2') ; 
	cross_3to2 = cross(floor2, floor3_in2) ; cross_3to2=cross_3to2/norm(cross_3to2) ; 
	W_3to2 = [0,-cross_3to2(3),cross_3to2(2); cross_3to2(3), 0, -cross_3to2(1); -cross_3to2(2), cross_3to2(1), 0] ; 
	rotmat_3to2 = eye(3) + sin(angle_3to2)*W_3to2 + (2*((sin(angle_3to2/2))^2))*W_3to2^2 ;
	mat_3to2 = zeros(4,4) ; mat_3to2(1:3,1:3) = rotmat_3to2 ; mat_3to2(4,4) = 1 ;  
	mat_3to2(4,1:3) = 0.1442*floor2 ;
	
	mat_3to2_floor = eye(4) ; mat_3to2_floor(4,1:3) = -0.028*trans_vec_ver + 0.042*trans_vec_hor ; % THESE ARE THE X,Y directions
end

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
				for l=1:26 % PAY ATTENTION TO THE ORDER OF TRANSFORMATIONS!
					temp = [squeeze(walkings{i}(j,l,:))',1]*mat ; % ICP 					
					temp = temp*mat_2to1	;	% Floor rotation + height fixations 
					temp = temp*mat_2to1_floor ; % 	horizontal and vetrical fixations
					walkings{i}(j,l,:) = temp(1:3) ; 
				end
			end
			if i==3
				for l=1:26 % after we have decided on height fixation in 2 to 1, we choose 3 to 2. 
					temp = [squeeze(walkings{i}(j,l,:))',1]*mat2 ; % ICP (3 to 2)
					temp = temp*mat_3to2 ; % Floor rotation (3 to 2) + height fixations
					temp = temp*mat ; % ICP (2 to 1)
					temp = temp*mat_2to1 ; % Floor rotation 2 to 1 + internal height change
					temp = temp*mat_3to2_floor ; % horizontal and vetrical fixations
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

%% Merging and saving walking 

[walking_merged, walking_parts_before_cut, walking_parts_after_cut, sample_times, sample_times_parts_before_cut, sample_times_parts_after_cut] = Kinects_merge_with_cut_GUY_OR(walkings, inferred_vector, timestamps, end_times, new_A1, new_B1, new_C1, new_D1) ; 
save(save_walking_name,'walking_merged') ; 

%% Choosing walking 

if walking_to_use == 1 
	walking_chosen = walking_merged ; 
elseif walking_to_use == 2 
	walking_chosen = [walking_parts_after_cut{3}; walking_parts_after_cut{2}; walking_parts_after_cut{1}] ;
else 
	walking_chosen = [walking_parts_before_cut{3}; walking_parts_before_cut{2}; walking_parts_before_cut{1}] ;
end

%% Plotting 

if plot_flag == 1 
	CM = squeeze(walking_chosen(:,skeleton.CM,:));
	if walking_to_use == 1 
		[T, avg_h, avg_speed] = parameters_estimation_specific(CM, directory, 'Center of Mass - Subject 1',-1) ;
	elseif walking_to_use == 3 
		[T, avg_h, avg_speed] = parameters_estimation_specific(CM, directory, 'Center of Mass - Subject 1',...
		                        [size(walking_parts_before_cut{3},1),size(walking_parts_before_cut{3},1)+size(walking_parts_before_cut{2},1)]) ;
	else
		[T, avg_h, avg_speed] = parameters_estimation_specific(CM, directory, 'Center of Mass - Subject 1',...
		                        [size(walking_parts_after_cut{3},1),size(walking_parts_after_cut{3},1)+size(walking_parts_after_cut{2},1)]) ;
	end
end

%% Play walking

if play_flag == 1 
	play_points_simple(walking_chosen); %, play_speed) ; 
end
