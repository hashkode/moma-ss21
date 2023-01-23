function errorModelDropdownCb(obj)
% ERRORMODELDROPDOWNCB The callback function of choosing
% a model for error analysis

%% Reset unseen data array
obj.ClassifyDropDown.Items = {};
obj.ConfusionTestButton.Enable = 'off';
obj.ClassifyButton.Enable = 'off';

%% Determine the Model to test
obj.ClassificationModel = obj.ModelDropDown.Value;
if ~strcmp(obj.ModelDropDown.Value,'-')
    obj.ErrorPanel.Enable = 'on';
    obj.ClassifyPanel.Enable = 'on';
    obj.RefreshButton.Enable = 'on';
else
    obj.ErrorPanel.Enable = 'off';
    obj.ClassifyPanel.Enable = 'off';
    obj.RefreshButton.Enable = 'off';
end
%% Clear axes
if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end
delete(obj.ConfChart);

%% Load model and classify
obj.BalancedAccuracyLabel.Visible = 'off';
obj.AccuracyLabel.Visible = 'off';
obj.BalancedAccuracyLabel.Text = '';
obj.AccuracyLabel.Text = '';
obj.ClassifyPanel.Enable = 'off';

obj.Model = '';
d = uiprogressdlg(obj.UIFigure,'Title','Testing the model...',...
            'Indeterminate','on');
switch obj.ClassificationModel
    case '-'
        return
    case 'Final'
        if isfile(fullfile(obj.MainPath,'Model.mat'))
            obj.ModelPath = fullfile(obj.MainPath,'Model.mat');
            obj.Model = load(fullfile(obj.MainPath,'Model.mat'));
            obj.Model = obj.Model.model;

        else
            warning(append(obj.ClassificationModel,...
                'Model not trained'));
            obj.ConfusionMatrixButton.Enable = 'off';
            obj.EffeciencyButton.Enable = 'off';
        end
    otherwise
        obj.ModelPath = fullfile(obj.Models(obj.ClassificationModel),...
            obj.ClassificationModel);
        obj.Model = load(obj.ModelPath);
        obj.Model = obj.Model.model;

end
if isempty(obj.Model)
    obj.TestDropDown.Items = {'-'};
    if isvalid(obj.UIAxes_Train)
        cla(obj.UIAxes_Train,'reset');
        obj.UIAxes_Train.Visible = 'off';
    end
    obj.YPred = categorical();
    obj.YTest = categorical();
    obj.ConfusionMatrixButton.Enable = 'off';
    obj.EffeciencyButton.Enable = 'off';
    warning(append("Model ", obj.ModelDropDown.Value ," not yet implemented"));
    return;
end
%% Load erroneous test datasets to the dropdown list
obj.ErrorData = {};

% Path preprocessing
testDataDir = 'TestData';
path = fullfile(obj.MainPath,testDataDir);
list = dir(path);
FileMask = 'Group';
TestFiles = filterFileStruct(list, FileMask, '.mat'); % get available test .mat files

% Get the model data processing parameters
if isKey(obj.TrainingParameters,obj.ModelDropDown.Value)
    modelParameters = obj.TrainingParameters(obj.ModelDropDown.Value);
    targetFrequency = modelParameters{1};
    targetWindowlength = modelParameters{2};
else
    targetFrequency = obj.TrainingFrequency.Value;
    targetWindowlength = obj.WindowLength.Value;
end

[accuracy, balancedAccuracy,XTest,YTest,YPred, dataSizes] =...
    runExtractTrainClassify('pretrained',obj.ModelPath,path,...
    targetFrequency,targetWindowlength);
obj.Accuracy = accuracy;
obj.BalancedAccuracy = balancedAccuracy;
obj.YTest = YTest;
obj.YPred = YPred;
obj.XTest = XTest;

%% Retrieve erroneous
dataSizes = cell2mat(dataSizes);
cumSizes = cumsum(dataSizes); % Get cumalitive sum array of all sizes of test data
errorInd = find(YPred ~= YTest);
errorMap = containers.Map({'-'},{[]});
for i=1:length(errorInd)
    
    % The error is in the first datafile where the cumilative sum >= errorPlac
    mask =  cumSizes >= errorInd(i);
    occ = find(mask,1,'first'); 
    fileName = TestFiles(occ);
    
    % The error batch in the file 
    if occ~= 1
        batchNum = errorInd(i)-cumSizes(occ-1);
    else
        batchNum = errorInd(i);
    end
    if isKey(errorMap,fileName)
        oldData = errorMap(fileName);
        batchArray = [oldData{3},batchNum];
        originInd = [oldData{2},errorInd(i)];
        errorMap(fileName) = {oldData{1},originInd,batchArray};
    else
        matFileContent = load(fullfile(path,fileName));
        errorMap(fileName) = {matFileContent,...
            [errorInd(i)],[batchNum]};
    end
end
obj.ErrorPanel.Enable = 'on';
obj.ClassifyPanel.Enable = 'on';
obj.ConfusionMatrixButton.Enable = 'on';
obj.EffeciencyButton.Enable = 'on';
close(d);

% Fill the error data Map container
obj.ErrorData = errorMap;

%% Add erroneous data to list
obj.TestDropDown.Items = keys(errorMap);
end