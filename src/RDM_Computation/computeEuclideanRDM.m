function [dissimilarities] = computeEuclideanRDM(X, Y, num_permutations, rand_seed)
%------------------------------------------------------------------------------------
%  [dissimilarities] = computeEuclideanRDM(X, Y, num_permutations, rand_seed)
%------------------------------------------------------------------------------------
%
% Returns pairwise similarities with respect to cross-validated Euclidean
% distance.  A possible data input to this function would have dimensions:
% nElectrodes x (nTrials*nImages).  With this input, the resulting RDM would be
% computed using the electrode values at a specific time point as features.  On
% the other hand, one could also provide, as input, data of dimensions:
% nTimepoints x (nTrials*nImages).  In this case, the resulting RDM would be
% computed using the time point values for a particular electrode as features.
%
% Input Args:
%   X - data matrix. The size of X should be nFeatures x
%              nTrials. Users working with 3D data matrices should already
%              have subset the data along a single sensor (along the space
%              dimension) or time sample (along the time dimension).
%   Y - labels vector. The length of Y should be nTrials.
%   num_permutations (optional) - how many permutations to randomly select
%                                 train and test data matrix. If not entered,
%                                 this defaults to 10.
%   rand_seed (optional) - random seed for reproducibility. If not entered, rng
%       will be assigned as ('shuffle', 'twister').
%       --- Acceptable specifications for rand_seed ---
%           - Single acceptable rng specification input (e.g., 1,
%               'default', 'shuffle'); in these cases, the generator will
%               be set to 'twister'.
%           - Dual-argument specifications as either a 2-element cell
%               array (e.g., {'shuffle', 'twister'}) or string array
%               (e.g., ["shuffle", "twister"].
%           - rng struct as assigned by rand_seed = rng.
%
% Output Args:
%   dissimilarities - the dissimilarity matrix, dimensions: num_images
%                     x num_images x num_permutations

num_dim = length(size(X));
assert(num_dim == 2, 'Input data must be a 2D matrix. See documentation.');
assert(size(X,2) == length(Y), ['Mismatch in number of trials in data and length of labels vector. 2D input matrix should be feature x trial']);

if nargin < 3 || isempty(num_permutations)
    num_permutations = 10;
end

% Set random number generator
if nargin < 4 || isempty(rand_seed), setUserSpecifiedRng();
else, setUserSpecifiedRng(rand_seed);
end

unique_labels = unique(Y);
num_images = length(unique_labels);
num_features = size(X,1);
dissimilarities = zeros(num_permutations, num_images, num_images);
for p=1:num_permutations
    
    for i=1:num_images
        curr_label_i = unique_labels(i);
        
        img1_data = squeeze(X(:,Y==curr_label_i));
        % Split trials into two partitions (i.e. train/test)
        img1_trials = size(img1_data, 2);
        % Randomly permute data
        img1_data = img1_data(:,randperm(img1_trials));
        % Split into train/test
        img1_train = img1_data(:,1:floor(img1_trials/2));
        img1_test = img1_data(:,floor(img1_trials/2)+1:img1_trials);
        % Compute mean across the trials
        img1_train = squeeze(mean(img1_train,2));
        img1_test = squeeze(mean(img1_test,2));
        
        for j=i+1:num_images
            curr_label_j = unique_labels(j);
            
            img2_data = squeeze(X(:,Y==curr_label_j));
            % Split trials into two partitions (i.e. train/test)
            img2_trials = size(img2_data, 2);
            % Randomly permute data
            img2_data = img2_data(:,randperm(img2_trials));
            % Split into train/test
            img2_train = img2_data(:,1:floor(img2_trials/2));
            img2_test = img2_data(:,floor(img2_trials/2)+1:img2_trials);
            % Compute mean across the trials
            img2_train = squeeze(mean(img2_train,2));
            img2_test = squeeze(mean(img2_test,2));
            
            % Compute cv-Euclidean distance (x-y)'(x-y)
            cvEd = dot((img1_train - img2_train), (img1_test - img2_test));
            % Record value
            dissimilarities(p,i,j) = cvEd;
            dissimilarities(p,j,i) = cvEd;
            
        end % second image
    end % first image
end % permutations

%  Permute so that the dimensions are: nLabels x nLabels x nPerms
dissimilarities = permute(dissimilarities, [2,3,1]);

end % function

