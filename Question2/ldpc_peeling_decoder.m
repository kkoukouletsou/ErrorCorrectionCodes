function decoded = ldpc_peeling_decoder(H, rx)
    decoded = rx;
    [M, ~] = size(H);

    % Check node adjacency
    check_adj = cell(M, 1);
    for i = 1:M
        check_adj{i} = find(H(i,:));
    end

    max_iter = 50;
    for iter = 1:max_iter
        changed = false;

        erased_indices = find(isnan(decoded));
        if isempty(erased_indices), break; end

        for i = 1:M
            neighbors = check_adj{i};
            vals = decoded(neighbors);

            if sum(isnan(vals)) == 1
                nan_local_idx = isnan(vals);
                target_var = neighbors(nan_local_idx);
                parity_sum = mod(sum(vals(~nan_local_idx)), 2);
                decoded(target_var) = parity_sum;
                changed = true;
            end
        end

        if ~changed, break; end
    end
end

