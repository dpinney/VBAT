%
% 1/24/2017 updated to get 10-minute capacities for residential buildings
% Update virtual battery capacity for CA, WA, and OR
% Input: 'virtualBatteryData_org.mat'
% Functions called: 
%   * updateVB_capacity_Temperrature_data() to update virtual battery capacities for CA
%	* updateVB_capacity_State() to update virtual battery capacities for WA and OR
% Output: updated virtual battery data structure with residential building virtual battery capacities for CA,% WA, and OR: 'virtualBatteryData.mat'
% Note: this is probably what needs to be exposed in the OMF to user inputs.

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


















