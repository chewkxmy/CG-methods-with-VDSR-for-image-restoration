function [xopt, fopt, gopt, NI, Nf] = RMIL(f, df, x0, Tolerance, CRestart, MaxIter, delta, ro, minimumofalpha, maxiter)
% RMIL - Implements a conjugate gradient optimization method with Wolfe conditions
%
% Inputs:
%   f               - Objective function
%   df              - Gradient (derivative) of the objective function
%   x0              - Initial guess for the optimization variable
%   Tolerance       - Termination condition for gradient norm
%   CRestart        - Restart condition for direction computation
%   MaxIter         - Maximum number of iterations
%   delta           - Parameter for Wolfe conditions
%   ro              - Reduction factor for line search
%   minimumofalpha  - Minimum allowable step size in line search
%   maxiter         - Maximum number of line search iterations
%
% Outputs:
%   xopt - Optimized variable
%   fopt - Objective function value at the optimum
%   gopt - Gradient at the optimum
%   NI   - Number of iterations
%   Nf   - Number of function evaluations

% Initialization
x_k  = x0;                      % Current variable value
f_k = feval(f, x_k);            % Evaluate objective function at x_k
g_k = feval(df, x_k);           % Evaluate gradient at x_k
Nf = 1;                         % Initialize function evaluation count
NI = 0;                         % Initialize iteration count
d_k  = -g_k;                    % Initial search direction 
firsttrying = 1;                % Flag for the first iteration
trace = 0;                      % Trace parameter 
c2 = 0.9;                       % Wolfe condition parameter


% Optimization loop
while (norm(g_k, inf) > Tolerance * (1 + abs(f_k))) && (NI < MaxIter)
    % Line search initialization
    if firsttrying
        Alpha0 = 1 / norm(g_k, inf); % Initial step size
        firsttrying = 0;             % Reset the flag after first use
    else
        Alpha0 = norm(s_1k) / norm(d_k); % Compute step size based on previous direction
    end

    % Perform line search with Wolfe conditions
    [x_k1, alpha_k, f_k1, dfval, nfe, nge] = Wolfesearch2(f, df, x_k, d_k,Alpha0, delta, c2, f_k, g_k, trace);
    NI = NI + 1;          % Increment iteration count
    Nf = Nf + nfe;        % Increment function evaluation count

    % Update variables for conjugate gradient method
    s_k = alpha_k * d_k;      % Step taken
    g_k1 = feval(df, x_k1);   % Gradient at new point
    y_k = g_k1 - g_k;         % Gradient difference

    % Compute conjugate gradient parameter (beta)
     if 0 <= (g_k1' * g_k) && (g_k1' * g_k) <= (g_k1' * g_k1)
          beta = (g_k1' * y_k) / (d_k' * d_k);
        else
          beta = 0; % Reset direction if beta calculation is invalid
     end

    % Update search direction
    d_k1 = -g_k1 + beta * d_k;

    % Restart condition (optional, commented out)
    % if d_k1' * g_k1 > -CRestart * norm(d_k1) * norm(g_k1)
    %     d_k1 = -g_k1;
    % end

    % Prepare for the next iteration
    s_1k = s_k;  % Save the current step
    x_k = x_k1;  % Update variable
    f_k = f_k1;  % Update function value
    g_k = g_k1;  % Update gradient
    d_k = d_k1;  % Update search direction
end

% Return results
xopt = x_k;  % Optimized variable
fopt = f_k;  % Function value at the optimum
gopt = g_k;  % Gradient at the optimum
