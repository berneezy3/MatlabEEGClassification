function [RDM, params] = computeClassificationRDM(M, matrixType, varargin)
%-------------------------------------------------------------------
% [RDM, params] = computeClassification_RDM(M, matrixType, varargin)
% ------------------------------------------------------------------
% Blair - January 31, 2017, revised July-September 2019
%
% [RDM, params] = computeClassification_RDM(M, matrixType, varargin)
% converts classifier output (multicategory confusion matrix or matrix of
% pairwise accuracies) into an RDM.
%
% Required inputs:
% - M: A square confusion matrix or matrix of pairwise accuracies.
% - matrixType: String specifying the type of input matrix.
%   -- Enter 'p', 'pair', 'pairs', or 'pairwise' if inputting a matrix of
%     pairwise accuracies (values between 0 and 1.0).
%   -- Enter 'm', 'multi', 'multiclass', or 'multicategory' if inputting a
%     confusion matrix from multicategory classification (typically a
%     matrix of counts).
%
% Optional name-value pairs:
% - 'normalize': 'diagonal', 'sum', 'none'
%   -- For 'multiclass' input matrix M, the default is 'diagonal', but any
%     of the three options may be specified.
%   -- For 'pairwise' input matrix M, the default and only specification is
%     'none'. If 'diagonal' or 'sum' is specified with this input type,
%     the function will override it with 'none' and print a warning.
% - 'symmetrize': 'arithmetic', 'geometric', 'harmonic', 'none'
%   -- For 'multiclass' input matrix M, the default is 'arithmetic', but any
%     of the four options may be specified.
%   -- For 'pairwise' input matrix M, the default and only specification is
%     'none'. Any of the four options may be specified, but should not
%     affect an input matrix that is symmetric to begin with.
% - 'distance': 'linear', 'power', 'logarithmic', 'none'
% - 'distpower': Integer > 0 (if using 'power' or 'log' distance)
%   -- For 'multiclass' input matrix M, the default 'distance' is 'linear',
%     but any of the four options may be specified. The default 'distpower'
%     is 1 and applies only to 'power' and 'logarithmic' specifications
%     of 'distance'.
%   -- For 'pairwise' input matrix M, the default and only specification is
%     'none'. If any other specification is given, the function will
%     override it with 'none' and print a warning.
% - 'rankdistances': 'none' (default), 'rank', 'percentrank'
%   -- For all input matrices M, the default is 'none'. If 'rank' or
%     'percentrank' are called but the input matrix is not symmetric,
%     the subfunction will issue a warning and operate only on the lower
%     triangle of the matrix, returning a symmetric matrix.
%
% Outputs:
% - RDM: The Representational Dissimilarity (distance) Matrix. RDM is a
%   square matrix of the same size as the input variable CM.
% - params: RDM computation parameters. It is a struct whose fields specify
%   normalization, symmetrization, distance measure, distance power, and 
%   ranking of distances.
%
% Notes
% - Computing ranks (with ties): tiedrank
% - Computing inverse percentile: http://bit.ly/2koMsAn
% - Harmonic mean with two numbers:
%   https://en.wikipedia.org/wiki/Harmonic_mean#Two_numbers

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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Begin input parser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Initialize the input parser
ip = inputParser;
ip.CaseSensitive = false;

if nargin < 2
    error('Must input at least a matrix M and pairs/multiclass specification.');
end
matrixType = lower(matrixType); % Convert to lowercase

% Specify input parser parameters based in pairwise or multiclass
if any(strcmp(matrixType, {'p', 'pair', 'pairs', 'pairwise'}))
    disp('Operating on pairwise input matrix.')
    defaultNormalize = 'none';
    defaultSymmetrize = 'none';
    defaultDistance = 'none';
elseif any(strcmp(matrixType, {'m', 'multi', 'multiclass', 'multicategory'}))
    disp('Operating on multiclass input matrix.')
    defaultNormalize = 'diagonal';
    defaultSymmetrize = 'arithmetic';
    defaultDistance = 'linear';
else
    error(['Specified matrix type is not in the allowable set of values. '...
        'See function documentation for more information.'])
end
defaultDistpower = 1;
defaultRankdistances = 'none';

% Specify expected values
expectedMatrixType = {'p', 'pair', 'pairs', 'pairwise',...
    'm', 'multi', 'multiclass', 'multicategory'};
expectedNormalize = {'diagonal', 'sum', 'none'};
expectedSymmetrize = {'arithmetic', 'mean',...
    'geometric', 'harmonic', 'none'};
expectedDistance = {'linear', 'power', 'logarithmic', 'none'};
expectedRankdistances = {'none', 'rank', 'percentrank'};

% Required inputs
addRequired(ip, 'M', @isnumeric)
addRequired(ip, 'matrixType',...
    @(x) any(validatestring(x, expectedMatrixType)))

% Optional name-value pairs
% NOTE: Should use addParameter for R2013b and later.
if verLessThan('matlab', '8.2')
    addParamValue(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParamValue(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParamValue(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParamValue(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
    addParamValue(ip, 'distpower', defaultDistpower,...
        @(x) floor(x)==x);
else
    addParameter(ip, 'normalize', defaultNormalize,...
        @(x) any(validatestring(x, expectedNormalize)));
    addParameter(ip, 'symmetrize', defaultSymmetrize,...
        @(x) any(validatestring(x, expectedSymmetrize)));
    addParameter(ip, 'distance', defaultDistance,...
        @(x) any(validatestring(x, expectedDistance)));
    addParameter(ip, 'rankdistances', defaultRankdistances,...
        @(x) any(validatestring(x, expectedRankdistances)));
    addParameter(ip, 'distpower', defaultDistpower,...
        @(x) floor(x)==x);
end

% Parse
parse(ip, M, matrixType, varargin{:});
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End input parser
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Verify the confusion matrix is square
if size(M, 1) ~= size (M, 2)
    error('The input matrix M should be square.')
end

disp('Computing distance matrix...')

% Initialize the 'params' output
params.normalize = ip.Results.normalize;
params.symmetrize = ip.Results.symmetrize;
params.distance = ip.Results.distance;
params.distpower = ip.Results.distpower;
params.rankdistances = ip.Results.rankdistances;

% Verify inappropriate parms not specified with pairwise input matrix
if any(strcmp(matrixType, {'p', 'pair', 'pairs', 'pairwise'}))
   if ~strcmp(params.normalize, 'none')
       warning(['Normalize was specified as ''' params.normalize ''' but '...
           'must be set to ''none'' for pairwise input matrix. Overriding '...
           'user input and setting to ''none''.'])
       params.normalize = 'none';
   end
   if ~strcmp(params.distance, 'none')
       warning(['Distance was specified as ''' params.distance ''' but '...
           'must be set to ''none'' for pairwise input matrix. Overriding '...
           'user input and setting to ''none''.'])
       params.distance = 'none';
   end
end

% NORMALIZE
NM = normalizeMatrix(M, params.normalize);

% SYMMETRIZE
SM = symmetrizeMatrix(NM, params.symmetrize);

% DISTANCE
DM = convertSimToDist(SM, params.distance, params.distpower);

% RANKDISTANCES
RDM = rankDistances(DM, params.rankdistances);


