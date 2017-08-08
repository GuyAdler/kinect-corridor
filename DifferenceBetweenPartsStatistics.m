% Function DifferenceBetweenPartsStatistics receives a skeleton vector and returns the Difference between wanted body parts. 

% Inputs: skeleton_vec - a matrix of dimensions NumofPointsXNumSkeletonPartsX3, containing all skeleton points.
%         sample_times - a vector of length NumofPoints containing the time of each sample (in seconds)
%         skeleton_parts - a matrix of dimensions 2XNumofDifferences containing the skeleton parts.
%                          Each column represents two body parts whos difference is wanted. 
%         plot_flag - 1 if we want to plot
%         project_flag - 1 if we want to output velocities in floor coordinates

% Outputs:  statistics - a structure with the following fields:
%             MeanDistance - a vector of length size(skeleton_parts, 2) containing the mean distance between body parts. 
%             VarDistance - a vector of length size(skeleton_parts, 2) containing the variance of distance between body parts.
%             MeanDistanceVec - a vector of length size(skeleton_parts, 2)X3 containing the mean distance between body parts, for each axis. 
%             MeanDifferenceVec - a vector of length size(skeleton_parts, 2)X3 containing the mean of difference between body parts, for each axis.
%             VarDistanceVec - a vector of length size(skeleton_parts, 2)X3 containing the variance of distance between body parts, for each axis.

function [ statistics] = DifferenceBetweenPartsStatistics( skeleton_vec, sample_times, skeleton_parts, plot_flag, project_flag )
% Projecting on floor 
if project_flag 
	unique_skel_parts = unique(skeleton_parts) ;
	find_new_floor = 0 ; 
	CorridorFloor = LoadFloor( '', find_new_floor );
	for i=1:length(unique_skel_parts)
		[floor_x,floor_y,floor_z,~] = floor_project(skeleton_vec(:,unique_skel_parts(i),:),CorridorFloor(1),CorridorFloor(2),CorridorFloor(3),CorridorFloor(4), 0) ; 
		skeleton_vec(:,unique_skel_parts(i),:) = [floor_x', floor_y', floor_z] ; 
	end
end

for i=1:size(skeleton_parts, 2)
	Distance_series = distance(squeeze(skeleton_vec(:,skeleton_parts(1,i),:)), squeeze(skeleton_vec(:,skeleton_parts(2,i),:))) ; 
	statistics.MeanDistance(i) = mean(Distance_series);
	statistics.VarDistance(i) = std(Distance_series);
end

Difference_series = skeleton_vec(:,skeleton_parts(1,:),:) - skeleton_vec(:,skeleton_parts(2,:),:) ; 

statistics.MeanDifferenceVec = squeeze(mean(Difference_series, 1)) ; 
statistics.MeanDistanceVec = squeeze(mean((Difference_series).^2, 1)) ; 
statistics.VarDistanceVec = squeeze(std((Difference_series).^2, 0, 1)) ;

if plot_flag 
	close all;
	Coordinates1 = skeleton_vec(:,skeleton_parts(1,:),:) ; 
	Coordinates2 = skeleton_vec(:,skeleton_parts(2,:),:) ;
	for i=1:size(skeleton_parts, 2)
		figure; 
		subplot(3,1,1)
		plot(sample_times, squeeze(Coordinates1(:,i,1)), 'LineWidth',1.5, 'color', [0,113,188]/301); hold on; 
		plot(sample_times, squeeze(Coordinates2(:,i,1)), '--', 'LineWidth',1.5, 'color', [0,113,188]/301);
		plot(sample_times, squeeze(Coordinates1(:,i,2)), 'LineWidth',1.5, 'color', [216,82,24]/322);
		plot(sample_times, squeeze(Coordinates2(:,i,2)), '--', 'LineWidth',1.5, 'color', [216,82,24]/322);
		plot(sample_times, squeeze(Coordinates1(:,i,3)), 'LineWidth',1.5, 'color', [236,176,31]/443);
		plot(sample_times, squeeze(Coordinates2(:,i,3)), '--', 'LineWidth',1.5, 'color', [236,176,31]/443);
		xlabel('time[sec]') ; ylabel('Coordinates[m]') ; legend('x1','x2','y1','y2','z1','z2');
		title(['Body parts Vs time - skeleton parts ', num2str(skeleton_parts(1,i)), ' and ', num2str(skeleton_parts(2,i))]) ;
		
		subplot(3,1,2)
		plot(sample_times, squeeze(Difference_series(:,i,1)), 'LineWidth',1.7); hold on; 
		plot(sample_times, squeeze(Difference_series(:,i,2)), 'LineWidth',1.7);
		plot(sample_times, squeeze(Difference_series(:,i,3)), 'LineWidth',1.7);
		xlabel('time[sec]') ; ylabel('Coordinates[m]') ; legend('x','y','z');
		title(['Difference between body parts Vs time - skeleton part ', num2str(skeleton_parts(1,i)),'-',num2str(skeleton_parts(2,i))]) ; 
		
		subplot(3,1,3)
		plot(sample_times, (squeeze(Difference_series(:,i,1))).^2, 'LineWidth',1.7); hold on; 
		plot(sample_times, (squeeze(Difference_series(:,i,2))).^2, 'LineWidth',1.7);
		plot(sample_times, (squeeze(Difference_series(:,i,3))).^2, 'LineWidth',1.7);
		xlabel('time[sec]') ; ylabel('Squared Coordinates[m^2]') ; legend('x','y','z');
		title(['Squared Difference between body parts Vs time - skeleton part ', num2str(skeleton_parts(1,i)),'-',num2str(skeleton_parts(2,i))]) ;

	end

end


end

