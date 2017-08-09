close all; clear variables ; clc; 

folder1 = uigetdir;
folder2  = uigetdir;
folder3  = uigetdir;

%%
data1 = loadpcd([folder1, '\10-color.pcd']) ; 
data2 = loadpcd([folder2, '\10-color.pcd']) ;
data3 = loadpcd([folder3, '\10-color.pcd']) ;

pcd1 = pointCloud(data1(1:3,:)','Color',data1(4:6,:)');
pcd2 = pointCloud(data2(1:3,:)','Color',data2(4:6,:)');
pcd3 = pointCloud(data3(1:3,:)','Color',data3(4:6,:)');

floor_vec = loadfloor(folder1);
A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);
alpha = -acos(B/norm([B C])); %angle between (0 1 0) and floor norm in X.
beta = -acos(B/norm([A B])); %angle between (0 0 1) and floor norm in Z.
rot_mtx = [ 1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)] * ...
          [ cos(beta) sin(beta) 0 ; -sin(beta) cos(beta) 0 ; 0 0 1];

AffinedTrans = [rot_mtx [0;0;0] ; [0 0 0 1]];
tform_axis1 = invert(affine3d(AffinedTrans));

floor_vec = loadfloor(folder2);
A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);
alpha = -acos(B/norm([B C])); %angle between (0 1 0) and floor norm in X.
beta = -acos(B/norm([A B])); %angle between (0 0 1) and floor norm in Z.
rot_mtx = [ 1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)] * ...
          [ cos(beta) sin(beta) 0 ; -sin(beta) cos(beta) 0 ; 0 0 1];

AffinedTrans = [rot_mtx [0;0;0] ; [0 0 0 1]];
tform_axis2 = invert(affine3d(AffinedTrans));

floor_vec = loadfloor(folder3);
A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);
alpha = -acos(B/norm([B C])); %angle between (0 1 0) and floor norm in X.
beta = -acos(B/norm([A B])); %angle between (0 0 1) and floor norm in Z.
rot_mtx = [ 1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)] * ...
          [ cos(beta) sin(beta) 0 ; -sin(beta) cos(beta) 0 ; 0 0 1];

AffinedTrans = [rot_mtx [0;0;0] ; [0 0 0 1]];
tform_axis3 = invert(affine3d(AffinedTrans));

pcd1 = pctransform(pcd1,tform_axis1);
pcd2 = pctransform(pcd2,tform_axis2);
pcd3 = pctransform(pcd3,tform_axis3);

figure; pcshow(pcd1); title('Camera 1 pre transformation'); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 
figure; pcshow(pcd2); title('Camera 2 pre transformation'); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 
figure; pcshow(pcd3); title('Camera 3 pre transformation'); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 

%% Transformation 
gridSize = 0.1 ;
initial_tform2t1 = affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0.06421 0 1.801230907440 1]) ; 
initial_tform3t2 = affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0.20777 0 1.7127 1]) ;
%initial_tform =  affine3d([0.9974,-0.0283,-0.0667,0 ; -0.0023,0.9073,-0.4204,0; 0.0724,0.4195,0.9049,0; -0.0397,-0.8755,-0.3734,1]) ;
%matrixush = [0.9977,-0.0068,-0.0674,0 ; -0.0176,0.9347,-0.3550,0; 0.0655,0.3553,0.9324,0; 0.1008,-0.2369,-0.0413,1] ; 
%matrixush(1:3,1:3) = matrixush(1:3,1:3)/det(matrixush(1:3,1:3)) ; 
%initial_tform =  affine3d(matrixush) ;
downsample1 = pcdownsample(pcd1, 'gridAverage', gridSize);
downsample2 = pcdownsample(pcd2, 'gridAverage', gridSize);
downsample3 = pcdownsample(pcd3, 'gridAverage', gridSize);

tform2t1 = pcregrigid(downsample2, downsample1, 'Metric', 'pointToPlane','Extrapolate',true, ...
 	'InitialTransform', initial_tform2t1);
tform3t2 = pcregrigid(downsample3, downsample2, 'Metric', 'pointToPlane','Extrapolate',true, ...
 	'InitialTransform', initial_tform3t2);

%	p1= [0.105,2.65,7.846];
%p2=[1.345,3.874,7.188] ;
%dp = [0.5745    1.4460    2.5230] ; 
%mat = tform.T ; 
%mat(4,2:3) = -5*mat(4,2:3) ; 
%mat(4,1) = mat(4,1) - 0; mat(4,2) = mat(4,2) - 1.5;
%mat(4,1:3) = mat(4,1:3) + dp ; 
%tform = affine3d(mat) ;
	
	
% dp_better = [-0.0250   -0.0740   -0.0250] ; 
%mat = tform.T ;
%mat(4,1:3) = mat(4,1:3) + dp_better ;
%tform = affine3d(mat) ; 
mergeSize = 0.015;

pcd3_Aligned = pctransform(pcd3,tform3t2);
pcd_merged_temp = pcmerge(pcd2, pcd3_Aligned, mergeSize);

pcd2_Aligned = pctransform(pcd_merged_temp,tform2t1);

% Merge

pcd_merged = pcmerge(pcd1, pcd2_Aligned, mergeSize);
figure; pcshow(pcd_merged); title('Merge Hallway'); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 