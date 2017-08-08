%Function parameters_estimation_specific - Estimates parameters for a specific body part. 

% INPUTS: coordinates - the specific body parts' coordinates, a matrix timeX3 of coordinates, rows are different times. 
%                       This is one of the skeleton points, could be CM, ankles and so on. 
%         directory - the directory where the data is at. 
%         name_str - a string with the name of the skeleton part. For instance - 'Center Of Mass' .

function [T, avg_height, avg_speed] = parameters_estimation_specific(coordinates, directory, name_str)


%% Find the center of mass
% calculate the average direction of movement
%CM = squeeze(walking(:,skeleton.CM,:));
i = 1:(size(coordinates,1)-1);
diff_avg = mean(coordinates(i+1,:) - coordinates(i,:));
mean_line = repmat(mean(coordinates)',1,length(i)) + ((i-mean(i))'*diff_avg)';

% Load floor and change it to the right direction.

% Floor given. 
floor_vec = loadfloor(directory);
A = floor_vec(1); B = floor_vec(2); C = floor_vec(3); D = floor_vec(4);

% Preffered values - Use this when the camera is set. No need to calculate new values for each run. 
new_A = -0.0183;
new_B = 0.8722;
new_C = -0.4888;
new_D = 2.1563;

% Calculation of the right floor using the time sequence of one of the skeleton parts. Should be done only once when the camera
% has been moved. 

%angle_of_rotation = Find_floor_rotation_angle(A,B,C,D,coordinates, 'Center of Mass'); 
%[new_A, new_B, new_C, new_D] = fix_floor(A,B,C,D, angle_of_rotation, diff_avg/norm(diff_avg)) ;

%Overriding the given floor. 
A = new_A ; 
B = new_B ; 
C = new_C ; 
D = new_D ;  

%%%%%%%%%%%%%%%%%%%%%%%%%%% Transformations and Graphs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Plot the coordinates with the average direction line.

figure; hold on;
scatter3(coordinates(:,1),coordinates(:,2),coordinates(:,3));
scatter3(mean_line(1,:),mean_line(2,:),mean_line(3,:));
title('Plotting Raw data'); xlabel('x'); ylabel('y'); zlabel('z'); legend('raw data','avg direction') ; 

% Projecting on the floor plane and plotting

[new_x_coordinates_floor, new_y_coordinates_floor, new_z_coordinates_floor, points_on_plane] = floor_project(coordinates, A, B, C, D) ; 
figure; subplot(2,1,1)
plot(new_x_coordinates_floor, new_y_coordinates_floor, 'o') ;
xlabel('Distance of walking[m]'); ylabel('y value') ; title(['Projection of the ',name_str,' on the floor plane'])  ;

subplot(2,1,2) 
plot(new_x_coordinates_floor, new_z_coordinates_floor, 'o', 'LineWidth', 2) ; 
xlabel('Distance of walking[m]'); ylabel('height above the floor[m]') ; title(['Height above the floor for the ',name_str])  ;

% Calculating DFT of y,z sequences. M is the number of points used to calculate the DFT.  

M = length(new_y_coordinates_floor); 
theta = 0:(2*pi/M):(2*pi*floor(M/2)/M);

