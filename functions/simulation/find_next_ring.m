function [t,type,idx] = find_next_ring(ring_d,ring_r,ring_n)
    % Next dynamic ring
    [t,idx] = min(ring_d);
    type = 1;
    % Next revision ring
    [aux_t,aux_idx] = min(ring_r);
    if aux_t < t
        t = aux_t;
        idx = aux_idx;
        type = 2;
    end
    % Next noise ring
    [aux_t,aux_idx] = min(ring_n);
    if aux_t < t
        t = aux_t;
        idx = aux_idx;
        type = 3;
    end
    % % Next environment ring
    % if ring_e < t
    %     t = ring_e;
    %     idx = nan;
    %     type = 4;
    % end
end