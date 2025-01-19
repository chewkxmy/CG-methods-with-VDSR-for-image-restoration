function g1 = gAlpha(u)

global X NhMat

g1 = 0;

LNM = length(NhMat);

for kk = 1:LNM
    
    if NhMat(kk,4)
        
        g1 = g1 + 0.5 * (1 + NhMat(kk,4))/2 * phi( u(NhMat(kk,3)) - u(NhMat(kk,5)) ) + ...
            (1 - NhMat(kk,4))/2 * phi( u(NhMat(kk,3)) - X(NhMat(kk,1),NhMat(kk,2)) );
        
    end
    
end   