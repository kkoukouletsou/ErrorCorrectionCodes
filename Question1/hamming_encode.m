function coded_bits = hamming_encode(bits, r)

    n = 2^r - 1; % συνολικά bits ανά codeword
    k = n - r; % bits πληροφορίας

    bits = bits(:);

    % Zero padding if needed
    if mod(length(bits), k) ~= 0
        bits = [bits; zeros(k - mod(length(bits), k), 1)];
    end

    coded_bits = [];

    parity_positions = 2.^(0:r-1);

    for i = 1:k:length(bits)
        data = bits(i:i+k-1);

        % Δημιουργία codeword
        codeword = zeros(n, 1);

        % Θέσεις data bits
        data_positions = setdiff(1:n, parity_positions);
        codeword(data_positions) = data;

        % Υπολογισμός parity bits
        for p = 1:r
            idx = find(bitget(1:n, p));   % θέσεις που ελέγχει το parity p
            parity_value = mod(sum(codeword(idx)), 2);
            codeword(parity_positions(p)) = parity_value;
        end

        coded_bits = [coded_bits; codeword];
    end
end
