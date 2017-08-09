function points = loadskeleton( fname , process)
%LOADSKELETON This functions loads a skeleton from fname, and then if 
% an optional argument is set to 1 modifies the "inferred" field when 
% the skeleton values make no sense.

persistent SkeletonWeights;
if isempty(SkeletonWeights)
    SkeletonWeights = zeros(1,25);
    SkeletonWeights(skeleton.AnkleLeft)  	= 1.33/2    ; % Foot weight divided equally between foot and ankle.
    SkeletonWeights(skeleton.AnkleRight)	= 1.33/2  	;
    SkeletonWeights(skeleton.ElbowLeft)		= 1.5  		; % The elbows take the role of "Forearm".
    SkeletonWeights(skeleton.ElbowRight)	= 1.5  		;
    SkeletonWeights(skeleton.FootLeft)		= 1.33/2  	;
    SkeletonWeights(skeleton.FootRight)		= 1.33/2  	;
    SkeletonWeights(skeleton.HandLeft)		= 0.585  	;
    SkeletonWeights(skeleton.HandRight)		= 0.585  	;
    SkeletonWeights(skeleton.HandTipLeft)	= 0  		;
    SkeletonWeights(skeleton.HandTipRight)	= 0  		;
    SkeletonWeights(skeleton.Head)			= 6.81 		; % Head & Neck
    SkeletonWeights(skeleton.HipLeft)		= 14.47  	; % The hips take the role of "thigh".
    SkeletonWeights(skeleton.HipRight)		= 14.47  	;
    SkeletonWeights(skeleton.KneeLeft)		= 4.57  	; % The knees take the role of "shank".
    SkeletonWeights(skeleton.KneeRight)		= 4.57  	; % 
    SkeletonWeights(skeleton.Neck)			= 0  		;
    SkeletonWeights(skeleton.ShoulderLeft)	= 2.63  	; % The shoulders take the role of "Upper Arm".
    SkeletonWeights(skeleton.ShoulderRight) = 2.63  	;
    SkeletonWeights(skeleton.SpineBase)		= 43.02/3	; % Trunk weight divided equally between spine points.
    SkeletonWeights(skeleton.SpineMid)		= 43.02/3	;
    SkeletonWeights(skeleton.SpineShoulder) = 43.02/3  	;
    SkeletonWeights(skeleton.ThumbLeft)		= 0  		;
    SkeletonWeights(skeleton.ThumbRight)	= 0  		;
    SkeletonWeights(skeleton.WristLeft)		= 0  		;
    SkeletonWeights(skeleton.WristRight)	= 0  		;
end

points = loadpcd(fname);
CM_x = points(1,:)*SkeletonWeights'/100;
CM_y = points(2,:)*SkeletonWeights'/100;
CM_z = points(3,:)*SkeletonWeights'/100;
points(1:3,skeleton.CM) = [CM_x ; CM_y ; CM_z];
points(4,skeleton.CM) = 1;

if process == 1
    LeftLegVector = [ points(1,skeleton.AnkleLeft) - points(1,skeleton.HipLeft) , ...
                    points(2,skeleton.AnkleLeft) - points(2,skeleton.HipLeft) , ...
                    points(3,skeleton.AnkleLeft) - points(3,skeleton.HipLeft)];
    LeftHipVector = [ points(1,skeleton.SpineBase) - points(1,skeleton.HipLeft) , ...
                    points(2,skeleton.SpineBase) - points(2,skeleton.HipLeft) , ...
                    points(3,skeleton.SpineBase) - points(3,skeleton.HipLeft)];
            
    RightLegVector = [ points(1,skeleton.AnkleRight) - points(1,skeleton.HipRight) , ...
                    points(2,skeleton.AnkleRight) - points(2,skeleton.HipRight) , ...
                    points(3,skeleton.AnkleRight) - points(3,skeleton.HipRight)];
    RightHipVector = [ points(1,skeleton.SpineBase) - points(1,skeleton.HipRight) , ...
                    points(2,skeleton.SpineBase) - points(2,skeleton.HipRight) , ...
                    points(3,skeleton.SpineBase) - points(3,skeleton.HipRight)];

    if(distance(points(1:3,skeleton.AnkleRight), points(1:3,skeleton.HipRight)) > 1.5)  % 1.5 as a long length for a leg ?
        points(4,skeleton.AnkleRight) = 0;
    end

    if(distance(points(1:3,skeleton.AnkleLeft), points(1:3,skeleton.HipLeft)) > 1.5)  % 1.5 as a long length for a leg ?
        points(4,skeleton.AnkleLeft) = 0;
    end

    if (acosd(dot(LeftLegVector,LeftHipVector)/(norm(LeftLegVector)*norm(LeftHipVector))) > 90 ...
        || acosd(dot(LeftLegVector,LeftHipVector)/(norm(LeftLegVector)*norm(LeftHipVector))) < -90)
        points(4,skeleton.AnkleLeft) = 0;
        points(4,skeleton.KneeLeft) = 0;
    end

    if (acosd(dot(RightLegVector,RightHipVector)/(norm(RightLegVector)*norm(RightHipVector))) > 90 ...
        || acosd(dot(RightLegVector,RightHipVector)/(norm(RightLegVector)*norm(RightHipVector))) < -90)
        points(4,skeleton.AnkleRight) = 0;
        points(4,skeleton.KneeRight) = 0;
    end

    % points(1:3,:) = points(1:3,:).*[points(4,:);points(4,:);points(4,:)];
end

end

