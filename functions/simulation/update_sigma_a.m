function sigma_a = update_sigma_a(c_t,k_t,u_t,Ac,Rd)
    % Init variables
    N = length(k_t);
    C = max(c_t);
    sigma_aux = cell(C,1);
    for c = 1:C
        sigma_aux{c,1} = zeros(length(Ac{c,1}),1);
    end
    for j = 1:N
        a = implement_pol(u_t{j},k_t(j));
        sigma_aux{c_t(j),1}(a) = sigma_aux{c_t(j),1}(a) + (1/N)*Rd;
    end
    sigma_a = cell2mat(sigma_aux);
end