function [data_cut, time_cut, options] = cutData(filename)
%CUTDATA cut the provided raw '.mat' data %
% This function cuts the beginning and end part of the recorded raw data
% and only outputs data of the actual walk.

% Inputs:
%  filename: Full path + filename of the recorded raw data
%  visualize: Visualize the raw data, the cut data and the data after
%             sliding a moving std filter over the raw data

%% Load file
load(filename);

%% Get data and time of recorded walk saved in filename
data = [Acceleration.X.';Acceleration.Y.';Acceleration.Z.'];
time = Acceleration.Timestamp;
time = time-time(1);
time = seconds(time).';

% Calculate sampling frequency of recorded walk
Fs = round(size(data,2)/time(end));

%% Increase Frequency to 50 Hz, if below 50 Hz
% Call function to edit time data such that f > 50 Hz
f_accurate = mean(1./diff(time));
if f_accurate < 50 % more precise calculation of Fs than in Column 21
    [time] = increaseFrequency(time, f_accurate); % Call function to edit timevector
    Fs = round(size(data,2)/time(end)); % Update frequency
end

%%
% Normalize data for moving std calculation
data_normalized = [data(1,:)/max(abs(data(1,:)));data(2,:)/max(abs(data(2,:)));data(3,:)/max(abs(data(3,:)))];

% Calculate moving std over a window of size of the sampling frequency -> 1sec
movingSTD = movstd(data_normalized,Fs,0,2);
[~,start] = min(movingSTD(:,Fs+1:Fs*4),[],2);         % minimum from interval [+1sec,+ 4sec] -> cut 1 sec at the start
[~,stop]  = min(movingSTD(:,end-Fs*4+1:end-Fs),[],2); % minimum from interval [end-1sec,end-4sec] -> cut 1 sec at end
% Average start and stop time over all dimension X,Y,Z
start = round(mean(start)) + Fs;                % +sf since the 1st second was skipped
stop  = round(mean(stop)) + size(time,2)-Fs*4;  % -sf*4 since we started ar sf*4+1

startingTime = time(start+2*Fs);
stopTime     = time(stop-2*Fs);
startingData = data(:,start+2*Fs); % data values for X,Y,Z at starting time
stopData     = data(:,stop-2*Fs);  % data values for X,Y,Z at stop time

% Cut the data at start+2sec and stop-2sec
data_cut = data(:,start+2*Fs:stop-2*Fs);
time_cut = time(start+2*Fs:stop-2*Fs);
time_cut = time_cut - time_cut(1);

opt = {'OriginalTime','OriginalData','StartingTime','StopTime'};
options = containers.Map(opt,{time,data,startingTime,stopTime});
end