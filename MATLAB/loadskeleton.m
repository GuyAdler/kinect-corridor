function points = loadskeleton( fname , varargin)
%LOADSKELETON This functions loads a skeleton from fname, and then if 
% an optional argument is set to 1 modifies the "inferred" field when 
% the skeleton values make no sense.

if nargin > 1
    process = varargin{1};
else
    process = 0;
end

points = loadpcd(fname);
points(1:3,skeleton.CM) = mean(points(1:3,:),2);
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

