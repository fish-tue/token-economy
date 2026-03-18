function sigma = update_sigma_class(c_t,k_t,u_t,R,Ac,Rd)
    % Init variables
    N = length(k_t);
    C = max(c_t);
    sigma = zeros(R,C);
    for j = 1:N
        r = Ac{c_t(j)}{implement_pol(u_t{j},k_t(j))};
        sigma(r,c_t(j)) = sigma(r,c_t(j)) + (1/N)*Rd;
    end
end