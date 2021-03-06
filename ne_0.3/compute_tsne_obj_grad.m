function [obj,grad] = compute_tsne_obj_grad(y,dim,P,weights,Pnz,I,J,attr,theta,constant,exact)
% compute objective and gradient of Student t-Distributed Stochastic
% Neighbor Embedding (t-SNE)
%
% Copyright (c) 2016, Zhirong Yang
% All rights reserved.

n = size(y,1) / dim;
Y = reshape(y, n, dim);

if ~exist('exact', 'var') || isempty(exact)
    exact = false;
end

if exact
    [repu_obj, repu_grad] = compute_tsne_obj_grad_repulsive_exact(Y);
else
    if nargout==1
        repu_obj = compute_tsne_obj_grad_repulsive_barneshut(Y, theta, 1);
    else
        [repu_obj, repu_grad] = compute_tsne_obj_grad_repulsive_barneshut(Y, theta, 2);
    end
end

qnzinv = 1+sum((Y(I,:)-Y(J,:)).^2,2);
obj = constant + attr*sum(Pnz.*log(qnzinv)) + repu_obj;
if nargout>1
    Pq = P.*sparse(I,J,1./qnzinv,n,n);
    grad = attr*4*GraphLaplacian(Pq) * Y + repu_grad;
    grad = grad(:);
end
