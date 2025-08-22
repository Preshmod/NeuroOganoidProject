

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
X.ImageName = [];     % Or whatever the name of the column is


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

% Hyperparameter optimization: Regularization strength (Lambda)
lambdas = [0.01, 0.1, 1, 10];
bestAcc = 0;

for i = 1:length(lambdas)
    template = templateLinear('Learner', 'logistic', 'Lambda', lambdas(i), 'Regularization', 'ridge');
    model = fitcecoc(XTrain, YTrain, 'Learners', template);
    predicted = predict(model, XTest);
    acc = sum(predicted == YTest) / numel(YTest);
    fprintf('Lambda: %.2f | Accuracy: %.2f%%\n', lambdas(i), acc*100);
    if acc > bestAcc
        bestAcc = acc;
        bestModel = model;
        bestPredicted = predicted;
    end
end


% Save the trained model
save('trainedLogisticRegressionModel.mat', 'bestModel');

% Compute classification metrics
cm = confusionmat(YTest, bestPredicted);
tp = diag(cm);
fp = sum(cm, 1)' - tp;
fn = sum(cm, 2) - tp;
precision = mean(tp ./ (tp + fp));
recall = mean(tp ./ (tp + fn));
f1 = 2 * (precision * recall) / (precision + recall);
fprintf('\nLogistic Regression Metrics:\nAccuracy: %.2f%%\nPrecision: %.2f\nRecall: %.2f\nF1-Score: %.2f\n', ...
    bestAcc*100, precision, recall, f1);


% Plot confusion matrix
figure;
confusionchart(YTest, bestPredicted);
title('Confusion Matrix - Best Logistic Regression Model');
saveas(gcf, 'confusion_logistic.png');


