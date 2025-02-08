function main()
    % Number of simulations
    num_simulations = 55;

    % Initialize parameters
    m = 1;
    c = 1;
    k = 1;
    f = 1;
    a = 1;
    b = 1;

    for i = 1:num_simulations
        % Call the modified main function for each set of parameters
        [t, displacement, velocity] = run_simulation(m, c, k, f, a, b);
        
        % Save results to a single Excel file, appending if it already exists
        save_to_single_excel(t, displacement, velocity, m, c, k, f, a, b);
        
        % Update parameters for the next iteration
        if m == c && c == k && k == f && f == a && a == b
            % Increment all parameters
            m = m + 1;
        else
            % Increment parameters based on the specified pattern
            if a < b
                a = a + 1;
            elseif b < f
                b = b + 1;
            elseif f < k
                f = f + 1;
            elseif k < c
                k = k + 1;
            elseif c < m
                c = c + 1;
            elseif m < 4
                m = m + 1;
            end
        end
    end
end

function [t, displacement, velocity] = run_simulation(m, c, k, f, a, b)
    % Display the current parameter values
    fprintf('Parameters: m=%d, c=%d, k=%d, f=%d, a=%d, b=%d\n', m, c, k, f, a, b);

    % Parameters
    tspan = [0, 10]; % time span
    y0 = [a; b];     % initial conditions
    
    % Solve using Runge-Kutta 4
    [t, sol] = ode45(@(t, y) odefunc(t, y, m, c, k, f), tspan, y0);
    
    % Extract displacement and velocity from solution
    displacement = sol(:, 1);
    velocity = sol(:, 2);
    
    % Plot results (optional)
    figure;
    subplot(2, 1, 1);
    plot(t, displacement);
    xlabel('Time');
    ylabel('Displacement');
    title(['Parameters: m=', num2str(m), ', c=', num2str(c), ', k=', num2str(k), ...
        ', f=', num2str(f), ', a=', num2str(a), ', b=', num2str(b)]);
    
    subplot(2, 1, 2);
    plot(t, velocity);
    xlabel('Time');
    ylabel('Velocity');
end

function save_to_single_excel(t, displacement, velocity, m, c, k, f, a, b)
    % Create a table with time, displacement, velocity, and parameters
    num_time_points = round(10 / 0.25) + 1;  % Ensure 0.25-second intervals
    time_points = linspace(t(1), t(end), num_time_points)';
    
    % Interpolate displacement and velocity at the specified time points
    interp_displacement = interp1(t, displacement, time_points, 'linear', 'extrap');
    interp_velocity = interp1(t, velocity, time_points, 'linear', 'extrap');
    
    % Create a table with the interpolated time, displacement, velocity, and parameters
    simulation_table = table(time_points, interp_displacement, interp_velocity, ...
        'VariableNames', {'Time', 'Displacement', 'Velocity'});
    
    % Add columns for the parameters
    simulation_table.Mass = repmat(m, num_time_points, 1);
    simulation_table.Damping = repmat(c, num_time_points, 1);
    simulation_table.SpringConstant = repmat(k, num_time_points, 1);
    simulation_table.ExternalForce = repmat(f, num_time_points, 1);
    simulation_table.InitialDisplacement = repmat(a, num_time_points, 1);
    simulation_table.InitialVelocity = repmat(b, num_time_points, 1);
    
    % Fill missing values with 0
    simulation_table = fillmissing(simulation_table, 'constant', 0);
    
    % Define the filename for the single Excel file
    filename = 'AllSimulations.xlsx';
    
    % Check if the file exists
    if exist(filename, 'file') == 2
        % If the file exists, load the existing table from the file
        existing_table = readtable(filename);
        
        % Append the new simulation data to the existing table
        combined_table = [existing_table; simulation_table];
    else
        % If the file doesn't exist, use the current simulation_table
        combined_table = simulation_table;
    end
    
    % Save the combined table to the Excel file
    writetable(combined_table, filename, 'WriteMode', 'overwrite');
end
