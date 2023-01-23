function classifyCb(obj)
% CLASSIFYCB function to call when clicking the classify button in the GUI
% It classifies the chosen input file into Silly or Normal Walks

d = uiprogressdlg(obj.UIFigure,'Title',append('Classifying ', obj.ClassifyDropDown.Value...
    ,'...'),'Indeterminate','on','Cancelable','on');
%% Get Data from file
ToClassifyData = load(fullfile(obj.ClassificationPath,obj.ClassifyDropDown.Value));
% Get index of file
index = find(strcmp(obj.ClassifyDropDown.Value,obj.ClassifyDropDown.Items));
%% Get result of the prediction

% Get cumulative sizes
cumSizes = cumsum(cell2mat(obj.UnseenSize));
if index == 1
    startTime = 1;
else
    startTime = cumSizes(index-1)+1;
end
endTime = cumSizes(index);
Ypred = obj.YPredUnseen(startTime:endTime);
Ytrue = obj.YTestUnseen(startTime);
%% Clear axes
if isvalid(obj.UIAxes_Train)
    cla(obj.UIAxes_Train,'reset');
    obj.UIAxes_Train.Visible = 'off';
end

%% Calculate Window Length
% Get trained model parameters
if isKey(obj.TrainingParameters,obj.ModelDropDown.Value)
    modelParameters = obj.TrainingParameters(obj.ModelDropDown.Value);
    targetFrequency = modelParameters{1};
    targetWindowlength = modelParameters{2};
else
    targetFrequency = obj.TrainingFrequency.Value;
    targetWindowlength = obj.WindowLength.Value;
end

% Assign limits and classes
wL = targetWindowlength*targetFrequency; % wL: window length 
if mod(wL,2) ~= 0 % making sure window length is even
    wL = wL-mod(wL,2);
end

%% Plot data
createAxis(obj);    
cutoff = (length(Ypred)+1)*wL/2;

% Resample data according to the frequency
time = ToClassifyData.time;
time_resampled = 0 : 1/targetFrequency : time(end);

X_resample = interp1(time,ToClassifyData.data(1,:),time_resampled); % default: linear interpolation
Y_resample = interp1(time,ToClassifyData.data(2,:),time_resampled);
Z_resample = interp1(time,ToClassifyData.data(3,:),time_resampled);

data_resampled = [X_resample;Y_resample;Z_resample];

p = plot(obj.UIAxes_Train,time_resampled(1:cutoff),...
    data_resampled(:,1:cutoff));
obj.UIAxes_Train.Visible = 'on';
hold(obj.UIAxes_Train,'on');

% Hack to display color patching on plot
patch(obj.UIAxes_Train,[time_resampled(1),time_resampled(1),...
    time_resampled(1),time_resampled(1)],[-0.1,-0.1,0.1,0.1],'blue');
patch(obj.UIAxes_Train,[time_resampled(1),time_resampled(1),...
    time_resampled(1),time_resampled(1)],[-0.1,-0.1,0.1,0.1],[0.9100 0.4100 0.1700]);
hold(obj.UIAxes_Train,'off');

for j=1:length(Ypred)
    if d.CancelRequested
        cla(obj.UIAxes_Train,'reset');
        obj.UIAxes_Train.Visible = 'off';
        return
    end
    startIndex = 1+(j-1)*(wL/2);
    timeAxe = time_resampled(startIndex:startIndex-1+wL);
    lim = ylim(obj.UIAxes_Train);
    color = assignColor(Ypred(j));
    x1 = xline(obj.UIAxes_Train,timeAxe(1),':','Color',color,'LineWidth',3,...
        'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','right',...
        'LabelOrientation','horizontal','Alpha',1);
    x2 = xline(obj.UIAxes_Train,timeAxe(end)-0.01,':','Color',color,'LineWidth',3,...
        'LabelVerticalAlignment','bottom','LabelHorizontalAlignment','left',...
        'LabelOrientation','horizontal','Alpha',1);
    
    colPatch = patch(obj.UIAxes_Train,[timeAxe(1),timeAxe(end)-0.01,timeAxe(end)-0.01,timeAxe(1)],...
        [lim(1),lim(1),lim(2),lim(2)],color);
    colPatch.FaceAlpha = 0.05;
end

title(obj.UIAxes_Train,append('Classification of the uploaded dataset (',cellstr(Ytrue),')'));
legend(obj.UIAxes_Train,'X','Y','Z','NW','SW');
end

function col = assignColor(type)
if strcmp(cellstr(type),'Normal walk')
    col = 'blue';
else
    % Carrot orange
    col = [0.9100    0.4100    0.1700];end
end