function vizAcceleration(obj)
% VIZACCELERATION  visualize the acceleration data of
%   a recorded sample

%% Plot the acceleration and label it correspondingly

value = obj.DropDown.Value;
if ~strcmp(value,'-')
    if isvalid(obj.UIAxes)
        cla(obj.UIAxes,'reset')
    end
    [data,time, opt] = cutData(fullfile(obj.RawDataURL,value));
    if(strcmp(obj.PlotTypeSwitch.Value,'Cut'))
        b = plot(obj.UIAxes,time,data);
        title(obj.UIAxes, 'Preprocessed sensor output for the acceleration')
    else
        time = opt('OriginalTime');
        data = opt('OriginalData');
        b = plot(obj.UIAxes,time,data);
        x1 = xline(obj.UIAxes,opt('StartingTime'),'--k','Start time','LineWidth',2,...
            'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right',...
            'LabelOrientation','horizontal','FontSize',16,'Alpha',1);
        x2 = xline(obj.UIAxes,opt('StopTime'),'--k','Stop time','LineWidth',2,...
            'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left',...
            'LabelOrientation','horizontal','FontSize',16,'Alpha',1);
        
        title(obj.UIAxes, 'Original sensor output for the acceleration')
    end
    
    xlabel(obj.UIAxes,'Time (s)');
    ylabel(obj.UIAxes,'Acceleration (m/s^{2})');
    labels = {'X','Y','Z'};
    legend(obj.UIAxes,labels, 'Location','northeast','FontSize',12);
else
    if isvalid(obj.UIAxes)
        cla(obj.UIAxes,'reset')
        obj.UIAxes.Visible = 'off';
    end
end
end