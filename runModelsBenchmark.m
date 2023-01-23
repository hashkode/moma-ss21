% *** MODEL BENCHMARK ***
% Script to run the benchmark and compare different trained models

%% determine best performing model
tStart = tic;
% apply models from the specified directory to the specified data directories
optimizationDir = "./Optimization/";
trainingCycleDirs = filterFileStruct(dir(optimizationDir), "", "cycle");
modelFileMask = '_t-';

% directories with data to use for benchmarking
% 1st entry: training data
% 2nd entry: test data
% 3rd entry: validation data
testDataDirs = ["TrainingData", "TestData", "TestDataVal"];

% switch to select all models or only a subset, e.g. classic in this case
testAll = true;

benchmarkFileName = 'performance_1stagebag_all.mat';

modelCounter = 0;

%% test models on training, test and validation data
% iterate over all training cycles
for i = 1:size(trainingCycleDirs, 1)
    disp(append("#> cycle ", num2str(i)))
    modelFileNames = dir(append(optimizationDir, trainingCycleDirs(i)));
    modelFileNames = filterFileStruct(modelFileNames, modelFileMask, '.mat');
    
    % iterate over all models of a training cycle
    for j = 1:size(modelFileNames, 1)
        disp(append("##> model ", num2str(j)))
        load(append(optimizationDir, trainingCycleDirs(i), "/", modelFileNames(j)))
        
        % store file name of the model under test
        models{i, j} = append(trainingCycleDirs(i), "/", modelFileNames(j));
        modelCounter = modelCounter + 1;
        
        % iterate over all data sets
        for k = 1:size(testDataDirs, 2)
            FileMask = 'Group';
            targetSamplingRateHz = 50;
            windowLengthSeconds = 3.4;
            
            testDataDirectory = fullfile(fileparts(mfilename('fullpath')), testDataDirs(k));
            TestFiles = dir(testDataDirectory);
            TestFiles = filterFileStruct(TestFiles, FileMask, '.mat');
            
            % Extract test data
            XTest = {};
            YTest = categorical();
            dataSizes = cell(1, size(TestFiles,1));
            
            % assemble test vector
            for l = 1:size(TestFiles, 1)
                matFileName = TestFiles(l);
                matFileContent = load(fullfile(testDataDirectory, matFileName));
                [X_sample_test,Y_sample_test] = extractData(matFileContent, matFileName, targetSamplingRateHz, windowLengthSeconds);
                XTest(end+1:end+size(X_sample_test,1),1) = X_sample_test;
                YTest(end+1:end+size(Y_sample_test,1),1) = Y_sample_test;
                dataSizes{l} = length(Y_sample_test);
            end
            
            % Classify test data
            YPred = classifyWalk(model, XTest);
            
            accuracy = sum(YPred == YTest)/numel(YTest)*100;
            if isnan(accuracy)
                warning('YTest is empty');
                accuracy = 0;
            end
            
            % Balanced accuracy
            nw      = find(YTest == 'Normal walk');
            nw_pred = find(YPred(nw) == 'Normal walk');
            TPR     = numel(nw_pred)/numel(nw); % True Positive Rate
            sw      = find(YTest == 'Silly walk');
            sw_pred = find(YPred(sw) == 'Silly walk');
            TNR     = numel(sw_pred)/numel(sw); % True Negative Rate
            
            balanced_accuracy = (TPR + TNR)/2 * 100;
            if isnan(balanced_accuracy)
                balanced_accuracy = 0;
            end
            % store yielded accuracy of model under test
            results{i, j, k} = [accuracy, balanced_accuracy];
        end
        
        performanceIndicators = [results{i, j, :}];
        accMean = mean(performanceIndicators(1:2:end));
        balAccMean = mean(performanceIndicators(2:2:end));
        
        % store mean value of all datasets for the model under test
        meanPerf{i, j} = [accMean, balAccMean];
        
        clear model
    end
end

%% determine optimal models
if testAll
    testIter = 1:size(meanPerf, 1);
else
    testIter = 2:3;
end
% determine best performing model by mean accuracy on all data
optimalModel.mean.mean = 0;
optimalModel.mean.iMax = 0;
optimalModel.mean.jMax = 0;
for i = testIter
    for j = 1:size(meanPerf, 2)
        if ~isempty(meanPerf{i, j})
            meanTmp = meanPerf{i, j}(2);
            
            if meanTmp > optimalModel.mean.mean
                optimalModel.mean.mean = meanTmp;
                optimalModel.mean.iMax = i;
                optimalModel.mean.jMax = j;
            end
        end
        
    end
end

