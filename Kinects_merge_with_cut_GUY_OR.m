%Function Kinects_Merge - Recives a walking time series from each camera, and merges them all to get the walking time series of the whole corridor.  

% INPUTS: walkings - A cell array of length Number_of_Cameras. 
%                    Each cell contains a matrix of dimensions: Length_of_Time_Series X Number_of_Skeleton_Points X 3 ( = X-Y-Z).
%                    Obviously this contains the walkings from each camera. THEY MUST BE RAW - NO DATA TAKEN OUT YET. 
%                    CURRENTLY ASSUMED TO BE SYNCHRONIZED - ALL CAMERAS ARE IN THE SAME FRAME OF REFERENCE. 
%         inferred_vector - A cell array of length Number_of_Cameras.
%                           Each cell contains a matrix of dimensions:  Length_of_Time_Series X Number_of_Skeleton_Points.  
%                           A value is 1 if it is not inferred, and 0 if it is. 
%         timestamps - A cell array of length Number_of_Cameras. 
%                      Each cell contains a vector of dimension: Length_of_Time_Series , representing the sample times for each camera. 
%         end_times - A cell array of length Number_of_Cameras.
%                     Each cell contains the timestamp of the LAST 'color' file for that camera.   
%                     WE ASSUME THAT THESE TIMESTAMPS REPRESENT THE SAME ABSOLUTE TIME FOR ALL THE CAMERAS.         


% OUTPUTS:  walking_merged - a matrix of dimensions: Length_of_Time_Series X Number_of_Skeleton_Points X 3 ( = X-Y-Z).
%                            Representing the walking time series merged from all the cameras - USING THE LAST CAMERAS' SYSTEM (THE 10 meter camera).
%                            Either no values are missing, or walking is invalid and the vector is empty. 
%           sample_times - a matrix of dimensions: Length_of_Time_Series,  representing the sample times.
%                          sample times are exactly every 1/30 seconds. 

function [walking_merged, walking_parts_before_cut, walking_parts_after_cut, sample_times, sample_times_parts_before_cut, sample_times_parts_after_cut] = ...
    Kinects_merge_with_cut(walkings, inferred_vector, timestamps, end_times, floor_vec)

A = floor_vec(1) ; 
B = floor_vec(2) ; 
C = floor_vec(3) ; 
D = floor_vec(4) ; 


%% 1 - Time synchronization 

	% ASSUMING ALL CAMERAS ARE SYNCHRONIZED
	
	walkings_sync = walkings ; 
	inferred_vector_sync = inferred_vector ; 
	timestamps_sync = cell(1,length(walkings_sync));
	for i = 1:length(walkings_sync)  % Changing the last recorded time of each camera to 0, so they are synced. 
		timestamps_sync{i} = timestamps{i} -  end_times{i};
	end
	
%% 2 - Space synchronization 

	% ASSUMING ALL CAMERAS ARE GIVEN WITHIN THE SAME COORDINATE SYSTEM
	
	
%% 3 - Find the sample times of valid frames, for each camera 

% Rounding sample times to multiples of 1/30 seconds

sample_times_temp = cell(1,length(walkings_sync));
for i = 1:length(walkings_sync)
	sample_times_temp{i} = round(30*timestamps_sync{i})/30 ; 
end

% Deleting sample times for invalid frames

