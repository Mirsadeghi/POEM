function LBP_data = LBP(I,BlkInfo,param)
% This function is written to extract LBP image descriptor.
% All steps are according to paper "Face Recognition with Local Binary
% Patterns" by T. Ahonen, A. Hadid and M. Pietik¨ainen (ECCV 2004, LNCS
% 3021, pp. 469–481)
%
% Syntax :
%           LBP_data = LBP(I,BlkInfo,param)
% Inputs :
%           I        - Input image (doubled format grayscale image)
%           BlkInfo  - Information of block size (Index image and block
%                      size in each dimension)
%           param    - parameter for LBP extraction
%                      param.L          : radius of LBP operator
%                      param.n          : Number of samples for LBP
%                      param.Uflag      : Uniform Pattern usage flag
% Output :
%           LBP_data - Structured output which contains :
%                      LBP Descriptor, LBP Image and Index of Uniform
%                      patterns
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : March 2016
% Modified @ : April 2016

L = param.L;
P = param.n;
Uflag = param.Uflag;

% "tao" is slightly larger than zero to provide some stability in uniform
% regions.
tao = 1e-13;

% Max number of samples around each pixel is limitted by the radius of
% descriptor.
if P > (4*(L/2)+4)
    error('P should less than or equal to (4*R) + 4')
end
% Maximum number of bins is limited by number of sample points.
n = 2^P;
if n > 2^P
    error('Number of bins should be less than 2^P')
end

BlkSize = BlkInfo.Size;

% Rotation angle is defined according to number of samples needed.
Theta = 360/P;
[row,col] = size(I);

% Idx variable store result of comparison for each neighbourhood.
Idx = zeros(row*col,P);

% Form sample patch and compute number of shifted needed
NumP = 0:P-1;

% Define direction and number of needed shifted for images
% fisrt row contain Colloum shift and second row contans row shift.
PixelShift = round([(L/2)*cosd(NumP.*Theta);(L/2)*sind(NumP.*Theta)]);

%% Main Part - computing LBP using Shifted Images

% Build Shifted Images and compare local neighbourhood
for i = 1 : P
    % Step 1 : Build Shifted Images
    % --------------------------------------------------------------------
    % To avoid loop over each pixel of entire image, we can simply shift
    % images with proper number of pixels according to predefiend value.
    ShiftedImg  = circshift(I,[PixelShift(2,i)  PixelShift(1,i)]);
    
    % Step 2 : pixel-wise comparison
    % --------------------------------------------------------------------
    % In order to compute LBP, we should compare neighbourhood of a local
    % center pixel and constrcut a binary code. The LBP descriptor of each
    % pixel is decimal value of the binary code.
    %
    % An extra stage is added to LBP extraction acording to Eq.2 of
    % reference paper (Page. 4, Second Column, Eq. 2)
    % If difference of a local center pixel and one of it's neighbour is
    % smaller than a specified value "tao", it will be discarded.
    tmp = ShiftedImg - I;
    Co = abs(tmp) >= tao;
    temp1 = (tmp >=0 ).*Co; Idx(:,i) = temp1(:);
end

% Step 3 : Combine binary bits to form binary code
% ------------------------------------------------------------------------

% Build Decimal Coefficient for binary Codes;
Coef = 2.^((P-1):-1:0);
BinCoef = repmat(Coef,size(Idx,1),1);
UP_Idx = param.UP_Idx;
N = sum(UP_Idx)+1;

% Calculate equivalent decimal value for each pixel and obtain LBP code
LbpData = sum(Idx.*BinCoef,2);
LbpData = reshape(LbpData,size(I,1),size(I,2));

if sum(size(LbpData) ~= size(BlkInfo.Image)) > 0
    error('Feature image and Index image must have equal size.')
end

if strcmpi(Uflag,'true')
    
    % Merge histogram of image blocks and constrcut descriptor.
    for k = 1 : BlkSize(1)*BlkSize(2)
        Indx = ( (k-1)*N ) + 1 : (k*N);
        temp1 = LbpData(BlkInfo.BlkMat(:,:,k));
        temp2 = hist(temp1,n);
        LBP_data.Desc(Indx) = [temp2(UP_Idx) sum(temp2(UP_Idx))];
    end
    
else % Reject Unifrom Pattern caculation
    
    % Merge histogram of image blocks and constrcut descriptor.
    for k = 1 : BlkSize(1)*BlkSize(2)
        Indx = ( (k-1)*n ) + 1 : (k*n);
        temp1 = LbpData(BlkInfo.BlkMat(:,:,k));
        LBP_data.Desc(Indx) = hist(temp1,n);
    end
end

% Sclae value of LBP for each pixel to range [0 255]
LbpImage = uint8(mat2gray(LbpData)*255);
LBP_data.Image = LbpImage;