function decoded = decodeIrregularLDPC(H, received)

    decoded = received;
    [M, ~] = size(H);

    while true
        updated = false;

        for c = 1:M
            idx = find(H(c, :));
            unknowns = idx(isnan(decoded(idx)));

            if length(unknowns) == 1
                v = unknowns;
                knowns = idx(~isnan(decoded(idx)));
                decoded(v) = mod(sum(decoded(knowns)), 2);
                updated = true;
            end
        end

        if ~updated
            break;
        end
    end
end
