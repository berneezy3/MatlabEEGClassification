function pairwiseCellMat = initPairwiseCellMat(numClasses)
%-------------------------------------------------------------------
% (c) Bernard Wang and Blair Kaneshiro, 2017.
% Published under a GNU General Public License (GPL)
% Contact: bernardcwang@gmail.com
%-------------------------------------------------------------------
% pairwiseCellMat = initPairwiseCellMat(numClasses)
% --------------------------------
% Bernard Wang, Sept 28, 2019
%
% Initializes an empty 2 x 2 x (numClasses choose 2) matrix for pairwise
% classification
% 
% INPUT ARGS:
%   - numClasses: number of classes in pairwise classification
%
% OUTPUT ARGS:
%   - pairwiseCellMat: an empty 2 x 2 x (numClasses choose 2) matrix
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

    
    pairwiseCellMat = cell(numClasses);
    for cat1 = 1:numClasses-1
        for cat2 = (cat1+1):numClasses
            tempStruct = struct();
            tempStruct.CM = zeros(2);
            tempStruct.classBoundary = [num2str(cat1) ' vs. ' num2str(cat2)];
            tempStruct.accuracy = NaN;
%             tempStruct.dataPoints = NaN;
%             tempStruct.predictions = NaN;
            pairwiseCellMat{cat1, cat2} = tempStruct;
            pairwiseCellMat{cat2, cat1} = tempStruct;
        end
    end

    for i = 1:numClasses
         pairwiseCellMat{i,i} = NaN;
    end



end