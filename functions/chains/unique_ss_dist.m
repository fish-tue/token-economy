function eta = unique_ss_dist(phi)
    % Null space is the invarinat measure
    eta = null(phi);
    if size(eta,2) > 1
        k_max = size(phi,1)-1;
        phiN_D = [[zeros(1,k_max); eye(k_max)] [zeros(k_max,1);1]];
        phiN_D = phiN_D-eye(size(phiN_D,1));
        Rn_inc = 0.05;
        count = 0;
        while true
            count = count+1;
            phi = phi + Rn_inc*phiN_D;
            eta = null(phi);
            if size(eta,2) == 1
                break;
            end   
        end
        warning(sprintf('Using higher noise to induce unique steady state distribution (added Rn = %g).\n',count*Rn_inc));
    end
    eta = eta/sum(eta); 
    % Remove numerical error
    epsl = 1e-6/length(eta);
    eta(eta<epsl) = 0;
    eta = eta/sum(eta);
end