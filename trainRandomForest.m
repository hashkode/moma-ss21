function model = trainRandomForest(features, labels, nIterations)
%TRAINRANDOMFOREST Train a Random Forest classifier using the training features and labels
%   This function trains a Random Forest classifier with the training
%   feature vector @features and the training label vector @labels. The
%   training process is executed for @nIterations training cycles.

% initialize MATLAB rng to yield repeatable results
rng(0)

% select type from 'Tree' or 'Subspace'
% select subtype from
% Tree: 'AdaBoostM1', 'LogitBoost', 'GentleBoost', 'RobustBoost',
%       'LPBoost', 'TotalBoost', 'RUSBoost', 'Bag', 'TreeBagger'
% Subspace: 'Discriminant', 'KNN'
type = 'Tree';
subtype = 'Bag';

switch type
    case 'Tree'
        switch subtype
            case 'AdaBoostM1'
                model = fitensemble(features, labels, 'AdaBoostM1', nIterations, 'Tree');
            case 'LogitBoost'
                model = fitensemble(features, labels, 'LogitBoost', nIterations, 'Tree');
            case 'GentleBoost'
                model = fitensemble(features, labels, 'GentleBoost', nIterations, 'Tree');
            case 'RobustBoost'
                model = fitensemble(features, labels, 'RobustBoost', nIterations, 'Tree');
            case 'LPBoost'
                model = fitensemble(features, labels, 'LPBoost', nIterations, 'Tree');
            case 'TotalBoost'
                model = fitensemble(features, labels, 'TotalBoost', nIterations, 'Tree');
            case 'RUSBoost'
                model = fitensemble(features, labels, 'RUSBoost', nIterations, 'Tree');
            case 'Bag'
                tT = templateTree('Reproducible', true);
                model = fitensemble(features, labels, 'Bag', nIterations, 'Tree', 'Type', 'classification', 'Learners', tT);
            case 'TreeBagger'
                nTrees = 20;
                model = TreeBagger(nTrees, features, labels, 'Method', 'classification');
            otherwise
                error("Unknown combination of type and subtype for function trainRandomForest");
        end
    case 'Subspace'
        switch subtype
            case 'Discriminant'
                model = fitensemble(features, labels, 'Subspace', nIterations, 'Discriminant', 'Type', 'classification');
            case 'KNN'
                model = fitensemble(features, labels, 'Subspace', nIterations, 'KNN', 'Type', 'classification');
            otherwise
                error("Unknown combination of type and subtype for function trainRandomForest");
        end
    otherwise
        error("Unknown combination of type and subtype for function trainRandomForest");
end
end
