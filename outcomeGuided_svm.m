%% simpleMKL MultiClass - Simulated datasets

clear all
close all
clc

cd      '~/Documents/combining-PSMs/simpleMKL'
 
addpath '~/Documents/MATLAB/rand-index/' % adjusted rand index
addpath '~/Documents/MATLAB/svm-km' % localized multiple kernel k-means
addpath '~/Documents/MATLAB/simpleMKL-github' % simpleMKL toolbox (GitHub version from Maxis1718)
% addpath '~/Documents/MATLAB/silhouette'

%% Load data

load('~/Documents/combining-PSMs/simulations/PSMs_simulatedData_trainingTest_permuted.mat')

%% Response

menouno = -ones(n*1.5,1);
uno = ones(n*1.5,1); 
ybin = vertcat(menouno, uno);

uno = ones(n/2,1);
due = ones(n/2,1)*2;
tre = ones(n/2,1)*3;
qua = ones(n/2,1)*4;
cin = ones(n/2,1)*5;
sei = ones(n/2,1)*6;
y = vertcat(uno, due, tre, qua, cin, sei);

%%  Initalize parameters of the algorithm 
% Parameters are similar to those used for mklsvm

C = 100;
lambda = 1e-7;
verbose = 1;
nbclass = 6;
options.algo='oneagainstall';
options.seuildiffsigma=1e-4;
options.seuildiffconstraint=0.1;
options.seuildualitygap=1e-2;
options.goldensearch_deltmax=1e-1;
options.numericalprecision=1e-8;
options.stopvariation=1;
options.stopKKT=0;
options.stopdualitygap=1;
options.firstbasevariable='first';
options.nbitermax=500;
options.seuil=0.;
options.seuilitermax=10;
options.lambdareg = 1e-6;
options.miniter=0;
options.verbosesvm=0;
options.efficientkernel=0;

%%  Train + test

n_subsets_w = 4; % number of different subsets of simulated datasets 
n_datasets  = 2; % number of simulated datasets in each subset
subsets_w = [2,2; 3,3; 4,4; 5,5]; % subsets of simulated datasets
n_class = 6; % number of classes

bc_OAA = zeros(n_experiments, n_subsets_w);
bc_OAO = zeros(n_experiments, n_subsets_w);
n_sv   = zeros(n_experiments, n_subsets_w);

for i = 1:n_experiments
    for j = 1:n_subsets_w
        
        ws = subsets_w(j,:);
        
        psm_training_ij = reshape(psm_training(:,:,i,ws),[n*3,n*3,2]);
        [beta,w,w0,pos,nbsv,~,~] = mklmulticlass(psm_training_ij,y,C,n_class,options,verbose);
        
        psm_test_ij = reshape(psm_test(:,:,i,ws),[n*3,n*3,2]);
        weighted_psm_test_ij = beta(1)*psm_test_ij(:,pos,1) + beta(2)*psm_test_ij(:,pos,2);
       
        kernel='numerical';
        kerneloption.matrix = weighted_psm_test_ij;
        if options.algo == 'oneagainstall'
            [ypred_OAA,~] = svmmultival([],[],w,w0,nbsv,kernel,kerneloption);
            bc_OAA(i,j) = mean(ypred_OAA == y);
        elseif options.algo == 'oneagainstone'
            [ypred_OAO,~] = svmmultivaloneagainstone([],[],w,w0,nbsv,kernel,kerneloption);
             bc_OAO(i,j) = mean(ypred_OAO == y);
        end
        
        n_sv(i,j) = length(pos);
    end
end

%% Generate density matrix for misclassification rate

nPts = 1000;
densMatr_misclass_OAA = zeros(nPts,4);
densMatr_misclass_OAO = zeros(nPts,4);
gridPts = linspace(0, 1, nPts);

for j = 1:4
    if options.algo == 'oneagainstall'
        [f_OAA,~] = ksdensity(1-bc_OAA(:,j),gridPts);
        densMatr_misclass_OAA(:,j) = f_OAA;
        save('~/Documents/combining-PSMs/densityMatrix_SVMusingSimpleMKL_multiclass_misclassOAA_permuted.mat', 'densMatr_misclass_OAA')
    elseif options.algo == 'oneagainstone'    
        [f_OAO,~] = ksdensity(1-bc_OAO(:,j),gridPts);
        densMatr_misclass_OAO(:,j) = f_OAO;
        save('~/Documents/combining-PSMs/densityMatrix_SVMusingSimpleMKL_multiclass_misclassOAO_permuted.mat', 'densMatr_misclass_OAO')

    end
end

%% Plot correct classification rate

figure; 
if options.algo == 'oneagainstall'
    imagesc(bc_OAA); colorbar
elseif options.algo == 'oneagainstone'
    imagesc(bc_OAO); colorbar
end

%% Plot (total) number of support vectors

figure; imagesc(n_sv); colorbar 
print('num_supp_vec_permuted','-dpng')