function accuracyCb(obj)
% Callback function shows accuracy of model on test and training data in
% GUI

% Remove confusion chart
delete(obj.ConfChart);

% Remove Plots
if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end

% Reset dropdown menu
obj.TestDropDown.Value = '-';

if ~isempty(obj.YTest)

    obj.AccuracyLabel.Text = append('The accuracy on the test data is ', num2str(obj.Accuracy));
    obj.BalancedAccuracyLabel.Text = append('The balanced accuracy on the test data is ', num2str(obj.BalancedAccuracy));
    
    obj.AccuracyLabel.Visible = 'on';
    obj.BalancedAccuracyLabel.Visible = 'on';
end
end