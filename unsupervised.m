%% Load PSMs

clear all
close all
clc

addpath '~/Documents/MATLAB/rand-index/' % adjusted rand index
addpath '~/mosek/8/toolbox/r2014a/'      % for lmkkmeans
addpath '~/Documents/MATLAB/lmkkmeans'   % localized multiple kernel k-means
% addpath '~/Documents/PhD/silhouette'
% addpath '~/Documents/combining-PSMs/kernel-kmeans-examples'

%% Load data

psm = zeros(300, 300, 100, 6);

for i=1:100
    for j=0:5
        w = j*0.2;
        file_name = fullfile('~/Documents/combining-PSMs/PSMsOnly/p10NoResponse', strcat('Experiment_', int2str(i)), strcat('w_',num2str(w)),'premium_output_psm.csv');  
        psm(:,:,i,j+1) = csvread(file_name);
    end
end 

%% Response

uno = ones(50,1); 
y = vertcat(uno, uno*2, uno*3, uno*4, uno*5, uno*6);

%% Plot experiment 1

experiment = randi([1 100], 1, 1);

psm1 = reshape(psm(:,:,experiment,1),[300,300]);
psm2 = reshape(psm(:,:,experiment,2),[300,300]);
psm3 = reshape(psm(:,:,experiment,3),[300,300]);
psm4 = reshape(psm(:,:,experiment,4),[300,300]);
psm5 = reshape(psm(:,:,experiment,5),[300,300]);
psm6 = reshape(psm(:,:,experiment,6),[300,300]);

figure
subplot(2,3,1)
imagesc(psm1); 
subplot(2,3,2)
imagesc(psm2);
subplot(2,3,3)
imagesc(psm3);
subplot(2,3,4)
imagesc(psm4); 
subplot(2,3,5)
imagesc(psm5);
subplot(2,3,6)
imagesc(psm6);

%% Initalize parameters of the algorithm %%

parameters = struct();
parameters.cluster_count = 6; %set the number of clusters
parameters.iteration_count = 10; %set the number of iterations %dovrebbe essere il numero di start diversi

%% Kernel k-means %%

ari_kkm = zeros(100,6);

for i = 1:100
    for j = 1:6
    
    psm_ij = reshape(psm(:,:,i,j),[300,300]);
    state = kkmeans_train(psm_ij, parameters);
    ari_kkm(i,j) = rand_index(state.clustering, y, 'adjusted');
    
    end 
end

% Histograms

figure
subplot(2,3,1)
histogram(ari_kkm(:,1)) 
subplot(2,3,2)
histogram(ari_kkm(:,2))
subplot(2,3,3)
histogram(ari_kkm(:,3))
subplot(2,3,4)
histogram(ari_kkm(:,4))
subplot(2,3,5)
histogram(ari_kkm(:,5))
subplot(2,3,6)
histogram(ari_kkm(:,6))

%% Generate density matrix

nPts = 1000;
densityMatrix = zeros(4,nPts);

gridPts       = linspace(0, 1, nPts);
for i = 2:5
    [f,xi] = ksdensity(ari_kkm(:,i),gridPts);
    densityMatrix(i,:) = f;
end

%% Plot density plots

myColors = [         
    0         0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840
    0.5       0.5       0.5
    0         0         0
    ];

ct = 1;
for i = 2:5
    plot(xi, densityMatrix(i,:), 'LineWidth', 2, 'Color', myColors(ct,:));
    ct = ct + 1;
    hold on
end

title('Kernel k-means')
xlabel('Adjusted Rand Index')
ylabel('Density')
legend('w = 0.2', 'w = 0.4', 'w = 0.6', 'w = 0.8')
set(gca, 'FontSize', 18)

%% Multiple kernel k-means %%

% NON FUNZIONA 

ari_mkkm = zeros(100,1);

for i = 1:100
    psms_experiment_i = reshape(psm(:,:,i,:), [300, 300, 6]);
    state_m = mkkmeans_train(psms_experiment_i, parameters);
    ari_mkkm(i,1) = rand_index(state_m.clustering, y, 'adjusted'); % calculate Rand index
end

figure
histogram(ari_mkkm)

mean_ari_mkkm = mean(ari_mkkm);

display(state_m.clustering); % display the clustering
plot(state_m.clustering)

