function decoded = decodeIrregularLDPC(H, received)
    decoded = received;
    [M, ~] = size(H);

    while true
        updated = false;
        nan_indices = find(isnan(decoded));
        if isempty(nan_indices), break; end
        
        [rows, ~] = find(H(:, nan_indices));
        unique_rows = unique(rows);
        
        for c = unique_rows'
            idx = find(H(c,:));
            vals = decoded(idx);
            nan_in_row = isnan(vals);
            if sum(nan_in_row) == 1
                v_to_fix = idx(nan_in_row);
                known_vals = vals(~nan_in_row);
                decoded(v_to_fix) = mod(sum(known_vals), 2);
                updated = true;
            end
        end
        if ~updated, break; end
    end
end