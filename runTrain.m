% *** TRAINING BENCHMARK ***
% this script trains multiple models to allow optimization

tStart = tic;
for i = 1:4
    disp(append("#> model ", num2str(i)))
    
    FileMask = 'Group';
    targetSamplingRateHz = 50;
    windowLengthSeconds = 3.4;
    
    trainDataDirectory = "TrainingData/";
    TrainFiles = dir(trainDataDirectory);
    TrainFiles = filterFileStruct(TrainFiles, FileMask, '.mat'); % get available train .mat files
    
    % Extract training data
    XTrain = {};
    YTrain = categorical();
    for j = 1:size(TrainFiles,1)
        matFileName = TrainFiles(j);
        matFileContent = load(append(trainDataDirectory,matFileName));
        [X_sample_train,Y_sample_train] = extractData(matFileContent, matFileName, targetSamplingRateHz, windowLengthSeconds);
        XTrain(end+1:end+size(X_sample_train,1),1) = X_sample_train;
        YTrain(end+1:end+size(Y_sample_train,1),1) = Y_sample_train;
    end
    
    % Train the model
    trainSillyWalkClassifier(XTrain, YTrain);
end
tEnd = toc(tStart);
disp(append("Total runtime: ", string(tEnd), "s"))
disp(append("Cycle time: ", string(tEnd/i), "s per model"))