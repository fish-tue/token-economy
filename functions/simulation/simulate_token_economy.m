function [sigma_dt_LP_f,sigma_dt_LP] = simulate_token_economy(c_t,k_t,u_t,next_ring_d,next_ring_r,next_ring_n,p,ti,tf,dt,N,R,C,Ac,lr,k_max,Rd,Rr,Rn,sigma_r_star,alpha_LP_dt,N_new_policies_p_update)
    %% Outputs
    
    % Long
    % [k_t,u_t,next_ring_d,next_ring_r,next_ring_n,sigma_dt,sigma_dt_LP,k_dt]
   
    % Short
    % 

    %% Extract some variables

    %% Compute payoff and revision handles
    type_rev = 0.5;
    Fu = payoff_handles(p,Ac,lr,k_max,Rd,Rn);
    r_rpl = @(c,u,v) max(0,Fu{c}(v,sigma_r_star)-Fu{c}(u,sigma_r_star)); % Imitative via comparison
    phi_cmp = @(c,u,v) max(0,Fu{c}(v,sigma_r_star)-Fu{c}(u,sigma_r_star));

    % Users using invalid policies have to reconsider
    count = 0;
    for j = 1:N
        % Check if policy is valid
        if ~is_map_valid(u_t{j},p{c_t(j)},k_max)
            count = count+1;
            new_policies = cell(N_new_policies_p_update,1);
            new_policies_dist = zeros(N_new_policies_p_update,1);
            [~,idx_sort_old] = sort(u_t{j}(1,:));   
            for k = 1:N_new_policies_p_update
                new_policies{k} = rand_valid_pol(p{c_t(j)},k_max);
                [~,idx_sort_new] = sort(new_policies{k}(1,:));                     
                new_policies_dist(k) = norm(new_policies{k}(2,idx_sort_new)-u_t{j}(2,idx_sort_old));
            end
            idx = softmax_randi(new_policies_dist);
            u_t{j} = new_policies{idx};
        end
    end
    %count
    %users_w_invalid_polidx_update) = count;

    %% Time
    t_span = ti:dt:tf;

    %% Simulation variables
    %sigma_dt = zeros(R,length(t_span),C);
    sigma_dt_LP = zeros(R,length(t_span));
    
    %% Simulate events 
    for i = 1:length(t_span)
        %i/length(t_span)
        % Previous policies (for imitative dynamics)
        for idx_ring = 1:N
            while true
                % Find next event
                [t_ring, type_ring] = min([next_ring_d{idx_ring},next_ring_r{idx_ring},next_ring_n{idx_ring}]);
     
                % Break loop and sample if next event is after t_span(i)
                if t_ring >= t_span(i)
                    break;
                end
    
                % Perform next event
                switch type_ring
                    case 1 % Dynamic ring
                        % Jump in individual state
                        k_t{idx_ring} = min([k_max k_t{idx_ring}-p{c_t(idx_ring)}(implement_pol(u_t{idx_ring},k_t{idx_ring}))]);
                        % Compute next ring
                        next_ring_d{idx_ring} = next_ring_d{idx_ring} + exprnd(1/Rd);
                    case 2 % Revision ring
                        if rand() < type_rev % Pairwise cmp
                            % Choose a random policy
                            v = rand_valid_pol(p{c_t(idx_ring)},k_max);
                            if rand() < phi_cmp(c_t(idx_ring),u_t{idx_ring},v)/Rr % Immitate w/ prob. r_uv/R_r
                                u_t{idx_ring} = v;
                            end
                        else % Imitative
                            % Choose a random player of the population to compare
                            aux = find(c_t == c_t(idx_ring));
                            v = u_t{aux(randi(length(aux)))};
                            if rand() < r_rpl(c_t(idx_ring),u_t{idx_ring},v)/Rr % Immitate w/ prob. r_uv/R_r
                                u_t{idx_ring} = v;
                            end
                        end
                        % Compute next ring
                        next_ring_r{idx_ring} = next_ring_r{idx_ring} + exprnd(1/Rr);
                    case 3 % Noise ring
                        % Give gift of one token
                        k_t{idx_ring} = min([k_max k_t{idx_ring}+1]);
                        % Compute next ring
                        next_ring_n{idx_ring} = next_ring_n{idx_ring} + exprnd(1/Rn);
                end
            end
        end

        % Update sampled population states
        %sigma_dt(:,i,:) = update_sigma_class(c_t,cell2mat(k_t),u_t,R,Ac,Rd); % Current distribution of each player;
        %sigma_t = sum(sigma_dt(:,i,:),3);
        aux = update_sigma(c_t,cell2mat(k_t),u_t,R,Ac,Rd);
        if i >  1
            sigma_dt_LP(:,i) = sigma_dt_LP(:,i-1)*alpha_LP_dt + (1-alpha_LP_dt)*aux;
        else
            sigma_dt_LP(:,i) = aux;
        end  
    end
    sigma_dt_LP_f = sigma_dt_LP(:,end);
end


% Notes: For non parfor randomize order of agents