function [M, varargout] = classifyTrain(X, Y, varargin)
% -------------------------------------------------------------------------
% [C, ] = classifyTrain(X, Y)
% -------------------------------------------------------------------------
% Blair/Bernard - Feb. 22, 2017
%
% The main function for fitting data to create a model.  
%
% INPUT ARGS (REQUIRED)
%   X - training data
%   Y - labels
%
% INPUT ARGS (OPTIONAL NAME-VALUE PAIRS)
%   'timeUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the time dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       time dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'spaceUse' - If X is a 3D, space-by-time-by-trials matrix, then this
%       option will subset X along the space dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       space dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 2D, trials-by-feature matrix.
%   'featureUse' - If X is a 2D, trials-by-features matrix, then this
%       option will subset X along the features dimension.  The input
%       argument should be passed in as a vector of indices that indicate the 
%       feature dimension indices that the user wants to subset.  This arugument 
%       will not do anything if input matrix X is a 3D,
%       space-by-time-by-trials matrix.
%   'randomSeed' - This option determines whether the randomization is to produce
%       varying or unvarying results each different execution.  The value
%       of this parameter is passed into the Matlab rng() function.
%        --options--
%       'shuffle' (default)
%       'default' (replicate results)
%   'shuffleData' - determine whether to shuffle the order of trials within 
%       training data matrix X (order of labels in the labels vector Y will be
%       shuffled in the same order)
%       --options--
%       1 - shuffle (default)
%       0 - do not shuffle
%   'averageTrials' - how to compute averaging of trials in X to increase accuracy
%       --options--
%       (negative value) - don't average
%       (postitive int) - number of integers to average over
%   'averageTrialsHandleRemainder' - Handle remainder trials (if any) from 
%       trial averaging 
%       --options--
%       'discard'
%       'newGroup'
%       'append'
%       'distribute'
%   'PCA' - Conduct Principal Component analysis on data matrix X. Default is to
%       keep components that explan 90% of the variance. To retrieve
%       components that explain a certain variance, enter the variance as a
%       decimal between 1 and 0.  To retrieve a certain number of most
%       significant features, enter an integer greater or equal to 1.
%       --options--
%       (decimal between 0 and 1, N) - Use most important features that
%           explain N * 100% of the variance in input matrix X.
%       (integer greater than or equal to 1, N) - Use N most important
%       features of input matrix X.
%   'classifier' - choose classifier. 
%        --options--
%       'SVM' (default)
%       'LDA' 
%       'RF' 
%   'kernel' - Choose the kernel for decision function for SVM.  This input will do
%       nothing if a classifier other than SVM is selected.
%        --options--
%       'linear' 
%       'polynomial' 
%       'rbf' (default)
%       'sigmoid' 
%   'numTrees' - Choose the number of decision trees to grow.  Default is
%   128.
%   'minLeafSize' - Choose the inimum number of observations per tree leaf.
%   Default is 1,
%
% OUTPUT ARGS 
%   M - Classification output produced by classifyTrain.  This contains two 
%   structs: M.mdl, which contains the model, and M.classifierInfo. which 
%   contains classifier related info.  Must pass M to classifyPredict() to
%   predict new data.

% TODO:
%   

% This software is licensed under the 3-Clause BSD License (New BSD License), 
% as follows:
% -------------------------------------------------------------------------
% Copyright 2017 Bernard C. Wang, Anthony M. Norcia, and Blair Kaneshiro
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
% 
% 1. Redistributions of source code must retain the above copyright notice, 
% this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright notice, 
% this list of conditions and the following disclaimer in the documentation 
% and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its 
% contributors may be used to endorse or promote products derived from this 
% software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ?AS IS?
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE 
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE 
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR 
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF 
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS 
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) 
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
% POSSIBILITY OF SUCH DAMAGE.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TODO : FINISH DOCSTRING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    tic
    
    %initialize output struct C
    C = struct;
    
    % Initialize the input parser
    ip = inputParser;
    ip.CaseSensitive = false;

    % ADD SPACEUSE TIMEUSE AND FEATUREUSE, DEAFULT SHOULD B EMPTY MATRIX
    
    %Specify default values
    defaultShuffleData = 1;
    defaultRandomSeed = 'shuffle';
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';
    defaultPCA = .99;
    defaultClassifier = 'SVM';
    defaultTimeUse = [];
    defaultSpaceUse = [];
    defaultFeatureUse = [];
    defaultKernel = 'rbf';
