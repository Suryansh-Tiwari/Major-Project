clc; clear; close all;

% =====================================================
% FBG-BASED SHM (2000s, VARIABLE STRAIN, 4 SEVERITIES)
% =====================================================

% -------------------------------
% FBG PARAMETERS
% -------------------------------
lambda_B0 = 1550e-9;   % Bragg wavelength (m)
pe = 0.22;
alpha = 0.55e-6;
xi = 8.6e-6;

% -------------------------------
% TIME VECTOR (0–2000 s)
% -------------------------------
t = (0:1:2000)';

% -------------------------------
% VARIABLE STRAIN GENERATION
% -------------------------------

strain = 500e-6*sin(0.01*t);      % Dynamic strain

% -------------------------------
% TEMPERATURE VARIATION
% -------------------------------
temp   = 5*sin(0.005*t);          % Temperature variation

% -------------------------------
% DAMAGE SEVERITY REGIONS
% -------------------------------
sev0 = t <= 800;                  % Healthy
sev1 = t > 800 & t <= 1100;       % Minor crack
sev2 = t > 1100 & t <= 1500;      % Moderate crack
sev3 = t > 1500;                 % Severe damage

% -------------------------------
% APPLY MULTI-SEVERITY DAMAGE
% -------------------------------
strain(sev1) = strain(sev1) + 200e-6;   % Minor
strain(sev2) = strain(sev2) + 400e-6;   % Moderate
strain(sev3) = strain(sev3) + 1000e-6;  % Severe

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
noise = 5e-12*randn(size(t));     % Interrogator noise
thermal_drift = 2e-12*t;          % Long-term drift

% -------------------------------
% FBG PHYSICS MODEL
% -------------------------------
delta_lambda = lambda_B0 * ((1 - pe)*strain + (alpha + xi)*temp);
lambda_B = lambda_B0 + delta_lambda + noise + thermal_drift;

% -------------------------------
% PHYSICS-INFORMED RESIDUAL
% -------------------------------
lambda_physics = lambda_B0 + delta_lambda;
residual = abs(lambda_B - lambda_physics);

% -------------------------------
% ML-READY DATASET
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
plot(t, lambda_B*1e9,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Bragg Wavelength (nm)');
title('FBG Bragg Wavelength Response (0–2000 s)');
grid on;


figure;
plot(t, temp,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature Variation Over Time');
grid on;
figure;

plot(t, residual*1e9,'LineWidth',1.5);
xline(800,'--r','Minor Damage');
xline(1100,'--k','Moderate Damage');
xline(1500,'--m','Severe Damage');
xlabel('Time (s)');
ylabel('Residual (nm)');
title('Physics-Informed Residual for Damage Detection');
grid on;

figure;
plot(t, damage_severity,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Damage Severity Index');
title('Progressive Damage Severity Estimation');
ylim([0 1.05]);
grid on;

figure;
plot(t, strain*1e6,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Strain (\mue\epsilon)');
title('Variable Strain Response Over Time');
grid on;

figure;
plot(t(labels==0), lambda_B(labels==0)*1e9,'.'); hold on;
plot(t(labels==1), lambda_B(labels==1)*1e9,'.');
plot(t(labels==2), lambda_B(labels==2)*1e9,'.');
plot(t(labels==3), lambda_B(labels==3)*1e9,'.');
xlabel('Time (s)');
ylabel('Bragg Wavelength (nm)');
title('Healthy vs Multi-Level Damaged Structural Response');
legend('Healthy','Minor','Moderate','Severe');
grid on;

figure;
histogram(residual(labels==0)*1e9,30); hold on;
histogram(residual(labels==1)*1e9,30);
histogram(residual(labels==2)*1e9,30);
histogram(residual(labels==3)*1e9,30);
xlabel('Residual (nm)');
ylabel('Frequency');
title('Residual Distribution by Damage Severity');
legend('Healthy','Minor','Moderate','Severe');
grid on;
