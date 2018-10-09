% load data_training
load('db_training.mat');

% training
SVMModel = svmtrain(X, Y);

% load data_testing
load('db_testing.mat');

% test Xt to YResult
YResult = svmclassify(SVMModel, Xt);

cMat = confusionmat(Yt, YResult);
tp = cMat(1,1);
fp = cMat(2,1);
fn = cMat(1,2);
tn= cMat(2,2);

accuration = (((tp + tn ) / (tp + tn + fp + fn )) * 100);
presition = ((tp / (fp + tp)) * 100);
recall = ((tp / (fn + tp)) * 100);
