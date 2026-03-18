function pR = normalize_price(pR, sigma_r_star,C,A,Ac,R,k_max,Rn)
    obj = @(pR_norm) norm(pR_norm-pR)^2 + (sigma_r_star'*pR_norm-Rn)^2+ sum(abs(pR_norm-round(pR_norm)));
    ub = ones(R,1)*k_max;
    lb = -ub;
    cntr_margin = 2;
    nonlin_cntr = @(pR_norm) non_lin_cntr_wrapper(pR_norm,C,A,Ac,R,cntr_margin);
    opts = optimoptions('fmincon','Display','none','Algorithm','sqp','MaxFunctionEvaluations',200*sum(A));
    [pR_norm,~,exitflag,output] = fmincon(obj,pR,[],[],[],[],lb,ub,nonlin_cntr,opts);
    if exitflag == 1 || exitflag == 2
        if exitflag == 1
            pR = round(pR_norm);
        else
            warning('Using best feasible local minimum found.');
            pR = round(output.bestfeasible.x);
        end
        pA = pR2pA(pR,C,A,Ac);
        min_pc = zeros(C,1);
        for c = 1:C
            min_pc(c) = min(pA{c});
        end
        if max(min_pc)>0
            pR = nan;
            error("Invalid normalized prices: Constraint failed.");
        end
    else
        pR = nan;
        disp(output)
        disp(exitflag)
        error("Invalid normalized prices: Optimization failed.");
    end
    
end

function [cntr,cntr_eq] = non_lin_cntr_wrapper(pR_norm,C,A,Ac,R,cntr_margin)
    cntr_eq = [];
    cntr = zeros(R,1);
    p = pR2pA(pR_norm,C,A,Ac);
    for c = 1:C
        cntr(c) = min(p{c})+cntr_margin;
    end
end