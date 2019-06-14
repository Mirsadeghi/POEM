function UP_Idx = Uniform_Pattern(n)
% Detect Uniform Patterns in the range [0 , 2^n]
% Unifrom pattern are those pattern whos contained more than 2
% transition from '0' to '1' or vice versa. to detect such transition
% we can use 'XOR' operator between two consecutive bit. 'XOR' result
% '1' for transition and result '0' for no-change.
% Syntax:
%           UP_Idx = Uniform_Pattern(param)
% Input:
%           n      - number of samples
% output:
%           UP_Idx - index that define which number in the range [0 , 2^n]
%           is correspond to uniform pattern and which number can't be a
%           uniform pattern.
% 
% -------------------------------
% Written by : S.Ehsan Mirsadeghi
% Date       : April 2016


% Pre-allocation
UPIdx = zeros(2^n,n);

% Build binary numbers from 0 to 2^P
for i = n : -1 : 1
    t1 = kron(ones(1,(2^(n-1))/(2^(i-1))),[0 1]);
    t2 = ones(1,(2^(i-1)));
    UPIdx(:,n-(i-1)) = kron(t1,t2)';
end

% Find transitions between consecutive bits by 'XOR' Operator
TBit = 0;
for i = 1 : n-1
    TBit = TBit + xor(UPIdx(:,i),UPIdx(:,i+1));
end
TBit = TBit + xor(UPIdx(:,n),UPIdx(:,1));

% Find Uniform patterns which contains at most 2 transition from zero to
% one or vice versa.
U_th = 2;
UP_Idx = TBit <= U_th;
end