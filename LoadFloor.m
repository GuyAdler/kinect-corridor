% Function loadfloor - This receives a folder name and loads the corresponding floor vector.
%					If find_new_floor = 1, the floor is loaded and adjusted according to the spine
%					of the walking individual. Otherwise, use the default vector.

% INPUT:  foldername - Folder name to load floor vector.
% OUTPUT: floor_vec - A 1X4 vector [A B C D] describing the floor plane.

function [ floor_vec ] = LoadFloor( foldername , find_new_floor)

if find_new_floor == 1
	floor_vec = LoadFloorFromFile( foldername );
	A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);
	[skel_vec , ~, ~, ~, ~, NoSkeleton] = LoadVideoFromSingleKinect( foldername, KinectNum );
	
	% If no skeleton is recorded in foldername, call the function again with find_new_floor = 0 
	% in order to receive the default floor vector. Maybe there is a more elegant way to do this.
	% But I like this way. It amuses me.
	if NoSkeleton == 1
		floor_vec = LoadFloor( foldername , 0);
	else
		CM = squeeze(skel_vec(:,skeleton.CM,:));
		angle_of_rotation = Find_floor_rotation_angle(A,B,C,D,CM, 'Center of Mass');
		i = 1:(size(CM,1)-1);	diff_avg = mean(CM(i+1,:) - CM1(i,:));
		[new_A, new_B, new_C, new_D] = fix_floor(A,B,C,D, angle_of_rotation, diff_avg/norm(diff_avg)) ;
		floor_vec = [new_A, new_B, new_C, new_D] ;
	end
else
	floor_vec(1) = -0.0183;
	floor_vec(2) = 0.8722;
	floor_vec(3) = -0.4888;
	floor_vec(4) = 2.1563;
end

% Normalize A,B,C values.
floor_vec(1:3) = floor_vec(1:3)/norm(floor_vec(1:3)) ;

end