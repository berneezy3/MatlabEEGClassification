function [randX, randY, randP, randIdx] = shuffleData(X, Y, P, r)
%-------------------------------------------------------------------
% [randX, randY, randP, randIdx] = shuffleData(X,Y,P,r)
% -------------------------------------------------------------
% Bernard Wang - April 30, 2017
% Revised by Blair Kaneshiro, August 9 2019
%
% This function randomizes, in tandem, ordering of trials in data matrix X,
% labels vector Y, and, optionally, participants vector P. Therefore,
% ordering is disrupted, but mappings between trials, stimulus labels, and
% participants is preserved. The function can be used in cases where users
% wish to mix trials across the course of a recording session or across
% participants prior to trial averaging or cross-validation.
%
% INPUT ARGS:
%   X: Data matrix. Data can be in 3D (space x time x trial) or 2D
%       (trial x feature) form.
%   Y: Labels vector. The length of Y must correspond to the length of the
%       trial dimension of X.
%   P: Participant vector (optional). The length of P must correspond to
%       the length of Y and the length of the trial dimension of X. If P
%       is not entered, the function will return NaN as randomized P. P can
%       be a numeric vector, string array, or cell array.
%   r: Random number generator (rng) specification. If not entered, defaults to
%       'shuffle'. It can be a single acceptable input (e.g., 1, 'default')
%       or, for dual-argument specifications, either a 2-element cell
%       array (e.g., {'shuffle', 'twister'}) or string array (e.g.,
%       ["shuffle", "twister"].
%
% OUTPUT ARGS:
%   randX: Data matrix with its trials reordered (same size as X).
%   randY: Labels vector with its trials reordered (same size as Y).
%   randP: Participants vector with its trials reordered (same size as P).
%   randIdx: Randomized ordering applied to all inputs.
%
% TODO:
% - Confirm whether labels vector has to be numeric or can be cell array of
%   strings.

% Set random number generator
if nargin < 4 || isempty(r), rng('shuffle');
elseif length(r) == 2, rng(r{1}, r{2});
elseif ischar(r) || length(r) == 1, rng(r);
else, error('Input r should be a single value or cell array of length 2.');
end

% Make sure data matrix X is a 2D or 3D matrix
assert(ndims(X) == 2 | ndims(X) == 3,...
    'Input data matrix must be a 2D or 3D matrix.');

% Make sure labels input Y is a vector
assert(isvector(Y), 'Input labels must be a vector.');

% Make sure length of Y matches the trial length of X
if ndims(X) == 3, [~, ~, nTrial] = size(X);
else, [nTrial, ~] = size(X); end
assert(length(Y) == nTrial, ...
    'Length of input labels vector must equal length of trial dimension of input data.');

% Compute randomization index
randIdx = randperm(nTrial);

% Randomize data and labels
if ndims(X) == 3, randX = X(:, :, randIdx);
else, randX = X(randIdx,:);
end
randY = Y(randIdx);

% Handle participants randomization if specified as output
if nargout > 2
    if nargin < 3 || isempty(P), randP = NaN;
    elseif ~isvector(P)
        error('Input participant identifiers must be a vector.');
    elseif length(P) ~= length(Y)
        error('Input labels vector and input participants vector must be the same length.');
    else
        randP = P(randIdx);
    end
end

end