for kinect_index = 1:length(walkings_sync)
	indices_to_delete = [] ;
	for time_index = 1:size(walkings_sync{kinect_index}, 1)
		TooManyInferred = sum(inferred_vector_sync{kinect_index}(time_index, :)) < 16 ; 
		HeadWrong = (inferred_vector_sync{kinect_index}(time_index, skeleton.Head) == 0) ; 
		TwoFootsWrong = (inferred_vector_sync{kinect_index}(time_index, skeleton.FootLeft) == 0)&&(inferred_vector_sync{kinect_index}(time_index, skeleton.FootRight) == 0) ; 
		
		%skel_dist = getSkeletonDist(squeeze(walkings_sync{kinect_index}(time_index, :, :))');
		%DistanceNotInRange = (skel_dist > max_dists{kinect_index})||(skel_dist < min_dists{kinect_index}) ; 
		% PUT SEGMENT LENGTHS OUTLIERS HERE 
		if TooManyInferred || HeadWrong || TwoFootsWrong 
			indices_to_delete = [indices_to_delete, time_index] ; 
		end
	end
	
	sample_times_temp{kinect_index}(indices_to_delete) = [] ;
	walkings_sync{kinect_index}(indices_to_delete,:,:) = [] ; 
	timestamps_sync{kinect_index}(indices_to_delete) = [] ;
    inferred_vector_sync{kinect_index}(indices_to_delete, :) = [] ;
	
end

%% 4 - Linear extrapolation for each camera.  

for kinect_index = 1:length(walkings_sync)
	walkings_temp{kinect_index} = zeros(length(sample_times_temp{kinect_index}), size(walkings_sync{1}, 2), 3) ;
	for skeleton_index = 1:size(walkings_sync{kinect_index}, 2)
        %time_indices = find(inferred_vector_sync{kinect_index}(:,skeleton_index)) ; 
        time_indices = 1:length(inferred_vector_sync{kinect_index}(:,skeleton_index)) ; 
		walkings_temp{kinect_index}(: ,skeleton_index,:) = interp1(timestamps_sync{kinect_index}(time_indices),  ...
		squeeze(walkings_sync{kinect_index}(time_indices,skeleton_index,:)), sample_times_temp{kinect_index}, 'linear', 'extrap');
	end
end

for kinect_index = 1:length(walkings_sync)
	sample_times{kinect_index} = (sample_times_temp{kinect_index}(1)):(1/30):(sample_times_temp{kinect_index}(end)) ; 
	walkings_merged{kinect_index} = zeros(length(sample_times{kinect_index}), size(walkings_sync{1}, 2), 3) ;
	for skeleton_index = 1:size(walkings_sync{kinect_index}, 2)
        walking_merged{kinect_index}(: ,skeleton_index,:) = interp1(sample_times_temp{kinect_index}, squeeze(walkings_temp{kinect_index}(:, skeleton_index, :)), ...
				 sample_times{kinect_index}, 'spline', 'extrap');
	end
	walking_parts_before_cut{kinect_index} = walking_merged{kinect_index} ;
	sample_times_parts_before_cut{kinect_index} = sample_times{kinect_index} ; 
end

%% Merging cameras by copy and paste 

new_cp_flag = 1 ; % 1 if we want to find places to cut, 0 if we want to use calculated values. 

%if new_cp_flag == 1 ; 
	extremum_dists = zeros(2, length(walkings_sync)) ; % line 1 is min, line 2 is max
	extremum_indices = zeros(2, length(walkings_sync)) ; 
	CM_all = [] ; 
	for kinect_index = length(walkings_sync):(-1):1
		CM = squeeze(walking_merged{kinect_index}(:,skeleton.CM,:));
		CM_all = [CM_all ; CM] ; 
	end
	
	[x_all, y_all, z_all, points_on_plane] = floor_project(CM_all, A, B, C, D, 0) ;
	
	indices_counter = 1 ; 
	
	for kinect_index = length(walkings_sync):(-1):1
		x{kinect_index} = x_all(indices_counter:(indices_counter+size(walking_merged{kinect_index}, 1) -1)) ;
		y{kinect_index} = y_all(indices_counter:(indices_counter+size(walking_merged{kinect_index}, 1) -1)) ;
		z{kinect_index} = z_all(indices_counter:(indices_counter+size(walking_merged{kinect_index}, 1) -1)) ;		
		indices_counter = indices_counter + size(walking_merged{kinect_index}, 1) ; 
	end
	
	for kinect_index = 1:length(walkings_sync) 
		[extremum_dists(1,kinect_index), extremum_indices(1,kinect_index)] = min(x{kinect_index}) ;
		[extremum_dists(2,kinect_index), extremum_indices(2,kinect_index)] = max(x{kinect_index}) ;		
	end
	
	extremum_dists(2,1:(end-1)) = extremum_dists(2,2:end); 
	extremum_dists(:,end) = [] ; 
	extremum_indices(2,1:(end-1)) = extremum_indices(2,2:end); 
	extremum_indices(:,end) = [] ;
	cut_dists = mean(extremum_dists, 1) ; 
	
	cut_begining_indices = zeros(1, length(walkings_sync)-1) ; 
	cut_ending_indices = zeros(1, length(walkings_sync)-1) ;
	
	for kinect_index = 1:(length(walkings_sync)-1)
		[x_min, cut_begining_indices(kinect_index)] = min(abs(x{kinect_index} - cut_dists(kinect_index))) ; 
		[x_max, cut_ending_indices(kinect_index)] = min(abs(x{kinect_index+1} - cut_dists(kinect_index))) ;
		if x{kinect_index}(cut_begining_indices(kinect_index)) < x{kinect_index+1}(cut_ending_indices(kinect_index))
			cut_begining_indices(kinect_index) = cut_begining_indices(kinect_index) + 1 ; 
		end
    end
	
    %for kinect_index = 2:length(walkings_sync)
    %    translation_vec = find_translation(walking_merged{kinect_index-1}, walking_merged{kinect_index},...
    %        cut_begining_indices(kinect_index-1), cut_ending_indices(kinect_index-1));
    %    trans_repmat = repmat(translation_vec,size(walking_merged{kinect_index},1)*26,1);
    %    trans_repmat = reshape(trans_repmat,size(walking_merged{kinect_index},1),26,3);
    %    walking_merged{kinect_index} = walking_merged{kinect_index} - trans_repmat;
    %end
	
	walking_merged{1} = walking_merged{1}(cut_begining_indices(1):end,:,:) ;
	sample_times{1} = sample_times{1}(cut_begining_indices(1):end) ;
	walking_merged{length(walkings_sync)} = walking_merged{length(walkings_sync)}(1:cut_ending_indices(length(walkings_sync)-1),:,:) ;
	sample_times{length(walkings_sync)} = sample_times{length(walkings_sync)}(1:cut_ending_indices(length(walkings_sync)-1)) ;
	for kinect_index = 2:(length(walkings_sync)-1)
		walking_merged{kinect_index} = walking_merged{kinect_index}(cut_begining_indices(kinect_index):cut_ending_indices(kinect_index-1),:,:) ; 
		sample_times{kinect_index} = sample_times{kinect_index}(cut_begining_indices(kinect_index):cut_ending_indices(kinect_index-1)) ;
	end
	
	for kinect_index = 2:length(walkings_sync)
        translation_vec = find_translation_OR(walking_merged{kinect_index-1}, walking_merged{kinect_index}) ;
      
		trans_repmat = zeros(size(walking_merged{kinect_index},1), skeleton.NumPoints, 3) ; 
		for j=1:size(trans_repmat, 1)
			trans_repmat(j,:,:) = translation_vec ; % for NOT only CM
			%trans_repmat(j,:,:) = repmat(translation_vec', 26, 1) ;
		end
        walking_merged{kinect_index} = walking_merged{kinect_index} - trans_repmat;
    end
%end 


walking_merged_super = [] ; 
for kinect_index = length(walkings_sync):(-1):1
	walking_parts_after_cut{kinect_index} = walking_merged{kinect_index} ; 
	sample_times_parts_after_cut{kinect_index} = sample_times{kinect_index} ; 
	walking_merged_super = [walking_merged_super ; walking_merged{kinect_index}] ; 
end

walking_merged = walking_merged_super ; 
%sample_times = 0:(1/30):(size(walking_merged, 1) - 1) ; 
sample_times = (0:1:(size(walking_merged, 1) - 1))/30 ; 
