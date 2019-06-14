function MagImg = AMI(I,param)
% This function is written to calculate Accumulated Magnitude Image.
% All steps are according to paper "Enhanced Patterns of Oriented Edge
% Magnitudes for Face Recognition and Image Matching" by Ngoc-Son and Alice
% Caplier. IEEE Transaction on Image Processing, 2011.
%
% Syntax :
%           MagImg = AMI(I,param)
% Inputs :
%           I        - Input image (doubled format grayscale image)
%           param    - parameters for AMI computation:
%                      param.m          : number of orientations
%                      param.w          : cell size
%                      param.angle_type : angle representation type
%
% Output :
%           MagImg - a multidimentional image which that each dimention
%           corresponde to a range of discrete gradient orientation.
%
%
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2016

% Compute gradient magnitude and orientation of input image.
[GradMag,GradAngle] = compute_gradient(I);

% Call a local function to build accumulated magnitude image very fast 
% by aid of Intergral Image.
MagImg = compute_AMI(GradMag,GradAngle,param);

end

function [GradMag,GradAngle] = compute_gradient(I)
% Approximate image derivation as:
%           dI/dx = dI(x+1) - dI(x-1)
%           Equivalent Derivative Kernel : [-1  0 +1]

% Build Shifted Images.
Il = [I(:,2:end) I(:,1)];     % Left  shfited image
Ir = [I(:,end) I(:,1:end-1)]; % Right shfited image
Iu = [I(2:end,:);I(1,:)];     % Up    shfited image
Id = [I(end,:);I(1:end-1,:)]; % Down  shfited image

Dx = (Il - Ir);
Dy = (Iu - Id);

% Compute magnitude of gradient.
GradMag = sqrt(abs(Dx).^2 + abs(Dy).^2);

GradAngle = atan2d(Dx,Dy);

%{
GradAngle = atand(-Dy./(Dx+eps));

SecQuarter = -Dy > 0 & Dx <= 0;
GradAngle(SecQuarter) = (90 - GradAngle(SecQuarter));
 
TrdQuarter = -Dy <= 0 & Dx < 0;
GradAngle(TrdQuarter) = -GradAngle(TrdQuarter) - 90 ;

FthQuarter = -Dy < 0 & Dx >= 0;
GradAngle(FthQuarter) = -(90-GradAngle(FthQuarter));
%}
end

% A local function to compute Accumulated Magnitude Images (AMIs)
function MagImg = compute_AMI(GradMag,GradAngle,param)

% Check angle computation method for input image.
% double angle representation show better results than single angle.
if strcmpi(param.angle_type,'single')
    Range = 180;
    % Using single angle representation.
    % (all negative angles convert to positive angles)
    GradAngle = abs(GradAngle);
elseif strcmpi(param.angle_type,'double')
    Range = 360;
else
    error('Undefined method for computing angle')
end

% Pre-alocation.
m = param.m;
w = param.w;
[row,col] = size(GradMag);
MagImg = zeros(row-(floor(w/2)*2),col-(floor(w/2)*2),m);

% Compute AMIs.
for i = 1 : m
    
    % Find index of gradient orientations in currect range.
    Idx = (GradAngle >= (i-1)*(Range/m)) & (GradAngle < (i*(Range/m)));
    
    % Build Shifted Images and compute AMIs using Integral Image
    % Computing Accumulated Magnitude images is equivalent to local average
    % of pixels in the local Cells. This process can be done in constant 
    % time for every size of cells using integral image strategy.We just 
    % need to do 2 summation and 2 subtraction.
    
    % Step 1 : Compute Integral Image
    % --------------------------------------------------------------------
    Im = cumsum(cumsum(GradMag.*Idx,1),2);
    Im = [zeros(row+1,1) [zeros(1,col);Im]];
    
    % Step 2 : Build Shifted Images
    % --------------------------------------------------------------------
    Il  = [Im(:,w:end)   Im(:,1:w-1)];
    Iu  = [Im(w:end,:) ; Im(1:w-1,:)];
    Ilu = [Iu(:,w:end)   Iu(:,1:w-1)];
    
    % Step 3 : Compute AMIs very fast using Integral Image
    % --------------------------------------------------------------------
    temp = (Im + Ilu) - (Iu + Il);
    
    % Discard border of AMIs which contains invalid information
    temp = temp(1:end-w,1:end-w);
    MagImg(:,:,i) = temp;
end
end