% Function fix_floor - given a tilted floor, an angle of rotation and the direction of walking - the function returns the new floor
%                      whose normal is rotated with angle degrees, in the plain of the old normal and the direction of walking.
%                      The projection of the origin (the camera) on the old floor plane is identical to that on the new floor plane. 


% INPUTS: A,B,C,D - The old floor plane paramteres, where its' equation is Ax+By+Cz+D=0 
%                   (D being the height of the camera above the floor - ~2.15 meter).
%         angle   - angle of rotation (should be positive for current camera position)
%         direction_of_walking - the direction of the walking session from which A,B,C,d was received. A unit vector. 

% OUTPUTS: new_A,new_B,new_C,new_D - new floor plane parameters, such that its equation is new_Ax+new_By+new_Cz+new_D=0


function [new_A, new_B, new_C, new_D] = fix_floor(A,B,C,D, angle, direction_of_walking)

old_normal = [A,B,C] ; 
new_normal = cos(angle)*old_normal + sin(angle)*direction_of_walking ; 
new_normal = new_normal/norm(new_normal) ;

% Finding the projection of the origin (0,0,0) on the old floor, so we can use it as a fixed point for the new one. 
% Thus the new floor should be with a right height relative to the camera.

t_value = -D/((norm([A,B,C]))^2) ;
origin_new = t_value*[A,B,C] ; 
 
new_A = new_normal(1) ; new_B = new_normal(2); new_C = new_normal(3) ; 

new_D = -new_normal*origin_new' ; 

