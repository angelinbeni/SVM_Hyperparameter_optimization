function [err,svmModel]= fitness_fun(p)
global  traindata trainlabel valdata vallabela

kernel = {'gaussian', 'polynomial','linear'};
op1=kernel{round(p(1))};
kernelScale =  round(p(2));
boxx = round(p(3));

svmModel = fitcsvm(traindata, trainlabel, ...
        'BoxConstraint', boxx, ...
        'KernelFunction', op1, ...
        'KernelScale', kernelScale, ...
        'Standardize', true);
    out=predict(svmModel,valdata);
    accuracy=length(find(out==vallabela))/length(vallabela);
err=1-accuracy;
end