function angle_deg = SpineAngle( skeleton )
%SPINEANGLE receives an N X 25 skeleton, returns the angle between the
%points: SpineBase , SpineMid, SpineShoulder

UpperSpineVector = [ points(1,skeleton.SpineShoulder) - points(1,skeleton.SpineMid), ...
                     points(2,skeleton.SpineShoulder) - points(2,skeleton.SpineMid), ...
                     points(3,skeleton.SpineShoulder) - points(3,skeleton.SpineMid)];
LowerSpineVector = [ points(1,skeleton.SpineMid) - points(1,skeleton.SpineBase) , ...
                     points(2,skeleton.SpineMid) - points(2,skeleton.SpineBase) , ...
                     points(3,skeleton.SpineMid) - points(3,skeleton.SpineBase)];


angle_deg = acosd(acosd(dot(UpperSpineVector,LowerSpineVector)/ ...
                (norm(UpperSpineVector)*norm(LowerSpineVector))));

end

