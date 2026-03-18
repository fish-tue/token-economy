function sigma_r = sigma_a2r(sigma_a,C,R,A,Ac)
    % Divide c in classes
    sigma_a_exp = cell(C,1);
    count = 0;
    for c = 1:C
        sigma_a_exp{c} = zeros(A(c));
        sigma_a_exp{c} = sigma_a(count+1:count+A(c));
        count = count + A(c);
    end
    % Compute sigma_r
    sigma_r = zeros(R,1);
    for r = 1:R
        for c = 1:C
            for a = 1:A(c)
                if sum(Ac{c}{a} == r)
                    sigma_r(r) = sigma_r(r) + sigma_a_exp{c}(a);
                end
            end
        end
        
    end
end