% Script to train model on images of mitotic nuclei, non-mitotic nuclei and
% miscellaneous objects

% Create datastore for training images
imds = imageDatastore("nuclei_training", ...
    LabelSource="foldernames", ... 
    IncludeSubfolders=true, ... 
    FileExtensions=".png");

% Split the data into training, validation, and testing sets
[imdsTrain, imdsRest] = splitEachLabel(imds, 0.7, "randomized");
[imdsValidation, imdsTest] = splitEachLabel(imdsRest, 0.5, "randomized");

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
    'MaxEpochs', 10, ...
    'Verbose', false, ...
    'Plots', "training-progress", ...
    'ExecutionEnvironment', 'auto', ...
    'MiniBatchSize', 16, ...
    'InitialLearnRate', 1e-3, ...
    'ValidationData', imdsValidation, ...
    'ValidationFrequency', 3);

% Train the network
net = trainNetwork(imdsTrain, layers, options);

% Save the trained network
save('trainedNetwork.mat', 'net');

% Evaluate the network on the test set
YPred = classify(net, imdsTest);
YTest = imdsTest.Labels;
accuracy = sum(YPred == YTest) / numel(YTest);
fprintf('Test accuracy: %.2f%%\n', accuracy * 100);