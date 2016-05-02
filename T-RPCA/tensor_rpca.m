function [L, S] = tensor_rpca(X, lambda)
    
    % set ADMM parameters
    epsilon = 1.25;
    rho = 2/3; 
    maxiter = 500;
    % initialize L, S, and Y
    L = ones(size(X));
    S = X - L;
    Y = L + S - X;

    % ADMM based on Zhang paper
    figure;
    for k=1:maxiter
        fprintf('Iteration: %d', k);
        oldL = L;
        oldS = S;
        L = L_Update(-(oldS - X + Y), 1/rho);
        S = S_Update(-(L - X + Y), lambda/rho);
        Y = Y + L + S - X;

        L_diff = norm(L(:)-oldL(:));
        S_diff = norm(S(:)-oldS(:));
        fprintf('\tL_diff: %f\tS_diff: %f\n', L_diff, S_diff);
        
        % draw current values of L and S for 10th frame
        subplot(121);imagesc(L(:,:,10));colormap(gray); drawnow;
        subplot(122);imagesc(S(:,:,10));colormap(gray); drawnow;
        
        if (L_diff < epsilon && S_diff < epsilon)
            break;
        end
    end
end

function result = L_Update(term, threshold)
    % first, transform S and Y to fourier space
    fft_term = fft(term, [], 3);
    result = zeros(size(term));
    [n1, n2, n3] = size(term);
    U = zeros(n1,n1,n3);
    Sigma = zeros(n1,n2,n3);
    V = zeros(n2,n2,n3);
   
    % calculate SVD for each ith frontal slice of input term
    % threshold diagonal of Sigma by input threshold
    for i=1:size(result,3)
        [Uf, Sigmaf, Vf] = svd(fft_term(:,:,i));
        for j=1:min(size(Sigmaf,1), size(Sigmaf,2))
            % Sigmaf(j,j) = subplus(Sigmaf(j,j) - threshold); 
            Sigmaf(j,j) = Sigmaf(j,j) * (1 - min( threshold/abs(Sigmaf(j,j)), 1 ));
        end
        U(:,:,i) = Uf;
        Sigma(:,:,i) = Sigmaf;
        V(:,:,i) = Vf;
    end
    
    % transform to original space
    U = ifft(U, [], 3);
    Sigma = ifft(Sigma, [], 3);
    V = ifft(V, [], 3); 
    
    % determine result = U * Sigma * V' using tprod
    result = tprod( tprod(U,Sigma), tran(V));
end

function result = S_Update(term, threshold)
    n3 = size(term,3);
    % calculate norm of each tube of term
    fnorm = sum(term .* term, 3);
    % perform soft threshold on each tube
    soft_threshold = pos( 1 - threshold./fnorm );
    % determine result for each tube of S
    tube_result = repmat(soft_threshold, [1,1,n3]);
    result = term .* tube_result;
end