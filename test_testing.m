% add lssvm to path
lssvmPath = strcat(pwd, '..\lssvm');
addpath(lssvmPath);

% type of lssvm is classification
type = 'classification';

% load data_training
load('db_training.mat');

%L_fold = 10;
%[gam,sig2] = tunelssvm({X, Y, type, [], [], 'RBF_kernel'}, 'simplex', 'crossvalidatelssvm', {L_fold, 'misclass'});
gam = 12.6361;
sig2 = 1.3253;
 
[alpha,b] = trainlssvm({X, Y, type, gam, sig2, 'RBF_kernel'});

% load data_testing
load('db_testing.mat');

% test Xt to Yresult
YResult = simlssvm({X, Y, type, gam, sig2, 'RBF_kernel'}, {alpha, b}, Xt);

% plot classification
% plotlssvm({X, Y, type, gam, sig2, 'RBF_kernel'}, {alpha, b});

% Y_latent = latentlssvm({X, Y, type, gam, sig2, 'RBF_kernel'}, {alpha, b}, X);
% [area,se,thresholds,oneMinusSpec,Sens]=roc(Y_latent, Y);

cMat = confusionmat(Yt, YResult);
tp = cMat(1,1);
fp = cMat(2,1);
fn = cMat(1,2);
tn= cMat(2,2);

accuration = (((tp + tn ) / (tp + tn + fp + fn )) * 100);
presition = ((tp / (fp + tp)) * 100);
recall = ((tp / (fn + tp)) * 100);
