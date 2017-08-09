close all; clear variables; clc; 

find_new_floor = 0;
SkelPoints = [skeleton.CM skeleton.AnkleLeft skeleton.AnkleRight];
skeleton_pairs = [skeleton.HandLeft skeleton.HandRight;
                  skeleton.CM skeleton.HandLeft;
                  skeleton.CM skeleton.HandRight
                  skeleton.AnkleRight skeleton.AnkleLeft
                  skeleton.Head skeleton.CM
                  skeleton.AnkleLeft skeleton.HandLeft
                  skeleton.AnkleRight skeleton.HandRight];

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

NumPairs = size(skeleton_pairs,1);
NumPoints = length(SkelPoints);
VideoParameters = zeros(numVideos,NumPairs*11 + 1 + NumPoints*9);
InvalidVideos = [];

for Vid = 1:numVideos
	[walking_merged, sample_times] = LoadAndTransformVideo(nameVideos{Vid});
    
    if ~isempty(walking_merged)
        [ statistics ] = DifferenceBetweenPartsStatistics( walking_merged, sample_times, skeleton_pairs', 0, 0);
        VideoParameters(Vid, 1:NumPairs) = statistics.MeanDistance(:);
        VideoParameters(Vid, NumPairs+1:2*NumPairs) = statistics.VarDistance(:);
        VideoParameters(Vid, 2*NumPairs+1:5*NumPairs) = statistics.MeanDistanceVec(:);
        VideoParameters(Vid, 5*NumPairs+1:8*NumPairs) = statistics.VarDistanceVec(:);
        VideoParameters(Vid, 8*NumPairs+1:11*NumPairs) = statistics.MeanDifferenceVec(:);
        
        [ ~, ~, statistics] = FrequencyStatistics( walking_merged, sample_times, skeleton_pairs', 0 );
        VideoParameters(Vid, 11*NumPairs+1) = statistics.Frequency;
        
        [ ~, ~, statistics ] = VelocityStatistics( walking_merged, sample_times, SkelPoints, 0, 0 );
        VideoParameters(Vid,(11*NumPairs+2):(11*NumPairs+2+3*NumPoints-1)) = statistics.avg_velocity(:);
        VideoParameters(Vid,(11*NumPairs+2+3*NumPoints):(11*NumPairs+2+6*NumPoints-1)) = statistics.avg_abs_velocity(:);
        VideoParameters(Vid,(11*NumPairs+2+6*NumPoints):end) = statistics.std_velocity(:);
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