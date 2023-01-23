function [windowedData, labels] = extractData(matFileContent, matFileName, targetSamplingRateHz, windowLengthSeconds)
%EXTRACTDATA 
% This function creates cell array 'windowedData' and 'labels' out of the 
% provided raw data stored in 'matFileContent' and 'matFileName'.

% Inputs:
%   matFileContent: Content of .mat-file obtained by load(matFileName) 
%   matFileName: The name of the file including extensions
%   targetSamplingRateHz: Target sampling rate in Hz
%   windowLengthSeconds: Window length in seconds

data = matFileContent.data;
time = matFileContent.time;
Fs   = targetSamplingRateHz;

%% Resample data at <targetSamplingRateHz>
X_sample = data(1,:);
Y_sample = data(2,:);
Z_sample = data(3,:);

if time(1) ~= 0 % in case time axis does not start at 0s.
    time = time-time(1);
end
   
time_resample = 0 : 1/Fs : time(end);

X_resample = interp1(time,X_sample,time_resample); % default: linear interpolation
Y_resample = interp1(time,Y_sample,time_resample);
Z_resample = interp1(time,Z_sample,time_resample);

data_resample = [X_resample;Y_resample;Z_resample];

%% Perform windowing and Put all windows into cell array 'windowedData'
wL = windowLengthSeconds*Fs; % wL: window length
if mod(wL,2) ~= 0 % making sure window length is even
   wL = wL-mod(wL,2); 
end

% Check if window length 'wL' is smaller than resampled data length
dataSize = size(data_resample,2);
if wL > dataSize
    warndlg('It''s not possible to have a window that is larger than your data. Try again with a smaller window!','Window length too big!');
    error('<windowLengthSeconds> is larger than data. Choose smaller value!');
end

% Preallocation of cell array windowedData
possible_windows = 1 + floor((size(data_resample,2)-wL)/(wL/2));
windowedData = cell(possible_windows,1);

window_start = 1;
wL_half      = wL/2;
for i = 1:possible_windows
    windowedData{i} = data_resample(:,window_start:window_start-1+wL);
    window_start = window_start+wL_half;
end

%% Construct categorical array 'labels' of class labels from filename

label = strsplit(matFileName,'_');
label = strsplit(string(label(end)),'.');
label = char(label(1));

switch label
    case 'N'
        label = 'Normal walk';
    case 'S'
        label = 'Silly walk';
end
labels = cell(possible_windows,1);
labels(:) = {label};
labels = categorical(labels);
end