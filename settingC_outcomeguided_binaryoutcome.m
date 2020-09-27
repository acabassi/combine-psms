%% Setting C / Outcome-guided

clear all
close all
clc

cd '/home/ac2051/rds/hpc-work/klic-psm-code'
addpath '/home/ac2051/rds/hpc-work/klic-psm-code/SimpleMKL'
addpath '/home/ac2051/rds/hpc-work/klic-psm-code/svm-km'

%% Initialise variables

n_experiments = 100;
n_values_w = 4;
N = 300;

%% Load PSMs

all_psms = zeros(N,N,n_experiments, n_values_w);

for experiment = 1:n_experiments
    for w = 1:3
        load(strcat('/home/ac2051/rds/hpc-work/klic-psm-code/kernels-matlab/binary-outcome/experiment', int2str(experiment), '_w', int2str(w*2), '_ncov10_chain1_psm_exclude_y.mat'))
        all_psms(:,:,experiment,w) = psm;
    end
    w=4;
    load(strcat('/home/ac2051/rds/hpc-work/klic-psm-code/kernels-matlab/binary-outcome/experiment', int2str(experiment), '_w', int2str(w*2), '_ncov10_chain1_psm_exclude_y_permuted.mat'))
    all_psms(:,:,experiment,w) = psm;
end

%% Response

y = binary_outcome*2-1;

% menouno = ones(150,1)*(-1);
% piuuno = ones(150,1);
% y = vertcat(menouno, piuuno);

%%  Initalize parameters of the algorithm 

C = [100];
verbose=1;

options.algo='svmclass'; % Choice of algorithm in mklsvm can be either
                         % 'svmclass' or 'svmreg'
%------------------------------------------------------
% choosing the stopping criterion
%------------------------------------------------------
options.stopvariation=0; % use variation of weights for stopping criterion 
options.stopKKT=0;       % set to 1 if you use KKTcondition for stopping criterion    
options.stopdualitygap=1; % set to 1 for using duality gap for stopping criterion

%------------------------------------------------------
% choosing the stopping criterion value
%------------------------------------------------------
options.seuildiffsigma=1e-2;        % stopping criterion for weight variation 
options.seuildiffconstraint=0.1;    % stopping criterion for KKT
options.seuildualitygap=0.01;       % stopping criterion for duality gap

%------------------------------------------------------
% Setting some numerical parameters 
%------------------------------------------------------
options.goldensearch_deltmax=1e-1; % initial precision of golden section search
options.numericalprecision=1e-8;   % numerical precision weights below this value
                                   % are set to zero 
options.lambdareg = 1e-8;          % ridge added to kernel matrix 

%------------------------------------------------------
% some algorithms paramaters
%------------------------------------------------------
options.firstbasevariable='first'; % tie breaking method for choosing the base 
                                   % variable in the reduced gradient method 
options.nbitermax=500;             % maximal number of iteration  
options.seuil=0;                   % forcing to zero weights lower than this 
options.seuilitermax=10;           % value, for iterations lower than this one 

options.miniter=0;                 % minimal number of iterations 
options.verbosesvm=0;              % verbosity of inner svm algorithm 

%
% Note: set 1 would raise the `strrep`
%       error in vectorize.dll
%       and this error is not able to fix
%       because of the missing .h libraay files
% Modify: MaxisKao @ Sep. 4 2014
options.efficientkernel=0;         % use efficient storage of kernels 

%%  Training

n_subsets_w = 4; % number of different subsets of simulated datasets 
n_datasets  = 3; % number of simulated datasets in each subset
subsets_w = [1,2,3; 1,2,4; 1,3,4; 2,3,4]; % subsets of simulated datasets

all_betas = zeros(n_datasets, n_experiments, n_subsets_w);

for i = 1:n_experiments
    for j = 1:n_subsets_w
        
        ws = subsets_w(j,:);
        psm_training_ij = reshape(all_psms(:,:,i,ws),[N,N,n_datasets]);
        
        [beta,~,~,~,~,~] = mklsvm(psm_training_ij,y,C,options,verbose);
          
        all_betas(:,i,j) = beta; 
        
    end
end

%% Write betas to file

save('results/binary-outcome/settingC_outcomeguided_weights.mat', 'all_betas');
