function result=dTreeBenchmark()
    load('spam.mat'); % loads Xtrain, ytrain, Xtest into the workspace
    num_samples = length(ytrain);
    ytrain = double(ytrain);
    XtrainWithLabels = horzcat(Xtrain,ytrain); % combine the labels with the samples, with labels at last column
    num_folds = 10;
    fold_size = floor(num_samples / num_folds);
    accuracies = zeros(num_folds,1);
    perm = randperm(num_samples);
    XtrainWithLabels = XtrainWithLabels(perm,:);
    for depth=1:40
        for f=1:fold_size:num_samples
            test_upperbound = min(f+fold_size-1, num_samples);
            xtest = XtrainWithLabels(f:test_upperbound,:);
            xtrain_fold = [XtrainWithLabels(1:f-1,:); XtrainWithLabels(test_upperbound+1:num_samples,:)];
            dtree = dTree(xtrain_fold, depth);
            accuracy = predictor(xtest, dtree);
            accuracies(floor(f/fold_size)+1) = accuracy;
            %break; %comment this out to get the result for all 10 folds.
        end
        performance=mean(accuracies);
        fprintf(' --- Accuracy with depth %d: %f\n', depth, performance);
    end
    
function accuracy=predictor(XtestWithLabels, dtree)
    numSamples = size(XtestWithLabels,1);
    numFeatures = size(XtestWithLabels,2)-1;
    numError = 0;
    for i=1:numSamples
       ourLabel = spamOrHam(XtestWithLabels(i,:), dtree);
       actualLabel = XtestWithLabels(i,numFeatures+1);
       if ourLabel ~= actualLabel
            numError = numError + 1;
       end
    end
    accuracy = (numSamples-numError)/numSamples;
    