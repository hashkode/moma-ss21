function vizErroneous(obj)
% Callback function to plot samples of wrong classified data

if(strcmp(obj.TestDropDown.Value,'-'))
    if isvalid(obj.UIAxes_Train)
        cla(obj.UIAxes_Train,'reset');
        obj.UIAxes_Train.Visible = 'off';
    else
        createAxis(obj);
    end
    return
end

% Clean Figure
delete(obj.ConfChart)
obj.BalancedAccuracyLabel.Visible = 'off';
obj.AccuracyLabel.Visible = 'off';
obj.BalancedAccuracyLabel.Text = '';
obj.AccuracyLabel.Text = '';
if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'on';
else
    createAxis(obj);
    obj.UIAxes_Train.Visible = 'on';
end
% Get the erroneous Map container
% dt is:
%%% 1: original cut Data of the file
%%% 2: Index of the errors in the concatenated X vector
%%% 3: Index of the errors in the data matrix of the file
dt = obj.ErrorData(obj.TestDropDown.Value);
time = dt{1}.time;

% Get parameters of the trained model
if isKey(obj.TrainingParameters,obj.ModelDropDown.Value)
    modelParameters = obj.TrainingParameters(obj.ModelDropDown.Value);
    targetFrequency = modelParameters{1};
    targetWindowLength = modelParameters{2};
else
    targetFrequency = obj.TrainingFrequency.Value;
    targetWindowLength = obj.WindowLength.Value;
end
% Resample data according to the frequency
time_resampled = 0 : 1/targetFrequency : time(end);

X_resample = interp1(time,dt{1}.data(1,:),time_resampled); % default: linear interpolation
Y_resample = interp1(time,dt{1}.data(2,:),time_resampled);
Z_resample = interp1(time,dt{1}.data(3,:),time_resampled);

% Plot original data transparent
XPlot = plot(obj.UIAxes_Train,time_resampled,X_resample);
hold(obj.UIAxes_Train,'on');
YPlot = plot(obj.UIAxes_Train,time_resampled,Y_resample);
ZPlot = plot(obj.UIAxes_Train,time_resampled,Z_resample);
if ~strcmp(obj.Knob.Value, 'Original')
    XPlot.Color(4) = 0.2;
    YPlot.Color(4) = 0.2;
    ZPlot.Color(4) = 0.2;
end
grid(obj.UIAxes_Train,'on');
% Retrieve array of erroneous data
originalInd = dt{2};
smallDt = obj.XTest(originalInd);

% Calculate window length
wL = targetWindowLength*targetFrequency; % wL: window length
if mod(wL,2) ~= 0 % making sure window length is even
    wL = wL-mod(wL,2);
end

% Plot the erroneous samples
idx = dt{3};

% Plot the limits of the sample
if strcmp(obj.Knob.Value,'Borders') || strcmp(obj.Knob.Value,'Bkgd Color')
    for j=1:length(idx)
        startIndex = 1+(idx(j)-1)*(wL/2);
        timeAxe = time_resampled(startIndex:startIndex-1+wL);
        data = smallDt{j};
        
        % Plot erroneous data
        Xp = plot(obj.UIAxes_Train,timeAxe,data(1,:));
        Yp = plot(obj.UIAxes_Train,timeAxe,data(2,:));
        Zp = plot(obj.UIAxes_Train,timeAxe,data(3,:));
        Xp.Color = XPlot.Color(1:3);
        Yp.Color = YPlot.Color(1:3);
        Zp.Color = ZPlot.Color(1:3);
        
        [color,symbol] = colorPicker(j);
        x1 = xline(obj.UIAxes_Train,timeAxe(1),symbol,'Color',color,'LineWidth',3,...
            'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right',...
            'LabelOrientation','horizontal','Alpha',1);
        x2 = xline(obj.UIAxes_Train,timeAxe(end),symbol,'Color',color,'LineWidth',3,...
            'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left',...
            'LabelOrientation','horizontal','Alpha',1);
        if strcmp(obj.Knob.Value,'Bkgd Color')
            lim = ylim(obj.UIAxes_Train);
            colPatch = patch(obj.UIAxes_Train,[timeAxe(1),timeAxe(end),timeAxe(end),timeAxe(1)],...
                [lim(1),lim(1),lim(2),lim(2)],colorPicker(j));
            colPatch.FaceAlpha = 0.1;
            
        end
    end
    
end
Y = obj.YTest(originalInd);
Ypred = obj.YPred(originalInd);

% Set appropriate title and legends
title(obj.UIAxes_Train,append('True: ',cellstr(Y(1)),' --- Estimated: ',cellstr(Ypred(1))));
if strcmp(obj.Knob.Value,'Borders') || strcmp(obj.Knob.Value,'Bkgd Color')
    legend(obj.UIAxes_Train,{'X','Y','Z','Xe','Ye','Ze'});
else
    legend(obj.UIAxes_Train,{'X','Y','Z'});
end
hold(obj.UIAxes_Train,'off');
end

function [col,symb] = colorPicker(idx)
if mod(idx,2)
    col = 'blue';
    symb = ':';
else
    % Carrot orange
    col = [0.9100    0.4100    0.1700];
    symb = '--';
end
end