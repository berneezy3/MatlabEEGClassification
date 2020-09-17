function obj = trainDevTestPart(numTrials, nFolds, trainDevTestSplit)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% obj = trainDevTestPart(numTrials, nFolds,)
% --------------------------------
% Bernard Wang, June 27, 2017
% 
% This class stores a cross-validation partition for data.  This constructor
% of this class takes in the number of train samples n and number of
% train k folds, then creates k partitions in the data.  This object is
% to be passed into the constructor cvData() later.
%
% This class is an alternative to the matlab cvpartition class.  The reason
% this class is used instead of the matlab cvpartition class is because the
% matlab class uses randomization to assign partitions.  In MatClassRSA, 
% data shuffling is handled in the preprocessing step, we choose to assign
% partitions sequentially.  
% 
% INPUT ARGS:
%   - trainDevTestSplit: %   'trainDevTestSplit' - This determines the size 
%       of the train, developement (AKA validation) and test set sizes 
%       for each fold of cross validation. 
%   - numTrials: number of train samples
%   - nFolds: number of folds
%
% OUTPUT ARGS:
%   - obj:  an object of the cvpart class

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
    


assert(n >= nFolds, 'first parameter, k, must be lager than second parameter, n');

obj.train = {};
obj.dev = {};
obj.test = {};

%initialize indices list
obj.folds = {};

%initialize number of sets
obj.NumTestSets = nFolds;

%get size of train/dev/test sets
train = trainDevTestSplit(1);
dev = trainDevTestSplit(2);
test = trainDevTestSplit(3);

%get remainder
remainder = rem(numTrials, nFolds);

% foldSize is the number of trials each fold
foldSize = floor(numTrials/nFolds);

%case divisible
if remainder == 0
    for i = 1:nFolds
        indices = zeros( n,1 );
        for j = 1:foldSize
            indices(j+(i-1)*foldSize) = 1;
        end
        trainIndices = indices == 0;
        trainIndices = trainIndices(1:trainSize);
        devIndices = devIndices(end - devSize: end);

        testIndices = indices == 1;
        
        obj.train{end+1} = trainIndices;
        obj.dev{end+1} = devIndices;
        obj.test{end+1} = testIndices;
    end
%case indivisible
else
    indexlocation = 0;
    for i = 1:nFolds-remainder
        indices = ones( n,1 );
        for j = 1:foldSize
            indices(j+(i-1)*foldSize) = 0;
            indexlocation = indexlocation + 1;
        end
        obj.train{end+1} = indices;
        obj.dev{end+1} = devIndices;
        obj.test{end+1} = 1-indices;
    end
    for i = 1:remainder
        %disp(indexlocation);
        indices = ones( n,1 );
        for j = 1:foldSize+1
            indices(j+(i-1)*foldSize+indexlocation+(i-1)) = 0;
        end
        obj.train{end+1} = indices;
        obj.dev{end+1} = devIndices;
        obj.test{end+1} = 1-indices;
    end
end

end


