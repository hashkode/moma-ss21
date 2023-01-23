function trainCb(obj)
% TRAINCB callback to train the model chosen in the
% GUI
if ~strcmp(obj.TrainingModel,'-')
    % Path preprocessing
    trainDataDir = 'TrainingData';
    path = fullfile(obj.MainPath,trainDataDir);
    list = dir(path);
    FileMask = 'Group';
    TrainFiles = filterFileStruct(list, FileMask, '.mat');
    
    % Get target frequency and windowLength
    targetSamplingRateHz = obj.TrainingFrequency.Value;
    windowLengthSeconds = obj.WindowLength.Value;
    
    % generate XTrain and YTrain matrices
    XTrain = {};
    YTrain = categorical();
    for i = 1:size(TrainFiles,1)
        matFileName = TrainFiles(i);
        matFileContent = load(fullfile(path,matFileName));
        [X_sample_train,Y_sample_train] = extractData(matFileContent,...
            matFileName, targetSamplingRateHz, windowLengthSeconds);
        XTrain(end+1:end+size(X_sample_train,1),1) = X_sample_train;
        YTrain(end+1:end+size(Y_sample_train,1),1) = Y_sample_train;
    end
else
    warning('Please select a model');
    return;
end

d = uiprogressdlg(obj.UIFigure,'Title',append('Training ',...
    obj.TrainingModel ,' model ...'),'Indeterminate','on');
if ~isempty(XTrain)
    switch obj.TrainingModel
        case 'Final'
            % Train the final model
            model = trainSillyWalkClassifier(XTrain,YTrain);
        case 'SVM'
            % Train the SVM model
            model.settings.svm.type = 'superextended';
            model.settings.svm.sorting = true;
            model.settings.svm.parfor = canUseParallelPool;
            % Reduce model size for matlab online
            if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
                model.settings.svm.type = 'default';
                disp('- Set Feature Type to default to not exceed total runtime of matlab online')
            end
            features = getFeatures(XTrain,model.settings.svm.type,...
                model.settings.svm.sorting,model.settings.svm.parfor);
            labels = cellstr(YTrain);
            model.svm = trainSvm(features, labels);
        case 'RF'
            % Train the RF model
            model.settings.rf.type = 'superextended';
            model.settings.rf.sorting = true;
            model.settings.rf.parfor = canUseParallelPool;
            model.settings.rf.nTrainIterations = 100;
            features = getFeatures(XTrain,model.settings.rf.type,...
                model.settings.rf.sorting,model.settings.rf.parfor);
            labels = cellstr(YTrain);
            model.rf = trainRandomForest(features,labels,model.settings.rf.nTrainIterations);
        case 'LSTM_36'
            % Train the LSTM model
            model.settings.lstm1.nHiddenUnits = 36;
            model.settings.lstm1.sorting = true;
            model.lstm1 = trainLSTM(XTrain, YTrain,...
                model.settings.lstm1.nHiddenUnits, model.settings.lstm1.sorting);
        case 'LSTM_213'
            % Train the LSTM model
            model.settings.lstm2.nHiddenUnits = 213;
            model.settings.lstm2.sorting = true;
            % Reduce Units for Matlab Online
            if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
                model.settings.lstm2.nHiddenUnits = 36;
                disp('- Reduce number of hidden units to 36 to not exceed total runtime of matlab online')
            end
            model.lstm2 = trainLSTM(XTrain, YTrain,...
                model.settings.lstm2.nHiddenUnits, model.settings.lstm2.sorting);
        case 'LSTM_378'
            % Train the LSTM model
            model.settings.lstm3.nHiddenUnits = 378;
            model.settings.lstm3.sorting = true;
            % Reduce Units for Matlab Online
            if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
                model.settings.lstm3.nHiddenUnits = 36;
                disp('- Reduce number of hidden units to 36 to not exceed total runtime of matlab online')
            end
            model.lstm3 = trainLSTM(XTrain, YTrain,...
                model.settings.lstm3.nHiddenUnits, model.settings.lstm3.sorting);
        otherwise
            warning(append(obj.TrainingModel,' model not yet implemented'))
            return
    end
    
    % Save training parameter
    obj.TrainingParameters(append('Model_',obj.TrainingModel,'.mat')) =...
        {obj.TrainingFrequency.Value, obj.WindowLength.Value};
    
    if ~strcmp(obj.TrainingModel,'Final')
        save(fullfile(obj.MainPath,'Models',append('Model_',obj.TrainingModel,'.mat')),...
            'model');
    else
        save(fullfile(obj.MainPath,'Model.mat'),'model');
    end
    loadModels({fullfile(obj.MainPath,'Models','70'),...
    fullfile(obj.MainPath,'Models')},obj);
else
    error("No training data available: Can't train");
end
end