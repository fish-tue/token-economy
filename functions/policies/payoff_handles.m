function Fu = payoff_handles(p,Ac,lr,k_max,Rd,Rn)
    % Init payoff handles
    C = size(Ac,1);
    Fu = cell(C,1);
    for c = 1:C
        Fu{c} = @(pol,sigma) payoff_value(pol,sigma,p{c},Ac{c},lr,k_max,Rd,Rn);
    end
end

function Fcu = payoff_value(pol,sigma,pc,Ac,lr,k_max,Rd,Rn)
    % Get steady state distribution
    etaK = unique_ss_dist(phiK_pol(pol,pc,k_max,Rd,Rn));   
    % Sum payoff of resources
    Fcu = 0;
    for k = 1:k_max+1
        a = implement_pol(pol,k-1);
        for r = Ac{a}'
            Fcu = Fcu - etaK(k)*lr{r}(sigma(r));
        end
    end
end