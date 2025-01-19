function g = NablagAlpha(u)

global X NhMat

LN = length(u);
g = zeros(LN,1);

LNM = length(NhMat);
gg = zeros(LNM,1);

for kk = 1:LNM
    
    if NhMat(kk,4)
        
        gg(kk) = (1 + NhMat(kk,4))/2 * ( u(NhMat(kk,3)) - u(NhMat(kk,5)) ) / phi( u(NhMat(kk,3)) - u(NhMat(kk,5)) ) + ...
            (1 - NhMat(kk,4))/2 * ( u(NhMat(kk,3)) - X(NhMat(kk,1),NhMat(kk,2)) ) / phi( u(NhMat(kk,3)) - X(NhMat(kk,1),NhMat(kk,2)) );
        
    end
    
end   

for k = 1: LN
   
    g(k) = sum( gg(4*k-3:4*k) );
    
end
