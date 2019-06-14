I = imread('cameraman.tif');

% Set parameters for POEM feature extraction
% -----------------------------------------

% Number of Blocks in row and column of image
NumBlk = [6 6];

% Diameter of self-similarity decsriptor (LBP)
param.L = 14;

% Number of bins for local oriented histograms.
% It define number of accumulated magnitude image.
param.m = 4;

% Angle representation, single or double angle.
% single : range [0  180] for orientations
% double : range [0 -360] for orientations
param.angle_type = 'single';

% Uniform Pattern usage
% ('true' : just uniform patterns, 'false' : all patterns)
param.Uflag = 'true';

% Cell size for accumulated magnitude images construction.
param.w = 9;

% Number of samples around each pixel for self-similarity descriptor (LBP).
param.n = 8;

% Call function to Compute Unifrom Pattern Index.
param.UP_Idx = Uniform_Pattern(param.n);

% Call function to extract image blocks and related indexes.
ImSize = size(I);
BlkInfo = BlkIndex(ImSize(1:2), NumBlk, param);

% Extract POEM from sample image.
temp = POEM(double(I), BlkInfo, param);
POEM_desc  = temp.Desc;
LBPImg = temp.LBPIm;
AMImg  = temp.AMI;

%%
subplot(2,4,1)
imshow(LBPImg(:,:,1))
title('LBP image m1')

subplot(2,4,2)
imshow(LBPImg(:,:,2))
title('LBP image m2')

subplot(2,4,3)
imshow(LBPImg(:,:,3))
title('LBP image m3')

subplot(2,4,4)
imshow(LBPImg(:,:,4))
title('LBP image m1')

subplot(2,4,5)
imshow(AMImg(:,:,1), [])
title('AM image m2')

subplot(2,4,6)
imshow(AMImg(:,:,2), [])
title('AM image m3')

subplot(2,4,7)
imshow(AMImg(:,:,3), [])
title('AM image m4')

subplot(2,4,8)
imshow(AMImg(:,:,4),[])
title('AM image')