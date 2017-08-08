% If KinectNum is empty, do not transform. That means, treat this camera
% as camera 1. If the skeleton is too far to be accurate and useful,
% return RemoveFrame = 1 and vectors of all zeros.

function [ skeleton_result, inferred_vector, RemoveFrame] = LoadAndTransformSkeleton( SkeletonFileString , KinectNum)

	pcd_temp = loadskeleton(SkeletonFileString,0);
	skel_dist = getSkeletonDist(pcd_temp(1:3, :));

	skeleton_result = zeros(skeleton.NumPoints, 3);
	inferred_vector = zeros(1,size(pcd_temp,2));
	
	if isempty(KinectNum)
		[max_dist, min_dist] = GetMaxAndMinDistanceOfCamera(1);
		TransformationMatrix = GetTransformationMatrix(1);
	else
		[max_dist, min_dist] = GetMaxAndMinDistanceOfCamera(KinectNum);
		TransformationMatrix = GetTransformationMatrix(KinectNum);
	end
	
	
	if (skel_dist > max_dist || skel_dist < min_dist)
		RemoveFrame = 1;
	else
		RemoveFrame = 0;
		skeleton_result = (pcd_temp(1:3, :))';
		for l=1:skeleton.NumPoints 
            temp = [skeleton_result(l,:),1]*TransformationMatrix;
			skeleton_result(l,:) = temp(1:3);
		end
		
		inferred_vector = pcd_temp(4,:);
	end
end
