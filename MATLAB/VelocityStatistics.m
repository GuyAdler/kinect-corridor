% Function VelocityStatistics receives a skeleton vector and returns the velocity Vs time. 

% Inputs: skeleton_vec - a matrix of dimensions NumofPointsXNumSkeletonPartsX3, containing all skeleton points.
%         sample_times - a vector of length NumofPoints containing the time of each sample (in seconds)
%         skeleton_parts - a vector conatining the numbers of skeleton parts whose velocities we want to estimate. 
%         plot_flag - 1 if we want to plot
%         project_flag - 1 if we want to output velocities in floor coordinates

% Outputs:  velocity - a matrix of dimensions (NumofPoints-1)Xlength(skeleton_parts)X3 of the velocity at each point in time. 
%           velocity_times - a vector of length (NumofPoints-1) containing the time for each v(t). This is (t(n)+t(n-1))/2. 
%           statistics - a structure where each field is vector of length length(skeleton_parts)X3 containing the average statistics of velocities.


function [ velocity, velocity_times, statistics ] = VelocityStatistics( skeleton_vec, sample_times, skeleton_parts, plot_flag, project_flag )

% Projecting on floor 
if project_flag 
	find_new_floor = 0 ; 
	CorridorFloor = LoadFloor( '', find_new_floor );
	for i=1:length(skeleton_parts)
		[floor_x,floor_y,floor_z,~] = floor_project(skeleton_vec(:,skeleton_parts(i),:),CorridorFloor(1),CorridorFloor(2),CorridorFloor(3),CorridorFloor(4), 1) ; 
		skeleton_vec(:,skeleton_parts(i),:) = [floor_x', floor_y', floor_z] ; 
	end
end

velocity_times = (sample_times(2:end) + sample_times(1:(end-1)))/2 ; 
sample_times_rep = repmat(sample_times', 1, length(skeleton_parts), 3) ; 
velocity = (skeleton_vec(2:end, skeleton_parts, :) - skeleton_vec(1:(end-1), skeleton_parts, :))./(sample_times_rep(2:end,:,:) - sample_times_rep(1:(end-1),:,:)) ; 
statistics.avg_velocity = squeeze(mean(velocity, 1)) ;
statistics.avg_abs_velocity = squeeze(mean(abs(velocity), 1)) ;
statistics.std_velocity = squeeze(std((velocity), 0, 1)) ;

if plot_flag 
	close all; 
	for i=1:length(skeleton_parts)
		figure; 
		subplot(3,1,1)
		plot(sample_times, skeleton_vec(:,skeleton_parts(i),1), 'LineWidth',1.7); hold on; 
		plot(sample_times, skeleton_vec(:,skeleton_parts(i),2), 'LineWidth',1.7);
		plot(sample_times, skeleton_vec(:,skeleton_parts(i),3), 'LineWidth',1.7);
		xlabel('time[sec]') ; ylabel('Coordinates[m]') ; legend('x','y','z');
		title(['Coordinates of walking Vs time - ', skeleton.Names(skeleton_parts(i))]) ; 
		
		subplot(3,1,2)
		plot(velocity_times', squeeze(velocity(:,i,1)), 'LineWidth',1.7); hold on; 
		plot(velocity_times', squeeze(velocity(:,i,2)), 'LineWidth',1.7);
		plot(velocity_times', squeeze(velocity(:,i,3)), 'LineWidth',1.7);
		xlabel('time[sec]') ; ylabel('Velocity[m/sec]') ; legend('x','y','z');
		title(['Velocity of walking Vs time - ', skeleton.Names(skeleton_parts(i))]) ;
		
		subplot(3,1,3)
		plot(velocity_times', abs(squeeze(velocity(:,i,1))), 'LineWidth',1.7); hold on; 
		plot(velocity_times', abs(squeeze(velocity(:,i,2))), 'LineWidth',1.7);
		plot(velocity_times', abs(squeeze(velocity(:,i,3))), 'LineWidth',1.7);
		xlabel('time[sec]') ; ylabel('Velocity[m/sec]') ; legend('x','y','z');
		title(['Absolut Value of velocity of walking Vs time - ', skeleton.Names(skeleton_parts(i))]) ;
	end

end

end