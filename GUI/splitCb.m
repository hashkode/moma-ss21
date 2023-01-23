function splitCb(obj)
% SPLITCB  split the data between train and
%   test datasets

%% Run the split script and change the label in GUI

% Navigate to main directory
cd(obj.MainPath)

d = uiprogressdlg(obj.UIFigure,'Title','Splitting data...',...
        'Indeterminate','on');
preprocessRawData(obj.RawDataURL,obj.EditField.Value/100);
obj.SplitLabel.FontColor = 'blue';
obj.SplitLabel.Text = "Split succesfully ("+num2str(obj.EditField.Value)+"%)";
obj.DataSplit = true;
obj.TrainingLabel.Visible = 'off';
trainModelDropdownCb(obj);
close(d)
end