function a = implement_pol(pol,k) 
    % Take action
    aux = pol(1,pol(2,:)> k);
    a = aux(1);
end