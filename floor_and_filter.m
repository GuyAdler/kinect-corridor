function [floor_coordinates, filtered_floor_coordinates] = floor_and_filter(coordinates,filter_coeffs_num, A,B,C,D)

[x_floor, y_floor, z_floor, ~] = floor_project(coordinates, A, B, C, D, 0) ;
floor_coordinates = [x_floor', y_floor', z_floor] ; % timeX3 vector 

%% Filtering 

M = length(y_floor); 
theta = 0:(2*pi/M):(2*pi*floor(M/2)/M);

DFT_of_walking_floor = fft(y_floor) ; 
DFT_of_walking_z = fft(z_floor) ; 


% Filtering the DFT - y_values

[~,pass_theta_index] = max(abs(DFT_of_walking_floor(3:length(theta)))) ; % We never want the first two frequencies, it is risky... 
pass_theta = theta(pass_theta_index + 2) ; 
stop_theta = pass_theta + 0.15*pi ; 
pass_ripple = 1*10^(-03) ; 
weight = 10 ; fs = 2*pi ; f = [pass_theta,stop_theta] ; a= [1,0] ; dev = [pass_ripple, pass_ripple/weight] ;  

[N,fo,ao,w] = firpmord(f,a,dev,fs) ; 
N = floor(M/filter_coeffs_num) ; % N override
h_remez = firpm(N,fo,ao); 
[H_remez,thetot] = freqz(h_remez,1,1000) ; 


% Filtering the DFT - z_values
theta = 0:(2*pi/M):(2*pi*floor(M/2)/M);
[~,pass_theta_index] = max(abs(DFT_of_walking_z((3*2):length(theta)))) ; % We never want the first two frequencies, it is risky... 
pass_theta = theta(pass_theta_index+2*3-1) ; 
stop_theta = pass_theta + 0.1*pi ; 
f = [pass_theta,stop_theta] ; 

[N_z,fo,ao,w] = firpmord(f,a,dev,fs) ; 
N_z = floor(M/filter_coeffs_num) ; % N override
h_remez_z = firpm(N_z,fo,ao); 
[H_remez_z,thetot] = freqz(h_remez_z,1,1000) ; 

% filtering the coordinates through the filter

y_floor_filtered = filter(h_remez,1,y_floor) ;
y_floor_filtered = y_floor_filtered((N+1):end) ;
if mod(N_z,2) == 1 
	x_floor_filtered = x_floor((floor(N/2)+1):(end-floor(N/2)-1)) ;
else
	x_floor_filtered = x_floor((floor(N/2)+1):(end-floor(N/2))) ;
end

% filtering the coordinates height through the filter

z_floor_filtered = filter(h_remez_z,1,z_floor) ;
z_floor_filtered = z_floor_filtered((N_z+1):end) ;

%% Returning the filtered values 

x_floor_filtered = x_floor_filtered - min(x_floor_filtered) ; 
y_floor_filtered = y_floor_filtered - y_floor_filtered(1) ; 

filtered_floor_coordinates = [x_floor_filtered', y_floor_filtered', z_floor_filtered] ;