function [ka_map,flag_convergence] = simulate_ka_maps(p,Nout,flag_plot,Ac,lr,sigma_r_star,k_max,R)
    %% Outputs
    
    % Long
    % [k_t,u_t,next_ring_d,next_ring_r,next_ring_n,sigma_dt,sigma_dt_LP,k_dt]
   
    % Short
    % 

    %% Parameters
    % Time
    T_sim = 3e3; % Simlation length
    dt_sim = 10;%100;
    t_span = 0:dt_sim:T_sim;
    % Population
    N = 200;
    Rd = 1;
    Rr = 0.5;
    Rn = 0.1;
    
    %% Compute payoff and revision handles
    type_rev = 0.5;
    Fu = payoff_handles_one_class(p,Ac,lr,k_max,Rd,Rn);
    r_rpl = @(u,v) max(0,Fu(v,sigma_r_star)-Fu(u,sigma_r_star)); % Imitative via comparison
    phi_cmp = @(u,v) max(0,Fu(v,sigma_r_star)-Fu(u,sigma_r_star));

    %% Init evolutions
    sigma_dt = zeros(R,length(t_span));
    k_dt = zeros(4,length(t_span));
    
    % States
    k_t = cell(N,1);
    u_t = cell(N,1);
    for j = 1:N
        k_t{j} = randi(k_max+1,1,1)-1;
        u_t{j} = rand_valid_pol(p,k_max);
    end
    % Clocks
    next_ring_d = cell(N,1);
    next_ring_n = cell(N,1);
    next_ring_r = cell(N,1); % Next revision ring of each player
    for i = 1:N
        next_ring_d{i} = exprnd(1/Rd,1,1);
        next_ring_n{i} = exprnd(1/Rn,1,1);
        next_ring_r{i} = exprnd(1/Rr,1,1); % Next revision ring of each player
    end
    % Convergence flag
    flag_convergence = true;

    %% Simulate events 
    for i = 1:length(t_span)
        %i/length(t_span)
        for idx_ring = randperm(N)
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
                        k_t{idx_ring} = min([k_max k_t{idx_ring}-p(implement_pol(u_t{idx_ring},k_t{idx_ring}))]);
                        % Compute next ring
                        next_ring_d{idx_ring} = next_ring_d{idx_ring} + exprnd(1/Rd);
                    case 2 % Revision ring
                        if rand() < type_rev % Pairwise cmp
                            % Choose a random policy
                            v = rand_valid_pol(p,k_max);
                            if rand() < phi_cmp(u_t{idx_ring},v)/Rr % Immitate w/ prob. r_uv/R_r
                                u_t{idx_ring} = v;
                            end
                        else % Imitative
                            % Choose a random player of the population to compare
                            v = u_t{randi(N)};
                            if rand() < r_rpl(u_t{idx_ring},v)/Rr % Immitate w/ prob. r_uv/R_r
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

        sigma_dt(:,i) = update_sigma_one_class(cell2mat(k_t),u_t,R,Ac,Rd);
        k_t_aux = cell2mat(k_t);
        k_dt(1,i) = mean(k_t_aux);
        k_dt(2,i) = min(k_t_aux);
        k_dt(3,i) = max(k_t_aux);
        k_dt(4,i) = sqrt(var(k_t_aux));
     
        % Check convergence
        window = round(500/dt_sim);
        if i >= max([window 1e3/dt_sim])
            flag_break = true;
            for r = 1:R
                if abs(mean(sigma_dt(r,i-window:i-round(window/2))) - mean(sigma_dt(r,i-round(window/2):i)))/Rd > 0.0025
                    flag_break = false;
                    break;
                end
            end
            if flag_break
                break;
            end
        end

        if i == length(t_span)
            warning('This trajectory did not converge within the maximum time.\n');
            flag_convergence = false;
        end
       
    end

    %% Prepare output
    ka_map = zeros(Nout,2);
    count = 0;
    for j = randperm(N, Nout)
        count = count+1;
        ka_map(count,1) = k_t{j};
        ka_map(count,2) = implement_pol(u_t{j},k_t{j});
    end

    %% Plots 
    if flag_plot

        % Colorblind-safe color palette (Wong, B. Points of view: Color blindness.
        % Nat Methods 8,441 (2011). https://doi.org/10.1038/nmeth.1618)
        color.black = [0 0 0]/255;
        color.orange = [230 159 0]/255;
        color.cyan = [86 180 233]/255;
        color.green = [0 158 115]/255;
        color.yellow = [240 228 66]/255;
        color.blue = [0 114 178]/255;
        color.red = [213 94 0]/255;
        color.pink = [204 121 167]/255;

        % Plot resource flows
        figure('Position',4*[0 0 192 144]); % Nice aspect ratio for double column
        hold on;
        grid on;
        box on;
        set(gca,'FontSize',20);
        set(gca,'TickLabelInterpreter','latex') % Latex style axis 
        % Trajectories 
        R_plot = 1:R;
        R_color = [color.blue; color.red; color.orange; color.pink; color.green];
        % Sigma evolution
        for j = 1:length(R_plot)
            plot(t_span(1:i),sigma_dt(R_plot(j),1:i),'LineWidth',2,'Color',R_color(j,:));
        end
        % Labels
        xlabel("$t$",'Interpreter','latex');
        ylabel("$\hat{\sigma}_r(t)$",'Interpreter','latex');
        legend({"$\hat{\sigma}_1$","$\hat{\sigma}_2$","$\hat{\sigma}_3$","$\hat{\sigma}_4$"},'Interpreter','latex');
        hold off;
    
        % AC level
        k_dt_mean = k_dt(1,1:i);
        k_dt_min = k_dt(2,1:i);
        k_dt_max = k_dt(3,1:i);
        k_dt_var = k_dt(4,1:i);
        t_span_len = length(t_span(1:i))-1;
        figure('Position',4*[0 0 192 144/2]);
        hold on;
        grid on;
        box on;
        set(gca,'FontSize',20);
        set(gca, 'Layer', 'top');
        set(gca,'TickLabelInterpreter','latex');
        aux_x2 = [t_span(1:i) fliplr(t_span(1:i))]';
        aux_y2 = [k_dt_max fliplr(k_dt_min)]';
        [aux_x2,aux_y2] = stairs_vector(aux_x2,aux_y2);
        fill(aux_x2,aux_y2,'k',...
            'LineWidth',2,'FaceColor',color.blue,'FaceAlpha',0.2,'EdgeAlpha',0);
        aux_x1 = [t_span(1:i) fliplr(t_span(1:i))]';
        aux_y1 = [k_dt_mean+k_dt_var fliplr(k_dt_mean-k_dt_var)]';
        aux_y1(aux_y1<0) = 0;
        [aux_x1,aux_y1] = stairs_vector(aux_x1,aux_y1);
        fill(aux_x1,aux_y1,'k',...
            'LineWidth',2,'FaceColor',color.blue,'FaceAlpha',0.4,'EdgeAlpha',0);
        stairs(t_span(1:i),k_dt_mean,'LineWidth',2,'Color','black');
        stairs(aux_x1,aux_y1,'LineWidth',1,'Color',[0.4 0.4 0.4]);
        stairs(aux_x2,aux_y2,'LineWidth',1,'Color',[0.4 0.4 0.4]);
        legend({' $\max$/$\min$ $\{K_t\}$',' $\mathrm{E}[K_t]\pm\sqrt{\mathrm{Var}[K_t]}$',' $\mathrm{E}[K_t]$'},...
            'Location','northeast','Interpreter','latex');
        ylabel(sprintf('Tokens'),'Interpreter','latex');
        xlabel('$t$','Interpreter','latex');
        ylim ([0 k_max]);
        hold off;

        % Actions
        % Extra token level k_max +1 just for plotting
        a_end = zeros(length(Ac),k_max+2);
        for j = 1:N
            a_end(implement_pol(u_t{j},k_t{j}),k_t{j}+1) = a_end(implement_pol(u_t{j},k_t{j}),k_t{j}+1) + 1;
        end
        R_color = [color.blue; color.red; color.orange; color.pink; color.green];
        figure('Position',4*[0 0 192 144/2]);
        hold on;
        grid on;
        box on;
        set(gca,'FontSize',20);
        set(gca, 'Layer', 'top');
        set(gca,'TickLabelInterpreter','latex');
        for j = length(Ac):-1:1
            aux_x = (0:k_max+1)';
            aux_y = sum(a_end(1:j,1:end),1)';
            [aux_x,aux_y] = stairs_vector(aux_x,aux_y);
            a = area(aux_x,aux_y,'LineWidth',2,'FaceColor',R_color(j,:));
        end
        xlim([0, k_max+1]);
        xlabel('$k$','Interpreter','latex');
        ylabel(sprintf('Action'),'Interpreter','latex');
        legend({'$a_1$','$a_2$','$a_3$','$a_4$'},'Interpreter','latex','Location','best');
        hold off;
    end


end


% Notes: For non parfor randomize order of agents