% LoadTimestamps receives a folder name and two indecies: where the skeleton was first recorded,
% and where it was last recorded. It then reads the meta file, removes unnecessary parts, scales
% units to seconds, and finally returns only the times between start_index and end_index.
% RecordingHasMeta = 0 if the meta file is empty.

function [timestamps, end_times, RecordingHasMeta] = LoadTimestamps(KinectDir, start_index, end_index)

	fileID = fopen(strcat(KinectDir, '/meta.txt'),'r');
	formatSpec = '%f';
	timestamps = fscanf(fileID,formatSpec) ;
	
    if isempty(timestamps)
        RecordingHasMeta = 0;
        end_times = [];
    else
		RecordingHasMeta = 1;
		timestamps = [timestamps(1); timestamps(2:2:end)]	; % Related to the way meta.txt is organized. Don't mind that. 
		timestamps = (10^(-6))*timestamps ; % Now the units are seconds. 
		
		end_times = timestamps(end) ; 
		
		if end_index < start_index
			timestamps = timestamps(2:end);
		else
			timestamps = timestamps((start_index+2):(end_index+2)) ;
        end
    end

	fclose(fileID);
end