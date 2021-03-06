% Shows the CM from all the groups, CM_Or is a cell type with each cell containing the CM time series. 
% CM has to be divided into groups, and some cells can be [], corresponding to folders with no meta. 
% For example - first 4 cells are the first group, the next for are the second group and so on - and CM{3} might be [] . 
% close all; clear variables; clc; 

load_str = 'GuyDragsCM.mat';
save_str = 'GuyDragsCM_trim.mat' ; 

save_flag = 1 ; % 1 if we want to save a new cut data 
filter_flag = 0 ; % 1 if we want to filter. 
interp_flag = 0 ; % use this for smart downsampling using interpolation.
zero_mean_flag = 0; % To make sure that the results have zero mean.
DFT_flag = 0 ; % 1 if we use DFT instead of the time series.  
fixed_axis_flag = 1 ; % if 0, we merge using a direction-of-walk axis, if 1 we use a fixed axis. 
plot_flag = 0;

% Here we only allow the default floor. If this changes, you will need to add
% a custom floor vector into the file generated by CreateWalkingCells.
FloorVector = LoadFloor( '', 0 ); 
A = FloorVector(1); B = FloorVector(2); C = FloorVector(3); D = FloorVector(4);

LoadMat = load(load_str) ; 
group_sizes = LoadMat.lengths ; % Number of videos within each parameter group. 
Videos = LoadMat.walking;
SkelPoints = LoadMat.SkelPoints;
n_groups = length(group_sizes);
n_videos = length(Videos);
n_points = length(SkelPoints);

groups_acc = zeros(1,n_groups+1);
for i = 1:n_groups
    groups_acc(i+1) = groups_acc(i) + group_sizes(i);
end

%% Moving to floor coordiantes
floor_CM = cell(n_points,n_videos);
floor_coordinates = cell(n_points,n_videos);
filtered_floor_coordinates = cell(n_points,n_videos);

for i=1:n_videos
	if isempty(Videos{i})
        for points = 1:n_points
            floor_CM{points,i} = [] ; 
        end
    else
            for points = 1:n_points
                [floor_coordinates{points,i}, filtered_floor_coordinates{points,i}] = ...
                    floor_and_filter((Videos{i}(:,points,:)),3, A,B,C,D) ;
				[floor_cx, floor_cy, floor_cz, ~] = floor_project(squeeze(Videos{i}(:,points,:)),A,B,C,D,fixed_axis_flag) ;
				floor_coordinates{points, i} = [floor_cx', floor_cy', floor_cz] ;
            
                if filter_flag == 1 
            		floor_CM{points,i} = filtered_floor_coordinates{points,i} ; 
                else 
                    floor_CM{points,i} = floor_coordinates{points,i} ;
                end
                
                if zero_mean_flag
                    floor_CM{points,i} = floor_CM{points,i} - repmat(mean(floor_CM{points,i}), size(floor_CM{points,i},1), 1);
                end
            end
    end
end

min_time_length = Inf;
for i = 1:n_videos
    temp_length = size(floor_CM{1, i}, 1) ;
    if min_time_length > temp_length && temp_length > 0
       min_time_length = temp_length;
    end
end

max_time_length = 0;
for i = 1:n_videos
    temp_length = size(floor_CM{1, i}, 1) ;
    if max_time_length < temp_length && temp_length > 0
       max_time_length = temp_length;
    end
end    

%% Cutting to match the size of the minimal length video 
for i=1:n_videos
	if ~isempty(Videos{i})
        for points = 1:n_points
            if DFT_flag 
                M = size(floor_CM{points,i}, 1) ; 
                %theta = 0:(2*pi/M):(2*pi*floor(M/2)/M); 
                theta = linspace(0, 2*pi-(2*pi/M) , M) ; 
                fft_y = fft(floor_CM{points,i}(:,2)) ;
                fft_z = fft(floor_CM{points,i}(:,3)) ;
                floor_CM{points,i}(:,2:3) = [fft_y, fft_z] ;
                floor_CM{points,i}(:,1) = theta'/pi ; 
            end
            
            if interp_flag == 0
    			floor_CM{points,i} = floor_CM{points,i}(1:min_time_length,:) ;
            else 
				time = 1:size(floor_CM{points,i},1) ; 
				new_time = linspace(1, size(floor_CM{points,i},1), min_time_length) ; 
                floor_CM{points,i} = interp1(time, floor_CM{points,i}, new_time, 'linear') ;  
            end
            
            if DFT_flag == 1
                floor_CM{points,i} = abs(floor_CM{points,i}) ; 
            else 
				floor_CM{points,i}= real(floor_CM{points,i}) ;
            end
        end
	end
