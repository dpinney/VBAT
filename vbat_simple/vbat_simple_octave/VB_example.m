% Author: Di Wu and Tao Fu (PNNL)
% Last update time: September 19, 2017
% This script is used to estimate the power and energy capacities for a population of residential TCLs

clear,clc, close all

TCL_idx = 4; %TCL type index: 1, AC; 2, HP; 3, RG; 4, WH

if TCL_idx <=2 % WH model is different than the other TCLs because of water draw
    % read tempeature file
    tempFile = 'outdoor_temperature.csv'; % hourly ourdoor temperature data in C
    tempData = csvread(tempFile);
    temperature_a=tempData(:,2);
elseif TCL_idx ==3
    temperature_a=20*ones(8760,1); %ambient temperature for RG is assumed to be 20 degree in C
end

if TCL_idx<=3
    switch TCL_idx
        case 1
            paraFile = 'para_AC.csv';
        case 2
            paraFile = 'para_HP.csv';
        case 3
            paraFile = 'para_RG.csv';
    end
    [P_lower, P_upper, E_UL] = VB_core_TCL(paraFile, temperature_a,TCL_idx);
else
    paraFile = 'para_WH.csv';
    [P_upper, P_lower, E_UL] = VB_core_WH(paraFile);
end
     

%% write output file
fid = fopen('VB_output.csv','w');
fprintf(fid, 'upper_power(kW), lower_power(kW), upper_energy(kWh), lower_energy(kWh)\n');
for i = 1:length(P_upper)
    fprintf(fid, '%f, %f, %f, %f\n', P_upper(i), -P_lower(i), E_UL(i), -E_UL(i));    
end

%% plot
% dates = datetime(2017,1,1,0,0,0):hours(1):datetime(2017,12,31,23,0,0);
figure
subplot(2,1,1)
plot(P_upper)
% plot(dates,P_upper)
hold on
plot(-P_lower,'r')
% plot(dates,-P_lower,'r')
plot(zeros(length(P_upper),1),'k--')
% plot(dates,zeros(length(P_upper),1),'k--')
ylabel('Power (kW)')
xlabel('Time (timestep)')
subplot(2,1,2)
plot(E_UL)
% plot(dates,E_UL)

hold on
plot(-E_UL,'r')
% plot(dates,-E_UL,'r')
plot(zeros(length(E_UL),1),'k--')
% plot(dates,zeros(length(E_UL),1),'k--')
ylabel('Energy (kWh)')
xlabel('Time (timestep)')




