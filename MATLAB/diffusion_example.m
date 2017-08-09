% Example code for diffusion maps (diffuse.m)
% Instruction (Written by Or) - 
% 1. Load the wanted Data type (explanation there). 
% 2. Choose appropriate eps_val - small values means initial pair-distances are small, and it takes large t values for points to get closer. 
%                                 It depends on the data, but usually eps_val < 50 will cause NaN values. pick values of 100-500. 
% 3. Choose t_max - the first loop will play the points in the first 2 (or 3) dimensions, from t=1 to t_max. 
%                   the higher t is, the closer the points get. 
% 4. Play higher dimensions - the lower loop can play the first dimension with a higher one. 

%--------------------------------------------------------------------
% LOAD DATA
%--------------------------------------------------------------------
clear variables;
close('all');  % close all figures
clc;

parameters = 1;
plot3d = 0;

%%%%%%%INSERT HERE iNPUT PREPROCESSING%%%%%%%%%%%%%%
% Data - Ors CM. 
% Data_xy - Ors CM with only (x,y) coordinates. 
% Or_all - Ors whole body. 
% guy_all - guys whole body.

LoadMat = load('GuyDragsCM_int.mat');
fn = fieldnames(LoadMat);
Data = LoadMat.(fn{1}) ; 
group_lengths = LoadMat.lengths;
SkelPoints = LoadMat.SkelPoints;
n_groups = length(group_lengths);

groups_acc = cumsum(group_lengths);

[n,p]=size(Data); % Data(n,p), where n=#observations, p=#variables

if parameters == 1
    D = squareform(pdist(Data)); % pairwise distances, n-by-n matrix
else
    D = squareform(pdist(Data));
end
%%
%--------------------------------------------------------------------
% SET PARAMETERS IN MODEL
%--------------------------------------------------------------------

eps_val=100;
neigen=6;
flag_t=1; %flag_t=0 => Default: multi-scale geometry
if flag_t
    t=1;  % fixed time scale
end

%--------------------------------------------------------------------
% EIGENDECOMPOSITION
%--------------------------------------------------------------------
% Call function "diffuse.m" - play two dimensions (Or three using scatter3). 
% q = figure; 
t_max = 3 ; 
colors = {'blue', 'red', 'black', 'green'};
signs = {'o', '+', 'x', '*'};

h = cell(1,groups_acc(end));
text_cells = cell(1,groups_acc(end));

for t=1:t_max 

	[X, eigenvals, psi, phi] = diffuse(D,eps_val,neigen,t);

    for k = 1:groups_acc(end);
        group = find ( groups_acc >= k, 1);
        if plot3d == 1
            h{i} = scatter3(X(i,1), X(i,2),X(i,3),signs{group},'MarkerEdgeColor',colors{group}); hold on;
        else
            h{k} = plot(X(k,1), X(k,2),signs{group},'color',colors{group}); hold on;
        end
        
 %         text_cells{k} = text(X(k,1), X(k,2),num2str(k),'HorizontalAlignment','right');
	end
	 
	if t==1 
		x_min = min(X(:,1)) ; x_max = max(X(:,1)) ; y_min = min(X(:,2)) ; y_max = max(X(:,2)) ; z_min = min(X(:,3)) ; z_max = max(X(:,3)) ;
	end
% 	axis([1.1*x_min, 1.1*x_max,1.1*y_min, 1.1*y_max]) ; %close(h);
    %axis([-0.05 0.05 -0.05 0.05]);
	axis([1.1*x_min, 1.1*x_max, 1.1*y_min, 1.1*y_max, 1.1*z_min, 1.1*z_max]) ; 
    title(['t = ' num2str(t)]);
	pause(1);
    
	if t~=t_max
		for k=1:groups_acc(end)
			delete(h{k}) ; 
            delete(text_cells{k}) ;
		end
	end
	
end

% figure;
% stem(1:length(eigenvals),eigenvals)
% xlim([0 length(eigenvals)+1]);
% for k = 1:length(eigenvals)
%     text(k , eigenvals(k)+0.05, num2str(eigenvals(k)));
% end

% Play higher dimensions. 
if 0
	figure; 
	t_max = 10;
	eigen_number = 3 ; 
	for t=1:t_max 

		[X, eigenvals, psi, phi] = diffuse(D,eps_val,neigen,t);
		%h=figure; 
		for i=1:3 
			h{i} = plot(X(i,1), X(i,eigen_number),'o','color','blue'); hold on;
		end
		for i=4:6 
			h{i} = plot(X(i,1), X(i,eigen_number),'o','color','r'); hold on;
		end
		for i=7:9 
			h{i} = plot(X(i,1), X(i,eigen_number),'o','color','black'); hold on;
		end
		 
		if t==1 
			x_min = min(X(:,1)) ; x_max = max(X(:,1)) ; z_min = min(X(:,eigen_number)) ; z_max = max(X(:,eigen_number)) ; 
		end
		axis([x_min, x_max,z_min, z_max]) ; %close(h);
		pause(0.2) ; 
		
		if t~=t_max
			for i=1:9
				delete(h{i}) ; 
			end
		end
		
	end

end