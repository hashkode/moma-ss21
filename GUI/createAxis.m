function createAxis(obj)
% Callback function to create axes on the GUI to visualize samples of data

% Delete confusion chart
delete(obj.ConfChart);

% Hide accuracy labels
obj.AccuracyLabel.Visible = 'off';
obj.BalancedAccuracyLabel.Visible = 'off';

% Create UIAxes_Train
obj.UIAxes_Train = uiaxes(obj.VisualizationPanel);
obj.UIAxes_Train.Visible = 'off';
obj.UIAxes_Train.Units = 'Normalized';
obj.UIAxes_Train.Position = [0.01 0.05 0.98 0.95];
grid(obj.UIAxes_Train,'on');
end