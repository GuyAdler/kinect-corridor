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

function [walking_merged, sample_times] = Kinects_Merge(walkings, inferred_vector, timestamps, end_times)

%% 1 - Time synchronization 

	% ASSUMING ALL CAMERAS ARE SYNCHRONIZED
	
	walkings_sync = walkings ; 
	inferred_vector_sync = inferred_vector ; 
	
	for i = 1:length(walkings_sync)  % Changing the last recorded time of each camera to 0, so they are synced. 
		timestamps_sync{i} = timestamps{i} -  end_times{i};
	end
	
%% 2 - Space synchronization 

	% ASSUMING ALL CAMERAS ARE GIVEN WITHIN THE SAME COORDINATE SYSTEM
	
	
%% 3 - Find the sample times of valid frames, for each camera 

% Rounding sample times to multiples of 1/30 seconds

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

%% 5 - Merging frames from all cameras 

sample_times_temp_merged = [] ;

for i=1:length(walkings_sync)
	sample_times_temp_merged = [sample_times_temp_merged; sample_times_temp{i}] ; 
end

sample_times_temp_merged = unique(sample_times_temp_merged) ; 
walkings_temp_merged = zeros(length(sample_times_temp_merged), size(walkings_sync{1}, 2), 3) ; 

for time_index = 1:length(sample_times_temp_merged)
	frame_avg = 0 ; 
	counter = 0 ; 
	for kinect_index = 1:length(walkings_sync)
		if ismember(sample_times_temp_merged(time_index), sample_times_temp{kinect_index})
			time_index_specific = find(sample_times_temp{kinect_index} == sample_times_temp_merged(time_index)) ; 
			frame_avg = frame_avg + walkings_temp{kinect_index}(time_index_specific,:,:) ; 
			counter = counter + 1 ; 
		end
	end
	walkings_temp_merged(time_index, :, :) = frame_avg/counter ; % counter > 0 since there is at least one camera with that time. 
end 

%% 6 - Using Spline interpolation to obtain the final walkings vector 

sample_times = (sample_times_temp_merged(1)):(1/30):(sample_times_temp_merged(end)) ; 
walking_merged = zeros(length(sample_times), size(walkings_sync{1}, 2), 3) ; 

for skeleton_index = 1:size(walkings_sync{1}, 2)
	walking_merged(: ,skeleton_index,:) = interp1(sample_times_temp_merged, squeeze(walkings_temp_merged(:, skeleton_index, :)), ...
				 sample_times, 'spline', 'extrap');
end


