clc; clear; close all;

% =====================================================
% FBG-BASED SHM WITH 4 DAMAGE SEVERITY LEVELS
% =====================================================

% -------------------------------
% FBG PARAMETERS
% -------------------------------
lambda_B0 = 1550e-9;
pe = 0.22;
alpha = 0.55e-6;
xi = 8.6e-6;

% -------------------------------
% TIME VECTOR
% -------------------------------
t = (0:1:1000)';

% -------------------------------
% BASE STRAIN & TEMPERATURE
% -------------------------------
strain = 500e-6*sin(0.01*t);
temp   = 5*sin(0.005*t);

% -------------------------------
% DAMAGE SEVERITY REGIONS
% -------------------------------
sev0 = t <= 600;                 % Healthy
sev1 = t > 600 & t <= 700;       % Minor crack
sev2 = t > 700 & t <= 800;       % Moderate crack
sev3 = t > 800;                  % Severe damage

% -------------------------------
% APPLY MULTI-SEVERITY DAMAGE
% -------------------------------
strain(sev1) = strain(sev1) + 200e-6;   % Severity 1
strain(sev2) = strain(sev2) + 400e-6;   % Severity 2
strain(sev3) = strain(sev3) + 1000e-6;  % Severity 3

% -------------------------------
% DAMAGE LABELS (0–3)
% -------------------------------
labels = zeros(size(t));
labels(sev1) = 1;
labels(sev2) = 2;
labels(sev3) = 3;

% -------------------------------
% CONTINUOUS DAMAGE SEVERITY (0–1)
% -------------------------------
damage_severity = zeros(size(t));
damage_severity(sev1) = linspace(0.2,0.4,sum(sev1))';
damage_severity(sev2) = linspace(0.4,0.7,sum(sev2))';
damage_severity(sev3) = linspace(0.7,1.0,sum(sev3))';

% -------------------------------
% NOISE & DRIFT
% -------------------------------
noise = 5e-12*randn(size(t));
thermal_drift = 2e-12*t;

% -------------------------------
% FBG PHYSICS MODEL
% -------------------------------
delta_lambda = lambda_B0 * ((1-pe)*strain + (alpha+xi)*temp);
lambda_B = lambda_B0 + delta_lambda + noise + thermal_drift;

% -------------------------------
% PHYSICS-INFORMED RESIDUAL
% -------------------------------
lambda_physics = lambda_B0 + delta_lambda;
residual = abs(lambda_B - lambda_physics);

% -------------------------------
% DATASET TABLE
% -------------------------------
FBG_Dataset = table( ...
    t, strain*1e6, temp, ...
    lambda_B*1e9, residual*1e9, ...
    labels, damage_severity, ...
    'VariableNames', { ...
    'Time_s', 'Strain_microstrain', 'Temperature_C', ...
    'Bragg_Wavelength_nm', 'Residual_nm', ...
    'Damage_Class_4', 'Damage_Severity'});

% =====================================================
% VISUALIZATION
% =====================================================

figure;
plot(t, strain*1e6,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Strain (\mue\epsilon)');
title('Strain with 4 Damage Severity Levels');
grid on;

figure;
plot(t, residual*1e9,'LineWidth',1.5);
xline(600,'--r','Minor');
xline(700,'--k','Moderate');
xline(800,'--m','Severe');
xlabel('Time (s)');
ylabel('Residual (nm)');
title('Physics-Informed Residual');
grid on;

figure;
gscatter(t, lambda_B*1e9, labels, 'bgcm', '.', 10);
xlabel('Time (s)');
ylabel('Bragg Wavelength (nm)');
title('4-Class Damage Severity Labels');
legend('Healthy','Minor','Moderate','Severe');
grid on;
