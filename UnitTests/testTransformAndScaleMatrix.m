% testTransformAndScaleMatrix.m
% ---------------------
% Nathan - Sep 25, 2019
%
% Testing expected successful and unsuccessful calls to transformAndScaleMatrix.m.

% General checks: Try out different parameter configurations when inputting
% a confusion-type matrix and a pairwise accuracy-type matrix

% In addition to general checks please try the following conditions:
% - Check the params output when inputting (1) distance and (2) similarity
% matrices with no name-value pairs to make sure they are the correct 
% defaults for each case
% - Does the 'zeroToOne' normalization make sense for pairwise accuracy
% matrices?
% - Check cases where the user input a distance or similarity matrix along 
% with not-allowed specifications for name-value pairs -- see if the
% correct warning prints and if the params reflect what the docstring says
% the function will do in terms of overriding user input
% - when specifying distance input, try inputting a non-symmetric matrix
% and asking the function to rank distances, and see if the output is
% symmetric and ranked based on the lower triangle only

close all; clear all; clc

% Make random classification accuracy matrix
C = [0 0.5 0.5; 0.5 0 0.3; 0.5 0.3 0];

%% Testing basic usage
% Error:
%   Error using normalizeMatrix (line 60)
%   Cannot divide by zero on the diagonal.
% 
%   Error in transformAndScaleMatrix (line 261)
%   NM = normalizeMatrix(M, params.normalize);

[RDM, params] = transformAndScaleMatrix(C, 's');