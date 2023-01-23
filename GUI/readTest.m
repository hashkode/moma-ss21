function readTest(obj)
% Callback READTEST  load a test mat file for classification

%% Get the Path of the preprocessed data
path = uigetdir;
figure(obj.UIFigure);
if ~path
    return
end

% Extract all the files from the path
obj.ClassificationPath = path;
f = fullfile(path,'*Walk*.mat');
list = dir(f);

% Reset the axis for plotting and the upper dropdown
if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end
obj.TestDropDown.Value = '-';

%% Fill the dropdown menu for selecting the data to classify
obj.ClassifyDropDown.Items = {};
if size(list,1)
    obj.ClassifyDropDown.Items = {list.name};
    obj.ClassifyDropDown.Value = list(1).name;
    obj.ClassifyButton.Enable = 'on';
    obj.ConfusionTestButton.Enable = 'on';
else
    obj.ClassifyButton.Enable = 'off';
    obj.ConfusionTestButton.Enable = 'off';
    warning("Folder doesn't contain any data");
    return
end

%% Classify data
d = uiprogressdlg(obj.UIFigure,'Title','Testing unseen data...',...
    'Indeterminate','on');

% Get trained model parameters
if isKey(obj.TrainingParameters,obj.ModelDropDown.Value)
    modelParameters = obj.TrainingParameters(obj.ModelDropDown.Value);
    targetFrequency = modelParameters{1};
    targetWindowlength = modelParameters{2};
else
    targetFrequency = obj.TrainingFrequency.Value;
    targetWindowlength = obj.WindowLength.Value;
end

[accuracy, balanced_accuracy,XUTest,YUTest,YUPred,dataSizes] =...
    runExtractTrainClassify('pretrained',obj.ModelPath,obj.ClassificationPath,...
    targetFrequency,targetWindowlength);

obj.XTestUnseen = XUTest;
obj.YTestUnseen = YUTest;
obj.YPredUnseen = YUPred;
obj.UnseenSize = dataSizes;
obj.AccuracyUnseen = accuracy;
obj.BalancedAccuracyUnseen = balanced_accuracy;

close(d);
end