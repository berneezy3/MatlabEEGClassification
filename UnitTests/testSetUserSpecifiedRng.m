% testSetUserSpecifiedRng.m
% -----------------------------
% Blair - August 14, 2019
%
% Testing script for the function setUserSpecifiedRng.m. This script has
% helper functions at the bottom that initialize the rng to
% (234, 'threefry') before calling the function with other specified
% parameters so that we can make sure that both the seed and generator are
% being updated appropriately in each test attempt.

clear all; close all; clc
% Be sure to run the helper functions at the bottom before running other
% cells

%% Case: Empty input: Should set to rng=('shuffle', 'twister')
clc
disp('--------- No input ---------')
testUserSpecifiedRng()
% BK 20190814: OK - prints warning of no input and what it will do, and rng
% looks appropriate
% Warning: Nothing input to 'setUserSpecifiedRng' function. Setting rng=('shuffle',
% 'twister'). 
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'twister'
%      Seed: 1726775160
%     State: [625�1 uint32]

%%
clc
disp('--------- NaN input ---------')
testUserSpecifiedRng(NaN)
% BK 20190814: OK - same outcome as above.

%%
clc
disp('--------- Empty input ---------')
testUserSpecifiedRng([])
% BK 20190814: OK - same outcome as above.

%% Case: Single RNG STRUCT input (acceptable): Should assign to rng

clc
disp('--------- Single input (numeric) ---------')
rng(12345, 'combRecursive')
disp('--- User-specified rng to be entered: ---')
thisRng = rng
disp('-----------------------------------------')
testUserSpecifiedRng(thisRng)
clear thisRng
% BK 20190814: OK - gives appropriate message and rng is correct.
% Assigning user-specified rng struct:
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'combRecursive'
%      Seed: 12345
%     State: [12�1 uint32]

%% Case: Single RNG STRUCT input (unacceptable)

clc
disp('--------- Single input (numeric) ---------')
thisBadStruct.X = 1:10;
thisBadStruct.Y = 11:20;
thisBadStruct
testUserSpecifiedRng(thisBadStruct)
clear thisBadStruct
% BK 201990814: OK - returns appropriate error
% Error using setUserSpecifiedRng (line 30)
% If user-specified rng input is a struct, it must be an rng specification.

%% Case: Single input (acceptable): Should assign (input, 'twister')

clc
disp('--------- Single input (numeric) ---------')
testUserSpecifiedRng(10)
% BK 20190814: OK - prints useful message and output makes sense
% Single-input rng specification: Setting generator to 'twister'.
% Shuffling averaged data using rng=(10, 'twister').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'twister'
%      Seed: 10
%     State: [625�1 uint32]

%%
clc
disp('--------- Single input (string) ---------')
testUserSpecifiedRng('shuffle')
% BK 20190814: OK - prints useful message and output makes sense.
% Single-input rng specification: Setting generator to 'twister'.
% Shuffling averaged data using rng=('shuffle', 'twister').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'twister'
%      Seed: 1726787368
%     State: [625�1 uint32]

%%
clc
disp('--------- Single input (default) ---------')
testUserSpecifiedRng('default')
% BK 20190814: OK - Special message for 'default' and output looks correct
% Shuffling averaged data using rng=('default').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'twister'
%      Seed: 0
%     State: [625�1 uint32]

%%
clc
% Edge case: User incorrectly entered single string in double quotes
disp('--------- Single input (badly formatted string) ---------')
testUserSpecifiedRng("shuffle")
% BK 20190814: OK - treats as single input 'shuffle'
% Single-input rng specification: Setting generator to 'twister'.
% Shuffling averaged data using rng=('shuffle', 'twister').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'twister'
%      Seed: 1726793583
%     State: [625�1 uint32]

%% Case: Single input (unacceptable)

clc
disp('--------- Single input (numeric) ---------')
testUserSpecifiedRng(-10)
% BK 20190814: OK - error message makes sense
% Error using setUserSpecifiedRng (line 81)
% Rng specification should be a single value, or cell/string array of length 2,
% containing acceptable rng parameters.

%%
clc
disp('--------- Single input (bad string) ---------')
testUserSpecifiedRng('blah!')
% BK 20190814: OK - same as bove

