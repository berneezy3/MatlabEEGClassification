function [obj, V, nPC, colMeans, colScales] = cvData(X, Y, trainDevTestSplit, ip, center, scale, nFolds)
% cvDataObj = cvData_opt(X,Y, partition, PCA, PCAinFold);
% --------------------------------
% Bernard Wang, August 17, 2017
% 
% cvData is an object that stores data to be used for cross validation.  It
% It takes as input the data matrix, X, and the label vector Y, the 
% trainDevTestSplit object and the PCA parameters specificed in the 
% classifyCrossValidate() function call.  It formats the data into 
% partitions to enable convineint cross validationlater.  
% 
% INPUT ARGS:
%   - X: training data (2D)
%   - Y: labels
%   - partition: object of class trainDevTestSplit
%   - PCA: ip.Results.PCA parameter specified in classifyCrossValidate() 
%   - kPCAinFold: ip.Results.PCAinFold specified in classifyCrossValidate() 
%
% OUTPUT ARGS:
%   - obj:  an object of the trainDevTestSplit class

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
    

    PCA = ip.Results.PCA;
    PCAinFold = ip.Results.PCAinFold;

    if (isfield(ip.Results,'nFolds'))
        nFolds = ip.Results.nFolds;
    else 
        nFolds = 1;
    end

    obj = struct();
    obj.optimize = trainDevTestSplit.optimize;

    trainXall = {};
    devXall = {};
    testXall = {};
    trainYall = {};
    devYall = {};
    testYall = {};
    
    % initialize return variables for train functions
    V = NaN;
    nPC = NaN;
    colMeans = NaN;
    colScales = NaN;
    

    if (strcmp(center, 'on'))
        center = true;
    else
        center = false;
    end
    if (strcmp(scale, 'on'))
        scale = true;
    else
        scale = false;
    end
    
    %parpool;
    % DO PCA
    if (PCA >0)
        % outside of folds
        if (PCAinFold == 0)
%             disp('Conducting PCA on once on entire dataset');
            [X, colMeans, colScales] = centerAndScaleData(X, center, scale);
            [X, V, nPC] = getPCs(X, PCA);

            for i = 1:trainDevTestSplit.NumTestSets
                trainIndx = find(trainDevTestSplit.train{i});
                devIndx = find(trainDevTestSplit.dev{i});
                testIndx = find(trainDevTestSplit.test{i});

                trainX = X(trainIndx, :);
                trainY = Y(trainIndx);
                devX = X(devIndx, :);
                devY = Y(devIndx);
                testX = X(testIndx, :);
                testY = Y(testIndx);

                trainXall = [trainXall {trainX}];
                devXall = [devXall {devX}];
                testXall = [testXall {testX}];
                trainYall = [trainYall {trainY}];
                devYall = [devYall {devY}];
                testYall = [testYall {testY}];
            end
        % inside folds    
        else
            [r c] = size(X);

            for i = 1:nFolds
%                 disp(['  fold ' num2str(i) ' of ' num2str(trainDevTestSplit.NumTestSets)]);                
                trainIndx = find(trainDevTestSplit.train{i});
                devIndx = find(trainDevTestSplit.dev{i});
                testIndx = find(trainDevTestSplit.test{i});

                trainX = X(trainIndx, :);
                % center and scale training data
                [trainX, colMeans, colScales] = ...
                    centerAndScaleData(trainX, center, scale);
                trainY = Y(trainIndx);

                devX = X(devIndx, :);
                testX = X(testIndx, :);
                % accordingly center and scale test data
                    [testX, ~, ~] = centerAndScaleData(testX, colMeans, colScales);
                    [devX, ~, ~] = centerAndScaleData(devX, colMeans, colScales);
                devY = Y(devIndx);    
                testY = Y(testIndx);

                % PCA after data center/scaling
                if (PCAinFold == 1)
                    [trainX, V, nPC] = getPCs(trainX, PCA);
                    testX = testX*V;
                    testX = testX(:,1:nPC);
                    devX = devX*V;
                    devX = devX(:,1:nPC);
                end
                trainXall = [trainXall {trainX}];
                devXall = [devXall {devX}];
                testXall = [testXall {testX}];
                trainYall = [trainYall {trainY}];
                devYall = [devYall {devY}];
                testYall = [testYall {testY}];        
            end

        end
    % DONT DO PCA
    else
        if (~isnan(center) && ~isnan(scale))
            [X, ~, ~] = centerAndScaleData(X, center, scale);
        end
        for i = 1:nFolds
            trainIndx = find(trainDevTestSplit.train{i});
            devIndx = find(trainDevTestSplit.dev{i});
            testIndx = find(trainDevTestSplit.test{i});
            trainX = X(trainIndx, :);
            trainY = Y(trainIndx);
            devX = X(devIndx, :);
            devY = Y(devIndx);
            testX = X(testIndx, :);
            testY = Y(testIndx);

            trainXall = [trainXall {trainX}];
            devXall = [devXall {devX}];
            testXall = [testXall {testX}];
            trainYall = [trainYall {trainY}];
            devYall = [devYall {devY}];
            testYall = [testYall {testY}];
        end
        
        colMeans = 0;
        colScales = 0;
        [r c] = size(X);
        nPC = c;

    end
    obj.trainXall = trainXall;
    obj.devXall = devXall;
    obj.testXall = testXall;
    obj.trainYall = trainYall;
    obj.devYall = devYall;
    obj.testYall = testYall;
end
      
