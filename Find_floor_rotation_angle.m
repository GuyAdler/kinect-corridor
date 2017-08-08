% Function Find_floor_rotation_angle - finds the rotation angle needed to rotate the floor and make it right. Used later in 'fix_floor'.
%                                      This is done automatically by taking one of the sets of the kinect (could be CM, ankles - anything),
%                                      projecting them on the current floor and finding the height vs the direction of walking. 
%                                      Then we use linear fitting to this data, and the angle that this line makes with the x axis - 
%                                      is the angle the floor is titled about. 

% ATTENTION! when the camera is fixed, finding the rotation angle and using 'fix_floor' should be DONE ONCE. 
% Better results can be received when the operator does this manually, thus it is recommended to play with the given angle and try it out 
% on different recordings, to see what the best angle is. This is what the figure is used for. 
% ALSO - it might be beneficial to write a similar code which takes into account many recordings, and takes them all into account.

% INPUTS:  A,B,C,D - The old floor plane paramteres, where its' equation is Ax+By+Cz+D=0 
%                   (D being the height of the camera above the floor - ~2.15 meter).
%          coordinates_time_series - a matrix timeX3 of coordinates, rows are different times. This is one of the skeleton points, could be 
%                                    CM, ankles and so on. 
%          skeleton_point_str - a string with the name of the skeleton part. For instance - 'Center Of Mass' . 

function [angle_of_rotation] = Find_floor_rotation_angle(A,B,C,D,coordinates_time_series, skeleton_point_str)

[new_x_coordinates_floor, new_y_coordinates_floor, new_z_coordinates_floor, ~] = floor_project(coordinates_time_series, A, B, C, D) ;

% use this figure if you want to see how good the fit is. 
%figure; plot(new_x_coordinates_floor, new_z_coordinates_floor, 'LineWidth', 1.5) ; 
%xlabel('Distance of walking[m]'); ylabel('height above the floor[m]') ; title(['Height above the floor for the ', skeleton_point_str])  ;

fitObject=fit(new_x_coordinates_floor',new_z_coordinates_floor,'poly1');
%for example - fitObject = 
%     Linear model Poly1:
%     fitO(x) = p1*x + p2
%    Coefficients (with 95% confidence bounds):
%       p1 =    -0.03478  (-0.03905, -0.03051)
%       p2 =      0.8445  (0.8376, 0.8514)
slope = coeffvalues(fitObject) ; slope = slope(1) ; % p1
angle_of_rotation = -atan(slope) ; 
end