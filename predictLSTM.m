function YPred = predictLSTM(model, XTest, sortAxes)
%PREDICTLSTM Apply the LSTM model to the test data to yield predictions
%   This function applies the trained LSTM @model to the test data vector
%   @XTest and returns the prediction vector @YPred. The parameter
%   @sortAxes specifies, if Axes values should be reordered by magnitude of
%   their mean value.

% Prepare XTrain with z-score normalization of the training data and sort
% by magnitude of mean value if selected
if sortAxes
    for i = 1:size(XTest, 1)
        acc(1, : , :) = normalize(XTest{i}(1,:));
        acc(2, : , :) = normalize(XTest{i}(2,:));
        acc(3, : , :) = normalize(XTest{i}(3,:));
        
        meanAccX = abs(mean(XTest{i}(1,:), 'all'));
        meanAccY = abs(mean(XTest{i}(2,:), 'all'));
        meanAccZ = abs(mean(XTest{i}(3,:), 'all'));
        
        [~, sorting] = sort([meanAccX, meanAccY, meanAccZ]);
        
        for j = 1:3
            XTest{i, 1}(j,:) = reshape(acc(sorting(j), :, :), size(acc(j, : , :)));
        end
    end
else
    XTest = zscoreNorm(XTest);
end

% Classify test data with pretrained model
YPred = classify(model, XTest);
end