% *** PERMUTATION MATRIX ***
% Script to create new models by permutation of already created models

%% build RF and SVM permutation
% specify output location
tStart = tic;

outDir = "merge/merged/";
if ~exist(outDir, 'dir')
    mkdir(outDir)
end

% specify locations to SVM and RF models
modelFileMask = '_t-';
svmDir = 'merge/svm/';
svmFileNames = dir(svmDir);
svmFileNames = filterFileStruct(svmFileNames, modelFileMask, '.mat');

rfDir = 'merge/rf/';
rfFileNames = dir(rfDir);
rfFileNames = filterFileStruct(rfFileNames, modelFileMask, '.mat');

% load base model with benchmarked lstm models
load('Model.mat')
baseModel = model;
clear model
% iterate over all models of the specified directory
for i = 1:size(svmFileNames, 1)
    disp(append("#> svm ", num2str(i)))
    load(append(svmDir, svmFileNames(i)))
    svmModel = model;
    for j = 1:size(rfFileNames, 1)
        disp(append("#> rf ", num2str(j)))
        load(append(rfDir, rfFileNames(j)))
        
        % replace svm model and settings
        model.svm = svmModel.svm;
        model.settings.svm = svmModel.settings.svm;
               
        % replace lstm models and settings
        model.lstm1 = baseModel.lstm1;
        model.lstm2 = baseModel.lstm2;
        model.lstm3 = baseModel.lstm3;
        model.settings.lstm1 = baseModel.settings.lstm1;
        model.settings.lstm2 = baseModel.settings.lstm2;
        model.settings.lstm3 = baseModel.settings.lstm3;
        
        % store updated model
        [~, svmName, ~] = fileparts(svmFileNames(i));
        [~, rfName, ~] = fileparts(rfFileNames(j));
        save(append(outDir, "mrg", svmName, "+", rfName), 'model');
    end
end

tEnd = toc(tStart);
disp(append("Total runtime: ", string(tEnd), "s for ", num2str(i*j), " models"))
disp(append("Cycle time: ", string(tEnd/(i*j)), "s per model"))