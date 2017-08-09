function [ output ] = distance( A, B )
%DISTANCE Provides the euclidic distance between A and B. A & B need to be 
%       NX3 vectors.

if (~(size(A,2) == 3) || ~(size(B,2) == 3) || ~(ndims(A) == 2))
    error('Size of input vectors is not NX3.');
else
    i = 1:size(A,1);
    output(i) = sqrt( (A(i,1) - B(i,1)).^2 + (A(i,2) - B(i,2)).^2 + (A(i,3) - B(i,3)).^2);
end

end

