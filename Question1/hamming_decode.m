function decoded_bits = hamming_decode(received_bits, r)

    n = 2^r - 1;
    received_bits = received_bits(:);  % column vector

    % Trim extra bits
    if mod(length(received_bits), n) ~= 0
        received_bits = received_bits(1:end - mod(length(received_bits), n));
    end

    % Reshape σε blocks
    received_bits = reshape(received_bits, n, []).';
    decoded_bits = [];

    % Parity-check matrix H (r x n)
    H = fliplr(de2bi(1:n, r, 'left-msb')).';

    parity_positions = 2.^(0:r-1);
    data_positions = setdiff(1:n, parity_positions);

    for i = 1:size(received_bits, 1) 
        codeword = received_bits(i, :).';

        % Υπολογισμός συνδρόμου
        s = mod(H * codeword, 2);

        % Αν υπάρχει single-bit error
        if any(s)
            error_pos = bi2de(flip(s.'));
            if error_pos >= 1 && error_pos <= n
                codeword(error_pos) = mod(codeword(error_pos) + 1, 2);
            end
        end

        % Εξαγωγή data bits
        decoded_bits = [decoded_bits; codeword(data_positions)];
    end

    decoded_bits = decoded_bits(:);
end
 
