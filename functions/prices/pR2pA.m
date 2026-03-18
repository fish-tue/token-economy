function pA = pR2pA(pR,C,A,Ac)
    pA = cell(C,1);
    for c = 1:C
        pA{c} = zeros(A(c),1);
        for a = 1:A(c)
            for r = Ac{c}{a}'
                pA{c}(a,1) = pA{c}(a,1) + pR(r);
            end
        end
    end
end
