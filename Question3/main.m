clear
clc
close all

% 1. Παράμετροι Κώδικα
N = 5000;
rate = 0.5;
l_max = 12;
r_avg = 6;

SNR_dB_range = 0:3:24;
thresholds = [0.2, 0.4, 0.6, 0.8];
n_trials = 1000;

SNR_dB_design = 4;
Es = 5;

for t = 1:length(thresholds)
    current_th = thresholds(t);
    fprintf('\n--- Testing Threshold: %.1f ---\n', current_th);

    snr_linear_design = 10^(SNR_dB_design / 10);
    sigma_design = sqrt(Es / (2 * snr_linear_design));
    epsilon_effective = 2 * qfunc(current_th / sigma_design);

    [lambda, rho] = designIrregularLDPC(r_avg, l_max, epsilon_effective);
    H = createIrregularLDPCMatrix(lambda, rho, N, rate);

    BER = zeros(size(SNR_dB_range));
    Throughput = zeros(size(SNR_dB_range));

    for s = 1:length(SNR_dB_range)
        SNR_dB = SNR_dB_range(s);
        total_errors = 0;

        snr_linear = 10^(SNR_dB / 10);
        current_sigma = sqrt(Es / (2 * snr_linear));

        for trial = 1:n_trials
            tx_bits = randi([0 1], 1, N);

            symbols_map = [-3, -1, 3, 1];
            bits_reshaped = reshape(tx_bits, 2, [])';
            idx = bi2de(bits_reshaped, 'left-msb') + 1;
            tx_symbols = symbols_map(idx);

            rx_noisy = tx_symbols + current_sigma * randn(size(tx_symbols));

            rx_bits_bec = NaN(1, N);
            centers = [-3, -1, 1, 3];
            labels = [0 0; 0 1; 1 1; 1 0];

            for i = 1:length(rx_noisy)
                [dist, min_idx] = min(abs(rx_noisy(i) - centers));
                if dist < current_th
                    rx_bits_bec(2*i-1:2*i) = labels(min_idx, :);
                end
            end

            decoded = decodeIrregularLDPC(H, rx_bits_bec);
            decoded(isnan(decoded)) = randi([0 1]);

            total_errors = total_errors + sum(decoded ~= tx_bits);
        end

        BER(s) = total_errors / (N * n_trials);
        Throughput(s) = rate * (1 - BER(s));

        fprintf('Threshold %.1f | SNR: %2d dB | BER: %.4e | Throughput: %.3f\n', ...
                current_th, SNR_dB, BER(s), Throughput(s));
    end

    % === Plot BER ===
    figure('Color', 'w');
    semilogy(SNR_dB_range, BER, 'r-s', ...
             'LineWidth', 1.5, ...
             'MarkerSize', 6, ...
             'MarkerFaceColor', 'r');
    grid on;
    set(gca, 'FontSize', 10);
    xlabel('SNR [dB]', 'FontWeight', 'bold');
    ylabel('Bit Error Rate (BER)', 'FontWeight', 'bold');
    title(sprintf('Irregular LDPC: 4-PAM with d_{th} = %.1f', current_th));
    legend(sprintf('Irregular LDPC (R=%.1f)', rate), ...
           'Location', 'southwest');
    ylim([1e-4 1]);

    % === Plot Throughput ===
    figure('Color', 'w');
    plot(SNR_dB_range, Throughput, 'b-o', ...
         'LineWidth', 1.5, ...
         'MarkerSize', 6, ...
         'MarkerFaceColor', 'b');
    grid on;
    set(gca, 'FontSize', 10);
    xlabel('SNR [dB]', 'FontWeight', 'bold');
    ylabel('Throughput', 'FontWeight', 'bold');
    title(sprintf('Throughput vs SNR: 4-PAM, d_{th} = %.1f', current_th));
    legend(sprintf('Irregular LDPC (R=%.1f)', rate), ...
           'Location', 'southeast');
    ylim([0 rate+0.05]);
end

