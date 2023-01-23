function trainModelDropdownCb(obj)
% TRAINMODELDROPDOWNCB The callback function of choosing
% a model for training

if ~strcmp(obj.ModelDropDownTrain.Value,'-')
    obj.TrainingModel = obj.ModelDropDownTrain.Value;
    if obj.DataSplit
        obj.TrainingButton.Enable = 'on';
    else
        obj.TrainingButton.Enable = 'off';
    end
else
    obj.TrainingButton.Enable = 'off';
end

end