% testComputeSampleSizeReliability.m
% -------------------------------------------
% Blair - Sep 02, 2019

clear all; close all; clc
load('/user/b/blairbo/Codebase/MatClassRSA/UnitTests/S06.mat')

X2d = squeeze(X(96,:,:))';

%% 3D input -- looks good
r = computeSampleSizeReliability(X, labels72, 19, 1:11);
rMean = squeeze(mean(r,1));
close all
plot(rMean(:,96), 'linewidth', 2); grid on

%% 3D input, single electrode -- looks good
r3d_1chan = computeSampleSizeReliability(X(96,:,:), labels72, 19, 1:20,...
    [], [], 1);

% r3d is 10 perm x 20 trials in split
r3dMean = mean(r3d_1chan, 1);
close all
plot(r3dMean, 'linewidth', 2); grid on

%% 2D input -- looks good, matches 3D single-electrode input

X2d = squeeze(X(96,:,:))'; % Trial by time
r2d_1chan = computeSampleSizeReliability(X2d, labels72, 19, 1:20,...
    [], [], 1);

assert(isequal(r3d_1chan, r2d_1chan)); 
disp('Success: 3d input single electrode equals 2d input')

%% 3D input, 6-class labels -- xx acting strange xx 

clear r
r = computeSampleSizeReliability(X, labels6, 1, 1:20, [], [], 1);
rMean = squeeze(mean(r,1));
close all
plot(rMean(:,96), 'linewidth', 2); grid on

%% 3D input, single channel, bad time point -- xx acting strange xx
clc
clear r
r = computeSampleSizeReliability(X(96,:,:), labels72, 1, 1:36, [], [], 1);
rMean = mean(r, 1);
close all
plot(rMean, 'linewidth', 2); grid on

%% 3D input, single channel, good time point -- looks good
clc
clear r
r = computeSampleSizeReliability(X(96,:,:), labels72, 19, 1:36, [], [], 1);
rMean = mean(r, 1);
close all
plot(rMean, 'linewidth', 2); grid on

%% Testing rng - looks good

close; clc
rng(42, 'philox')
rng
r = computeSampleSizeReliability(X(96,:,:), labels72, 19, [], [], [], 1);
rng

rng(42, 'philox')
rng
r = computeSampleSizeReliability(X(96,:,:), labels72, 19, [], [], [], 'default');
rng

rng(42, 'philox')
rng
r = computeSampleSizeReliability(X(96,:,:), labels72, 19, [], [], [], {'shuffle', 'twister'});
rng

rng(42, 'philox')
rng
r = computeSampleSizeReliability(X(96,:,:), labels72, 19, [], [], [], ["shuffle", "twister"]);
rng

%% 3D input with ntrials in split too large -- ** feature request **
r = computeSampleSizeReliability(X, labels72, 19, [1000 1]);

split1 = squeeze(r(:,1,:));
split2 = squeeze(r(:,2,:));
n = numel(split1);

assert(isequal(n, sum(isnan(split1(:)))));
disp('success: first split output is all nan.')

assert(isequal(sum(isnan(split2(:))), 0));
disp('success: second split output contains no nans.')