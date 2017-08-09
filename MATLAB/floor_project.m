% Function floor_project - takes a set of 3D points and converts them into a 2D set that is on the floor plane. 
%                          Steps:
%                         1) The function projects all the points into the given floor plane, so that now they are all exactly on it. 
%                         2) The function uses the avg walking vector (which contains the approximate direction of walking) 
%                            as the new x axis, and cross(dir_of_walking,normal) as the new y axis.
%                            The new x,y coordinates are calculated as distances on the plane. 

% INPUTS: old_coordinates - a matrix timeX3 of coordinates, rows are different times. 
%         A,B,C,D - The old floor plane paramteres, where its' equation is Ax+By+Cz+D=0 
%                   (D being the height of the camera above the floor - ~2.15 meter).
%         fixed_axis_flag - if 0, we define the floor x axis as the direction of walking given in old_coordinates. 
%                           if 1 - we use an arbitrary axis. 

% OUTPUTS: new_x_coordinates - the new x coordiantes, a 1Xtime vector. 
%          new_y_coordinates - the new y coordiantes, a 1Xtime vector. 
%          new_z_coordinates - the new z coordinate (height above the floor), a 1Xtime vector. 


function [new_x_coordinates, new_y_coordinates, new_z_coordinates,points_on_plane] = floor_project(old_coordinates,A,B,C,D, fixed_axis_flag)

normal = [A,B,C]/norm([A,B,C]) ; 

% Calculating z coordinates by using the 'distance of point from a plane' formula 
new_z_coordinates = (A*old_coordinates(:,1) + B*old_coordinates(:,2) + C*old_coordinates(:,3) + D)/norm([A,B,C]) ; 

% Finding the projection of the points on the floor plane, still being 3D

t_values = -new_z_coordinates/norm([A,B,C]) ; 
temp_x_coordinates = A*t_values + old_coordinates(:,1) ; 
temp_y_coordinates = B*t_values + old_coordinates(:,2) ;
temp_z_coordinates = C*t_values + old_coordinates(:,3) ;

temp_coordinates = [temp_x_coordinates, temp_y_coordinates, temp_z_coordinates] ; 
points_on_plane = temp_coordinates ; 

% Calculating the new 2D coordinates

if fixed_axis_flag == 0 
	time_seq = 1:(size(temp_coordinates,1)-1);
	new_x_vector = mean(temp_coordinates(time_seq+1,:) - temp_coordinates(time_seq,:)); new_x_vector = new_x_vector/norm(new_x_vector) ; 
else 
	% This vector was chosen as the direction of walking axis from one of the walkings
	new_x_vector = cross([-0.0385   -0.4891   -0.8714], normal) ; new_x_vector = -cross(new_x_vector, normal) ; 
	%new_x_vector = cross([-1   0   0], normal) ;	
	new_x_vector=new_x_vector/norm(new_x_vector) ;
end
new_y_vector = cross(new_x_vector, normal) ;  new_y_vector = new_y_vector/norm(new_y_vector) ;
new_origin = temp_coordinates(1,:) ;

new_x_coordinates = zeros(1, size(temp_coordinates,1)) ; 
new_y_coordinates = zeros(1, size(temp_coordinates,1)) ; 

for j = 2:size(temp_coordinates,1) % Projection loop
	temp = temp_coordinates(j,:) - new_origin ;
	normush = norm(temp) ; 
	temp = temp/normush ; 
	angle_x = acos(temp*new_x_vector') ; 
	new_x_coordinates(j) = normush*cos(angle_x) ; 
	new_y_coordinates(j) = sign(temp*new_y_vector')*normush*sin(angle_x) ;
end