% determine best performing model by balanced accuracy on training data
optimalModel.balAccTra.balAcc = 0;
optimalModel.balAccTra.iMax = 0;
optimalModel.balAccTra.jMax = 0;
for i = testIter
    for j = 1:size(meanPerf, 2)
        if ~isempty(meanPerf{i, j})
            balAccTmp = results{i, j, 1}(2);
            
            if balAccTmp > optimalModel.balAccTra.balAcc
                optimalModel.balAccTra.balAcc = balAccTmp;
                optimalModel.balAccTra.iMax = i;
                optimalModel.balAccTra.jMax = j;
            end
        end
        
    end
end

% determine best performing model by balanced accuracy on test data
optimalModel.balAccTst.balAcc = 0;
optimalModel.balAccTst.iMax = 0;
optimalModel.balAccTst.jMax = 0;
for i = testIter
    for j = 1:size(meanPerf, 2)
        if ~isempty(meanPerf{i, j})
            balAccTmp = results{i, j, 2}(2);
            
            if balAccTmp > optimalModel.balAccTst.balAcc
                optimalModel.balAccTst.balAcc = balAccTmp;
                optimalModel.balAccTst.iMax = i;
                optimalModel.balAccTst.jMax = j;
            end
        end
        
    end
end

% determine best performing model by balanced accuracy on validation data
optimalModel.balAccVal.balAcc = 0;
optimalModel.balAccVal.iMax = 0;
optimalModel.balAccVal.jMax = 0;
for i = testIter
    for j = 1:size(meanPerf, 2)
        if ~isempty(meanPerf{i, j})
            balAccTmp = results{i, j, 3}(2);
            
            if balAccTmp > optimalModel.balAccVal.balAcc
                optimalModel.balAccVal.balAcc = balAccTmp;
                optimalModel.balAccVal.iMax = i;
                optimalModel.balAccVal.jMax = j;
            end
        end
        
    end
end

% save name of the model in the struct for easy retrieval
optimalModel.mean.modelName = models{optimalModel.mean.iMax, optimalModel.mean.jMax};
optimalModel.balAccTra.modelName = models{optimalModel.balAccTra.iMax, optimalModel.balAccTra.jMax};
optimalModel.balAccTst.modelName = models{optimalModel.balAccTst.iMax, optimalModel.balAccTst.jMax};
optimalModel.balAccVal.modelName = models{optimalModel.balAccVal.iMax, optimalModel.balAccVal.jMax};

% save model names, results and optimal model information
save(append(optimizationDir, benchmarkFileName), 'results', 'models', 'meanPerf', 'optimalModel');

tEnd = toc(tStart);
disp(append("Total runtime: ", string(tEnd), "s for ", num2str(modelCounter), " models"))
disp(append("Cycle time: ", string(tEnd/modelCounter), "s per model"))

%% print results
disp("#> results")
% mean optimal model
tmpResults = [results{optimalModel.mean.iMax, optimalModel.mean.jMax, :}];
disp(append("##> mean optimal model: ", models{optimalModel.mean.iMax, optimalModel.mean.jMax}))
disp("balanced accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.mean.iMax, optimalModel.mean.jMax}(2), tmpResults(2:2:end)])
disp("accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.mean.iMax, optimalModel.mean.jMax}(1), tmpResults(1:2:end)])

% training optimal model
tmpResults = [results{optimalModel.balAccTra.iMax, optimalModel.balAccTra.jMax, :}];
disp(append("##> training optimal model: ", models{optimalModel.balAccTra.iMax, optimalModel.balAccTra.jMax}))
disp("balanced accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccTra.iMax, optimalModel.balAccTra.jMax}(2), tmpResults(2:2:end)])
disp("accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccTra.iMax, optimalModel.balAccTra.jMax}(1), tmpResults(1:2:end)])

% testing optimal model
tmpResults = [results{optimalModel.balAccTst.iMax, optimalModel.balAccTst.jMax, :}];
disp(append("##> testing optimal model: ", models{optimalModel.balAccTst.iMax, optimalModel.balAccTst.jMax}))
disp("balanced accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccTst.iMax, optimalModel.balAccTst.jMax}(2), tmpResults(2:2:end)])
disp("accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccTst.iMax, optimalModel.balAccTst.jMax}(1), tmpResults(1:2:end)])

% validation optimal model
tmpResults = [results{optimalModel.balAccVal.iMax, optimalModel.balAccVal.jMax, :}];
disp(append("##> validation optimal model: ", models{optimalModel.balAccVal.iMax, optimalModel.balAccVal.jMax}))
disp("balanced accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccVal.iMax, optimalModel.balAccVal.jMax}(2), tmpResults(2:2:end)])
disp("accuracy (mean, train, test, validation)")
disp([meanPerf{optimalModel.balAccVal.iMax, optimalModel.balAccVal.jMax}(1), tmpResults(1:2:end)])
