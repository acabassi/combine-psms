%% Setting A / Outcome-guided

clear all
close all
clc

cd '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/klic-psm-code'
addpath '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/SimpleMKL'
addpath '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/klic-psm-code/kernels-matlab'
addpath '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/KLIC2/KLIC-PSMs/Matlab/svm-km'

%% Initialise variables

n_experiments = 100;
n_values_w = 4;
N = 300;

%% Load PSMs

all_psms = zeros(N,N,n_experiments, n_values_w);

for experiment = 1:n_experiments
    for w = 1:n_values_w
        load(strcat('~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/klic-psm-code/kernels-matlab/experiment', int2str(experiment), '_w', int2str(w*2), '_ncov10_chain1_psm_exclude_y.mat'))
        all_psms(:,:,experiment,w) = psm;
    end
end
%% Response

uno = ones(50,1);
due = ones(50,1)*2;
tre = ones(50,1)*3;
qua = ones(50,1)*4;
cin = ones(50,1)*5;
sei = ones(50,1)*6;
y = vertcat(uno, due, tre, qua, cin, sei);

%%  Initalize parameters of the algorithm 

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

%%  Training

n_subsets_w = 4; % number of different subsets of simulated datasets 
n_datasets  = 3; % number of simulated datasets in each subset
subsets_w = [1,2,3; 1,2,4; 1,3,4; 2,3,4]; % subsets of simulated datasets
n_class = 6; % number of classes

all_betas = zeros(n_datasets, n_experiments, n_subsets_w);

for i = 1:n_experiments
    for j = 1:n_subsets_w
        
        ws = subsets_w(j,:);
        psm_training_ij = reshape(all_psms(:,:,i,ws),[N,N,n_datasets]);
        
        [beta,w,w0,pos,nbsv,~,~] = mklmulticlass(psm_training_ij,y,C,n_class,options,verbose);
        
        all_betas(:,i,j) = beta; 
        
    end
end

%% Write betas to file

save('results/settingA_outcomeguided_weights.mat', 'all_betas');
