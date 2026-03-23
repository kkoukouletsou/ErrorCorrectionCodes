clear
clc
close all

% Αρχικοποίηση Παραμέτρων 
M_list = [4, 8]; % 4-PAM και 8-PAM
r_list = [3, 4]; % Hamming (7,4), (15,11)
SNR_dB = 0:1:24;
Nbits_total = 1e5;

% Δημιουργία τυχαίου μηνύματος
msg = randi([0 1], Nbits_total, 1);

BER_coded = zeros(length(M_list), length(r_list), length(SNR_dB));
BER_uncoded = zeros(length(M_list), length(SNR_dB));

for i = 1: 1: length(M_list)
    M = M_list(i);
    sym_levels = -(M-1):2:(M-1);
    k_sym = log2(M); % Bits ανά σύμβολο

    % Uncoded M-PAM
    pad = mod(k_sym - mod(length(msg), k_sym), k_sym);
    msg_pad = [msg; zeros(pad,1)];

    bits_grp = reshape(msg_pad, k_sym, []).';

    % Gray Mapping
    sym_bin = bi2de(bits_grp,'left-msb');
    sym_dec = bitxor(sym_bin, bitshift(sym_bin,-1));  % manual Gray mapping

    for s = 1: 1: length(SNR_dB)

        Es = mean(sym_levels.^2); % μέση ισχύς σύμβολου
        SNR_lin = 10^(SNR_dB(s)/10);
        noise_var = Es / SNR_lin;

        tx_signal = sym_levels(sym_dec + 1);
        r = tx_signal + sqrt(noise_var)*randn(size(tx_signal));

        % Minimum Distance Detection
        [~, rx_indices] = min(abs(r.' - sym_levels), [], 2); 
        rx_sym_dec = rx_indices - 1;  % επιστροφή σε 0..M-1 integers

        % Gray Demapping 
        rx_sym_bin = gray2binfun(rx_sym_dec, k_sym);

        % Από σύμβολα σε bits
        rx_bits = de2bi(rx_sym_bin, k_sym, 'left-msb'); 
        rx_bits = rx_bits.'; 
        rx_bits = rx_bits(:); % column vector
        rx_bits = rx_bits(1:length(msg));  % αφαίρεση padding
    
        % Υπολογισμός BER
        BER_uncoded(i,s) = mean(rx_bits ~= msg);

    end

    
    % Coded M-PAM
    for j = 1: 1: length(r_list)
        r_h = r_list(j);
        n = 2^r_h - 1;
        k = n - r_h;

        coded_bits = hamming_encode(msg, r_h);


        rem = mod(length(coded_bits), k_sym);
        if rem ~= 0
            pad = k_sym - rem;
        else
            pad = 0;
        end

        coded_pad = [coded_bits; zeros(pad,1)];

        bits_grp = reshape(coded_pad, k_sym, []).';


        % Gray Mapping 
        sym_bin = bi2de(bits_grp,'left-msb');
        sym_dec = bitxor(sym_bin, bitshift(sym_bin,-1));  % manual Gray mapping

        for s = 1: 1: length(SNR_dB)

            Es = mean(sym_levels.^2); % μέση ισχύς σύμβολου
            SNR_lin = 10^(SNR_dB(s)/10);
            noise_var = Es / SNR_lin;

            tx_signal = sym_levels(sym_dec + 1);
            rx_signal = tx_signal + sqrt(noise_var)*randn(size(tx_signal));

   
            % Minimum Distance Detection
            [~, rx_indices] = min(abs(rx_signal.' - sym_levels), [], 2); 
            rx_sym_dec = rx_indices - 1;  % επιστροφή σε 0..M-1 integers

            % Gray Demapping 
            rx_sym_bin = gray2binfun(rx_sym_dec, k_sym);

            % Από σύμβολα σε bits
            rx_bits = de2bi(rx_sym_bin, k_sym, 'left-msb'); 
            rx_bits = rx_bits.'; 
            rx_bits = rx_bits(:); % column vector
            rx_bits = rx_bits(1:length(coded_bits));  % αφαίρεση padding
            

            decoded_bits = hamming_decode(rx_bits,r_h);

            L = min(length(msg), length(decoded_bits));
            BER_coded(i,j,s) = mean(msg(1:L) ~= decoded_bits(1:L));
        end
    end

    for j = 1:length(r_list)
        r_h = r_list(j);
        n = 2^r_h - 1;
        k = n - r_h;
        R = k/n;

        % BER Plot
        figure;
        semilogy(SNR_dB, BER_uncoded(i,:), 'k-o', 'LineWidth', 1.5); hold on;
        semilogy(SNR_dB, squeeze(BER_coded(i,j,:)), 'r-s', 'LineWidth', 1.5);
        grid on;
        xlabel('SNR [dB]');
        ylabel('Bit Error Rate (BER)');
        title(sprintf('%d-PAM with Hamming (%d,%d)', M, n, k));
        legend('Uncoded', 'Hamming coded', 'Location', 'southwest');

        % Throughput Plot
        throughput_uncoded = k_sym * (1 - BER_uncoded(i,:));
        throughput_coded = R * k_sym * (1 - squeeze(BER_coded(i,j,:)));

        figure;
        plot(SNR_dB, throughput_uncoded, 'k-o', 'LineWidth', 1.5); hold on;
        plot(SNR_dB, throughput_coded, 'r-s', 'LineWidth', 1.5);
        grid on;
        xlabel('SNR [dB]');
        ylabel('Throughput [bits/symbol]');
        title(sprintf('Throughput %d-PAM with Hamming (%d,%d)', M, n, k));
        legend('Uncoded', 'Hamming coded', 'Location', 'southeast');
    end
end