display(state_m.theta); % display the kernel weights

%% Localized multiple kernel k-means %%

% INUTILE
% 
% ari_lmkkm = zeros(100,1);
% 
% for i = 1:100
%     psms_experiment_i = reshape(psm(:,:,i,:), [300, 300, 6]);
%     state_lm = lmkkmeans_train(psms_experiment_i, parameters);
%     ari_lmkkm(i,1) = rand_index(state_lm.clustering, y, 'adjusted'); % calculate Rand index
% end
% 
% figure 
% imagesc(ari_lmkkm)
% colorbar
% 
% %display(state_lm.clustering); % display the clustering
% figure
% plot(state_lm.clustering)
% 
% %display(state_lm.Theta); % display the kernel weights
% figure
% imagesc(state_lm.Theta)

%% w = [0.2 0.4 0.6 0.8]

% PER ADESSO NON SERVE

% ari_lmkkm_02to08 = zeros(100,1);
% 
% for i=1:100
%     psms_experiment_i = reshape(psm(:,:,i,2:5), [300, 300, 4]);
%     state_02to08 = lmkkmeans_train(psms_experiment_i, parameters);
%     ari_lmkkm_02to08(i,1) = rand_index(state_02to08.clustering, y, 'adjusted'); % calculate Rand index
% end
% 
% figure
% histogram(ari_lmkkm_02to08)
% 
% figure
% imagesc(state_02to08.Theta)
% colorbar

%% Sottoinsiemi di 3 

ari_lmkkm_3w = zeros(100,4);
weights_lmkkm_3w = zeros(100, 4, 300, 3);

for i=1:100
    psms_experiment_i = reshape(psm(:,:,i,2:4), [300, 300, 3]);
    state_02to06 = lmkkmeans_train(psms_experiment_i, parameters);
    ari_lmkkm_3w(i,1) = rand_index(state_02to06.clustering, y, 'adjusted'); 
    weights_lmkkm_3w(i,1,:,:) = state_02to06.Theta;

    psms_experiment_i = reshape(psm(:,:,i,[2 3 5]), [300, 300, 3]);
    state_020408 = lmkkmeans_train(psms_experiment_i, parameters);
    ari_lmkkm_3w(i,2) = rand_index(state_020408.clustering, y, 'adjusted');
    weights_lmkkm_3w(i,2,:,:) = state_020408.Theta;

    psms_experiment_i = reshape(psm(:,:,i,[2 4 5]), [300, 300, 3]);
    state_020608 = lmkkmeans_train(psms_experiment_i, parameters);
    ari_lmkkm_3w(i,3) = rand_index(state_020608.clustering, y, 'adjusted');
    weights_lmkkm_3w(i,3,:,:) = state_020608.Theta;

    psms_experiment_i = reshape(psm(:,:,i,3:5), [300,300,3]);
    state_04to08 = lmkkmeans_train(psms_experiment_i, parameters);
    ari_lmkkm_3w(i,4) = rand_index(state_04to08.clustering, y, 'adjusted'); 
    weights_lmkkm_3w(i,4,:,:) = state_04to08.Theta;
end

%% Plots

figure
subplot(2,2,1)
imagesc(state_02to06.Theta)
colorbar
title('w = [0.2 0.4 0.6]')
subplot(2,2,2)
imagesc(state_020408.Theta)
colorbar
title('w = [0.2 0.4 0.8]')
subplot(2,2,3)
imagesc(state_020608.Theta)
colorbar
title('w = [0.2 0.6 0.8]')
subplot(2,2,4)
imagesc(state_04to08.Theta)
colorbar
title('w = [0.4 0.6 0.8]')

figure
subplot(2,2,1)
histogram(ari_lmkkm_3w(:,1))
title('w = [0.2 0.4 0.6]')
subplot(2,2,2)
histogram(ari_lmkkm_3w(:,2))
title('w = [0.2 0.4 0.8]')
subplot(2,2,3)
histogram(ari_lmkkm_3w(:,3))
title('w = [0.2 0.6 0.8]')
subplot(2,2,4)
histogram(ari_lmkkm_3w(:,4))
title('w = [0.4 0.6 0.8]')

%% Create matrices for density plots

nPts = 1000;
newDensityMatrix = zeros(8,nPts);
densityMatrix_weights = zeros(4,3,nPts);

