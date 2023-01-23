function vizConfusion(obj,type)
% Callback function to create and display confusion matrix in GUI

if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end
obj.TestDropDown.Value = '-';

% Reset accuracy labels
obj.BalancedAccuracyLabel.Visible = 'off';
obj.AccuracyLabel.Visible = 'off';

if strcmp(type,'test')
    if ~isempty(obj.YPred)
        obj.ConfChart = confusionchart(obj.VisualizationPanel,...
            obj.YTest,obj.YPred);
        obj.ConfChart.Title = 'Confusion matrix for the test data';
    end
elseif strcmp(type,'unseen')
    if ~isempty(obj.YPredUnseen)
        obj.ConfChart = confusionchart(obj.VisualizationPanel,...
            obj.YTestUnseen,obj.YPredUnseen);
        obj.ConfChart.Title = 'Confusion matrix for the unseen data';
    end
else
    error(append('No mode called ',type));
end
obj.ConfChart.RowSummary = 'row-normalized';
obj.ConfChart.ColumnSummary = 'column-normalized';
end