%% Case: Dual input, string array (acceptable): Should fill seed, generator

clc
disp('--------- Dual input (numeric and string) ---------')
testUserSpecifiedRng([10, "philox"])
% BK 20190814: OK - Says what it's doing and output makes sense
% Shuffling averaged data using rng=(10,philox).
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'philox'
%      Seed: 10
%     State: [7�1 uint32]

%%
clc
disp('--------- Dual input (string numeric and string) ---------')
testUserSpecifiedRng(["10", "philox"])
% BK 20190814: OK - gives same output as above

%%
clc
disp('--------- Dual input (two strings) ---------')
testUserSpecifiedRng(["shuffle", "philox"])
% BK 20190814: OK
% Shuffling averaged data using rng=('shuffle', 'philox').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'philox'
%      Seed: 1726866450
%     State: [7�1 uint32]

%% Case: Dual input, string array (unacceptable)

clc
disp('--------- Dual input (''default'' and string) ---------')
testUserSpecifiedRng(["default", "philox"])
% BK 20190814: OK - gives specific error
% Error using setUserSpecifiedRng (line 49)
% Dual-input rng specification is not allowed with 'default'.

%%
clc
disp('--------- Dual input (forgot double quotes) ---------')
testUserSpecifiedRng([0, 'philox'])
% BK 20190814: OK - gives an error
% Error using setUserSpecifiedRng (line 81)
% Rng specification should be a single value, or cell/string array of length 2,
% containing acceptable rng parameters.

%%
clc
disp('--------- Dual input (bad first argument) ---------')
testUserSpecifiedRng(["blah", "philox"])
% BK 20190814: OK - gives rng error
% Error using rng (line 130)
% First input must be a nonnegative integer seed less than 2^32, 'shuffle', 'default',
% or generator settings captured previously using S = RNG.

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng([0, "blah"])
% BK 20190814: OK - gives rng error
% Error using rng (line 141)
% 'blah' is not a valid generator type.

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng(["shuffle", "blah"])
% BK 20190814: OK - same as above

%% Case: Dual input, cell array (acceptable): Should fill seed, generator

clc
disp('--------- Dual input (numeric and string) ---------')
testUserSpecifiedRng({10, 'philox'})
% BK 20190814: OK - message and output look correct
% Shuffling averaged data using rng=(10, 'philox').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'philox'
%      Seed: 10
%     State: [7�1 uint32]

%%
clc
disp('--------- Dual input (two strings) ---------')
testUserSpecifiedRng({'shuffle', 'philox'})

% BK 20190814: OK - message and output look correct
% Shuffling averaged data using rng=('shuffle', 'philox').
% 
% ans = 
% 
%   struct with fields:
% 
%      Type: 'philox'
%      Seed: 1726871920
%     State: [7�1 uint32]

%% Case: Dual input, cell array (unacceptable)

clc
disp('--------- Dual input (''default'' and string) ---------')
testUserSpecifiedRng({'default', 'philox'})
% BK 20190814: OK - error makes sense
% Error using setUserSpecifiedRng (line 49)
% Dual-input rng specification is not allowed with 'default'.

%%
clc
disp('--------- Dual input (bad first argument) ---------')
testUserSpecifiedRng({'blah', 'philox'})
% BK 20190814: OK - rng error
% Error using rng (line 130)
% First input must be a nonnegative integer seed less than 2^32, 'shuffle', 'default',
% or generator settings captured previously using S = RNG.

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng({0, 'blah'})
% BK 20190814: OK - rng error
% Error using rng (line 141)
% 'blah' is not a valid generator type.

%%
clc
disp('--------- Dual input (bad second argument) ---------')
testUserSpecifiedRng({'shuffle', 'blah'})
% BK 20190814: OK - same as above

%%
clc
disp('--------- Dual input (entering number as string) ---------')
testUserSpecifiedRng({'20', 'philox'})
% BK 20190814: OK - same as above
%% Helper functions
function testUserSpecifiedRng(input)
disp('Before:')
dummyRng;
disp('After:')
if nargin < 1, setUserSpecifiedRng();
else setUserSpecifiedRng(input); end
rng
disp(' ')
end

function dummyRng()
rng(234, 'threefry'); rng
end
