function model = trainSillyWalkClassifier(XTrain, YTrain)
%% Optimization support
optimizationSupport = false;
fixedLstmSettings = true;

if fixedLstmSettings
    nHiddenUnits.lstm1 = 36;
    sorting.lstm1 = true;
    nHiddenUnits.lstm2 = 213;
    sorting.lstm2 = true;
    nHiddenUnits.lstm3 = 378;
    sorting.lstm3 = true;
else
    nHiddenUnits.lstm1 = randi([10 100]);
    sorting.lstm1 = randi([0, 1], 1);
    nHiddenUnits.lstm2 = randi([100 250]);
    sorting.lstm2 = randi([0, 1], 1);
    nHiddenUnits.lstm3 = randi([250 450]);
    sorting.lstm3 = randi([0, 1], 1);
end

if optimizationSupport
    % uncomment for single classifier optimization from a base model
    load("Model.mat")
    curTime = string(datetime(now, 'ConvertFrom', 'datenum', 'Format', 'yyMMdd-HHmm'));
    disp(append(num2str(nHiddenUnits.lstm1), "-", string(sorting.lstm1), "_", num2str(nHiddenUnits.lstm2), "-", string(sorting.lstm2), "_", num2str(nHiddenUnits.lstm3), "-", string(sorting.lstm3), "_t-", curTime))
end

%% Classifier settings
model.settings.svm.type = 'superextended';
model.settings.svm.sorting = true;
model.settings.svm.parfor = canUseParallelPool;
model.settings.rf.type = 'superextended';
model.settings.rf.sorting = true;
model.settings.rf.parfor = canUseParallelPool;
model.settings.rf.nTrainIterations = 100;
model.settings.lstm1.nHiddenUnits = nHiddenUnits.lstm1;
model.settings.lstm1.sorting = sorting.lstm1;
model.settings.lstm2.nHiddenUnits = nHiddenUnits.lstm2;
model.settings.lstm2.sorting = sorting.lstm2;
model.settings.lstm3.nHiddenUnits = nHiddenUnits.lstm3;
model.settings.lstm3.sorting = sorting.lstm3;

%% Reduce model size for matlab online
if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
    disp('- Simple Model with less iterations gets trained to reduce runtime and work with Matlab Online ...')
    model.settings.lstm1.nHiddenUnits = 10;
    model.settings.rf.nTrainIterations = 20;
    model.settings.svm.type = 'default';
    model.settings.rf.type = 'default'; 
end

%% Extract feature vector
if isequal(model.settings.svm.type, model.settings.rf.type) ...
        && isequal(model.settings.svm.sorting, model.settings.rf.sorting) ...
        && isequal(model.settings.svm.parfor, model.settings.rf.parfor)
    % extract features only once, as SVM and RF settings are equal
    featuresSvm = getFeatures(XTrain, model.settings.svm.type, ...
        model.settings.svm.sorting, model.settings.svm.parfor);
    featuresRf = featuresSvm;
else
    % extract features twice, as SVM and RF settings differ
    featuresSvm = getFeatures(XTrain, model.settings.svm.type, ...
        model.settings.svm.sorting, model.settings.svm.parfor);
    featuresRf = getFeatures(XTrain, model.settings.rf.type, ...
        model.settings.rf.sorting, model.settings.rf.parfor);
end

labels = cellstr(YTrain);

%% Train classifiers
model.svm = trainSvm(featuresSvm, labels);
model.rf = trainRandomForest(featuresRf, labels, model.settings.rf.nTrainIterations);
model.lstm1 = trainLSTM(XTrain, YTrain, model.settings.lstm1.nHiddenUnits, model.settings.lstm1.sorting);
if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
    model.lstm2 = model.lstm1;
    model.lstm3 = model.lstm1;
else
model.lstm2 = trainLSTM(XTrain, YTrain, model.settings.lstm2.nHiddenUnits, model.settings.lstm2.sorting);
model.lstm3 = trainLSTM(XTrain, YTrain, model.settings.lstm3.nHiddenUnits, model.settings.lstm3.sorting);
end

if optimizationSupport
    save(fullfile(fileparts(mfilename('fullpath')), append( ...
        num2str(nHiddenUnits.lstm1), "-", string(sorting.lstm1), "_", ...
        num2str(nHiddenUnits.lstm2), "-", string(sorting.lstm2), "_", ...
        num2str(nHiddenUnits.lstm3), "-", string(sorting.lstm3), "_t-", ...
        curTime , '.mat')), 'model');
else
    save(fullfile(fileparts(mfilename('fullpath')), 'Model.mat'), 'model'); % do not change this line
end
