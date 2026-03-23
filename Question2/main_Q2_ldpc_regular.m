clear; clc; close all;
rng(42);

% ΠΑΡΑΜΕΤΡΟΙ
M_mod = 4;                   % 4-PAM
k_sym = log2(M_mod);         
levels = [-3 -1 1 3];        % Gray mapping: 00->-3, 01->-1, 11->1, 10->3

Es = mean(levels.^2);        
SNR_dB_range = 0:3:24;
thresholds = [0.2 0.4 0.6 0.8];  % Thresholds για Erasures
n_trials = 100;              % πλήθος επαναλήψεων

%% LDPC Regular Parameters
N = 5000;        % μήκος κώδικα
dv = 3; dc = 6;
R = 1 - dv/dc; 
K = round(N * R);
M = N - K;

fprintf('--- REGULAR LDPC (3,6) | N=%d ---\n', N);

% ΚΑΤΑΣΚΕΥΗ REGULAR LDPC
H = make_ldpc_regular_fixed(N, K, dv, dc);

BER = zeros(length(SNR_dB_range), length(thresholds));
epsilon_eff = zeros(length(SNR_dB_range), length(thresholds));
throughput = zeros(length(SNR_dB_range), length(thresholds));

% ΚΥΡΙΟΣ ΒΡΟΧΟΣ
for t = 1:length(thresholds)
    th = thresholds(t);
    fprintf('\nErasure Threshold = %.2f\n', th);

    for s = 1:length(SNR_dB_range)
        SNR_dB = SNR_dB_range(s);
        snr_lin = 10^(SNR_dB/10);
        sigma = sqrt(Es / (2 * snr_lin));

        bit_errors = 0;
        erasures_count = 0;

        for trial = 1:n_trials
            % 1. Πληροφορία & Κωδικοποίηση
            tx_bits = randi([0 1], 1, N);  % τυχαία bits
            
            % Gray mapping σε 4-PAM
            bits_reshaped = reshape(tx_bits, 2, []).';
            idx = bi2de(bits_reshaped, 'left-msb') + 1;
            tx_symbols = levels(idx);

            % 2. AWGN Channel
            rx = tx_symbols + sigma * randn(size(tx_symbols));

            % 3. Hard decision + Erasures
            rx_bits = NaN(1, N);
            for i = 1:length(rx)
                dist = abs(rx(i) - levels);
                [min_dist, min_idx] = min(dist);

                if min_dist <= th
                    switch min_idx
                        case 1, bits = [0 0];
                        case 2, bits = [0 1];
                        case 3, bits = [1 1];
                        case 4, bits = [1 0];
                    end
                    rx_bits(2*i-1 : 2*i) = bits;
                else
                    erasures_count = erasures_count + 1;
                end
            end

            % 4. Peeling Decoder
            decoded = ldpc_peeling_decoder(H, rx_bits);
            decoded(isnan(decoded)) = randi([0 1], 1, sum(isnan(decoded)));

            % 5. Error Counting
            bit_errors = bit_errors + sum(decoded ~= tx_bits);
        end

        BER(s,t) = bit_errors / (N * n_trials);
        epsilon_eff(s,t) = erasures_count / (N * n_trials);
        throughput(s,t) = R * k_sym * (1 - BER(s,t));  % effective bits/symbol
        fprintf('SNR=%2d dB | BER=%.2e | Eff. Erasures=%.3f\n', ...
                SNR_dB, BER(s,t), epsilon_eff(s,t));
    end
end

% PLOTS: 1 plot ανά threshold
for t = 1:length(thresholds)
    current_th = thresholds(t);
    
    % --- SNR vs BER (linear scale) ---
    figure('Color', 'w');
    plot(SNR_dB_range, BER(:,t), 'r-s', ...
         'LineWidth', 1.5, ...
         'MarkerSize', 6, ...
         'MarkerFaceColor', 'r');
    grid on;
    set(gca, 'FontSize', 10);
    xlabel('SNR [dB]', 'FontWeight', 'bold');
    ylabel('Bit Error Rate (BER)', 'FontWeight', 'bold');
    title(sprintf('Regular LDPC: 4-PAM with d_{th} = %.1f', current_th));
    legend(sprintf('Regular LDPC (R=%.2f)', R), ...
           'Location', 'southwest');
    ylim([0 max(BER(:,t))*1.2]); 

    % SNR vs Throughput
    figure('Color', 'w');
    plot(SNR_dB_range, throughput(:,t), 'b-o', ...
         'LineWidth', 1.5, ...
         'MarkerSize', 6, ...
         'MarkerFaceColor', 'b');
    grid on;
    set(gca, 'FontSize', 10);
    xlabel('SNR [dB]', 'FontWeight', 'bold');
    ylabel('Throughput [bits/symbol]', 'FontWeight', 'bold');
    title(sprintf('Throughput: 4-PAM with d_{th} = %.1f', current_th));
    legend(sprintf('Regular LDPC (R=%.2f)', R), ...
           'Location', 'southeast');
end