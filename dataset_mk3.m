clc; clear;

% -------------------------------
% FBG PARAMETERS
% -------------------------------
lambda_B0 = 1550e-9;   % Bragg wavelength (m)
pe = 0.22;
alpha = 0.55e-6;
xi = 8.6e-6;

% -------------------------------
% TIME VECTOR
% -------------------------------
t = (0:1:1000)';   % Column vector

% -------------------------------
% STRAIN & TEMPERATURE
% -------------------------------
strain = 500e-6*sin(0.01*t);      % Dynamic strain
temp   = 5*sin(0.005*t);          % Temperature variation

% -------------------------------
% STRUCTURAL DAMAGE
% -------------------------------
damage_index = t > 600;
strain(damage_index) = strain(damage_index) + 800e-6;  % Crack effect

% Damage label (0 = healthy, 1 = damaged)
damage_label = double(damage_index);

% Progressive damage severity (0–1)
damage_severity = zeros(size(t));
damage_severity(damage_index) = ...
    linspace(0.3,1,sum(damage_index))';

% -------------------------------
% NOISE & DRIFT
% -------------------------------
noise = 5e-12*randn(size(t));     % Interrogator noise
thermal_drift = 2e-12*t;          % Long-term drift

% -------------------------------
% WAVELENGTH SHIFT
% -------------------------------
delta_lambda = lambda_B0*((1-pe)*strain + (alpha+xi)*temp);
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
    t, ...
    strain*1e6, ...
    temp, ...
    lambda_B*1e9, ...
    residual*1e9, ...
    damage_label, ...
    damage_severity, ...
    'VariableNames', { ...
    'Time_s', ...
    'Strain_microstrain', ...
    'Temperature_C', ...
    'Bragg_Wavelength_nm', ...
    'Residual_nm', ...
    'Damage_Label', ...
    'Damage_Severity'});

% -------------------------------
% SAVE DATASET
% -------------------------------
%writetable(FBG_Dataset,'FBG_SHM_Dataset.csv');
%disp('FBG SHM dataset successfully created.');

% -------------------------------
% VISUALIZATION
% -------------------------------
figure;
plot(t, lambda_B*1e9,'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Bragg Wavelength (nm)');
title('FBG-Based Structural Health Monitoring Simulation');
grid on;



figure;
plot(t, temp, 'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Temperature (°C)');
title('Temperature Variation Over Time');
grid on;


figure;
plot(t, residual*1e9, 'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Residual (nm)');
title('Physics-Informed Residual for Damage Detection');
xline(600,'--r','Damage Initiation');
grid on;


figure;
plot(t, damage_severity, 'LineWidth',1.5);
xlabel('Time (s)');
ylabel('Damage Severity Index');
title('Progressive Damage Severity Estimation');
ylim([0 1.05]);
grid on;

figure;
plot(t, strain*1e6, 'LineWidth', 1.5);
xlabel('Time (s)');
ylabel('Strain (\mue\epsilon)');
title('Strain Variation Over Time');
grid on;

figure;
plot(t(~damage_index), lambda_B(~damage_index)*1e9, '.');
hold on;
plot(t(damage_index), lambda_B(damage_index)*1e9, '.');
xlabel('Time (s)');
ylabel('Bragg Wavelength (nm)');
title('Healthy vs Damaged Structural Response');
legend('Healthy','Damaged');
grid on;


figure;
histogram(residual(~damage_index)*1e9,30);
hold on;
histogram(residual(damage_index)*1e9,30);
xlabel('Residual (nm)');
ylabel('Frequency');
title('Residual Distribution: Healthy vs Damaged');
legend('Healthy','Damaged');
grid on;



