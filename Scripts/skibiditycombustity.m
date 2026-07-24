clc;clear;close all
data = readmatrix("off Design/Data5.xlsx",'Range','C1:R175');

% TASKS
% - find volume, cross-sectional areas, Mach numbers
% - Estimated loss
% - Expected loading 
% - Calculate airflow liner (for Primary, Secondary, Tertiary)

FARstoich = 0.067; % for jet fuels
R = 287; 
gamma = 1.4;

% Equivalence Ratios

% Combustor Reference Quantities (GASTURB)
% Cruise TOC Manuever Ceiling TOLDG
% W = [6.68412 7.45911 16.8764 5.9934 19.255]; % mdot
% Wf = [0.150838 0.168604 0.379002 0.137823 0.441267]; % mdot fuel, ^^
W = data(78,:);
Wf = data(18,:);

FAR = Wf./W;
EquivalenceRatio = FAR./FARstoich; % If >1 = rich combustion; if <1 = lean combustion

% Tt3 = [642.086 657.838 719.098 652.04 734.264]; % K
% Pt3 = [671.173 753.045 1737.35 606.896 2001.06]; % kPa
% 
% Tt4 = [1604.3 1629.83 1667.84 1627.25 1575.96]; % K
% Pt4 = [637.631 714.902 1644.84 576.607 1894.31]; % kPa
% 
% Vref = [100.162 102.098 109.587 100.868 110.843];  % m/s
% 
% rho = [3.56 3.908 8.237 3.17862  9.287]; % used to be rho3

Tt3 = data(48,:);
Pt3 = data(49,:);
Tt4 = data(52,:);
Pt4 = data(51,:); 

% if youre sigma and smart use this instead of my manual adding of cringe
% :))))))))))))))))))))))))))))))))

% Ps3 = data(50,:); % static pressure (Pa)
% M3 = sqrt((2/(gamma-1)) .* (((Pt3 ./ Ps3).^((gamma-1)/gamma)) - 1));
% Ts3 = Tt3 ./ (1 + (gamma-1)/2 .* M3.^2);
% rho = Ps3 ./ (R .* Ts3) *1000;
% a3 = sqrt(gamma .* R .* Ts3); % speed of sound
% Vref = M3 .* a3;

% Cruise, serv ceiling, abs, maneuv, TO, SLS, c1, c2, c3, c4, c5, d5, d4,
% d3, d2, d1 -- 16 pts total
Vref = [102.058 105.98 107.361 112.05 111.528 110.328 113.088 110.868 108.945 107.738 105.513 93.4804 95.4415 99.4255 103.875 108.431]; %v3
rho = [3.79477 3.5538 3.46062 9.08083 9.62088 8.95578 10.1005 8.39622 6.86579 5.29952 3.67067 2.48328 3.13891 3.94985 5.23391 7.13415]; %rho3

% Combustor Pressure loss
% - Can assume dPt/Pt ~ 5-6 %

dPtpt = -0.05; 

% Reference Calculations

qref = (rho.*Vref.^2)./2;                 % m^3/s
Mref = Vref./sqrt(gamma.*R.*Tt3);          % no units
PressureLossCoeff = (Pt4-Pt3)./qref;     % no units
Aref = sqrt(((R/2).*(W.*(sqrt(Tt3)./Pt3)).^2.*PressureLossCoeff)./dPtpt);
Vref = W./(rho.*Aref);               % m/s


% Pressure loss & Combustor Area Sizing

losscold = 16; % typical for annular combustor (assumed)
TR = Tt4./Tt3 ;
losshot = 1.3.*(TR-1);
losscoeff = losscold + losshot;

% Area of Combustor

Areacombustor = sqrt(((R./2).*(W.*(sqrt(Tt3)./Pt3)).^2.*PressureLossCoeff)./dPtpt); % m^2

% Combuster Length calculations

timeres = 5.*10^-3; % supposed to be in milliseconds
% timeres = Lcomb/Vref
Lcomb = timeres.*Vref; % in meters or multiply by 3.281 for feet

% Volume of Combustor

VolumeCombustor = Areacombustor.*Lcomb; % m^3

% Combustor Loading & Volume Calculations

Aliner = 0.60.*Aref; % Set Aliner = 60% of Aref
LHV = 43.15.*10^6;
Pt3atm = Pt3./101.325;

combustorloading = W./(VolumeCombustor.*(Pt3atm.^1.8).*10.^(0.00145.*(Tt3-400)));
combeff = (-5.4697.*10^-11).*(combustorloading.^5) + (3.97923.*10^-8).*(combustorloading.^4)+(8.73718.*10^-6).*(combustorloading.^3)+(0.000300007).*(combustorloading.^2)-(0.004568246).*(combustorloading)+99.7;



% Display
% fprintf('Our combustor area is %.4f m^2 \n',Areacombustor)
% fprintf('Our combustor volume is %.4f m^3 \n',VolumeCombustor)
% fprintf('Our combustor lenght is %.4f m \n',Lcomb)

