%% Setting A / Outcome-guided / Binary outcome

clear all
close all
clc

cd '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/klic-psm-code'
addpath '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/SimpleMKL'
addpath '~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/KLIC2/KLIC-PSMs/Matlab/svm-km'

%% Initialise variables

n_experiments = 2;
n_values_w = 4;
N = 300;

%% Load PSMs

all_psms = zeros(N,N,n_experiments, n_values_w);

for experiment = 1:n_experiments
    for w = 1:n_values_w
        load(strcat('~/OneDrive - University of Cambridge, MRC Biostatistics Unit/PHD-PROJECTS/klic-psm-code/kernels-matlab/binary-outcome/experiment', int2str(experiment), '_w', int2str(w*2), '_ncov10_chain1_psm_exclude_y.mat'))
        all_psms(:,:,experiment,w) = psm;
    end
end
%% Response

y = binary_outcome*2-1;
% menouno = ones(150,1)*(-1);
% piuuno = ones(150,1);
% y = vertcat(menouno, piuuno);

%%  Initalize parameters of the algorithm 

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

%%  Cross-validation

n_folds = 2;
indices = crossvalind('Kfold',y,n_folds);

n_subsets_w = 4; % number of different subsets of simulated datasets 
n_datasets  = 3; % number of simulated datasets in each subset
subsets_w = [2,1,3; 2,1,4; 3,1,4; 3,2,4]; % subsets of simulated datasets
c_values = [1, 10, 100, 100];
n_c_values = 4;

misclassification_rate = zeros(n_experiments, n_subsets_w, n_c_values);

for i = 1:n_experiments
    for j = 1:n_subsets_w
        ws = subsets_w(j,:);
        for l = 1:n_c_values
            C = c_values(l);
            for fold = 1:n_folds
                test = (indices == fold); 
                train = ~test;
                psm_training_ij = reshape(all_psms(train,train,i,ws),[sum(train),sum(train),n_datasets]);
                [beta,w,b,posw,~,~] = mklsvm(psm_training_ij,y(train),C,options,verbose);
                psm_test_ij=reshape(all_psms(test, posw,i,ws),[sum(test),length(posw),n_datasets]);
                weighted_kernel = zeros(sum(test), length(posw));
                for m = 1:3
                    weighted_kernel = weighted_kernel + psm_test_ij(:,:,m) * beta(m);
                end
                ypred=weighted_kernel*w+b;
                misclassification_rate(i,j,l) =  misclassification_rate(i,j,l) + (1-mean(sign(ypred)==y(test)));
            end
        end
    end
end

misclassification_rate = misclassification_rate/n_folds;

%% Get weights with optimal value of C

all_betas = zeros(n_datasets, n_experiments, n_subsets_w);

for i = 1:n_experiments
    for j = 1:n_subsets_w
         ws = subsets_w(j,:);
         c_index = find(misclassification_rate(i,j,:) == min(misclassification_rate(i,j,:)));
         C = c_values(c_index);
         C = C(1);
         psm_ij = reshape(all_psms(:,:,i,ws),[N,N,n_datasets]);
         [beta,~,~,~,~,~] = mklsvm(psm_ij,y,C,options,verbose);
         all_betas(:,i,j) = beta;
    end
end


%% Write betas to file

save('results/binary-outcome/settingA_outcomeguided_weights.mat', 'all_betas');
