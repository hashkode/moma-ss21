% *** BENCHMARK STATISTICS ***
% Script to create benchmark statistics table in .md-format

%% derive statistical measures of benchmark data
idxCycle = 10;
meanArray = [meanPerf{idxCycle, :}];
resTraArray = [results{idxCycle, :, 1}];
resTstArray = [results{idxCycle, :, 2}];
resValArray = [results{idxCycle, :, 3}];

%% mean
maxMeanAcc = max(meanArray(1:2:end));
minMeanAcc = min(meanArray(1:2:end));
meanMeanAcc = mean(meanArray(1:2:end));
stdMeanAcc = std(meanArray(1:2:end));

maxMeanBalAcc = max(meanArray(2:2:end));
minMeanBalAcc = min(meanArray(2:2:end));
meanMeanBalAcc = mean(meanArray(2:2:end));
stdMeanBalAcc = std(meanArray(2:2:end));

% max
maxTraAcc = max(resTraArray(1:2:end));
maxTraBalAcc = max(resTraArray(2:2:end));

maxTstAcc = max(resTstArray(1:2:end));
maxTstBalAcc = max(resTstArray(2:2:end));

maxValAcc = max(resValArray(1:2:end));
maxValBalAcc = max(resValArray(2:2:end));

% min
minTraAcc = min(resTraArray(1:2:end));
minTraBalAcc = min(resTraArray(2:2:end));

minTstAcc = min(resTstArray(1:2:end));
minTstBalAcc = min(resTstArray(2:2:end));

minValAcc = min(resValArray(1:2:end));
minValBalAcc = min(resValArray(2:2:end));

% mean
meanTraAcc = mean(resTraArray(1:2:end));
meanTraBalAcc = mean(resTraArray(2:2:end));

meanTstAcc = mean(resTstArray(1:2:end));
meanTstBalAcc = mean(resTstArray(2:2:end));

meanValAcc = mean(resValArray(1:2:end));
meanValBalAcc = mean(resValArray(2:2:end));

% std
stdTraAcc = std(resTraArray(1:2:end));
stdTraBalAcc = std(resTraArray(2:2:end));

stdTstAcc = std(resTstArray(1:2:end));
stdTstBalAcc = std(resTstArray(2:2:end));

stdValAcc = std(resValArray(1:2:end));
stdValBalAcc = std(resValArray(2:2:end));

%% print markdown table
disp(append("|Metric | Max  | Min | Mean | Std |"))
disp(append("|:--- | :--- | :--- | :--- | :--- |"))
disp(append("|mean mean accuracy |", string(maxMeanAcc), " |", string(minMeanAcc), " |", string(meanMeanAcc ), " |", string(stdMeanAcc), " |"))
disp(append("|mean mean balanced accuracy |", string(maxMeanBalAcc), " |", string(minMeanBalAcc), " |", string(meanMeanBalAcc), " |", string(stdMeanBalAcc), " |"))
disp(append("|training accuracy |", string(maxTraAcc), " |", string(minTraAcc), " |", string(meanTraAcc), " |", string(stdTraAcc), " |"))
disp(append("|training balanced accuracy |", string(maxTraBalAcc), " |", string(minTraBalAcc), " |", string(meanTraBalAcc), " |", string(stdTraBalAcc), " |"))
disp(append("|testing accuracy |", string(maxTstAcc), " |", string(minTstAcc), " |", string(meanTstAcc), " |", string(stdTstAcc), " |"))
disp(append("|testing balanced accuracy |", string(maxTstBalAcc), " |", string(minTstBalAcc), " |", string(meanTstBalAcc), " |", string(stdTstBalAcc), " |"))
disp(append("|validation accuracy |", string(maxValAcc), " |", string(minValAcc), " |", string(meanValAcc), " |", string(stdValAcc), " |"))
disp(append("|validation balanced accuracy |", string(maxValBalAcc), " |", string(minValBalAcc), " |", string(meanValBalAcc), " |", string(stdValBalAcc), " |"))