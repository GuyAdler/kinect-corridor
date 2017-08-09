% This function receives a skeleton vector and returns two statistics
% regarding the ankles: the mean of the distance between them (over time),
% and the variance of this distance.
% Ankles are used and not feet because there is a lot of noise in the feet
% recordings.
function [ MeanDistance, Variance ] = DifferenceBetweenAnklesStatistics( skeleton_vec )

AnklesDist = distance(squeeze(skeleton_vec(:,skeleton.AnkleLeft,:)), squeeze(skeleton_vec(:,skeleton.AnkleRight,:)));

MeanDistance = mean(AnklesDist);
Variance = var(AnklesDist);

end

