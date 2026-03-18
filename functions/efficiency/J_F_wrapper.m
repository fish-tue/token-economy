function w_bar_min = J_F_wrapper(sigma_a,C,R,A,Ac,lr)
    % Compute minimum reward
    w_bar_min = min(sigma_a2w_bar(sigma_a,C,R,A,Ac,lr));
end