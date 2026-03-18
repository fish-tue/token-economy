function flag = is_map_valid_affordable(map,p,k_max)
    flag = 1;
    for k = 0:k_max
        aux = map(1,map(2,:)> k);
        if p(aux(1)) > k
            flag = 0;
            return;
        end
    end
end