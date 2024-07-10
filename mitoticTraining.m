

imds = imageDatastore("nuclei_training", ...
    LabelSource="foldernames", ... 
    IncludeSubfolders=true, ... 
    FileExtensions=".png");

% Split the data into training and testing sets
[imdsTrain, imdsTest] = splitEachLabel(imds, 0.7, "randomized");

% Define the input size and number of classes
inputSize = [22 22 1];
numClasses = numel(categories(imds.Labels));

% Define the layers of the network
layers = [
    imageInputLayer(inputSize)
    convolution2dLayer(5, 20)
    batchNormalizationLayer
    reluLayer
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

% Set training options
options = trainingOptions("sgdm", ...
    'MaxEpochs', 15, ...
    'Verbose', false, ...
    'Plots', "training-progress", ...
    'ExecutionEnvironment', 'auto', ...
    'MiniBatchSize', 32, ...
    'InitialLearnRate', 1e-3, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 3);

% Train the network
net = trainNetwork(imdsTrain, layers, options);

% Evaluate the network on the test set
YPred = classify(net, imdsTest);
YTest = imdsTest.Labels;
accuracy = sum(YPred == YTest) / numel(YTest);
fprintf('Test accuracy: %.2f%%\n', accuracy * 100);