%
% 1/24/2017 updated to get 10-minute capacities for residential buildings
%

clc;
clear;

%% load data set
load('virtualBatteryData_org.mat');

%% update virtual battery capacity for CA
% time interval of temperature data in minutes
allStates = {virtualBatteryData.stateCode};
state_Idx = find(strcmp(allStates,'CA'));
deltaT = 60;
str = [num2str(deltaT),'-minute capacity:'];
disp(str);
capData = updateVB_capacity_Temperrature_data(virtualBatteryData, 'California', deltaT); %takes about 1 hour

virtualBatteryData(state_Idx).cap_60_minute=capData;

% deltaT = 10;
% str = [num2str(deltaT),'-minute capacity:'];
% disp(str);
% capData = updateVB_capacity_Temperrature_data(virtualBatteryData, 'California', deltaT);
% virtualBatteryData(CA_Idx).cap_10_minute=capData;

%% update virtual battery capacity for WA and OR
state_Idx = find(strcmp(allStates,'WA'));
deltaT = 60;
str = [num2str(deltaT),'-minute capacity:'];
disp(str);
capData = updateVB_capacity_State(virtualBatteryData, 'Washington',deltaT);
virtualBatteryData(state_Idx).cap_60_minute=capData;

state_Idx = find(strcmp(allStates,'OR'));
deltaT = 60;
str = [num2str(deltaT),'-minute capacity:'];
disp(str);
capData = updateVB_capacity_State(virtualBatteryData, 'Oregon',deltaT);
virtualBatteryData(state_Idx).cap_60_minute=capData;



%% update virtual battery capacity for 
virtualBatteryFile = 'virtualBatteryData.mat';
save(virtualBatteryFile, 'virtualBatteryData');


















