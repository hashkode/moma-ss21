function YPred = classifyWalk(model, XTest)
% CLASSIFYWALK
%   This function classifies a given test dataset on a pretrained model
%   and outputs the classified prediction labels

%% Get Features for SVM and RF (if model has those properties)
if (isfield(model,'svm') & isfield(model,'rf'))
    % Disable Parfor Setting for e.g. Matlab Online
    if canUseParallelPool == false
        model.settings.svm.parfor = false;
        model.settings.rf.parfor = false;
    end
    % Extract feature vector
    if isequal(model.settings.svm.type, model.settings.rf.type) ...
            && isequal(model.settings.svm.sorting, model.settings.rf.sorting) ...
            && isequal(model.settings.svm.parfor, model.settings.rf.parfor)
        % extract features only once, as SVM and RF settings are equal
        featuresSvm = getFeatures(XTest, model.settings.svm.type, ...
            model.settings.svm.sorting, model.settings.svm.parfor);
        featuresRf = featuresSvm;
    else
        % extract features twice, as SVM and RF settings differ
        featuresSvm = getFeatures(XTest, model.settings.svm.type, ...
            model.settings.svm.sorting, model.settings.svm.parfor);
        featuresRf = getFeatures(XTest, model.settings.rf.type, ...
            model.settings.rf.sorting, model.settings.rf.parfor);
    end
elseif isfield(model,'svm')
    % Disable Parfor Setting for e.g. Matlab Online
    if canUseParallelPool == false
        model.settings.svm.parfor = false;
    end
    featuresSvm = getFeatures(XTest, model.settings.svm.type, ...
        model.settings.svm.sorting, model.settings.svm.parfor);
elseif isfield(model,'rf')
    % Disable Parfor Setting for e.g. Matlab Online
    if canUseParallelPool == false
        model.settings.rf.parfor = false;
    end
    featuresRf = getFeatures(XTest, model.settings.rf.type, ...
        model.settings.rf.sorting, model.settings.rf.parfor);
end

%% Predict with classifiers
% Use stacking if final model is predicting
if (isfield(model,'svm') & isfield(model,'rf') &...
        isfield(model,'lstm1') & isfield(model,'lstm2') &...
        isfield(model,'lstm3'))
    YPredPreliminary(:, 1) = predictSvm(model.svm, featuresSvm);
    YPredPreliminary(:, 2) = predictRandomForest(model.rf, featuresRf);
    YPredPreliminary(:, 3) = cellstr(string(predictLSTM(model.lstm1, XTest, model.settings.lstm1.sorting)));
    YPredPreliminary(:, 4) = cellstr(string(predictLSTM(model.lstm2, XTest, model.settings.lstm2.sorting)));
    YPredPreliminary(:, 5) = cellstr(string(predictLSTM(model.lstm3, XTest, model.settings.lstm3.sorting)));
    
    %% multistage stacking
    stackingType = "1stage";
    
    switch stackingType
        case "1stage"
            iterFinalBag = 1:size(YPredPreliminary, 2);
        case "2stage"
            % Merge LSTM predicted labels
            for i = 1:size(YPredPreliminary, 1)
                tmpPred = categorical(YPredPreliminary(i, 3:5));
                categoryList = categories(tmpPred)';
                countList = countcats(tmpPred);
                [~, idxMax] = max(countList);
                YPredPreliminary(i, 3) = categoryList(idxMax);
            end
            iterFinalBag = 1:3;
        otherwise
    end
    
    % Take maximum count of predicted labels as final prediction
    for i = 1:size(YPredPreliminary, 1)
        tmpPred = categorical(YPredPreliminary(i, iterFinalBag));
        categoryList = categories(tmpPred)';
        countList = countcats(tmpPred);
        [~, idxMax] = max(countList);
        YPred(i, 1) = categoryList(idxMax);
    end
elseif isfield(model,'svm')
    YPred = predictSvm(model.svm, featuresSvm);
elseif isfield(model,'rf')
    YPred = predictRandomForest(model.rf, featuresRf);
elseif isfield(model,'lstm1')
    YPred = cellstr(string(predictLSTM(model.lstm1, XTest, model.settings.lstm1.sorting)));
elseif isfield(model,'lstm2')
    YPred = cellstr(string(predictLSTM(model.lstm2, XTest, model.settings.lstm2.sorting)));
elseif isfield(model,'lstm3')
    YPred = cellstr(string(predictLSTM(model.lstm3, XTest, model.settings.lstm3.sorting)));
end

YPred = categorical(YPred);
