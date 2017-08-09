% This code reorganizes folder taken from the kinects. This is necessary before "CreateWalkingCells".
% The OLD order is as follows:
% KinectPC1
%	Video1
%	Video2
%	...
% KinectPC2
%	Video1
%	Video2
%	...
% ...
% The NEW order will be:
% Video1
% 	KinectPC1
% 	KinectPC2
%	...
% Video2
% 	KinectPC1
% 	KinectPC2
%	...
% ...

folder = uigetdir;

namePCs = getSubfolders(folder);
num_PCs = length(namePCs);

nameVideos = getSubfolders(strcat(folder,'/',namePCs{1}));
num_Videos = length(nameVideos);
VideoList = cell(1, num_Videos);
VideoList{1} = nameVideos;

for i = 2:num_PCs
    nameVideos = getSubfolders(strcat(folder,'/',namePCs{i}));
    if length(nameVideos) ~= num_Videos
        error('PCs did not record the same number of videos!');
    end
    VideoList{i} = nameVideos;
end

for Vid = 1:num_Videos
    VideoFolderName = strcat(folder,'\Video', num2str(Vid));
    mkdir(VideoFolderName);
    for PC = 1:num_PCs
        thisList = VideoList{PC};
        SourceFolder = strcat(folder,'/',namePCs{PC},'/',thisList{Vid});
        DestinationFolder = strcat(VideoFolderName,'/PC',num2str(PC));
        movefile(SourceFolder,DestinationFolder);
    end
    message = strcat(VideoFolderName,' created.');
    disp(message);
end

for i = 1:num_PCs
    rmdir(strcat(folder,'/',namePCs{i}));
end