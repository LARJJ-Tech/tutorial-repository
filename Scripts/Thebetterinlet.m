clc; clear; close all
 
% Data from Design Point (GASTURB)
M0 = 0.65; 
M1 = 0.65; 
M2 = 0.50; 
M8 = 1;

A0 = 0.30012947; 
A1 = 0.235274064; 
A2 = 0.277575127; 
A8 = 0.162108187; % m^2

D2 = 2*sqrt(A2/pi); 
D8 = 2*sqrt(A8/pi); 

% From Compressible Aero Calculator
AA1 = 1.1356; % For M1 = 0.65 gives this A/A* value
AA2 = 1.3398; % For M2 = 0.5 gives this A/A* value
AA8 = 0.9999; % Sonic conditions

% Mass Flow Ratio (Capture Ratio)
MFR = A0/A1;

%% Static Pressures from GASTURB
P0 = 20.646;   % kPa, ambient static pressure
P1 = 27.430;   % kPa, station 1 static pressure
P2 = 26.882;   % kPa, station 2 static pressure

rho1 = 0.332;  % kg/m^3
V1 = 191.90;   % m/s (GASTURB)

%% Diffuser Pressure Recovery
q1 = 0.5 * rho1 * V1^2;                  % Pa
deltaP = (P2 - P1) * 1000;              % convert kPa to Pa
CPR = deltaP / q1;                       % diffuser pressure recovery coefficient
CPRideal = 1 - (A1/A2)^2;               % ideal diffuser pressure recovery

fprintf('\n')
fprintf('--- Diffuser Pressure Recovery ---\n')
fprintf('Station 1 static pressure = %.3f kPa\n', P1)
fprintf('Station 2 static pressure = %.3f kPa\n', P2)
fprintf('Dynamic pressure at station 1 = %.3f Pa\n', q1)
fprintf('Pressure rise (P2 - P1) = %.3f Pa\n', deltaP)
fprintf('Actual CPR = %.4f\n', CPR)
fprintf('Ideal CPR  = %.4f\n', CPRideal)
fprintf('\n')

% Thrust & Drag Bookkeeping
FN = 6100; % kN (DESIGN POINT)
% FNgasturb = 4.84*10^3; % GASTURB
TSFC = 21.469; % g/(kN*s) - GASTURB

% Additive Drag
mdot0corr = 50; % kg/s (GASTURB)
V0 = 184.24; % m/s (GASTURB)
Dadd = mdot0corr*(V1-V0) + (P1-P0)*1000*A1; 
Dspillage = 0; % Assumptions from POWERPOINT (AE440 Inlets - Run Dong)

% Nacelle Diameter calculations
Cpcrit = 1.1; % at M0 = 0.63 (assumption)
gamma = 1.4;
placeholder = 1 + ((gamma-1)/2);

AMA1 = 1 + ((2*MFR*((M1/M0)*sqrt((placeholder*M0^2)/(placeholder*M1^2)) - 1) ...
    + 2/(gamma-M0^2)*(((placeholder*M0^2)/(placeholder*M1^2))^(gamma/(gamma-1)) - 1)))/(-Cpcrit);

NacelleArea = AMA1*A1; 
NacelleDiameter = 2*sqrt(NacelleArea/pi); % m

% Inlet Area Calculations 
A1new = AA1*A1; 
D1new = (2*sqrt(A1new/pi))*39.3701; % in

A2new = AA2*A2;
D2new = (2*sqrt(A2new/pi))*39.3701; % in

Mthroat = 0.75; % given by Dr. Luis
AAthroat = 1.06241711; % compressible aero calculator
Athroatnew = AAthroat*A8; 
Dthroatnew = (2*sqrt(Athroatnew/pi))*39.3701; % in

% Display
fprintf('Our A1 area is %.2f m^2\n', A1new)
fprintf('Our A2 area is %.2f m^2\n', A2new)
fprintf('Our Athroat area is %.2f m^2\n', Athroatnew)
fprintf('Our A1 diameter at cruise is %.2f inches\n', D1new)
fprintf('Our A2 diameter at cruise is %.2f inches\n', D2new)
fprintf('Our Athroat diameter at cruise is %.2f inches\n', Dthroatnew)
fprintf('\n')