gridPts = linspace(0, 1, nPts);

for i = 1:4 % i = 1: w = 0.2; i = 2: w = 0.4; i = 3: w = 0.6; i = 4: w = 0.8
    [f,xi] = ksdensity(ari_kkm(:,i+1),gridPts);
    newDensityMatrix(i,:) = f;
end

for i = 5:8 % i = 5: w = [0.2, 0.4, 0.6]; i = 6: w = [0.2, 0.6, 0.8]; i = 7: w = [0.2, 0.4, 0.8]; i = 8: w = [0.4, 0.6, 0.8]
    [f,xi] = ksdensity(ari_lmkkm_3w(:,i-4),gridPts);
    newDensityMatrix(i,:) = f;
end

average_weight = mean(weights_lmkkm_3w, 3); 

for i = 1:4 % per ogni sottoinsieme
   for j = 1:3 % per ogni dataset appartenente al sottoinsieme
      [f, xi] = ksdensity(average_weight(:,i,1,j), gridPts);
      densityMatrix_weights(i,j,:) = f;
   end
end

%% Density plots weights

otherColors = ['magenta', 'cyan', 'blue'];

figure
subplot(2,2,1)
for j = 1:3
    plot(xi, reshape(densityMatrix_weights(1,j,:),1,[]), 'LineWidth',2)
    hold on
end
subplot(2,2,2)
for j = 1:3
    plot(xi, reshape(densityMatrix_weights(2,j,:),1,[]), 'LineWidth',2)
    hold on
end
subplot(2,2,3)
for j = 1:3
    plot(xi, reshape(densityMatrix_weights(3,j,:),1,[]), 'LineWidth',2)
    hold on
end
subplot(2,2,4)
for j = 1:3
    plot(xi, reshape(densityMatrix_weights(4,j,:),1,[]), 'LineWidth',2)
    hold on
end

%% Density plots ARI

arandi3_densityPlot = figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1)
for i = [1:3, 5]
    plot(xi, newDensityMatrix(i,:), 'LineWidth', 2, 'Color', myColors(i,:));
    hold on
end
title('w = [0.2, 0.4, 0.6]')
xlabel('Adjusted Rand Index')
ylabel('Density')
legend('w = 0.2', 'w = 0.4', 'w = 0.6', 'w = [0.2, 0.4, 0.6]')
set(gca, 'FontSize', 18)

subplot(2,2,2)
for i = [1, 2, 4, 6]
    plot(xi, newDensityMatrix(i,:), 'LineWidth', 2, 'Color', myColors(i,:));
    hold on
end
title('w = [0.2, 0.4, 0.8]')
xlabel('Adjusted Rand Index')
ylabel('Density')
legend('w = 0.2', 'w = 0.4', 'w = 0.8', 'w = [0.2, 0.4, 0.8]')
set(gca, 'FontSize', 18)

subplot(2,2,3)
for i = [1, 3, 4, 7]
    plot(xi, newDensityMatrix(i,:), 'LineWidth', 2, 'Color', myColors(i,:));
    hold on
end
title('w = [0.2, 0.6, 0.8]')
xlabel('Adjusted Rand Index')
ylabel('Density')
legend('w = 0.2', 'w = 0.6', 'w = 0.8', 'w = [0.2, 0.6, 0.8]')
set(gca, 'FontSize', 18)

subplot(2,2,4)
for i = [2, 3, 4, 8]
    plot(xi, newDensityMatrix(i,:), 'LineWidth', 2, 'Color', myColors(i,:));
    hold on
end
title('w = [0.4, 0.6, 0.8]')
xlabel('Adjusted Rand Index')
ylabel('Density')
ylim([0 40])
legend('w = 0.4', 'w = 0.6', 'w = 0.8', 'w = [0.4, 0.6, 0.8]')
set(gca, 'FontSize', 18)

% saveas(arandi3_densityPlot, 'prova.pdf')

%% Save results

save('~/Documents/combining-PSMs/newDensityMatrix.mat', 'newDensityMatrix')
save('~/Documents/combining-PSMs/densityMatrix_weights.mat', 'densityMatrix_weights')
save('~/Documents/combining-PSMs/gridPts.mat', 'gridPts')

%% Load results

addpath '~/Documents/combining-PSMs'
load('ari_lmkkm3.mat')