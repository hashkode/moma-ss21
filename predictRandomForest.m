function YPred = predictRandomForest(model, TestFeatures)
%PREDICTRANDOMFOREST Apply the Random Forest model to the test data to yield predictions
%   This function applies the trained Random Forest @model to the test data
%   vector @TestFeatures and returns the prediction vector @YPred.

[YPred,~] = predict(model, TestFeatures);
end
