% *** UPDATE MODEL SETTINGS ***
% Script to update model settings during working process

%% update model settings and/or classifiers
% apply the settings to the model files from the specified directory
modelDir = [];
modelFileMask = '_t-';
modelFileNames = dir(modelDir);
modelFileNames = filterFileStruct(modelFileNames, modelFileMask, '.mat');

load('Model.mat')
base = model;
clear model
% iterate over all models of the specified directory
for i = 1:size(modelFileNames, 1)
    load(append(modelDir, modelFileNames(i)))
    
    % update classifier from base model
    % e.g.: model.settings.feature.parfor = true;
%     model.lstm1 = base.lstm1;
%     model.lstm2 = base.lstm2;
%     model.lstm3 = base.lstm3;
%     model.svm = base.svm;
%     model.settings.svm = base.settings.svm;
    
    % change model struct properties
    % e.g.: model.settings.feature.parfor = true;
%     svm = model.settings.feature;
%     rf = model.settings.feature;
%     rf.nTrainIterations = model.settings.rf.nTrainIterations;
%     model.settings.svm = svm;
%     model.settings.rf = rf;
%     model.settings = rmfield(model.settings, 'feature'); % remove the old filed name

    % store updated model
    save(append(modelDir, modelFileNames(i)), 'model');
    
    clear model
end