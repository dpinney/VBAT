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

function virtual_battery_data_reformat(location_name)

load('virtualBatteryData.mat')

for i=1:51
    if strcmp(location_name,virtualBatteryData(i).state)
        x = i;
    end
end
location_struct = struct('ACminPData',-virtualBatteryData(x).cap_60_minute.minPCapTotal.ac(:)/1e6,...  %AC 
    'ACmaxPData',-virtualBatteryData(x).cap_60_minute.maxPCapTotal.ac(:)/1e6,...  %AC 
    'ACminEData',-virtualBatteryData(x).cap_60_minute.minECapTotal.ac(:)/1e6,...  %AC
    'ACmaxEData',-virtualBatteryData(x).cap_60_minute.maxECapTotal.ac(:)/1e6,...  %AC 
    'HPminPData',-virtualBatteryData(x).cap_60_minute.minPCapTotal.hp(:)/1e6,...  %HP
    'HPmaxPData',-virtualBatteryData(x).cap_60_minute.maxPCapTotal.hp(:)/1e6,...  %HP
    'HPminEData',-virtualBatteryData(x).cap_60_minute.minECapTotal.hp(:)/1e6,...  %HP
    'HPmaxEData',-virtualBatteryData(x).cap_60_minute.maxECapTotal.hp(:)/1e6,...  %HP
	'OFFICEminPData',-virtualBatteryData(x).cap_60_minute.minPCapTotal.office(:)/1e6,...
    'OFFICEmaxPData',-virtualBatteryData(x).cap_60_minute.maxPCapTotal.office(:)/1e6,...
    'OFFICEminEData',-virtualBatteryData(x).cap_60_minute.minECapTotal.office(:)/1e6,...
    'OFFICEmaxEData',-virtualBatteryData(x).cap_60_minute.maxECapTotal.office(:)/1e6,...
    'RGminPData',-virtualBatteryData(x).cap_60_minute.minPCapTotal.rg(:)/1e6,...  %RG
    'RGmaxPData',-virtualBatteryData(x).cap_60_minute.maxPCapTotal.rg(:)/1e6,...  %RG
    'RGminEData',-virtualBatteryData(x).cap_60_minute.minECapTotal.rg(:)/1e6,...  %RG
    'RGmaxEData',-virtualBatteryData(x).cap_60_minute.maxECapTotal.rg(:)/1e6,...  %RG
    'WHminPData',-virtualBatteryData(x).cap_60_minute.minPCapTotal.wh(:)/1e6,...  %WH
    'WHmaxPData',-virtualBatteryData(x).cap_60_minute.maxPCapTotal.wh(:)/1e6,...  %WH
    'WHminEData',-virtualBatteryData(x).cap_60_minute.minECapTotal.wh(:)/1e6,...  %WH
    'WHmaxEData',-virtualBatteryData(x).cap_60_minute.maxECapTotal.wh(:)/1e6);    %WH

location = struct2array(location_struct);

mat_name = [location_name,'_data_reformat.mat'];
save(mat_name,'location_struct');

csv_name = [location_name, '_data_reformat.csv'];
fileID = fopen(csv_name,'w');

fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'AC','','','','HP','','','','OFFICE','','','','RG','','','','WH','','','');
fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal');
fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n',location);

fclose(fileID);