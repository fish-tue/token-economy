function pol = rand_valid_pol(p,k_max)
    pol = rand_ordered(p,k_max);
end

function map  = rand_ordered(p, k_max)
    % Number of actions
    A = length(p);
    % Random permutation to circumvent deterministic max and sort
    idx_perm = randperm(A);
    p_perm = p(idx_perm);
    % Sort prices in descending order
    [p_sorted,idx_sorted] = sort(p_perm, 'ascend');  % Descending order
    % Sorted stop ammount of tokens
    k_sorted = zeros(A,1);
    while true % Easy way out to guarantee an uniform selection
        % Nondecreasing uniform sequence generation
        nondec_seq = sort(randperm(k_max+1 + A-1, A-1))-(1:A-1);
        % Last is played to the end
        [~,idx_max] = max(flip(p_sorted));
        idx_max = A-idx_max+1;
        k_sorted(1:A~=idx_max) = nondec_seq;
        k_sorted(idx_max) = k_max+1;
        % Action #, to token threshold map
        map = [idx_perm(idx_sorted);k_sorted'];
        if is_map_valid_affordable(map,p,k_max), break; end
    end
end