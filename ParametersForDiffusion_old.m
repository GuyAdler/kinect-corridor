close all; clear variables; clc; 

find_new_floor = 0;
SkelPoints = skeleton.CM;

savename = input('Filename to save: ', 's');
n_groups = input('Number of groups: ');

nameVideos = [];
group_lengths = zeros(1,n_groups);
for i = 1:n_groups
    group_folders = sort_videos(uipickfiles);
    nameVideos = [nameVideos group_folders];
    group_lengths(i) = length(group_folders);
end

numVideos = length(nameVideos);

% Inserting an empty string into loadfloor because we are currently only using it to load a known vector.
CorridorFloor = LoadFloor( '', find_new_floor );

%%
NumPoints = length(SkelPoints);
VideoParameters = zeros(numVideos,parameters.NumParameters - 3 + 6*NumPoints);
InvalidVideos = [];

for Vid = 1:numVideos
	[walking_merged, sample_times] = LoadAndTransformVideo(nameVideos{Vid});
    
    if ~isempty(walking_merged)
        [ MeanDistance , LeftHandVariance, RightHandVariance] = DifferenceBetweenHandsStatistics( walking_merged );
        VideoParameters(Vid,parameters.HandsMean) = MeanDistance;
        VideoParameters(Vid,parameters.LeftHandVariance) = LeftHandVariance;
        VideoParameters(Vid,parameters.RightHandVariance) = RightHandVariance;
        
        [ MeanDistance, Variance ] = DifferenceBetweenAnklesStatistics( walking_merged );
        VideoParameters(Vid,parameters.AnklesMean) = MeanDistance;
        VideoParameters(Vid,parameters.AnklesVariance) = Variance;
        
        [ ~, ~, statistics ] = VelocityStatistics( walking_merged, sample_times, SkelPoints, 0, 0 );
        VideoParameters(Vid,(end-9*NumPoints+1):(end-6*NumPoints)) = statistics.avg_velocity(:);
        VideoParameters(Vid,(end-6*NumPoints+1):(end-3*NumPoints)) = statistics.avg_abs_velocity(:);
        VideoParameters(Vid,(end-3*NumPoints+1):end) = statistics.std_velocity(:);

    else
        a = cumsum(group_lengths);
        group = find( a  >= Vid, 1);
        InvalidVideos = [InvalidVideos Vid];
        group_lengths(group) = group_lengths(group) - 1;
    end
    disp(strcat(nameVideos{Vid}, ' loaded.'));
end

VideoParameters(InvalidVideos,:) = [];

save_struct.VideoParameters = VideoParameters;
save_struct.lengths = group_lengths;
save_struct.SkelPoints = SkelPoints;

save(strcat(savename, '.mat'),'-struct','save_struct');
disp(['Saved as ' strcat(savename, '.mat')]);