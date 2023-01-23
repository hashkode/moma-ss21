function preprocessRawData(rawDataDirectory, trainRatio)
%PREPROCESSRAWDATA Read, trim and split the raw data sets
%   This function performs the preprocessing of the raw data sets stored in
%   the directory specified by the argument rawDataDirectory. It reads all
%   data sets, performs a trim algorithm implemented in the function
%   cutData and distributes the data sets according to the argument
%   trainRatio.

% perform checks on function inputs
if trainRatio > 1
    warning("Training ratio must be in the intervall [0, 1]. Capped at upper bound.")
    trainRatio = 1;
elseif trainRatio < 0
    warning("Training ratio must be in the intervall [0, 1]. Capped at lower bound.")
    trainRatio = 0;
end

% specify training and testing data directory names and empty them
trainDataDirectory = "TrainingData/";
testDataDirectory = "TestData/";
delete(append(trainDataDirectory, "*"));
delete(append(testDataDirectory, "*"));
warning off
mkdir(trainDataDirectory);
mkdir(testDataDirectory);
warning on

%% EDITED to split normal and silly walking data seperately 
% initialize file list, filter mask and file name lists
rawFiles = dir(rawDataDirectory);
rawFileMask = 'Group';

rawFiles_N = filterFileStruct(rawFiles, rawFileMask, 'N'); % Get normal walk names
rawFiles_S = filterFileStruct(rawFiles, rawFileMask, 'S'); % Get silly walk names

% initialize rng
rng(0)

% draw random samples from the index range until target amount of training
% samples is met
nTrainTarget_N = ceil(size(rawFiles_N, 1) * trainRatio); % normal 
idxTrain_N = randperm(size(rawFiles_N,1),nTrainTarget_N); % normal
nTrainTarget_S = ceil(size(rawFiles_S, 1) * trainRatio); % silly
idxTrain_S = randperm(size(rawFiles_S,1),nTrainTarget_S); % silly
trainingFiles = [rawFiles_N(idxTrain_N); rawFiles_S(idxTrain_S)]; % write both in one array

% check if number of training samples is larger than 0
if (sum(idxTrain_N) + sum(idxTrain_S)) > 0
    rawFiles_N(idxTrain_N) = [];
    rawFiles_S(idxTrain_S) = [];
    testFiles = [rawFiles_N; rawFiles_S];
else
    trainingFiles = [];
    testFiles = [rawFiles_N; rawFiles_S];
end

% cut train data and store the result in the train data directory
for i = 1:size(trainingFiles, 1)
    [data, time, ~] = cutData(fullfile(rawDataDirectory,trainingFiles(i)));
    save(append(trainDataDirectory, trainingFiles(i)), 'data', 'time');
end

% cut test data and store the result in the test data directory
for i = 1:size(testFiles, 1)
    [data, time, ~] = cutData(fullfile(rawDataDirectory,testFiles(i)));
    save(append(testDataDirectory, testFiles(i)), 'data', 'time');
end
end
