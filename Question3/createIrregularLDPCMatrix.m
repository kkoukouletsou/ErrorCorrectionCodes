function H = createIrregularLDPCMatrix(lambda, rho, N, rate)

    M = round(N * (1 - rate));

    deg_v = 2:length(lambda);
    sum_inv_lambda = sum(lambda(deg_v) ./ deg_v);
    Lambda_i = (lambda(deg_v) ./ deg_v) / sum_inv_lambda * N;
    Lambda_i = round(Lambda_i);

    % P_i = (rho_i / i) / sum(rho_j / j) * M
    deg_c = 2:length(rho);
    sum_inv_rho = sum(rho(deg_c) ./ deg_c);
    P_i = (rho(deg_c) ./ deg_c) / sum_inv_rho * M;
    P_i = round(P_i);

    % 2. Δημιουργία Λίστας Ακμών
    var_sockets = [];
    for k = 1:length(Lambda_i)
        degree = deg_v(k);
        num_nodes = Lambda_i(k);

        for n_idx = 1:num_nodes
            node_id = sum(Lambda_i(1:k-1)) + n_idx;
            if node_id <= N
                var_sockets = [var_sockets, repmat(node_id, 1, degree)];
            end
        end
    end

    check_sockets = [];
    for k = 1:length(P_i)
        degree = deg_c(k);
        num_nodes = P_i(k);
        for n_idx = 1:num_nodes
            node_id = sum(P_i(1:k-1)) + n_idx;
            if node_id <= M
                check_sockets = [check_sockets, repmat(node_id, 1, degree)];
            end
        end
    end

    % 3. Ταίριασμα Ακμών
    num_edges = min(length(var_sockets), length(check_sockets));
    var_sockets   = var_sockets(randperm(length(var_sockets)));
    check_sockets = check_sockets(randperm(length(check_sockets)));

    % Αρχικοποίηση πίνακα H
    H = zeros(M, N);
    for e = 1:num_edges
        v_node = var_sockets(e);
        c_node = check_sockets(e);

        H(c_node, v_node) = mod(H(c_node, v_node) + 1, 2);
    end
end
