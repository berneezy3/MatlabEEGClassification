function [reliabilities] = computeSpaceTimeReliability(X, Y, num_permutations, rand_seed)
%------------------------------------------------------------------------------------------
%  [reliabilities] = computeSpaceTimeReliability(X, Y, num_permutations, rand_seed)
%------------------------------------------------------------------------------------------
%
% Returns reliabilities computed for each component across time. With the resulting
% data matrix, one can take the mean along the third dimension (the components axis)
% and this will tell you the average reliability across components at each time point.
% On the other hand, if one takes the mean across the first dimension (the time axis),
% one will be able to see how reliable each component is across time (on average).
%
% Input Args:
%   X - data matrix. 3D data matrices are assumed to be nSpace x nTime x
%              nTrial.  If the data matrix is 2D, it is assumed to be nTrial x 
%              nFeature.
%   Y - labels vector. The length of labels should be equal to nTrials.
%   num_permutations (optional) - how many permutations to split the trials for split-half
%                                 reliability. If not entered, this defaults to 10.
%   rand_seed (optional) - Random number generator specification. If not entered, defaults to
%       'shuffle'. If specifying a dual-argument random number generator
%       (e.g., ('shuffle', 'twister'), it should be entered as elements of
%       a cell array (e.g., {'shuffle', 'twister'}).
%
% Output Args:
%   reliabilities - reliability for each electrode across time. The dimensions of
%                   this matrix are: nSpace x nTime x nPermutations if a 3D matrix was
%                   provided.  If a 2D matrix was provided, the dimensions of the results
%                   are: nTime x nPermutations. You would typically average across the permutations 
%                   dimension.

% If 3D matrix entered, dimensions are: space x time x trial
% We will permute so that it becomes space x trial x time
if length(size(X)) == 3
    X = permute(X, [1,3,2]);
% If 2D matrix entered, dimensions are: trial x time
% We will permute so that it becomes time x trial and add
% a singleton dimension in the front for space.
elseif length(size(X)) == 2
    X = permute(X, [2,1]);
    [dim1, dim2] = size(X);
    X = reshape(X, [1,dim1,dim2]);
else
    error('Input data should be a 2D or 3D matrix.');
end

if nargin < 3 || isempty(num_permutations)
    num_permutations = 10;
end

% Set random seed
if nargin < 4 || isempty(rand_seed), rng('shuffle');
elseif length(rand_seed) == 2, rng(rand_seed{1}, rand_seed{2});
elseif ischar(rand_seed) || length(rand_seed) == 1, rng(rand_seed);
else, error('Input rand_seed should be a single value or cell array of length 2.');
end

num_components = size(X, 1);
num_timepoints = size(X, 3);

reliabilities = zeros(num_timepoints, num_permutations, num_components);
for t=1:num_timepoints
    fprintf('Timepoint %d\n', t);
    curr_data = squeeze(X(:,:,t));
    rels = computeReliability(curr_data, Y, num_permutations);
    assert(isequal(size(rels), [num_permutations, num_components]));
    reliabilities(t,:,:) = rels;
end

% This means a 3D data matrix was provided. Permute the results matrix 
% so that the dimensions are: space x time x permutations
if num_components > 1
    reliabilities = permute(reliabilities, [3,1,2]);
end

end


