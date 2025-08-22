% Script to train RM model on predictors of mitotic nuclei, non-mitotic nuclei and
% miscellaneous objects



% ---- Load and preprocess data ----

% Loading tables for each class
T1 = readtable('Training_Dataset\dividing_nuclei\dividing_nucleus_features.csv');

T2 = readtable('Training_Dataset\interphase_nuclei\interphase_nucleus_features.csv');

T3 = readtable('Training_Dataset\miscellaneous\miscellaneous_features.csv');

% Combine all into one table
X = [T1; T2; T3];


% ---- Encode Class Labels Numerically ----

% Difine class names and corresponding numeric labels 
k=["dividing","interphase","miscellaneous"];

% Assign numeric codes to each class
l=[0,1,2]; 

% Extract the original class label column(text)
g=X.Class;

% Preallocate array to store numeric labes
number=zeros(length(g),1);

% Assign numeric label for each row
for i=1:length(k)
    rs=ismember(g,k(i));
    number(rs)=l(i);
end

% Add encoded labels as new column
X.category_encoded=number;

% Remove the original string class label column and image name
X.Class=[];
X.ImageName = [];     

% ---- Split into Training and Testing Sets ----

% Perform 70/30 train-test split using cross-validation object
cv = cvpartition(size(X,1),'HoldOut',0.3);

% Get logical indexing for test samples
idx = cv.test;

% Create training and test sets
dataTrain = X(~idx,:);
dataTest = X(idx,:);

% Separate test features (exclude label column for prediction)
% Extract features and labels
XTrain = dataTrain(:, 1:end-1);             
YTrain = categorical(dataTrain.category_encoded);

XTest  = dataTest(:, 1:end-1);              
YTest  = categorical(dataTest.category_encoded);

XTrain(:, {'Eccentricity', 'Orientation', 'Extent', 'Solidity', 'MinIntensity'}) = [];  % remove directly
XTest(:, {'Eccentricity', 'Orientation', 'Extent', 'Solidity', 'MinIntensity'}) = [];

finalModel = fitcensemble(...
    XTrain, ...
    YTrain, ...
    'Method', 'Bag', ...
    'NumLearningCycles', 100, ...
    'Learners', templateTree('MaxNumSplits', 12), ...
    'ClassNames', categories(YTrain));


% Predict on Test Data
YTestPred = predict(finalModel, XTest);

% ---- Make Predictions & Evaluate Accuracy ----

% Compute test accuracy
testAccuracy = mean(YTestPred == YTest);
fprintf('Test Set Accuracy: %.2f%%\n', testAccuracy * 100);

% Save the trained model
save('trainedRandomForestModel.mat', 'finalModel');

% Display confusion matrix
figure;
confusionchart(YTest, YTestPred);
title('Test Set Confusion Matrix');

% ---- Evaluating the prediction accuracy ----

YTestPred = predict(finalModel, XTest);  % or XTest_reduced if you're using fewer features
YTestPred = categorical(YTestPred);  % make sure it's categorical
YTest = categorical(YTest);          % already done earlier

% Get confusion matrix
[confMat, order] = confusionmat(YTest, YtestPred);

numClasses = size(confMat, 1);
precision = zeros(numClasses, 1);
recall    = zeros(numClasses, 1);
f1score   = zeros(numClasses, 1);

for i = 1:numClasses
    TP = confMat(i,i);
    FP = sum(confMat(:,i)) - TP;
    FN = sum(confMat(i,:)) - TP;
    
    precision(i) = TP / (TP + FP + eps);  % eps avoids divide-by-zero
    recall(i)    = TP / (TP + FN + eps);
    f1score(i)   = 2 * (precision(i) * recall(i)) / (precision(i) + recall(i) + eps);
end

% Display
for i = 1:numClasses
    fprintf('Class: %s\n', string(order(i)));
    fprintf('  Precision: %.2f%%\n', precision(i)*100);
    fprintf('  Recall: %.2f%%\n', recall(i)*100);
    fprintf('  F1-score: %.2f%%\n\n', f1score(i)*100);
end



% ---- Testing the importance of predictors 

imp = predictorImportance(finalModel);
bar(imp);
xticks(1:length(imp));                 % Ensure tick positions match bar count
xticklabels(model.PredictorNames); % Use correct predictor names
xtickangle(45);
ylabel('Importance Score');             % <-- Added y-axis label
title('Predictor Importance (Fitensemble)');
% Use stastical analysis eg ANOVA to test predictors 

for i = 1:(width(dataTrain)-1)
    p = anova1(dataTrain{:,i}, dataTrain.category_encoded, 'off');
    fprintf('%s: p-value = %.4f\n', dataTrain.Properties.VariableNames{i}, p);
end







