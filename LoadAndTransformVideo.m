% This function receives a folder name that has inside it a folder for every
% seperate camera. It then loads all the skeletons recorded from all those 
% cameras in that recording, transforms them to the same frame of reference,
% and returns the combined result as though it came from a single source.

function [walking,sample_times] = LoadAndTransformVideo(foldername)

VideoFolder = foldername;
namePCs = getSubfolders(VideoFolder);
Num_of_Kinects = length(namePCs);
walkings = cell(1,Num_of_Kinects);
inferred_vector = cell(1,Num_of_Kinects);
timestamps = cell(1,Num_of_Kinects);
end_times = cell(1,Num_of_Kinects);
RecordingHasMeta = 1;
NoSkeleton = 0;

for Kinect = 1:Num_of_Kinects 
	KinectDir = strcat(VideoFolder,'\',namePCs{Kinect});
	[walkings{Kinect} , inferred_vector{Kinect}, timestamps{Kinect}, end_times{Kinect}, RecordingHasMeta, NoSkeleton] = ...
		LoadVideoFromSingleKinect(KinectDir, Kinect);

    if RecordingHasMeta == 0
		disp(strcat('No meta.txt in ', KinectDir));
        break;
	elseif NoSkeleton == 1
		disp(strcat('No skeleton data in ', KinectDir));
		break;
    end
end
    
find_new_floor = 0;
	
if RecordingHasMeta == 1 && NoSkeleton == 0
	CorridorFloor = LoadFloor( '', find_new_floor ); % Inserting an empty string into loadfloor because we are currently only using it to load a known vector.
													 % For a proper implementation of this function, see "CreateWalkingCells".
    [walking, ~, ~ ,sample_times, ~] = Kinects_merge_with_cut_GUY_OR(walkings, inferred_vector, timestamps, end_times, CorridorFloor) ; 
else
    walking = [];
	sample_times = [] ; 
end

end