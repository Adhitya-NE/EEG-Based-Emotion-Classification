function D = HiguchiFD(x, kmax)
    N = length(x);
    L_k = zeros(kmax, 1);
    
    for k = 1:kmax
        Lk_sum = 0;
        for m = 1:k
            num_samples = floor((N - m) / k);
            if num_samples < 1
                L_m_k = 0;
            else
                L_m_k = 0;
                for i = 1:num_samples
                    L_m_k = L_m_k + abs(x(m + i*k) - x(m + (i-1)*k));
                end
                L_m_k = (L_m_k * (N - 1)) / (k * num_samples * k);
            end
            Lk_sum = Lk_sum + L_m_k;
        end
        L_k(k) = Lk_sum / k;
    end
    
    % Ambil log untuk regresi linear
    log_L = log(L_k);
    log_k = log(1 ./ (1:kmax)');
    
    % Regresi linear log(L) vs log(1/k)
    p = polyfit(log_k, log_L, 1);
    D = p(1);
end