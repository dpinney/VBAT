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

function virtual_battery_data_reformat(state_name,county_id)

load('virtualBatteryData.mat')

for i=1:51
    if strcmp(state_name,virtualBatteryData(i).state)
        x = i;
    end
end

if county_id == 0
    factor_1 = 1;
    factor_2 = 1;
else
    factor_1 = (virtualBatteryData(x).detachedHousing(county_id))/1000;
    if x == 5           %California
        factor_2 = virtualBatteryData(x).county_office_building_ratio(county_id);
    else
        factor_2 = 1;
    end
    
end

minPCapTotal_ac = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minPCapTotal.ac(:)/1e6;
maxPCapTotal_ac = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxPCapTotal.ac(:)/1e6;
minECapTotal_ac = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minECapTotal.ac(:)/1e6;
maxECapTotal_ac = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxECapTotal.ac(:)/1e6;
minPCapTotal_hp = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minPCapTotal.hp(:)/1e6;
maxPCapTotal_hp = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxPCapTotal.hp(:)/1e6;
minECapTotal_hp = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minECapTotal.hp(:)/1e6;
maxECapTotal_hp = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxECapTotal.hp(:)/1e6;
minPCapTotal_office = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minPCapTotal.office(:)/1e6;
maxPCapTotal_office = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxPCapTotal.office(:)/1e6;
minECapTotal_office = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minECapTotal.office(:)/1e6;
maxECapTotal_office = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxECapTotal.office(:)/1e6;
minPCapTotal_rg = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minPCapTotal.rg(:)/1e6;
maxPCapTotal_rg = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxPCapTotal.rg(:)/1e6;
minECapTotal_rg = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minECapTotal.rg(:)/1e6;
maxECapTotal_rg = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxECapTotal.rg(:)/1e6;
minPCapTotal_wh = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minPCapTotal.wh(:)/1e6;
maxPCapTotal_wh = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxPCapTotal.wh(:)/1e6;
minECapTotal_wh = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.minECapTotal.wh(:)/1e6;
maxECapTotal_wh = factor_1*factor_2*-virtualBatteryData(x).cap_60_minute.maxECapTotal.wh(:)/1e6;

state_struct = struct('ACminPData',minPCapTotal_ac,'ACmaxPData',maxPCapTotal_ac,...
    'ACminEData',minECapTotal_ac,'ACmaxEData',maxECapTotal_ac,...
    'HPminPData',minPCapTotal_hp,'HPmaxPData',maxPCapTotal_hp,...
    'HPminEData',minECapTotal_hp,'HPmaxEData',maxECapTotal_hp,...
    'OFFICEminPData',minPCapTotal_office,'OFFICEmaxPData',maxPCapTotal_office,...
    'OFFICEminEData',minECapTotal_office,'OFFICEmaxEData',maxECapTotal_office,...
    'RGminPData',minPCapTotal_rg,'RGmaxPData',maxPCapTotal_rg,...  
    'RGminEData',minECapTotal_rg,'RGmaxEData',maxECapTotal_rg,...  
    'WHminPData',minPCapTotal_wh,'WHmaxPData',maxPCapTotal_wh,...  
    'WHminEData',minECapTotal_wh,'WHmaxEData',maxECapTotal_wh);

state = struct2array(state_struct);
county_id = num2str(county_id);
mat_name = [state_name,'_',county_id,'_data_reformat.mat'];
save(mat_name,'state_struct');

csv_name = [state_name,'_',county_id, '_data_reformat.csv'];
fileID = fopen(csv_name,'w');

fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'AC','','','','HP','','','','OFFICE','','','','RG','','','','WH','','','');
fprintf(fileID,'%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,\n',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal',...
    'minPCapTotal','maxPCapTotal','minECapTotal','maxECapTotal');
fprintf(fileID,'%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,%f,\n',state);

fclose(fileID);