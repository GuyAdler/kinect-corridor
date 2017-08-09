% This functions receives a skeleton vector and returns three statistics
% regarding the hands: the mean of the difference between them, the
% variance of the distance between the left hand and the CoM, and the
% variance of the distance between the right hand and the CoM.
% Adding statistics such as the variance of the distance between the hands
% should be trivial.
function [ MeanDistance , LeftHandVariance, RightHandVariance] = DifferenceBetweenHandsStatistics( skeleton_vec )

HandsDist = distance(squeeze(skeleton_vec(:,skeleton.HandLeft,:)), squeeze(skeleton_vec(:,skeleton.HandRight,:)));
LeftHand = squeeze(skeleton_vec(:,skeleton.HandLeft, :));
RightHand = squeeze(skeleton_vec(:,skeleton.HandRight, :));
CM = squeeze(skeleton_vec(:,skeleton.CM, :));

MeanDistance = mean(HandsDist);

LeftHandDistance  = distance(LeftHand, CM);
RightHandDistance = distance(RightHand, CM);

LeftHandVariance = var(LeftHandDistance);
RightHandVariance = var(RightHandDistance);


end

