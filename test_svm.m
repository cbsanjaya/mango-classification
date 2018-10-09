% load data_training
load('data_training.mat');

% training
SVMModel = svmtrain(ciri_database, ciri_mapping);

% test
ciri_hasil = svmclassify(SVMModel, ciri_database);

cMat = confusionmat(ciri_mapping, ciri_hasil);
tp = cMat(1,1);
fp = cMat(2,1);
fn = cMat(1,2);
tn= cMat(2,2);

accuration = (((tp + tn ) / (tp + tn + fp + fn )) * 100);
presition = ((tp / (fp + tp)) * 100);
recall = ((tp / (fn + tp)) * 100);
