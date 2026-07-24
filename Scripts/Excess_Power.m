%% Specific Excess Power Map
clear; 
clc;
close all;


% Inputs
TW  = 0.37;
WL  = 57.5 * 47.880258888889;      % [N/m^2]

k1  = 0.18;
k2  = 0;
Cdr = 0;
B   = 1;

gamma = 1.4;
n     = 1;

% Flight Envelope
M      = (0.01 : 0.001 : 1.2).';
alt_ft = 0 : 100 : 60000;
alt_m  = alt_ft * 0.3048;

% Atmosphere
[~, a, P, rho] = atmosisa(alt_m);
a   = a(:).';
P   = P(:).';
rho = rho(:).';

% Drag Polar
Cd0        = 0.014 * ones(size(M));
comp       = M > 0.8;
Cd0(comp)  = 0.014 + (M(comp) - 0.8) * 0.035;

% Flight Conditions
V       = M .* a;
q       = 0.5 .* rho .* V.^2;
Pt_ps   = (1 + (gamma-1)/2 .* M.^2) .^ (gamma/(gamma-1));
alpha_T = (P ./ 101325) .* Pt_ps;

% Specific Excess Power
Ps = V .* ( ...
    (alpha_T ./ B) .* TW ...
    - k1 .* n^2 .* (B ./ q) .* WL ...
    - k2 .* n ...
    - (Cd0 + Cdr) ./ ((B ./ q) .* WL));

%Comp Climb and Accel
g = 9.80665;

% ----- Max climb -----
[ROC_max_mps, idx_climb] = max(Ps, [], 1);
ROC_max_fpm = ROC_max_mps * 3.28084 * 60;
M_best_climb = M(idx_climb);

% ----- Max acceleration (level flight) -----
accel = g * Ps ./ V;      % m/s^2

% Optional: ignore unrealistically low Mach for accel search
valid = M >= 0.2;
accel(~valid, :) = -Inf;

[accel_max_mps2, idx_accel] = max(accel, [], 1);
accel_max_g = accel_max_mps2 / g;
M_best_accel = M(idx_accel);

% Absolute maxima
[ROC_abs_max_mps, idx1] = max(Ps(:));
[iM1, ih1] = ind2sub(size(Ps), idx1);

[accel_abs_max_mps2, idx2] = max(accel(:));
[iM2, ih2] = ind2sub(size(accel), idx2);

fprintf('Absolute max climb: %.1f ft/min at M = %.3f, h = %.0f ft\n', ...
    ROC_abs_max_mps * 3.28084 * 60, M(iM1), alt_ft(ih1));

fprintf('Absolute max accel: %.3f m/s^2 (%.3f g) at M = %.3f, h = %.0f ft\n', ...
    accel_abs_max_mps2, accel_abs_max_mps2/g, M(iM2), alt_ft(ih2));

% Power Map
figure;
hold on

[~, h0] = contour(M, alt_ft, Ps.', [0 0], 'k', 'LineWidth', 2);

Ps_fpm = [300 600 1200 2400] / (3.28*60);

[~, h1] = contour(M, alt_ft, Ps.', [Ps_fpm(1) Ps_fpm(1)], 'b--', 'LineWidth', 2);
[~, h2] = contour(M, alt_ft, Ps.', [Ps_fpm(2) Ps_fpm(2)], 'c--', 'LineWidth', 2);
[~, h3] = contour(M, alt_ft, Ps.', [Ps_fpm(3) Ps_fpm(3)], 'y--', 'LineWidth', 2);
[~, h4] = contour(M, alt_ft, Ps.', [Ps_fpm(4) Ps_fpm(4)], 'r--', 'LineWidth', 2);

grid on;
grid minor;
title(['Operating Envelope (β=',num2str(B),')'])
xlabel('Flight Mach Number');
ylabel('Altitude [ft]');
yticks(0:10000:50000)
ylim([0 50000])


legend([h0 h1 h2 h3 h4], ...
    'P_s = 0 ft/min', ...
    'P_s = 300 ft/min', ...
    'P_s = 600 ft/min', ...
    'P_s = 1200 ft/min', ...
    'P_s = 2400 ft/min', ...
    'Location', 'best');
%%
M_query      = 0.6;      % Mach number
alt_query_ft = 30000;      % altitude [ft]

% --- Specific Excess Power at point ---
Ps_point_mps = interp2(M, alt_ft, Ps.', M_query, alt_query_ft, 'linear');
Ps_point_fpm = Ps_point_mps * 3.28084 * 60;

% --- Acceleration at point ---
accel_point = interp2(M, alt_ft, accel.', M_query, alt_query_ft, 'linear');
accel_point_g = accel_point / g;

fprintf('At M = %.3f, h = %.0f ft:\n', M_query, alt_query_ft)
fprintf('  Ps    = %.3f m/s  (%.1f ft/min)\n', ...
    Ps_point_mps, Ps_point_fpm)

fprintf('  Accel = %.3f m/s^2 (%.3f g)\n', ...
    accel_point, accel_point_g)