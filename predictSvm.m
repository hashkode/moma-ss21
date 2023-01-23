function YPred = predictSvm(model, TestFeatures)
%PREDICTSVM Apply the SVM model to the test data to yield predictions
%   This function applies the trained SVM @model to the test data vector
%   @TestFeatures and returns the prediction vector @YPred.

[YPred,~] = predict(model, TestFeatures);
end
