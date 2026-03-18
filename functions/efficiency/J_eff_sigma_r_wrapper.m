function J = J_eff_sigma_r_wrapper(sigma_r,C,R,A,Ac,lr)
    % Compute cost
    J = 0;
    for r = 1:R
        J = J - sigma_r(r)*lr{r}(sigma_r(r));
    end
end