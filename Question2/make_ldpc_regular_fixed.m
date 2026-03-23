function H = make_ldpc_regular_fixed(N, K, dv, dc)
% Κατασκευάζει έναν (dv, dc)-regular πίνακα H (MxN) γρήγορα.

    M = N - K;
    if (dv * N) ~= (dc * M)
        error('Οι παράμετροι δεν ικανοποιούν τη συνθήκη dv*N = dc*M');
    end
    
    fprintf('Δημιουργία πίνακα LDPC (%d,%d)... ', N, K);
    
    n_edges = dv * N;
    v_sockets = reshape(repmat(1:N, dv, 1), 1, []);
    c_sockets = reshape(repmat(1:M, dc, 1), 1, []);
    
    % Τυχαία μετάθεση
    rand_order = randperm(n_edges);
    c_sockets = c_sockets(rand_order);
    
    % Δημιουργία πίνακα H
    H = sparse(c_sockets, v_sockets, 1, M, N);
    H = spones(H); 
    
    fprintf('Ολοκληρώθηκε.\n');
end