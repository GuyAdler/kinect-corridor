% Receives a foldername, loads all the floor vectors in that folder,
% and returns an average of all of them.

function [ floor_vec ] = LoadFloorFromFile( foldername )

list_floor = dir(strcat(foldername,'/*floor.pcd'));
floor_vec = zeros(1,4);
for i=1:length(list_floor)
	filename = strcat(foldername,'/',list_floor(i).name);
	file = fopen(filename,'r');
	for j=1:4
		floor_vec(j) = floor_vec(j) + str2double(fgetl(file));
	end
	fclose(file);
end
floor_vec = floor_vec / length(list_floor); % An average of all the floor vectors within the file.

end