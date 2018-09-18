% add lssvm to path
lssvmPath = strcat(pwd, '\lssvm');
addpath(lssvmPath);

% type of lssvm is classification
type = 'classification';

% X is dataset
X = 2.*rand(100,2)-1;

% Y is Result
Y = sign(sin(X(:,1))+X(:,2));

% set gamma and sig2
gam = 10;
sig2 = 0.4;

% train dataset
[alpha,b] = trainlssvm({X,Y,type,gam,sig2,'RBF_kernel'});

% Xt is data testing
Xt = 2.*rand(10,2)-1;

% test Xt
Ytest = simlssvm({X,Y,type,gam,sig2,'RBF_kernel'},{alpha,b},Xt);

% plot classification
plotlssvm({X,Y,type,gam,sig2,'RBF_kernel'},{alpha,b});


