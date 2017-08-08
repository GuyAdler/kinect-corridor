% Function self_project - takes a set of 3D points and converts them into a 2D set. 
%                         ASSUMPTION: THE SET FALLS WELL INTO A PLANE TO BEGIN WITH! steps: 
%                         1) The function finds the approximate plane the set is sitting on. 
%                         2) The function then projects all the points into that plane, so that now they are all exactly on it. 
%                         3) The function uses the diff_avg vector as the new x axis, and cross(diff_avg,normal) as the new y axis.
%                            The new x,y coordinates are calculated as distances on the plane. 

% INPUTS: old_coordinates - a matrix timeX3 of coordinates, rows are different times.
%         random - 1 if we chose the self plane randomaly, or 0 if we do this deterministically.  

% OUTPUTS: new_x_coordinates - the new x coordiantes, a 1Xtime vector. 
%          new_y_coordinates - the new y coordiantes, a 1Xtime vector. 


function [new_x_coordinates, new_y_coordinates] = self_project(old_coordinates, random)

% Calculating 3 points in the plane, and the normal vector to the plane (unit normal)

time_seq = 1:(size(old_coordinates,1)-1);
diff_avg = mean(old_coordinates(time_seq+1,:) - old_coordinates(time_seq,:)); % a vector in the direction of walking

if random 

	total_time = size(old_coordinates,1) ; 
	average_point_1 = mean(old_coordinates(1:floor(total_time/3),:),1) ;
	average_point_2 = mean(old_coordinates((floor(total_time/3)+1):floor(2*total_time/3),:),1) ; 
	average_point_3 = mean(old_coordinates((floor(2*total_time/3)+1):end,:),1) ;
	rand_point = old_coordinates(randi(total_time), :) ; 
	average_point_3 = (average_point_3 + rand_point)/2;
	
	normal = cross(average_point_1-average_point_2, average_point_1-average_point_3);
	normal = normal/norm(normal) ; 
else

	normals = zeros(size(old_coordinates,1)-1,3) ; 

	for j=2:size(old_coordinates,1)
		tmp_vec = old_coordinates(j,:)-old_coordinates(1,:) ; 
		tmp_vec = tmp_vec/norm(tmp_vec) ; 
		normals(j-1,:) = cross(tmp_vec, diff_avg/norm(diff_avg));
		normals(j-1,:) = normals(j-1,:)/norm(normals(j-1,:)) ; 
	end

	normal = mean(normals,1) ; 
	normal = normal/norm(normal) ; 
	
end

% Projecting all points to the new plane (3D) 

coordinates_projected = zeros(size(old_coordinates,1), 3) ; 
coordinates_projected(1,:) = old_coordinates(1,:) ; 

for j=2:size(old_coordinates,1)
	temp_vector = old_coordinates(j,:) - old_coordinates(1,:) ; 
	coordinates_projected(j,:) = old_coordinates(1,:) + temp_vector - (temp_vector*normal')*normal;
end

diff_avg_projected = diff_avg - (diff_avg*normal')*normal ; 

% The vectors that will be the new axis
		  
new_origin = coordinates_projected(1,:) ;
new_x_vector = diff_avg_projected/norm(diff_avg_projected) ;
new_y_vector = cross(new_x_vector, normal) ;  new_y_vector = new_y_vector/norm(new_y_vector) ;

% Calculating the new 2D coordinates

new_x_coordinates = zeros(1, size(coordinates_projected,1)) ; 
new_y_coordinates = zeros(1, size(coordinates_projected,1)) ; 

for j = 2:size(coordinates_projected,1) % Projection loop
	temp_coordiantes = coordinates_projected(j,:) - new_origin ;
	normush = norm(temp_coordiantes) ; 
	temp_coordiantes = temp_coordiantes/normush ; 
	angle_x = acos(temp_coordiantes*new_x_vector') ; 
	new_x_coordinates(j) = normush*cos(angle_x) ; 
	new_y_coordinates(j) = sign(temp_coordiantes*new_y_vector')*normush*sin(angle_x) ;
end

