function sigma = update_sigma_one_class(k_t,u_t,R,Ac,Rd)
    % Init variables
    N = length(k_t);
    sigma = zeros(R,1);
    for j = 1:N
        r = Ac{implement_pol(u_t{j},k_t(j))};
        sigma(r) = sigma(r) + (1/N)*Rd;
    end
end
