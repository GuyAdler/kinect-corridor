% Function connect_skeleton - This function receives a matrix of 25 skeleton XYZs and adds extra points between
%                               skeleton points that are connected in real life by bones. Displaying the result gives
%                               a video more similar to what kinect displays.

% INPUT:  skeleton points vector. Should be a 25X3 matrix.
% OUTPUT: A 215X3 robust skeleton matrix.

function [ full_skeleton ] = connect_skeleton( skeleton_vec )

full_skeleton = zeros(215,3);
% To operate properly, please insert a 25X3 vector!
if (~isequal(size(skeleton_vec),[25 3]))
    error('Size of skeleton vector is not 25X3.');
else
% These are just the values that seem good to the eye.
    full_skeleton(1:25,:) = skeleton_vec;
    full_skeleton(26:40,:) = straight_line(skeleton_vec(skeleton.SpineMid,:),skeleton_vec(skeleton.SpineBase,:),15);
    full_skeleton(41:55,:) = straight_line(skeleton_vec(skeleton.SpineMid,:),skeleton_vec(skeleton.SpineShoulder,:),15);
    full_skeleton(56:65,:) = straight_line(skeleton_vec(skeleton.Neck,:),skeleton_vec(skeleton.SpineShoulder,:),10);
    full_skeleton(66:75,:) = straight_line(skeleton_vec(skeleton.Neck,:),skeleton_vec(skeleton.Head,:),10);
    full_skeleton(76:85,:) = straight_line(skeleton_vec(skeleton.SpineShoulder,:),skeleton_vec(skeleton.ShoulderLeft,:),10);
    full_skeleton(86:95,:) = straight_line(skeleton_vec(skeleton.SpineShoulder,:),skeleton_vec(skeleton.ShoulderRight,:),10);
    full_skeleton(96:110,:) = straight_line(skeleton_vec(skeleton.ElbowRight,:),skeleton_vec(skeleton.ShoulderRight,:),15);
    full_skeleton(111:125,:) = straight_line(skeleton_vec(skeleton.ElbowLeft,:),skeleton_vec(skeleton.ShoulderLeft,:),15);
    full_skeleton(126:135,:) = straight_line(skeleton_vec(skeleton.ElbowLeft,:),skeleton_vec(skeleton.WristLeft,:),10);
    full_skeleton(136:145,:) = straight_line(skeleton_vec(skeleton.ElbowRight,:),skeleton_vec(skeleton.WristRight,:),10);
    full_skeleton(146:155,:) = straight_line(skeleton_vec(skeleton.SpineBase,:),skeleton_vec(skeleton.HipLeft,:),10);
    full_skeleton(156:165,:) = straight_line(skeleton_vec(skeleton.SpineBase,:),skeleton_vec(skeleton.HipRight,:),10);
    full_skeleton(166:175,:) = straight_line(skeleton_vec(skeleton.KneeRight,:),skeleton_vec(skeleton.HipRight,:),10);
    full_skeleton(176:185,:) = straight_line(skeleton_vec(skeleton.KneeLeft,:),skeleton_vec(skeleton.HipLeft,:),10);
    full_skeleton(186:195,:) = straight_line(skeleton_vec(skeleton.KneeLeft,:),skeleton_vec(skeleton.AnkleLeft,:),10);
    full_skeleton(196:205,:) = straight_line(skeleton_vec(skeleton.KneeRight,:),skeleton_vec(skeleton.AnkleRight,:),10);
    full_skeleton(206:210,:) = straight_line(skeleton_vec(skeleton.AnkleRight,:),skeleton_vec(skeleton.FootRight,:),5);
    full_skeleton(211:215,:) = straight_line(skeleton_vec(skeleton.AnkleLeft,:),skeleton_vec(skeleton.FootLeft,:),5);
end


end

% Inner function with the simple goal: to calculate a straight line in 3D
% between two points and return a number of points equal to num_points on that line.
function [ result_line ] = straight_line(x1, x2, num_points)
d = (x2 - x1)/(num_points+1);
result_line = repmat(d, num_points,1).*repmat((1:num_points)',1,3);
result_line = repmat(x1,num_points,1) + result_line;
end