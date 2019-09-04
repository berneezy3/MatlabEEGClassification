% testClassifyPredict.m
% ---------------------
% Nathan - Aug 26, 2019
%
% Testing expected successful and unsuccessful calls to classifyPredict.m.

clear all; close all; clc

rng('shuffle');

% S06.mat should be in UnitTests directory
uiwait(msgbox('In the next window, select the directory containing the .mat file ''S06.mat.'''))
inDir = uigetdir(pwd);
currDir = pwd;
cd(inDir)
load('S06.mat');
cd(currDir)
%%
[dim1, dim2, dim3] = size(X);
X_2D = reshape(X, [dim1*dim2, dim3]);
X_2D = X_2D';

%% Classification and prediction with 2D data using LDA
% Issue related to the random seed:
%    - Although the confusion matrices are the same for both runs, the
%      C.predY and C1.predY vectors are different.
%      ### BERNARD UPDATE:  C.predY and C1.predY should now be equal ###

trainData = X_2D(1:floor(dim3/5), :);
trainLabels = labels6(1:floor(dim3/5));
testData = X_2D(floor(dim3/5)+1:dim3, :);
testLabels = labels6(floor(dim3/5)+1:dim3);

%% Classification and prediction with 2D data using LDA and random seed
% Run successfully, predictions are the same in both models
% Issue:
%    - CM is no longer in the struct

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3), 'randomSeed', 1);

M1 = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1);
C1 = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3), 'randomSeed', 1);

figure; plotMatrix(C1.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%% Classification and prediction with 2D data using random forest
% Runs successfully, and CM looks OK.
% Issue:

%    - Why is PCA being run here? 
%   ### Bernard: PCA is turned to .99 by default ###
%    - Error using classifyPredict (line 103)
%      Expected a string for the parameter name, instead the input type was 'double'.

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'RF', 'numTrees', 200, 'minLeafSize', 1);
C = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3));

figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%% Classification and prediction with 2D data using SVM
% Issues:
%    - Output CM does not make any sense 
%    - Already stated in testClassifyTrain.m, but even though {'PCA', 0} is
%      set, PCA is being run.  However, if we do not input the kernel
%      name-value pair, PCA is not run (which is expected). (FIXED)
%    - Error using classifyPredict (line 103)
%      Expected a string for the parameter name, instead the input type was 'double'.

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'SVM', 'PCA', 0, 'kernel', 'rbf');
C = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3));

figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%% Classification and prediction with 2D data using SVM
% Issues:
%    - Run PCA with 1000 components, output CM does not make sense

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'SVM', 'kernel', 'rbf', 'PCA', 1000);
C = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3));
figure; plotMatrix(C.CM, 'matrixLabels', 0, 'colorMap', 'jet');

%% Classification and prediction with 2D data using pairwise and LDA
% Runs successfully

M = classifyTrain( X_2D(1:floor(dim3/5), :) , labels6(1:floor(dim3/5)), 'classifier', 'LDA', 'PCA', 0, 'randomSeed', 1, 'pairwise', 1);
C = classifyPredict( M, X_2D(floor(dim3/5)+1:dim3, :),  labels6(floor(dim3/5)+1:dim3), 'randomSeed', 1);