DFT_of_walking_floor = fft(new_y_coordinates_floor) ; 
figure; subplot(2,1,1)
plot(theta/pi, abs(DFT_of_walking_floor(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['DFT of the ',name_str,' projection on the floor plane - M = ', num2str(M)])  ;

DFT_of_walking_z = fft(new_z_coordinates_floor) ; 
subplot(2,1,2) 
plot(theta/pi, abs(DFT_of_walking_z(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['DFT of the ',name_str,' height from the floor plane - M = ', num2str(M)])  ;

% Filtering the DFT - y_values

[~,pass_theta_index] = max(abs(DFT_of_walking_floor(3:length(theta)))) ; % We never want the first two frequencies, it is risky... 
pass_theta = theta(pass_theta_index + 2) ; 
stop_theta = pass_theta + 0.15*pi ; 
pass_ripple = 1*10^(-03) ; 
weight = 10 ; fs = 2*pi ; f = [pass_theta,stop_theta] ; a= [1,0] ; dev = [pass_ripple, pass_ripple/weight] ;  

[N,fo,ao,w] = firpmord(f,a,dev,fs) ; 
N = floor(M/3) ; % N override
h_remez = firpm(N,fo,ao); 

[H_remez,thetot] = freqz(h_remez,1,1000) ; 
figure; subplot(2,1,1)
plot(theta/pi, abs(DFT_of_walking_floor(1:length(theta))), 'LineWidth', 2 ); hold on; 
plot(thetot/pi,(abs(H_remez)),'LineWidth', 1.5); 
xlabel('theta/pi'); ylabel('Filter Amplitude Response'); title(['Remez Filter Amplitude response, N=', num2str(N)]);

% Filtering the DFT - z_values
theta = 0:(2*pi/M):(2*pi*floor(M/2)/M);
[~,pass_theta_index] = max(abs(DFT_of_walking_z((3*2):length(theta)))) ; % We never want the first two frequencies, it is risky... 
pass_theta = theta(pass_theta_index+2*3-1) ; 
stop_theta = pass_theta + 0.1*pi ; 
f = [pass_theta,stop_theta] ; 

[N_z,fo,ao,w] = firpmord(f,a,dev,fs) ; 
N_z = floor(M/3) ; % N override
h_remez_z = firpm(N_z,fo,ao); 

[H_remez_z,thetot] = freqz(h_remez_z,1,1000) ; 
subplot(2,1,2)
plot(theta/pi, abs(DFT_of_walking_z(1:length(theta))), 'LineWidth', 2 ); hold on; 
plot(thetot/pi,(abs(H_remez_z)),'LineWidth', 1.5); 
xlabel('theta/pi'); ylabel('Filter Amplitude Response'); title(['Remez Filter Amplitude response for height, N=', num2str(N_z)]);

% filtering the coordinates through the filter

new_y_coordinates_floor_filtered = filter(h_remez,1,new_y_coordinates_floor) ;
new_y_coordinates_floor_filtered = new_y_coordinates_floor_filtered((N+1):end) ;
if mod(N_z,2) == 1 
	new_x_coordinates_floor_filtered = new_x_coordinates_floor((floor(N/2)+1):(end-floor(N/2)-1)) ;
else
	new_x_coordinates_floor_filtered = new_x_coordinates_floor((floor(N/2)+1):(end-floor(N/2))) ;
end


figure; subplot(2,2,1)
plot(new_x_coordinates_floor, new_y_coordinates_floor, 'o') ;
xlabel('Distance of walking[m]'); ylabel('y value') ; title(['Projection of the ',name_str,' on the floor plane'])  ;

subplot(2,2,2)
plot(new_x_coordinates_floor_filtered, new_y_coordinates_floor_filtered, 'o') ;
xlabel('Distance of walking[m]'); ylabel('y value') ; title(['FILTERED - Projection of the ',name_str,' on the floor plane'])  ;

DFT_of_walking_floor_filtered = fft(new_y_coordinates_floor_filtered) ; 
M_filtered = length(DFT_of_walking_floor_filtered) ; 
theta = 0:(2*pi/M_filtered):(2*pi*floor(M_filtered/2)/M_filtered) ;

subplot(2,2,3)
plot(theta/pi, abs(DFT_of_walking_floor(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['DFT of the ',name_str,' projection on the floor plane - M = ', num2str(M_filtered)])  ;

subplot(2,2,4)
plot(theta/pi, abs(DFT_of_walking_floor_filtered(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['FILTERED - DFT of the ',name_str,' projection on the floor plane - M = ', num2str(M)])  ;

% filtering the coordinates height through the filter

new_z_coordinates_floor_filtered = filter(h_remez_z,1,new_z_coordinates_floor) ;
new_z_coordinates_floor_filtered = new_z_coordinates_floor_filtered((N_z+1):end) ;
if mod(N_z,2) == 1 
	new_x_coordinates_floor_filtered = new_x_coordinates_floor((floor(N_z/2)+1):(end-floor(N_z/2)-1)) ;
else
	new_x_coordinates_floor_filtered = new_x_coordinates_floor((floor(N_z/2)+1):(end-floor(N_z/2))) ;
end

figure; subplot(2,2,1)
plot(new_x_coordinates_floor, new_z_coordinates_floor, 'o', 'LineWidth', 2) ; 
xlabel('Distance of walking[m]'); ylabel('height above the floor[m]') ; title(['Height above the floor for the ',name_str])  ;

subplot(2,2,2)
plot(new_x_coordinates_floor_filtered, new_z_coordinates_floor_filtered, 'o') ;
xlabel('Distance of walking[m]'); ylabel('y value') ; title(['FILTERED - Height above the floor for the ',name_str])  ;

DFT_of_walking_z_filtered = fft(new_z_coordinates_floor_filtered) ; 
M_filtered_z = length(DFT_of_walking_z_filtered) ; 
theta = 0:(2*pi/M_filtered_z):(2*pi*floor(M_filtered_z/2)/M_filtered_z) ;

subplot(2,2,3)
plot(theta/pi, abs(DFT_of_walking_z(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['DFT of the ',name_str,' height from the floor plane - M = ', num2str(M)])  ;

subplot(2,2,4)
plot(theta/pi, abs(DFT_of_walking_z_filtered(1:length(theta))), 'LineWidth', 2 );
xlabel('theta/pi'); ylabel('DFT') ; title(['FILTERED - DFT of the ',name_str,' height from the floor plane - M = ', num2str(M_filtered_z)])  ;


%%%%%%%%%%%%%%%%%%%%%%%%%%% Parameters Estimation %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% T - Period time (in samples) using DFT estimation
M = length(new_y_coordinates_floor); 
theta = 0:(2*pi/M):(2*pi*floor(M/2)/M);
[~,theta_horizontal_index] = max(abs(DFT_of_walking_floor(3:length(theta)))) ; % could be dangerous - estimating with the max of the DFT
T_horizontal = 2*pi/theta(theta_horizontal_index+2) ; 

[~,theta_vertical_index] = max(abs(DFT_of_walking_z(2*3:length(theta)))) ; % could be dangerous - estimating with the max of the DFT
T_vertical = 2*pi/theta(theta_vertical_index+2*3-1) ;

T=[T_horizontal,T_vertical] ; 

%% avg_height - average of height of the skeleton part above the floor. units [m]

avg_height = mean(new_z_coordinates_floor) ;

%% avg_speed - units [m/s] (INCOMPLETE)

total_time = (1/30)*(length(new_x_coordinates_floor) - 1) ; % assuming no inferred points (we use it to calculate avg so it is ok if there are), 
                                                            % The sampling period is 30Hz. 
avg_speed_naive = new_x_coordinates_floor(end)/total_time ; 

%avg_dist_between_points = mean(new_x_coordinates_floor(2:end) - new_x_coordinates_floor(1:(end-1))) ; 
%avg_speed_horizontal = avg_dist_between_points*T_horizontal/

avg_speed = avg_speed_naive ; 

%% step width - INCOMPLETE

%% step length - INCOMPLETE 

