function H = createIrregularLDPCMatrix(lambda, rho, N, rate)
    M = round(N * (1 - rate));
    deg_v = 2:length(lambda);
    sum_inv_lambda = sum(lambda(deg_v) ./ deg_v);
    Lambda_i = round((lambda(deg_v) ./ deg_v) / sum_inv_lambda * N);
    
    deg_c = 2:length(rho);
    sum_inv_rho = sum(rho(deg_c) ./ deg_c);
    P_i = round((rho(deg_c) ./ deg_c) / sum_inv_rho * M);

    v_sockets = [];
    for k = 1:length(Lambda_i)
        for n = 1:Lambda_i(k)
            v_sockets = [v_sockets, repmat(sum(Lambda_i(1:k-1)) + n, 1, deg_v(k))];
        end
    end
    
    c_sockets = [];
    for k = 1:length(P_i)
        for n = 1:P_i(k)
            c_sockets = [c_sockets, repmat(sum(P_i(1:k-1)) + n, 1, deg_c(k))];
        end
    end

    E = min(length(v_sockets), length(c_sockets));
    v_idx = v_sockets(randperm(length(v_sockets), E));
    c_idx = c_sockets(randperm(length(c_sockets), E));

    H_raw = sparse(c_idx, v_idx, 1, M, N);
    [r, c, v] = find(H_raw);
    H = sparse(r, c, mod(v, 2), M, N);

    empty_cols = find(sum(H, 1) == 0);
    for col = empty_cols
        H(randi(M, 1, 2), col) = 1;
    end
end