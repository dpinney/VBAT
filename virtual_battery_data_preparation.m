%% 
% This script will load the following county information for the virtual battery analysis:
% Housing Data:
%   1. State;
%   2. County;
%   3. Number of total housing units in a state
%   4. Number of detached housing units in each county
%   5. Number of occupied housing units in each county
%   6. Number of occupied housing units that using electricity as as heating fuel
% 
% IECC Climate zone of each county
%
% Temperature data for each climate zone in each state  
%
% Saturation rate for each state
%
% Output: 
%   'virtualBatteryData_org.mat': a structure list with each US State as an structure element
%
% 
%

clear;
clc;

%% read in the housing data and re-organize data into a structure
% read the data

%housingFile = '.\housing_county_DP04\ACS_12_5YR_DP04_with_ann.xlsx'; %USELESS
housingData = read_Housing_Data(); %housingData = read_Housing_Data(housingFile);

% re-organize the data
geography = housingData.Geography;
county = cell(1,length(geography));
state = cell(1,length(geography)); %pre allocating space


for i = 1:length(geography)
    currData = geography{i};
    k = strfind(currData,',');
    county{i} = currData(1:k-1);
    state{i} = strtrim(currData(k+1:end));
end


uniqueState = unique(state);


Run_time = clock; %starts timer
statePostalCodes = readtable('.\climate_zone_files\statePostalCode.xlsx');
%opening xlsx takes 700ms
%readtable() not in octave 
%statePostalCodes = readtable('.\climate_zone_files\statePostalCode.txt');
Run_time = seconds(clock) - seconds(Run_time);Run_time = Run_time(6) %#ok<NOPTS> %ends timer


for i = 1:length(uniqueState)
   currState = uniqueState{i};   
   idx = find(strcmp(state,currState));  %idx = find(strcmp(state,currState));  
   virtualBatteryData(i).state = strtrim(currState);
   k = strcmp(statePostalCodes.State, currState);
   virtualBatteryData(i).stateCode = statePostalCodes.PostalCode{i};%virtualBatteryData(i).stateCode = statePostalCodes.PostalCode{k};
   virtualBatteryData(i).nCounty = length(idx);
   counties = county(idx);
   for j = 1:length(counties)
       k = strfind(counties{j},'County');
       if(~isempty(k))
           counties{j} = counties{j}(1:k-2);
       end
   end
   virtualBatteryData(i).county = counties;   
   virtualBatteryData(i).countyId = housingData.Id(idx);
   virtualBatteryData(i).countId2 = housingData.Id2(idx);
   virtualBatteryData(i).totalHousing = housingData.totalHousing(idx);
   virtualBatteryData(i).detachedHousing = housingData.detachedHousing(idx);
   virtualBatteryData(i).occupiedHousing = housingData.occupiedHousing(idx);
   virtualBatteryData(i).elecHeatingOccupiedHousing = housingData.elecHeatingOccupiedHousing(idx);   
end


%% get IECC climate zone index for each county
climateZones = readtable('.\climate_zone_files\climate_zones.xlsx');
climateZones = sortrows(climateZones,[1,2]);

% need to delete Alexandria (city) to match housing data
str = 'Clifton Forge (city)';
k = find(strncmp(climateZones.County, str,length(str)));
climateZones(k,:) = [];

for i = 1:length(virtualBatteryData)
    stateCounties = virtualBatteryData(i).county;
    currCode = virtualBatteryData(i).stateCode;
    k = find(strcmp(climateZones.State,currCode));
    
    if(length(k) ~= length(stateCounties))
        debug = 1;
    end
    virtualBatteryData(i).IECCClimateZone = climateZones.IECCClimateZone(k);
    virtualBatteryData(i).BAClimateZone = climateZones.BAClimateZone(k);
    virtualBatteryData(i).IECCMoistureRegime = climateZones.IECCMoistureRegime(k);    
end


%% create a temperature data cell list for 8 climate zones as the place holder
zoneTemp_0 = cell(1,8);

for i = 1:length(virtualBatteryData)
    virtualBatteryData(i).temperatureData = zoneTemp_0;
end

%% load temperature data for CA
% get the index for CA
allStates = {virtualBatteryData.stateCode};
CA_Idx = find(strcmp(allStates,'CA'));
tempDataFile = '.\temperature_files\CA_all_stations.csv';
dataLinkFile = '.\temperature_files\NCDC_obs_locations_county_CA.csv';
countyTempMapFile = '.\temperature_files\CA_county_station_map.csv';

virtualBatteryData = update_temperature_county_mapping(virtualBatteryData, CA_Idx,tempDataFile, dataLinkFile, countyTempMapFile);

%% load temperature data for WA 
tempFile = '.\temperature_files\Washington_zone_4_Temperature.csv';
virtualBatteryData = updateTemperature_NCDC(virtualBatteryData, tempFile, 'Washington', 4);

tempFile = '.\temperature_files\Washington_zone_5_Temperature.csv';
virtualBatteryData = updateTemperature_NCDC(virtualBatteryData, tempFile, 'Washington', 5);

tempFile = '.\temperature_files\Washington_zone_6_Temperature.csv';
virtualBatteryData = updateTemperature_NCDC(virtualBatteryData, tempFile, 'Washington', 6);

%% load temperature data for OR
tempFile = '.\temperature_files\Oregon_zone_4_Temperature.csv';
virtualBatteryData = updateTemperature_NCDC(virtualBatteryData, tempFile, 'Oregon', 4);

tempFile = '.\temperature_files\Oregon_zone_5_Temperature.csv';
virtualBatteryData = updateTemperature_NCDC(virtualBatteryData, tempFile, 'Oregon', 5);

%% load saturation rates
saturationRateFile = '.\saturation_rate.csv';
virtualBatteryData = update_saturation_rate(virtualBatteryData, saturationRateFile);

%% save the data
save('virtualBatteryData_org.mat','virtualBatteryData');

%seconds not octave supported, easily implementable ie convert = [0;0;60*60*24;60*60;60;1]