function [accuracy, balanced_accuracy,XTest,YTest,YPred,dataSizes] ...
    = runExtractTrainClassify(testType,modelPath,testDataPath,samplingRate,windowLength)
% RUNEXTRACTTRAINCLASSIFY
%   This function serves as unit test replacement for GUI usage as well as
%   for easier debugging.
%   This function extracts the training and test data, trains one/multiple 
%   classifier, predicts the test data and gives info about accuracy,
%   balanced accuracy and the test split ratio of normal and silly walks.

FileMask = 'Group';
targetSamplingRateHz = samplingRate;
windowLengthSeconds = windowLength;

switch testType
    case 'train'
        trainDataDirectory = "TrainingData/";
        TrainFiles = dir(trainDataDirectory);
        TrainFiles = filterFileStruct(TrainFiles, FileMask, '.mat'); % get available train .mat files
        
        % Extract training data
        XTrain = {};
        YTrain = categorical();
        for i = 1:size(TrainFiles,1)
            matFileName = TrainFiles(i);
            matFileContent = load(append(trainDataDirectory,matFileName));
            [X_sample_train,Y_sample_train] = extractData(matFileContent, matFileName, targetSamplingRateHz, windowLengthSeconds);
            XTrain(end+1:end+size(X_sample_train,1),1) = X_sample_train;
            YTrain(end+1:end+size(Y_sample_train,1),1) = Y_sample_train;
        end
        
        % Train the model
        model = trainSillyWalkClassifier(XTrain, YTrain);
        
    case 'pretrained'
        
        % Load existing model
        load(modelPath);
        
    otherwise
        warndlg('Unknown test type','Warning');
        return
end

testDataDirectory = testDataPath;
TestFiles = dir(testDataDirectory);
TestFiles = filterFileStruct(TestFiles, FileMask, '.mat'); % get available test .mat files

% Extract test data
XTest = {};
YTest = categorical();
dataSizes = cell(1,size(TestFiles,1));

% sumy = 0;
for i = 1:size(TestFiles,1)
    matFileName = TestFiles(i);
    matFileContent = load(fullfile(testDataDirectory,matFileName));
    [X_sample_test,Y_sample_test] = extractData(matFileContent, matFileName, targetSamplingRateHz, windowLengthSeconds);
    XTest(end+1:end+size(X_sample_test,1),1) = X_sample_test;
    YTest(end+1:end+size(Y_sample_test,1),1) = Y_sample_test;
    dataSizes{i} = length(Y_sample_test);
end

%% Classify test data
YPred = classifyWalk(model, XTest);

%% Calculate accuracy and balanced accuracy
% Overall accuracy

accuracy = sum(YPred == YTest)/numel(YTest)*100;
if isnan(accuracy)
    warning('YTest is empty');
    accuracy = 0;
end

% Balanced accuracy
nw      = find(YTest == 'Normal walk');
nw_pred = find(YPred(nw) == 'Normal walk');
TPR     = numel(nw_pred)/numel(nw); % True Positive Rate
sw      = find(YTest == 'Silly walk');
sw_pred = find(YPred(sw) == 'Silly walk');
TNR     = numel(sw_pred)/numel(sw); % True Negative Rate

balanced_accuracy = (TPR + TNR)/2 * 100;
if isnan(balanced_accuracy)
    balanced_accuracy = 0;
end
end