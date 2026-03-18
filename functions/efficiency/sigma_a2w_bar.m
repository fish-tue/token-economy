function w_bar = sigma_a2w_bar(sigma_a,C,R,A,Ac,lr)
    % Divide c in classes
    sigma_a_exp = cell(C,1);
    count = 0;
    for c = 1:C
        sigma_a_exp{c} = zeros(A(c));
        sigma_a_exp{c} = sigma_a(count+1:count+A(c));
        count = count + A(c);
    end
    % Compute sigma_r
    sigma_r = sigma_a2r(sigma_a,C,R,A,Ac);
    % Compute w_bar
    w_bar = zeros(C,1);
    for c = 1:C
        for a = 1:A(c)
            % Compute reward of a
            la = 0;
            for r = Ac{c}{a}'
                la = la + lr{r}(sigma_r(r));
            end
            % Compute average reward of c
            w_bar(c) = w_bar(c) - sigma_a_exp{c}(a)*la;
        end
        w_bar(c) = w_bar(c)/sum(sigma_a_exp{c});
    end
end