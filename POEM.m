function POEM_data = POEM(I,BlkInfo,param)
% This fucntion is written to extract POEM Descriptor from inpute image.
% This function is joint with two function AMI.m and LBP.m
% All steps are according to paper "Enhanced Patterns of Oriented Edge
% Magnitudes for Face Recognition and Image Matching" by Ngoc-Son and Alice
% Caplier. IEEE Transaction on Image Processing, 2011. 
%
% Syntax :
%           POEM_data = POEM(I,BlkInfo,param)
% Inputs :
%           I        - Input image (doubled format grayscale image)
%           BlkInfo  - Information of block size
%                      (Index image and block size in each dimension)
%           param    - parameters for AMI and LBP computation:
%                      param.m          : number of orientations
%                      param.w          : cell size
%                      param.angle_type : angle representation type
%                      param.L          : diameter of LBP operator
%                      param.n          : Number of samples for LBP
%                      param.Uflag      : Uniform Pattern usage flag
% Output :
%           POEM_data - Structured output which contains :
%                       POEM Descriptor, AMI and LBP images and descriptor
%                       extraction time.
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2016

% Use timer to compute elapsed time
t1 = tic;

% Call function to compute Accumulated Magnitude Images
MagImg = AMI(I,param);

% Store AMI Images
POEM_data.AMI = MagImg;

% Loop over each AMIs and extract LBP Descriptor for AMI which is divided
% to some defined blocks.
% Size of output decsriptor will be : (2^param.n)*prod(BlkInfo.Size)
for i = 1 : param.m
    % Call function to extract LBP Descriptor for each AMI.
    temp = LBP(MagImg(:,:,i),BlkInfo,param);
    POEM_data.Desc(:,i) = temp.Desc';
    POEM_data.LBPIm(:,:,i) = temp.Image;
end

% Concatenate all descriptor to form final descriptors
POEM_data.Desc = POEM_data.Desc(:);

% Read runtime
POEM_data.Etime = toc(t1);
end