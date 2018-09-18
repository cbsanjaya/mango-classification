% add lssvm to path
lssvmPath = strcat(pwd, '\lssvm');
addpath(lssvmPath);

% type of lssvm is classification
type = 'classification';

% load data_training
load('data_training.mat');

L_fold = 10;
[gam,sig2] = tunelssvm({ciri_database, ciri_mapping, type, [], [], 'RBF_kernel'}, 'simplex', 'crossvalidatelssvm', {L_fold, 'misclass'});

[alpha,b] = trainlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'});

% test Xt
ciri_hasil = simlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'}, {alpha, b}, ciri_database);

% plot classification
% plotlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'}, {alpha, b});

% Y_latent = latentlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'}, {alpha, b}, ciri_database);
% [area,se,thresholds,oneMinusSpec,Sens]=roc(Y_latent, ciri_mapping);

cMat = confusionmat(ciri_mapping, ciri_hasil);
tp = cMat(1,1);
fp = cMat(2,1);
fn = cMat(1,2);
tn= cMat(2,2);

accuration = (((tp + tn ) / (tp + tn + fp + fn )) * 100);
presition = ((tp / (fp + tp)) * 100);
recall = ((tp / (fn + tp)) * 100);
