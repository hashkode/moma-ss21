function clearCb(obj)
% Callback function to clear the GUI

% Reset classification Parameters
obj.YPred = categorical();
obj.YTest = categorical();
obj.XTest = {};
obj.ModelDropDown.Value = '-';
obj.TestDropDown.Items = {'-'}; 
obj.TestDropDown.Value = '-';
delete(obj.ConfChart);
obj.ErrorPanel.Enable = 'off';
obj.ConfusionMatrixButton.Enable = 'off';
obj.EffeciencyButton.Enable = 'off';
obj.ClassifyPanel.Enable = 'off';
obj.RefreshButton.Enable = 'off';
obj.BalancedAccuracyLabel.Visible = 'off';
obj.AccuracyLabel.Visible = 'off';
obj.BalancedAccuracyLabel.Text = '';
obj.AccuracyLabel.Text = '';
obj.ClassifyButton.Enable = 'off';
obj.ToClassifyName = '';
obj.ToClassifyData = '';
obj.ClassifyDropDown.Items = {};
obj.ClassificationPath = '';
obj.ConfusionTestButton.Enable = 'off';

% Reset visualization parameters and variabls
obj.VizDataTeam = {};
obj.DropDown.Items = {};
obj.VizData = {};
obj.VizDataSeconds = {};
obj.DatanotimportedLamp.Color = 'red';
obj.DatanotimportedLampLabel.Text = 'No data found';

% Reset data split and train parameters
obj.SplitButton.Enable = 'off';
obj.SplitLabel.Text = 'No data read!';
obj.SplitLabel.FontColor = 'red';
obj.DataSplit = false;
obj.TrainingLabel.Visible = 'on';
trainModelDropdownCb(obj);
obj.Model = '';

% Clear axes
if isvalid(obj.UIAxes)
    cla(obj.UIAxes,'reset');
    obj.UIAxes.Visible = 'off';
end

if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end

end