%   defaultDiscrimType = 'linear';
    defaultNumTrees = 64;
    defaultMinLeafSize = 1;


    %Specify expected values
    expectedAverageTrialsHandleRemainder = {'discard','newGroup', 'append', 'distribute'};
    expectedPCAinFold = [0,1];
    expectedClassifier = {'SVM', 'LDA', 'RF'};
    expectedKernel = {'linear', 'sigmoid', 'rbf', 'polynomial'};
    
    
    %Required inputs
    addRequired(ip, 'X', @(X) ndims(X)==3 || ismatrix(X)==1)
    addRequired(ip, 'Y', @isvector)
    [r c] = size(X);
    dataSize = size(X);

    %Optional positional inputs
    %addOptional(ip, 'distpower', defaultDistpower, @isnumeric);
    if verLessThan('matlab', '8.2')
        addParamValue(ip, 'shuffleData', defaultShuffleData, ...
            @(x) (x==1 || x==0));
        addParamValue(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParamValue(ip, 'averageTrialsHandleRemainder', ...
            defaultAverageTrialsHandleRemainder, ...
            @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
        addParamValue(ip, 'PCA', defaultPCA);
        %addParamValue(ip, 'PCAinFold', defaultPCAinFold);
        addParamValue(ip, 'nFolds', defaultNFolds);
        addParamValue(ip, 'classifier', defaultClassifier, ...
             @(x) any(validatestring(x, expectedClassifier)));
        addParamValue(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParamValue(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParamValue(ip, 'kernel', @(x) any(validatestring(x, expectedKernels)));
        addParamValue(ip, 'numTrees', 128);
        addParamValue(ip, 'minLeafSize', 1);
    else
        addParameter(ip, 'shuffleData', defaultShuffleData, ...
            @(x)  (x==1 || x==0));
        addParameter(ip, 'averageTrials', defaultAverageTrials, ...
            @(x) assert(rem(x,1) == 0 ));
        addParameter(ip, 'averageTrialsHandleRemainder', ...
            defaultAverageTrialsHandleRemainder, ...
            @(x) any(validatestring(x, expectedAverageTrialsHandleRemainder)));
        addParameter(ip, 'PCA', defaultPCA);
        addParameter(ip, 'classifier', defaultClassifier, ...
             @(x) any(validatestring(x, expectedClassifier)));
        addParameter(ip, 'timeUse', defaultTimeUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'spaceUse', defaultSpaceUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'featureUse', defaultFeatureUse, ...
            @(x) (assert(isvector(x))));
        addParameter(ip, 'randomSeed', defaultRandomSeed,  @(x) isequal('default', x)...
            || isequal('shuffle', x) || (isnumeric(x) && x > 0));
        addParameter(ip, 'kernel', 'rbf', @(x) any(validatestring(x, expectedKernels)));
        addParameter(ip, 'numTrees', 128);
        addParameter(ip, 'minLeafSize', 1);
    end
    
    %Optional name-value pairs
    %NOTE: Should use addParameter for R2013b and later.

    % Parse
    try 
        parse(ip, X, Y, varargin{:});
    catch ME
        disp(getReport(ME,'extended'));
    end
    
    % check input data 
    checkInputData(X, Y);
    
    % this function contains input checking functions
    [X, Y, nSpace, nTime, nTrials] = subsetTrainTestMatrices(X,Y, ...
                                                    ip.Results.spaceUse, ...
                                                    ip.Results.timeUse, ...
                                                    ip.Results.featureUse);

                    
    defaultShuffleData = 1;
    defaultRandomSeed = 'shuffle';
    defaultAverageTrials = -1;
    defaultAverageTrialsHandleRemainder = 'discard';

    % SET RANDOM SEED
    % for data shuffling and permutation testing purposes
    rng(ip.Results.randomSeed);
    
    % DATA SHUFFLING (doing)
    % Default 1
    if (ip.Results.shuffleData)
        disp('Shuffling Trials...');
        [X, Y, shuffledInd] = shuffleData(X, Y);
    else
        classifierInfo.shuffleData = 'off';
        Y = Y';
    end

    % TRIAL AVERAGING (doing)
     if(ip.Results.averageTrials >= 1)
        disp('Averaging Trials...');
        [X, Y] = averageTrials(X, Y, ip.Results.averageTrials, ...
            'handleRemainder' ,ip.Results.averageTrialsHandleRemainder);
        classifierInfo.averageTrials = 'on';
        [r c] = size(X);
     end

    
    trainData = X;
    % PCA
    if (ip.Results.PCA > 0)
        disp('Conducting Principal Component Analysis...')
        [trainData, V, nPC] = getPCs(trainData, ip.Results.PCA);
%         testData = X*V;
%         testData = testData(:,1:nPC); 
    else 
        disp('Principal Component Analysis turned off')
        V = NaN;
        nPC = NaN;
    end
    
    % Train Model
    disp('Training Model...')
    mdl = fitModel(trainData, Y', ip);
    
    % create classifier info struct
    classifierInfo = struct('averageTrials', ip.Results.averageTrials, ...
                        'averageTrialsHandleRemainder', ip.Results.averageTrialsHandleRemainder, ...
                        'PCA', ip.Results.PCA, ...
                        'classifier', ip.Results.classifier, ...
                        'spaceUse', ip.Results.spaceUse, ...
                        'timeUse',ip.Results.timeUse, ...
                        'featureUse', ip.Results.featureUse, ...
                        'shuffleData', ip.Results.shuffleData,...
                        'randomSeed', ip.Results.randomSeed,...
                        'PCA_V', V,...
                        'PCA_nPC', nPC,...
                        'trainingDataSize', dataSize);

    M.mdl = mdl;
    M.classifierInfo = classifierInfo;
    

    
    disp('Training Finished...')
    disp('Returning Model')

    toc    
    return;

end