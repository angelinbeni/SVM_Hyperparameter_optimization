% visit - www.spaerix.com
% contact spaerixinfotech@gmail.com
% clear the environment
clc;clear;close all;
global  traindata trainlabel valdata vallabela
%% Load dataset - ionoshpere
load ionosphere
dataX = X;                              % data
dataY = categorical(Y);                 % label
%% partition data into training,testing and validation
% 70%-training, 10% -validation, 20%- testing
[trainInd,valInd,testInd] = dividerand(numel(dataY),0.7,0.1,0.2);
%% training data & label
traindata = dataX(trainInd,:);
trainlabel= dataY(trainInd,:);
%% validation data & label
valdata  = dataX(valInd,:);
vallabela= dataY(valInd,:);
%% testing data & label
testdata  = dataX(testInd,:);
testlabel = dataY(testInd,:);
%% optimise hyper-parameter
N=3;                                   % Number of search agents
T=10;                                   % Maximum number of iterations
fobj=@fitness_fun;                      % Name of the objective function
lb = [ 1 1 2 ];                         % lower bound
ub = [ 3 30 3 ];                        % upper bound
dim=3;
[SVM_model,best_parameter,CNVG]=SVM_HHO(N,T,lb,ub,dim,fobj);
%% predict the output of test data
out=predict(SVM_model,testdata);        % predict the output
accuracy=length(find(out==testlabel))/length(testlabel);
fprintf('Accuracy of HHO optimised SVM is %d\n',accuracy)
%% plot convergence curve
figure;
plot(CNVG,'-ob','linewidth',2)
xlabel('Iterations');ylabel('objective value')
