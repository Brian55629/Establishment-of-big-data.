function dydt = odefunc(t, y, m, c, k, f)
    % 1st order ODE system for second order equation
    % y(1) is displacement, y(2) is velocity
    dydt = [y(2);(f - c*y(2) - k*y(1)) / m];
end


