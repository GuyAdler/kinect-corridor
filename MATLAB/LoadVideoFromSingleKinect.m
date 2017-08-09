% Loads the skeleton vector and timestamps from a single kinect and transforms 
% the result to the frame of reference of camera 1.

function [walkings , inferred_vector, timestamps, end_times, RecordingHasMeta, NoSkeleton] = LoadVideoFromSingleKinect(foldername, KinectNum)

    KinectDir = foldername;
	list_skel = dir(strcat(KinectDir,'/*skeleton*'));
	list_skel = sort_dir(list_skel); % sort the data properly
	NoSkeleton = 0;
	
    
	% Find the start and finish indices of the skeleton estimation 
	tmp_start_str_index = strfind(list_skel(1).name, '-') ; 
	start_index = str2double(list_skel(1).name(1:(tmp_start_str_index-1))) ; 
	
	tmp_end_str_index = strfind(list_skel(end).name, '-') ; 
	end_index = str2double(list_skel(end).name(1:(tmp_end_str_index-1))) ; 
	
	FramesToRemove = [];
	walkings = zeros(length(list_skel), skeleton.NumPoints, 3);
	inferred_vector = zeros(length(list_skel), skeleton.NumPoints);
        
    for SkelVec = 1:length(list_skel)
		SkeletonFileString = strcat(KinectDir,'/', list_skel(SkelVec).name);
		[walkings(SkelVec,:,:) , inferred_vector(SkelVec,:) , RemoveFrame] = ...
			LoadAndTransformSkeleton(SkeletonFileString, KinectNum);
		if RemoveFrame == 1
			FramesToRemove(end+1) = SkelVec;
		end
    end
	
	walkings(FramesToRemove,:,:) = [];
	inferred_vector(FramesToRemove,:) = [] ;
	
    if isempty(walkings)
        NoSkeleton = 1;
    end
    
    if ~isempty(dir(strcat(KinectDir,'\meta.txt'))) 
        [timestamps, end_times, RecordingHasMeta] = LoadTimestamps(KinectDir, start_index, end_index);
        if RecordingHasMeta == 1
            timestamps(FramesToRemove) = [];
        end
    else
        RecordingHasMeta = 0;
        timestamps = [];
        end_times = [];
    end
	
end