%%
% 07/10/17 added codes to calculate the hourly capacities

clear;
clc

load('virtualBatteryData.mat');
allStates = {virtualBatteryData.stateCode};
CA_Idx = find(strcmp(allStates,'CA'));

%% read in counties with temperature data    
dataLink = readtable('.\temperature_files\NCDC_obs_locations_county_CA.csv');
countyWithTemp = dataLink.County;
for i = 1:length(countyWithTemp)
    currCounty = countyWithTemp{i};
    k = strfind(currCounty, ' ');
    if(~isempty(k))
        currCounty(k) = '_';
    end
    countyWithTemp{i} = currCounty;
end

%% read in results for counties that have temperature data
dataFolder = '.\SEB_CA_county_daily_temperature\';
for idx = 1:length(countyWithTemp)
    disp(['Temperature Data # ', num2str(idx)]);
    if(idx ~= 8) % county #8 is also LA and was not used
        currCounty = countyWithTemp{idx};
        currFolder = [dataFolder,currCounty,'\'];
        % get capacity from the folder
        minPower_all = [];
        maxPower_all = [];
        minEnergy_all = [];
        maxEnergy_all = [];
        baselinePower_all = [];
        selfDischarge_all = [];
        x5_all = [];
        x6_all = [];
        for j = 1:365
            currFile = [currFolder, '\power_v12_CA_',currCounty,'_',num2str(j),'.csv'];
            data = readtable(currFile);
            minPower = data.x1;
            maxPower = data.x2;
            minEnergy = data.x3;
            maxEnergy = data.x4;
            baselinePower = data.x5;
            selfDischarge = data.x6;
            minPower_all = [minPower_all;minPower];
            maxPower_all = [maxPower_all;maxPower];
            minEnergy_all = [minEnergy_all;minEnergy];
            maxEnergy_all = [maxEnergy_all;maxEnergy];
            baselinePower_all = [baselinePower_all; baselinePower];
            selfDischarge_all = [selfDischarge_all; selfDischarge];
        end
        % county capacity
        SEB_data(idx).county = currCounty;
        SEB_data(idx).data.minPCap = minPower_all;
        SEB_data(idx).data.maxPCap = maxPower_all;
        SEB_data(idx).data.minECap = minEnergy_all;
        SEB_data(idx).data.maxECap = maxEnergy_all;        
    end      
end

%% read in commercial build square feet
data = readtable('.\commercial_buildings\DS_California_County_Commercial_Space_for_input.xlsx');
allCounties = virtualBatteryData(CA_Idx).county;
% data in the commercial building sq2 file has been sorted using county names.
% this is a double check to make sure county names match
for i = 1:length(allCounties);
    currCounty = allCounties{i};
    k = strfind(data.County{i}, currCounty);
    if(k == 0)
        str = ['county names no matched: ', num2str(i), '_', currCounty];
        disp(str);
    end            
end

virtualBatteryData(CA_Idx).commercialBuilding_ft2 = data;

%% assign SEB results to each county
countyTempMap = readtable('.\temperature_files\CA_county_station_map.csv');
for i = 1:length(allCounties)
    if(i == 19)
        debug = 1;
    end
    currCounty = allCounties{i};
    k = find(strcmp(countyTempMap.county,currCounty));
    tempIdx = countyTempMap.Station(k); % temperature station index
    SEB_struct{i} = SEB_data(tempIdx).data;
end
% virtualBatteryData(CA_Idx).SEB_data = SEB_struct;
virtualBatteryData(CA_Idx).SEB_data = SEB_data;
for i = 1:length(SEB_data)
    if(i ~= 8) % temperature #8 is for LA; 
        virtualBatteryData(CA_Idx).cap_10_minute.minPCap(i).office = reshape(SEB_data(i).data.minPCap,[144,365]);
        virtualBatteryData(CA_Idx).cap_10_minute.maxPCap(i).office = reshape(SEB_data(i).data.maxPCap,[144,365]);
        virtualBatteryData(CA_Idx).cap_10_minute.minECap(i).office = reshape(SEB_data(i).data.minECap,[144,365]);
        virtualBatteryData(CA_Idx).cap_10_minute.maxECap(i).office = reshape(SEB_data(i).data.maxECap,[144,365]);
        
        % hourly data from 10-minute data
        idx = 0:1:23;   % houly idx
        idx = idx*6;    % hour idx in 10-minute data
        idx = idx+1;
        tmp = reshape(SEB_data(i).data.minPCap,[144,365]);
        virtualBatteryData(CA_Idx).cap_60_minute.minPCap(i).office = tmp(idx,:);
        tmp = reshape(SEB_data(i).data.maxPCap,[144,365]);
        virtualBatteryData(CA_Idx).cap_60_minute.maxPCap(i).office = tmp(idx,:);
        tmp = reshape(SEB_data(i).data.minECap,[144,365]);
        virtualBatteryData(CA_Idx).cap_60_minute.minECap(i).office = tmp(idx,:);
        tmp = reshape(SEB_data(i).data.maxECap,[144,365]);
        virtualBatteryData(CA_Idx).cap_60_minute.maxECap(i).office = tmp(idx,:);

    end
end

%% get office build results
SEB_ft2 = 13509; % SEB square feet from He's email
county_office_building_ratio = zeros(length(allCounties),1);
minPCapTotal_10min = zeros(144*365,1);
maxPCapTotal_10min = zeros(144*365,1);
minECapTotal_10min = zeros(144*365,1);
maxECapTotal_10min = zeros(144*365,1);


for i = 1:length(allCounties)
    office_ft2 = virtualBatteryData(CA_Idx).commercialBuilding_ft2.AllOffices(i);
    if(isnan(office_ft2))
        office_ft2 = 0;
    end
    ratio_ft2 = office_ft2/SEB_ft2;
    county_office_building_ratio(i) = ratio_ft2;
    
    minPCap = SEB_struct{i}.minPCap;
    maxPCap = SEB_struct{i}.maxPCap;
    minECap = SEB_struct{i}.minECap;
    maxECap = SEB_struct{i}.maxECap;
    
    minPCap = minPCap*ratio_ft2;
    maxPCap = maxPCap*ratio_ft2;
    minECap = minECap*ratio_ft2;
    maxECap = maxECap*ratio_ft2;

    % total power and energy for state
    minPCapTotal_10min = minPCapTotal_10min+minPCap;
    maxPCapTotal_10min = maxPCapTotal_10min+maxPCap;
    minECapTotal_10min = minECapTotal_10min+minECap;
    maxECapTotal_10min = maxECapTotal_10min+maxECap;


    
end

virtualBatteryData(CA_Idx).county_office_building_ratio = county_office_building_ratio;
virtualBatteryData(CA_Idx).cap_10_minute.minPCapTotal.office = reshape(minPCapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_10_minute.maxPCapTotal.office = reshape(maxPCapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_10_minute.minECapTotal.office = reshape(minECapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_10_minute.maxECapTotal.office = reshape(maxECapTotal_10min,[144,365]);


%% hourly data total capacity
idx = 0:1:23;   % houly idx
idx = idx*6;    % hour idx in 10-minute data
idx = idx+1;
tmp = reshape(minPCapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_60_minute.minPCapTotal.office = tmp(idx,:);
tmp = reshape(maxPCapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_60_minute.maxPCapTotal.office = tmp(idx,:);
tmp = reshape(minECapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_60_minute.minECapTotal.office = tmp(idx,:);
tmp = reshape(maxECapTotal_10min,[144,365]);
virtualBatteryData(CA_Idx).cap_60_minute.maxECapTotal.office = tmp(idx,:);

save('virtualBatteryData.mat','virtualBatteryData');

















