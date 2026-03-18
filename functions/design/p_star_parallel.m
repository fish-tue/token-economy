function [p_star_round,p_star,S] = p_star_parallel(sigma,l,Rd,Rn,p_max)
    % Parameters
    N_points = 100;
    % Limits for scaling S
    l_dif = (l'*sigma/Rd - l(sigma>1e-6));
    S_lim_up = min([(p_max-Rn/Rd)/max(l_dif) (-p_max-Rn/Rd)/min(l_dif)]);
    S_lim_lw = max([0 (p_max-Rn/Rd)/min(l_dif) (-p_max-Rn/Rd)/max(l_dif)]);
    S_points = S_lim_lw:(S_lim_up-S_lim_lw)/(N_points-1):S_lim_up;
    % Compute error to round
    error_round = zeros(N_points,1);
    p_norm = zeros(N_points,1);
    for i = 1:N_points
        aux = p_star_parallel_S(sigma,l,Rd,Rn,S_points(i));
        error_round(i) = norm(aux-round(aux));
        p_norm(i) = norm(aux);
    end
    % Get minimum error
    error_round(p_norm < p_max) = inf;
    [~,idx_min] = min(error_round);
    S = S_points(idx_min);
    p_star = p_star_parallel_S(sigma,l,Rd,Rn,S);
    p_star_round = round(p_star);
end

function p_star = p_star_parallel_S(sigma,l,Rd,Rn,S)
    R = length(sigma);
    p_star = zeros(R,1);
    for r = 1:R
        p_star(r) = Rn/Rd+S*(l'*sigma/Rd - l(r));
    end
end
