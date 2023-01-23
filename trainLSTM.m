function model = trainLSTM(XTrain, YTrain, numHiddenUnits, sortAxes)
%TRAINLSTM Train an LSTM classifier using the training features and labels
%   This function trains an LSTM classifier with the training feature vector
%   @features and the training label vector @labels. The third parameter
%   @numHiddenUnits specifies the amount of hidden units of the LSTM layer.
%   The parameter @sortAxes specifies, if Axes values should be reordered
%   by magnitude of their mean value.

% Prepare XTrain with z-score normalization of the training data and sort
% by magnitude of mean value if selected
if sortAxes
    for i = 1:size(XTrain, 1)
        acc(1, : , :) = normalize(XTrain{i}(1,:));
        acc(2, : , :) = normalize(XTrain{i}(2,:));
        acc(3, : , :) = normalize(XTrain{i}(3,:));
        
        meanAccX = abs(mean(XTrain{i}(1,:), 'all'));
        meanAccY = abs(mean(XTrain{i}(2,:), 'all'));
        meanAccZ = abs(mean(XTrain{i}(3,:), 'all'));
        
        [~, sorting] = sort([meanAccX, meanAccY, meanAccZ]);
        
        for j = 1:3
            XTrain{i, 1}(j,:) = reshape(acc(sorting(j), :, :), size(acc(j, : , :)));
        end
    end
else
    XTrain = zscoreNorm(XTrain);
end

% Initialize options and layers for training the neural network
inputSize = 3;
numClasses = 2;

layers = [
    sequenceInputLayer(inputSize)
    lstmLayer(numHiddenUnits, 'OutputMode', 'last')
    dropoutLayer(0.2)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

maxEpochs = 30;
batchSize = 20;
% Reduce number of epochs and batch size for matlab online
if strcmp(getenv('USER'), 'mluser') & strcmp(computer(),'GLNXA64') == 1
    maxEpochs = 1;
    batchSize = 1;
end

options = trainingOptions('sgdm', ...
    'MaxEpochs', maxEpochs, ...
    'MiniBatchSize', batchSize, ...
    'Shuffle', 'every-epoch', ...
    'Verbose', 0, ...
    'GradientThreshold', 1);

% Train the neural network model
model = trainNetwork(XTrain, YTrain, layers, options);
end
