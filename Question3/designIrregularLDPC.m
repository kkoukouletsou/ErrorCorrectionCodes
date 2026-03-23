function [lambda_opt, rho_opt] = designIrregularLDPC(r_avg, l_max, epsilon)

    % 1. Καθορισμός ρ(x)
    r_idx = floor(r_avg);
    rho = zeros(1, r_idx + 1);
    rho(r_idx)     = (r_idx * (r_idx + 1 - r_avg)) / r_avg;
    rho(r_idx + 1) = (r_avg - r_idx * (r_idx + 1 - r_avg)) / r_avg;
    rho_opt = rho;

    % 2. Προετοιμασία Linprog για τα lambda
    degrees = 2:l_max;
    f = -1 ./ degrees;

    % C2: ε * λ(1 - ρ(1-x)) - x <= 0
    x_grid = 0.01:0.01:0.95;
    A = zeros(length(x_grid), length(degrees));
    b = x_grid';

    for j = 1:length(x_grid)
        x_val = x_grid(j);

        z = 1 - x_val;
        rho_z = 0;
        for i = 1:length(rho)
            if rho(i) > 0
                rho_z = rho_z + rho(i) * (z^(i-1));
            end
        end

        for i_idx = 1:length(degrees)
            deg = degrees(i_idx);
            A(j, i_idx) = epsilon * (1 - rho_z)^(deg - 1);
        end
    end

    Aeq = ones(1, length(degrees));
    beq = 1;

    lb = zeros(1, length(degrees));
    ub = ones(1, length(degrees));

    rho_prime_1 = 0;
    for i = 1:length(rho)
        rho_prime_1 = rho_prime_1 + rho(i) * (i - 1);
    end
    ub(1) = 1 / (epsilon * rho_prime_1);

    options = optimoptions('linprog', 'Display', 'none');
    lambda_sol = linprog(f, A, b, Aeq, beq, lb, ub, options);

    lambda_opt = [0, lambda_sol'];
end
