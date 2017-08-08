function [merged_pcd, tforms] = transformation_var(original_pcds, varargin)

gridSize = 0.1 ;
mergeSize = 0.015;

for i = 1:(length(original_pcds)-1)
    init_transform{i} = affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0 0 0 1]) ;
    downsampled{i} = pcdownsample(original_pcds{i}, 'gridAverage', gridSize);
    tforms{i} = affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0 0 0 1]);
end
downsampled{end+1} = pcdownsample(original_pcds{end}, 'gridAverage', gridSize);

num_initial_tforms = (nargin - 1) / 2;
for i = 1:num_initial_tforms
    origin_video_idx = varargin{2*i-1};
    init_transform{origin_video_idx-1} = varargin{2*i};
end

merged_pcd = original_pcds{end};
for i = length(original_pcds):-1:2
    tforms{i-1} = pcregrigid(downsampled{i}, downsampled{i-1}, 'Metric', 'pointToPlane','Extrapolate',true, ...
        'InitialTransform', init_transform{i-1});
    pcd_Aligned = pctransform(merged_pcd,tforms{i-1});
    merged_pcd = pcmerge(original_pcds{i-1}, pcd_Aligned, mergeSize);
end