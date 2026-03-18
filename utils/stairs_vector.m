% To use the equivalent of stairs with area and fill functions
function [x,y] = stairs_vector(x,y)
    x = [x';x'];
    y = [y';y'];
    y = y(:);
    x = x([2:end end])';
end