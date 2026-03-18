function J = J_eff_wrapper(sigma_a,C,R,A,Ac,lr)
    % Compute sigma_r
    sigma_r = sigma_a2r(sigma_a,C,R,A,Ac);
    % Compute cost
    J = J_eff_sigma_r_wrapper(sigma_r,C,R,A,Ac,lr);
end