function skel_dist = getSkeletonDist( InputSkeleton )

    hips = InputSkeleton(:,[skeleton.HipLeft skeleton.HipRight]);
    hips_avg = 0.5*(hips(:,1) + hips(:,2));
    skel_dist = distance(hips_avg',[0 0 0]);
end

