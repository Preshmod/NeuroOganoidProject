% Script to train KNN model on predictors of mitotic nuclei, non-mitotic nuclei and
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
X.ImageName = [];     % Or whatever the name of the column is


% ---- Split into Training and Testing Sets ----

% Perform 70/30 train-test split using cross-validation object
cv = cvpartition(size(X,1),'HoldOut',0.20);

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

% ---- Train the Model ----
KnnModel = fitcknn(... 
XTrain, ...
YTrain, ...
'Distance', 'correlation', ...
'Exponent', [], ...
'NumNeighbors', 3, ...
'DistanceWeight', 'inverse', ...
'Standardize', true, ...
'ClassNames', categories(YTrain));

YTestPred_knn = predict(KnnModel, XTest);
YTestPred_knn = categorical(YTestPred_knn);

%Accuracy
accuracyKNN = mean(YTestPred_knn == YTest);
fprintf('KNN Test Accuracy: %.2f%%\n', accuracyKNN * 100);

% Save the trained model
save('trainedKNNModel.mat', 'KnnModel');

%Display Confusion Matrix
figure;
confusionchart(YTest, YTestPred_knn);
title('Test Set KNN Confusion Matrix');


