close all; clear variables; clc; 

Num_of_Kinects = 3 ; 

%max_dist(1) = 3.9467; % Empirical result for VISL corridor, can be modified.
%min_dist(2) = 1.6583; % Based on average distance of hips.
%min_dist(2) = 2.5;
%max_dist(2) = 8 ;

max_dist(1) = 4 ; 
max_dist(2) = 4 ; 
max_dist(3) = 4 ;
min_dist(1) = 2 ; 
min_dist(2) = 2 ; 
min_dist(3) = 2 ; 

%% rotations 2 to 1

load('mat2to1.mat');
load('mat3to2.mat');

mat2to1 = tform2t1.T;
mat3to2 = tform3t2.T;

%% Floors 

folders = cell(1,Num_of_Kinects);
RotateAxis = cell(1,Num_of_Kinects);
for j=1:Num_of_Kinects
	folders{j} = uigetdir ; 
    
    floor_vec = loadfloor(folders{j});
    A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);
    alpha = -acos(B/norm([B C])); %angle between (0 1 0) and floor norm in X.
    beta = -acos(B/norm([A B])); %angle between (0 1 0) and floor norm in Z.
    RotateAxis{j} = [ 1 0 0; 0 cos(alpha) sin(alpha); 0 -sin(alpha) cos(alpha)] * ...
                    [ cos(beta) sin(beta) 0 ; -sin(beta) cos(beta) 0 ; 0 0 1];
    RotateAxis{j} = RotateAxis{j}';
end


new_A = 0; new_B = 1; new_C = 0; new_D = D;


%%
walkings = cell(1,Num_of_Kinects);
inferred_vector = cell(1,Num_of_Kinects);
timestamps = cell(1,Num_of_Kinects);
end_times = cell(1,Num_of_Kinects);

for i=1:Num_of_Kinects 
	directory = folders{i} ; 
	list_skel = dir(strcat(directory,'/*skeleton*'));
	list_skel = sort_dir(list_skel); % sort the data properly
	
	% Find the start and finish indices of the skeleton estimation 
	tmp_start_str_index = strfind(list_skel(1).name, '-') ; 
	start_index = str2num(list_skel(1).name(1:(tmp_start_str_index-1))) ; 
	
	tmp_end_str_index = strfind(list_skel(end).name, '-') ; 
	end_index = str2num(list_skel(end).name(1:(tmp_end_str_index-1))) ; 
	
	%

	pcd_temp = zeros(4,25);
	walkings{i} = zeros(length(list_skel), 26, 3);
	inferred_vector{i} = zeros(length(list_skel), 26);
	
	to_remove = [];

	for j = 1:length(list_skel)
		pcd_temp = loadskeleton(strcat(directory,'/', list_skel(j).name),0);
		skel_dist = getSkeletonDist(pcd_temp(1:3, :));
		if (skel_dist > max_dist(i) | skel_dist < min_dist(i))
			to_remove(end+1) = j;
		else
			walkings{i}(j, :, :) = (pcd_temp(1:3, :))';
            inferred_vector{i}(j,:) = pcd_temp(4,:);
        end
    end
    
    walking_size = size(walkings{i});
    temp = reshape(walkings{i}, [walking_size(1)*walking_size(2) 3]);
    temp = temp*RotateAxis{i};
    if i==2
        temp = temp*mat2to1(1:3,1:3);
        temp(:,1) = temp(:,1) + mat2to1(4,1);
        temp(:,2) = temp(:,2) + mat2to1(4,2);
        temp(:,3) = temp(:,3) + mat2to1(4,3);
    elseif i==3
        temp = temp*mat3to2(1:3,1:3);
        temp = temp*mat2to1(1:3,1:3);
        temp(:,1) = temp(:,1) + mat2to1(4,1) + mat3to2(4,1);
        temp(:,2) = temp(:,2) + mat2to1(4,2) + mat3to2(4,2);
        temp(:,3) = temp(:,3) + mat2to1(4,3) + mat3to2(4,3);
	end

	walkings{i} = reshape(temp,walking_size);
    
	walkings{i}(to_remove,:,:) = [];
	inferred_vector{i}(to_remove,:) = [] ;
	
%     if i > 1
%         translation_vec = find_translation(squeeze(walkings{i-1}(:,26,:)), squeeze(walkings{i}(:,26,:)));
%         myvec_repmat = repmat(translation_vec,[size(walkings{i},1) 26 1]);
%         add_temp = reshape(myvec_repmat,size(walkings{i}));
%         walkings{i} = walkings{i} - add_temp;
%     end
    
	fileID = fopen([directory, '/meta.txt'],'r');
	formatSpec = '%f';
	timestamps{i} = fscanf(fileID,formatSpec) ;
	timestamps{i} = [timestamps{i}(1); timestamps{i}(2:2:end)]	; % Related to the way meta.txt is organized. Don't mind that. 
	timestamps{i} = (10^(-6))*timestamps{i} ; % Now the units are seconds. 
	
	end_times{i} = timestamps{i}(end) ; 
	
	timestamps{i} = timestamps{i}((start_index+2):(end_index+2)) ;
	timestamps{i}(to_remove) = [] ;
	
end

[walking_merged, walking_parts_before_cut, walking_parts_after_cut, sample_times, sample_times_parts_before_cut, sample_times_parts_after_cut] = ...
    Kinects_merge_with_cut(walkings, inferred_vector, timestamps, end_times, new_A, new_B, new_C, new_D) ; 

%%
figure;
temp1 = squeeze(walkings{1}(:,skeleton.CM,:));
temp2 = squeeze(walkings{2}(:,skeleton.CM,:));
temp3 = squeeze(walkings{3}(:,skeleton.CM,:));
temp4 = squeeze(walking_merged(:,skeleton.CM,:));
temp4 = temp4 + repmat([2 2 2], size(temp4,1),1);

hold on;
scatter3(temp1(:,1),temp1(:,2),temp1(:,3));
scatter3(temp2(:,1),temp2(:,2),temp2(:,3));
scatter3(temp3(:,1),temp3(:,2),temp3(:,3));
scatter3(temp4(:,1),temp4(:,2),temp4(:,3));
xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]');