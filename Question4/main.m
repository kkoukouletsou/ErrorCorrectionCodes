clear; clc; close all;

% Παράμετροι Σεναρίου
N = 2000;       
rate = 0.5;        
l_max = 20;        
r_avg = 6;         
n_trials = 300;    

% Διαφορετικές τιμές για τα κανάλια
epsilon1_vec = 0.01:0.05:0.5;   % Bob erasure probabilities
epsilon2_vec = 0.5:0.05:0.9;     % Eve erasure probabilities

fprintf('--- Ερώτημα 4: Security-Optimized Irregular LDPC ---\n');

% Σχεδιασμός Κώδικα
design_epsilon = max(epsilon1_vec) + 0.005; 
[lambda, rho] = designIrregularLDPC(r_avg, l_max, design_epsilon);
H = createIrregularLDPCMatrix(lambda, rho, N, rate);

% Simulation Loop
results_bob = zeros(length(epsilon1_vec), 1);
results_eve = zeros(length(epsilon2_vec), 1);

fprintf('\n--- Bob BER vs ε1 ---\n');
for idx1 = 1:length(epsilon1_vec)
    e1 = epsilon1_vec(idx1);
    totalErrorsBob = 0;

    for trial = 1:n_trials
        tx_bits = randi([0 1], 1, N);
        rx_bob = double(tx_bits);
        rx_bob(rand(1, N) < e1) = NaN;
        dec_bob = decodeIrregularLDPC(H, rx_bob);
        dec_bob(isnan(dec_bob)) = randi([0 1], 1, sum(isnan(dec_bob)));
        totalErrorsBob = totalErrorsBob + sum(dec_bob ~= tx_bits);
    end

    ber_bob = totalErrorsBob / (N * n_trials);
    results_bob(idx1) = ber_bob;
    fprintf('ε1=%.2f | BER Bob=%.4e\n', e1, ber_bob);
end

fprintf('\n--- Eve BER vs ε2 ---\n');
for idx2 = 1:length(epsilon2_vec)
    e2 = epsilon2_vec(idx2);
    totalErrorsEve = 0;

    for trial = 1:n_trials
        tx_bits = randi([0 1], 1, N);
        rx_eve = double(tx_bits);
        rx_eve(rand(1, N) < e2) = NaN;
        dec_eve = decodeIrregularLDPC(H, rx_eve);
        dec_eve(isnan(dec_eve)) = randi([0 1], 1, sum(isnan(dec_eve)));
        totalErrorsEve = totalErrorsEve + sum(dec_eve ~= tx_bits);
    end

    ber_eve = totalErrorsEve / (N * n_trials);
    results_eve(idx2) = ber_eve;
    fprintf('ε2=%.2f | BER Eve=%.4f\n', e2, ber_eve);
end

% Plotting
figure('Color','w'); 
plot(epsilon1_vec, results_bob, 'g-o','LineWidth',1.5,'MarkerFaceColor','g');
grid on; xlabel('\epsilon_1 (Bob)'); ylabel('BER'); title('BER vs ε1 for Bob');
ylim([0 0.1]);

figure('Color','w'); 
plot(epsilon2_vec, results_eve, 'r-s','LineWidth',1.5,'MarkerFaceColor','r');
grid on; xlabel('\epsilon_2 (Eve)'); ylabel('BER'); title('BER vs ε2 for Eve');
ylim([0 0.6]);
