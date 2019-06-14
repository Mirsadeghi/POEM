function BlkInfo = BlkIndex(ImSize,BlkSize,param)
% This function is written to build index image which contains value from 1
% to BlkSize(1)*BlkSize(2). Each number in this range define a block for
% image.
%
% Syntax :
%           BlkInfo = BlkIndex(ImSize,BlkSize,param)
% Inputs :
%           ImSize   - Size of image we want to split. Imsize(1) define
%           rows of image and ImSize(2) define columns of image.
%           BlkSize  - number of block in each dimension of image. BlkSize
%           must be real integer.
%           param    - parameter for building image blocks
%                      param.w  : width of cell for feature extrcation. 
%                      this variable define border of image which must be 
%                      discard.
% Output :
%           BlkInfo  - Output arguments in the structured form.
%                      Contains index matrix and block size;
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : March 2016
% Modified @ : April 2016

w = param.w;

% Exract size of image to be divided
row = ImSize(1);
col = ImSize(2);

% Build image blocks according to defined block size
nRow = row-(2*floor(w/2));
nCol = col-(2*floor(w/2));

RowBlk = ceil(nRow/BlkSize(1));
ColBlk = ceil(nCol/BlkSize(2));

% Build Index Image
BlkImg = kron(reshape(1:BlkSize(1)*BlkSize(2),BlkSize(1),BlkSize(2)),ones(RowBlk,ColBlk));

if size(BlkImg,1) > nRow
    % Reduce size of index matrix if it's greater than image
    BlkImg = BlkImg(1:nRow,:);
end
if size(BlkImg,2) > nCol
    % Reduce size of index matrix if it's greater than image
    BlkImg = BlkImg(:,1:nCol);
end
if size(BlkImg,1) < nRow
    % Increase size of index matrix if it's smaller than image
    BlkImg = [BlkImg;repmat(BlkImg(end,:),rem(nRow,BlkSize(1)),1)];
end
if size(BlkImg,2) < nCol
    % Increase size of index matrix if it's smaller than image
    BlkImg = [BlkImg repmat(BlkImg(:,end),1, rem(nCol,BlkSize(2)))];
end

% Crop index matrix
BlkImg = BlkImg(1:nRow,1:nCol);

% Build seperate image for each block for fats computation.
NumBlk = prod(BlkSize);
BlkMat = false(size(BlkImg,1),size(BlkImg,2),NumBlk);
for i = 1 : NumBlk
    
    % Store one image per block.
    BlkMat(:,:,i) = BlkImg == i;
    
    % Control flag to specify valid/invalid blocks.
    % If number of elements in the current block are greater than half of
    % compelete block it set to valid, else it set to invalid.
    BlkInfo.BlkMatFlag(i) = sum(sum(BlkMat(:,:,i))) > (RowBlk*ColBlk/2);
end

% Send data to output structure
BlkInfo.Image = BlkImg;
BlkInfo.Size = BlkSize;
BlkInfo.BlkMat = BlkMat;