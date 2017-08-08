[baseName, folder] = uigetfile();
fullFileName = fullfile(folder, baseName);
camera1 = loadpcd(fullFileName);

[baseName, folder] = uigetfile();
fullFileName = fullfile(folder, baseName);
camera2 = loadpcd(fullFileName);

%[baseName, folder] = uigetfile();
%fullFileName = fullfile(folder, baseName);
%tform = load(fullFileName);

%tform = tform.tform;

pcd1 = pointCloud(camera1(1:3,:)','Color',camera1(4:6,:)');
pcd2 = pointCloud(camera2(1:3,:)','Color',camera2(4:6,:)');

%%
gridSize = 0.05;
downsample1 = pcdownsample(pcd1, 'gridAverage', gridSize);
downsample2 = pcdownsample(pcd2, 'gridAverage', gridSize);

tform = pcregrigid(downsample2, downsample1, 'Metric', 'pointToPoint','Extrapolate',true);

%%
tform = affine3d(tform.T + [ 0 0 0 0; 0 0 0 0; 0 0 0 0 ; -0.3 -0.6 -3.8 0]);

pcd2_aligned = pctransform(pcd2, tform);

mergeSize = 0.015;
Corridor = pcmerge(pcd1, pcd2_aligned, mergeSize);

player = pcplayer(Corridor.XLimits,Corridor.YLimits,Corridor.ZLimits);
view(player,Corridor)