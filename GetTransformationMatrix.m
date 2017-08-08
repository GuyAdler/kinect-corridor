% Returns the transformation matrix for the Kinect numbered KinectNum.
% This file is MEANT to be changed. It is currently a mess of matrices that need
% to be loaded for every camera. In the future all "load" lines should be changed 
% to another function or to a single load line.
% The 4X4 matrices are persistent (static in C) so they aren't loaded every time
% the function is called.

function TransformationMatrix = GetTransformationMatrix(KinectNum)

persistent TransformationMatrix2to1;
persistent TransformationMatrix3to1;

TransformationMatrix = eye(4); % default - no transformation (true for Kinect #1).

% PAY ATTENTION TO THE ORDER OF TRANSFORMATIONS!
if KinectNum == 2
	if isempty(TransformationMatrix2to1)
		load('transmat_old/tform.mat');
		mat = tform.T ;
		load('transmat_old/mat_2to1.mat');
		load('transmat_old/mat_2to1_floor.mat')
		
		TransformationMatrix2to1 = mat ; % ICP 					
		TransformationMatrix2to1 = TransformationMatrix2to1*mat_2to1	;	% Floor rotation + height fixations 
        TransformationMatrix2to1 = TransformationMatrix2to1*mat_2to1_floor ; % 	horizontal and vetrical fixations
	end
	
	TransformationMatrix = TransformationMatrix2to1;
elseif KinectNum == 3
	if isempty(TransformationMatrix3to1)
		load('transmat_old/tform.mat');  % DELETE NEXT TIME WE SYNC FROM THE START
		load('transmat_old/tform2.mat');
		load('transmat_old/mat_2to1.mat');
		load('transmat_old/mat_3to2.mat');
		load('transmat_old/mat_3to2_floor.mat')
		mat = tform.T ; 
		mat2 = tform2.T ;

		TransformationMatrix3to1 = mat2 ; % ICP (3 to 2)
        TransformationMatrix3to1 = TransformationMatrix3to1*mat_3to2 ; % Floor rotation (3 to 2) + height fixations
        TransformationMatrix3to1 = TransformationMatrix3to1*mat ; % ICP (2 to 1)
        TransformationMatrix3to1 = TransformationMatrix3to1*mat_2to1 ; % Floor rotation 2 to 1 + internal height change
        TransformationMatrix3to1 = TransformationMatrix3to1*mat_3to2_floor;
	end
	
	TransformationMatrix = TransformationMatrix3to1;

end
	
end