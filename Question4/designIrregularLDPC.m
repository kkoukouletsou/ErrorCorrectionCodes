function [lambda_opt, rho_opt] = designIrregularLDPC(r_avg, l_max, epsilon)
    % Rho Distribution
    r_idx = floor(r_avg);
    rho = zeros(1, r_idx + 1);
    rho(r_idx) = (r_idx * (r_idx + 1 - r_avg)) / r_avg;
    rho(r_idx + 1) = (r_avg - r_idx * (r_idx + 1 - r_avg)) / r_avg;
    rho_opt = rho;

    % Optimization of Lambda
    degrees = 2:l_max;
    f = -1 ./ degrees; 
    x_grid = 0.01:0.01:0.98;
    A = zeros(length(x_grid), length(degrees));
    b = x_grid';

    rho_prime_1 = sum(rho .* (0:length(rho)-1));

    for j = 1:length(x_grid)
        x_val = x_grid(j);
        z = 1 - x_val;
        rho_z = sum(rho .* (z.^(0:length(rho)-1)));
        for i_idx = 1:length(degrees)
            deg = degrees(i_idx);
            A(j, i_idx) = epsilon * (1 - rho_z)^(deg - 1);
        end
    end

    Aeq = ones(1, length(degrees)); beq = 1;
    lb = zeros(1, length(degrees)); ub = ones(1, length(degrees));
    ub(1) = 1 / (epsilon * rho_prime_1); 

    options = optimoptions('linprog','Display','none');
    lambda_sol = linprog(f, A, b, Aeq, beq, lb, ub, options);
    lambda_opt = [0, lambda_sol'];
end