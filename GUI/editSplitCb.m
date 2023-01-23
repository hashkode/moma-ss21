function editSplitCb(obj)
% EDITSPLITCB  Callback for the edit field of the
% split function

%% set the slider value accordingly
obj.SplitRatioSlider.Value = obj.EditField.Value;
end