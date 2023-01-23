% *** DATA PREPROCESSING ***
% Script

%% run raw data preprocessing
% add directories to MATLAB path
run('prepareEnv');

% call preprocessing routine
rawDataDirectory = 'RawData/';
trainRatioNew = .7;

if exist('trainRatioOld', 'var') == false || trainRatioNew ~= trainRatioOld
    preprocessRawData(rawDataDirectory, trainRatioNew);
    disp(append("Data preprocessing done with training ratio: ", num2str(trainRatioNew)))
    trainRatioOld = trainRatioNew;
else
    disp(append("Nothing to do. Data preprocessing already done with current training ratio: ", num2str(trainRatioNew)))
end

%% test
% check number of data sets in training and test directory
dataFileMask = 'Group';
trainDataDirectory = "TrainingData/";
testDataDirectory = "TestData/";

% initialize file list, filter mask and file name lists
trainFiles = dir(trainDataDirectory);
testFiles = dir(testDataDirectory);

% remove non Monty MATLAB data sets from file list
trainFiles = filterFileStruct(trainFiles, dataFileMask, '.mat');
testFiles = filterFileStruct(testFiles, dataFileMask, '.mat');

disp(append("Number of training data sets: ", num2str(size(trainFiles, 1))))
disp(append("Number of test data sets: ", num2str(size(testFiles, 1))))
