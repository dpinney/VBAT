%%%%
% Export all virtualBatteryData.mat to csv
% First Row gives device name for the 4 columns (including the one with the
% device name(Ordered alphabetically)
% Column 1: minPCapTotal
% Column 2: maxPCapTotal
% Column 3: minECapTotal
% Column 4: maxECapTotal
% ...
% Column 20: maxECapTotal
%%%%

% function 

load('virtualBatteryData.mat')

California_Struct = struct('ACminPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.ac(:)/1e6,...  %AC 
    'ACmaxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.ac(:)/1e6,...  %AC 
    'ACminEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.ac(:)/1e6,...  %AC
    'ACmaxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.ac(:)/1e6,...  %AC 
    'HPminPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.hp(:)/1e6,...  %HP
    'HPmaxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.hp(:)/1e6,...  %HP
    'HPminEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.hp(:)/1e6,...  %HP
    'HPmaxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.hp(:)/1e6,...  %HP
    'OFFICEminPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.office(:)/1e6,...  %OFFICE
    'OFFICEmaxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.office(:)/1e6,...  %OFFICE
    'OFFICEminEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.office(:)/1e6,...  %OFFICE
    'OFFICEmaxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.office(:)/1e6,...  %OFFICE
    'RGminPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.rg(:)/1e6,...  %RG
    'RGmaxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.rg(:)/1e6,...  %RG
    'RGminEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.rg(:)/1e6,...  %RG
    'RGmaxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.rg(:)/1e6,...  %RG
    'WHminPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.wh(:)/1e6,...  %WH
    'WHmaxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.wh(:)/1e6,...  %WH
    'WHminEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.wh(:)/1e6,...  %WH
    'WHmaxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.wh(:)/1e6);    %WH

California = struct2array(California_Struct);

save('virtual_battery_data_reformat.mat','California_Struct');

fileID = fopen('virtual_battery_data_reformat.csv','w');

fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'AC','','','','HP','','','','OFFICE','','','','RG','','','','WH','','','');
fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal');
fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n',California);

fclose(fileID);