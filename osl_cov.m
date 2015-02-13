function C = osl_cov(X)
% Computes the covariance of a [channels x samples] matrix without 
% encountering memory issues. This allows the covariance matrix to be 
% computed for large data matrices without running out of memory.
% 
% This function can also compute the (channels x channels) covariance 
% matrix of a (channelx x samples x trials) MEEG object (using only good 
% samples). 
%
% Usage:
% C = osl_cov(X)
% 
% OR:
% C = osl_cov(D)
%
% Adam Baker 2014

if isa(X,'meeg')
    nch  = X.nchannels;
    samples2use = reshape(squeeze(~all(badsamples(X,':',':',':'))),X.nsamples*X.ntrials,1);
    nsmp = sum(samples2use);
else
    [nch,nsmp] = size(X);
    if nch > nsmp
        error(['Input has ' num2str(nsmp) ' rows and ' num2str(ncol) ' columns. Consider transposing']);
    end
    samples2use = true(1,nsmp);
end

% Compute means
chan_blks = osl_memblocks(X,1);
M = zeros(nch,1);
for i = 1:size(chan_blks,1)
    Xblk = X(chan_blks(i,1):chan_blks(i,2),:,:);
    Xblk = reshape(Xblk,size(Xblk,1),[]);
    M(chan_blks(i,1):chan_blks(i,2)) = mean(Xblk(:,samples2use),2);
end

% Compute covariance
smpl_blks = osl_memblocks(X,2);
C = zeros(nch);
for i = 1:size(smpl_blks,1)
    Xblk = X(:,smpl_blks(i,1):smpl_blks(i,2),:);
    Xblk = reshape(Xblk,size(Xblk,1),[]);
    Xblk = bsxfun(@minus,Xblk,M);
    samples2use_blk = samples2use(smpl_blks(i,1):smpl_blks(i,2));
    C = C + Xblk(:,samples2use_blk)*Xblk(:,samples2use_blk)';
end
C = C./(nsmp-1);


end