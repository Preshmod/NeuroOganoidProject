% Script to train CNN model on images of mitotic nuclei, non-mitotic nuclei and
% miscellaneous objects


currdir = pwd;
addpath(pwd);
filedir = uigetdir();
cd(filedir);

cd("Training_Dataset\");
files=dir("*.png");
cd(filedir);


% Create datastore for training images
imds = imageDatastore('Training_Dataset', ...
    LabelSource='foldernames', ... 
    IncludeSubfolders=true, ... 
    FileExtensions='.png');


% Resize automatically when reading
inputSize = [64 64];  % must match your network input
imdsValidation.ReadFcn = @(filename) imresize(imread(filename), inputSize);


% Split the data into training, validation, and testing sets
[imdsTrain, imdsRest] = splitEachLabel(imds, 0.7, "randomized");
[imdsValidation, imdsTest] = splitEachLabel(imdsRest, 0.5, "randomized");

% Define the input size and number of classes
inputSize = [64 64 ];
numClasses = numel(categories(imds.Labels));
imageSize = [64 64 1];
imdsTrain.ReadFcn = @(filename)imresize(imread(filename), imageSize(1:2));
imdsValidation.ReadFcn = @(filename)imresize(imread(filename), imageSize(1:2));

% Define the layers of the network
layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(4, 8)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

% Set training options
options = trainingOptions('sgdm', ...
    'MaxEpochs', 15, ...
    'MiniBatchSize', 32, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 4, ...
    'ExecutionEnvironment','auto', ...
    'InitialLearnRate', 1.0000e-03, ...
    'Plots', 'training-progress', ...
    'Shuffle', 'every-epoch', ...
    'Verbose', false);

% Train the network
net = trainNetwork(imdsTrain, layers, options);

% Save the trained network
save('CNNmodel.mat', 'net');

% Evaluate the network on the test set
inputSize = [64 64 1];  % from your CNN input layer
augimdsValidation = augmentedImageDatastore(inputSize(1:2), imdsValidation);
YPred = classify(net, augimdsValidation);
YTrue = imdsValidation.Labels;
accuracy = sum(YPred == YTrue) / numel(YTrue);
fprintf('Test accuracy: %.2f%%\n', accuracy * 100);