end

%% Saving 

if save_flag == 1 
	DM_Data = [] ; 
    for i=1:n_videos
        if ~isempty(Videos{i}) 
            DM_temp = [];
            for points = 1:n_points
                %temp = reshape(floor_CM{points,i}, 1, size(floor_CM{points,i},1)*size(floor_CM{points,i},2)) ; 
                temp = floor_CM{points,i}(:,1:3) ;
                temp = reshape(temp, 1, size(temp,1)*size(temp,2));
                DM_temp = [DM_temp temp]; 
            end
            DM_Data = [DM_Data;DM_temp] ;
        else
            for j = 2:length(groups_acc)
                if i > groups_acc(j-1) && i <= groups_acc(j)
                    group_sizes(j-1) = group_sizes(j-1) - 1;
                    break;
                end
            end
        end
            
    end
    
    save_struct.Data = DM_Data;
    save_struct.lengths = group_sizes;
    save_struct.SkelPoints = SkelPoints;

	save(save_str, '-struct', 'save_struct');
    
end

%% Plotting (x,y) values
color_vec{1} = [1 1 0] ; color_vec{2} = [1 0 1] ; color_vec{3} = [0 1 1] ; color_vec{4} = [1 0 0] ; color_vec{5} = [0 1 0];
color_vec{6} = [0 0 1] ; color_vec{7} = [1 1 1] ; color_vec{8} = [0 0 0] ; color_vec{9} = [0 0.4470 0.7410] ; color_vec{10} = [0.7410 0.4470 0];
if (plot_flag)
for skelpoint = 1:n_points
    figure
    for i=1:n_groups
        subplot(n_groups,1,i) ; 
        for j=1:group_sizes(i)
            if ~isempty(Videos{groups_acc(i) + j})
                if DFT_flag == 0 
    				plot(floor_CM{skelpoint,groups_acc(i) + j}(:,1), floor_CM{skelpoint,groups_acc(i) + j}(:,2),'o', 'color', color_vec{j}) ; hold on ;
                else 
        			plot(floor_CM{skelpoint,groups_acc(i) + j}(:,1), floor_CM{skelpoint,groups_acc(i) + j}(:,2),'LineWidth', 1.5, 'color', color_vec{j}) ; hold on ;
                end
                title(strcat('(x,y) values for walking group', {' '}, num2str(i), ' for', {' '}, skeleton.Names(SkelPoints(skelpoint)))) ;
                xlabel('x[m]') ; ylabel('y[m]');
            end
        end
    end
end

for skelpoint = 1:n_points
    figure
    for i=1:n_groups
    	subplot(n_groups,1,i) ; 
        for j=1:group_sizes(i)
    		if ~isempty(Videos{groups_acc(i) + j})
            	if DFT_flag == 0 
                	plot(floor_CM{skelpoint,groups_acc(i) + j}(:,1), floor_CM{skelpoint,groups_acc(i) + j}(:,3),'o', 'color', color_vec{j}) ; hold on ;
            	else
    				plot(floor_CM{skelpoint,groups_acc(i) + j}(:,1), floor_CM{skelpoint,groups_acc(i) + j}(:,3),'LineWidth', 1.5,'color', color_vec{j}) ; hold on ;
            	end
                title(strcat('(x,z) values for walking group', {' '}, num2str(i), ' for', {' '}, skeleton.Names(SkelPoints(skelpoint)))) ;
                xlabel('x[m]') ; ylabel('z[m]');		
    		end
        end
    end
end
end