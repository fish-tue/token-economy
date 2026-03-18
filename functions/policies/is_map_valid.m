function flag = is_map_valid(map,p,k_max)
    % Check if affordable
    for k = 0:k_max
        aux = map(1,map(2,:)> k);
        if p(aux(1)) > k
            flag = 0;
            return;
        end
    end
    % Check if senseless
    flag = issorted(p(map(1,:)));
end
