% Function FrequencyStatistics receives a skeleton vector and skeleton paris 
% and returns the frequency of their difference.

% Inputs: skeleton_vec - a matrix of dimensions NumofPointsXNumSkeletonPartsX3, containing all skeleton points.
%         sample_times - a vector of length NumofPoints containing the time of each sample (in seconds)
%         skeleton_pairs - a matrix of dimensions 2XNumofPoints conatining two skeleton parts between which a difference is calculated.
%         plot_flag - 1 if we want to plot

% Outputs:  statistics - a structure with the following fields:
%             Frequency - The frequency of walking calculated from the difference vector.
%           frequency_vector - vector of DFT frequencies, length is NumofPoints.
%           DFT_vectors - a matrix of size NumofPointsX3, each column is the DFT of a specific coordinate VS time. 
  


function [ DFT_vectors, frequency_vector, statistics] = FrequencyStatistics( skeleton_vec, sample_times, skeleton_pairs, plot_flag )

% Projecting on floor - ALWAYS 
unique_skel_parts = unique(skeleton_pairs) ;
find_new_floor = 0 ; 
CorridorFloor = LoadFloor( '', find_new_floor );
for i=1:length(unique_skel_parts)
	[floor_x,floor_y,floor_z,~] = floor_project(skeleton_vec(:,unique_skel_parts(i),:),CorridorFloor(1),CorridorFloor(2),CorridorFloor(3),CorridorFloor(4), 1) ; 
	skeleton_vec(:,unique_skel_parts(i),:) = [floor_x', floor_y', floor_z] ; 
end

Difference_series = squeeze(skeleton_vec(:,skeleton_pairs(1,:),:) - skeleton_vec(:,skeleton_pairs(2,:),:)) ; 
DifferenceMeanRepmat = repmat(mean(Difference_series, 1), size(Difference_series, 1), 1);
Difference_series = Difference_series - DifferenceMeanRepmat; 

DFT_vectors = fft(Difference_series) ; 
fs = 30 ; % Hz 
frequency_vector = (0:1:(length(sample_times)-1))*(fs/length(sample_times)); 

[~,max_index] = max(abs(DFT_vectors(:,1))) ; 
statistics.Frequency = frequency_vector(max_index) ;


if plot_flag 
	close all;
	Coordinates1 = 	skeleton_vec(:,skeleton_pairs(1,:),:) ; 
	Coordinates2 = skeleton_vec(:,skeleton_pairs(2,:),:) ;
	
	figure; 
	subplot(2,1,1)
	plot(sample_times, (Difference_series(:,1)), 'LineWidth',1.7); hold on; 
	plot(sample_times, (Difference_series(:,2)), 'LineWidth',1.7);
	plot(sample_times, (Difference_series(:,3)), 'LineWidth',1.7);
	xlabel('time[sec]') ; ylabel('Coordinates[m]') ; legend('x','y','z');
	title(['Difference between body parts Vs time - skeleton part ', num2str(skeleton_pairs(1)),'-',num2str(skeleton_pairs(2))]) ; 
	
	subplot(2,1,2)
	plot(frequency_vector, abs(DFT_vectors(:,1)), 'LineWidth',1.7); hold on; 
	plot(frequency_vector, abs(DFT_vectors(:,2)), 'LineWidth',1.7);
	plot(frequency_vector, abs(DFT_vectors(:,3)), 'LineWidth',1.7);
	xlabel('frequency[Hz]') ; ylabel('DFT') ; legend('DFT_x','DFT_y','DFT_z');
	title(['DFT of Difference between body parts Vs time - skeleton parts ', num2str(skeleton_pairs(1)),'-',num2str(skeleton_pairs(2))]) ; 


end


end

