function phi = phiK_pol(pol,p,k_max,Rd,Rn)
    % Discrete nominal phi
    phi = zeros(k_max+1,k_max+1);
    for k = 1:k_max+1
        % Find action that each state maps to
        a = implement_pol(pol,k-1);
        % Decrease amount of tokens by price of that action 
        phi(min([k_max+1,k-p(a)]),k) = 1;
    end
    phiN_D = [[zeros(1,k_max); eye(k_max)] [zeros(k_max,1);1]];
    % CT phi
    phi = Rd*(phi-eye(size(phi,1))) + Rn*(phiN_D-eye(size(phiN_D,1)));
end