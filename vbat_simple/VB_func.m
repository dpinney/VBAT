%This function takes the inputs:
%out_temp : a csv file containing outdoor temperature
%device_type : a number from 1 to 4 for which
% 1 is AC
% 2 is HP
% 3 is RG
% 4 is WH

function VB_func(out_temp,device_type)%,para)
if device_type == 3
    temperature_a = 20*ones(8760,1);
else
    if isempty(version('-release')) == 1
        tempData = csvread(out_temp);
        tempData(1,:)=[];
        temperature_a=tempData(:,2);
    else
        tempData = xlsread(out_temp);
        temperature_a=tempData(:,2);
    end
    
end

switch device_type
    case 1
        paraFile = 'para_AC.csv';
        [P_lower, P_upper, E_UL] = VB_core_TCL(paraFile, temperature_a,device_type);
    case 2
        paraFile = 'para_HP.csv';
        [P_lower, P_upper, E_UL] = VB_core_TCL(paraFile, temperature_a,device_type);
    case 3
        paraFile = 'para_RG.csv';
        [P_lower, P_upper, E_UL] = VB_core_TCL(paraFile, temperature_a,device_type);
    case 4
        paraFile = 'para_WH.csv';
        [P_upper, P_lower, E_UL] = VB_core_WH(paraFile);
end


    
    %% write output file
plotname = strrep(paraFile,'.csv','');
output_file = strcat('VB_output_', plotname, '.csv');
fid = fopen(output_file,'w');
fprintf(fid, 'upper_power(kW), lower_power(kW), upper_energy(kWh), lower_energy(kWh)\n');
for i = 1:length(P_upper)
    fprintf(fid, '%f, %f, %f, %f\n', P_upper(i), -P_lower(i), E_UL(i), -E_UL(i));    
end

%% plot

plotname = strrep(plotname,'_',' ');

figure
subplot(2,1,1)
plot(P_upper)
hold on
plot(-P_lower,'r')
plot(zeros(length(P_upper),1),'k--')
title(strcat(plotname,' Power'))
ylabel('Power (kW)')
xlabel('Time (timestep)')
subplot(2,1,2)
plot(E_UL)

hold on
plot(-E_UL,'r')
plot(zeros(length(E_UL),1),'k--')
title(strcat(plotname,' Energy'))
ylabel('Energy (kWh)')
xlabel('Time (timestep)')