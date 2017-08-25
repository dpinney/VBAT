%%%%
% update temperature for virutal battery data structure, temperature is downloaded from NCDC web site
% 
% Input:
%   virtualBatteryMat: virtual battery data strudture 
%   tempFile: temperature file from NCDC web site
%   State: state of the input temperature file
%   Zone: temperature zone of the input temperature file
% 


function out = updateTemperature_NCDC(virtualBatteryMat, tempFile, state, zone)

%% load virtual battery data
if(ischar(virtualBatteryMat))
    load(virtualBatteryMat);
else
    virtualBatteryData = virtualBatteryMat;
end

%% get state index
if(length(state) == 2)
    allStates = {virtualBatteryData.stateCode};
else
    allStates = {virtualBatteryData.state};
end

stateIdx = find(strcmp(allStates, state));


%% read in the temperature file and format data
tempData = readtable(tempFile);
% look like this data missed on hour, it only has 8759 rows, instead of 8760 rows
tempTime = tempData.DATE;
tempF = tempData.HLY_TEMP_NORMAL;

tempOut = temperatureFormatConversion_NCDC(tempF,tempTime);

%% 

virtualBatteryData(stateIdx).temperatureData(zone) = {tempOut};  

if(ischar(virtualBatteryMat))
    save(virtualBatteryMat, virtualBatteryData);
else
    out = virtualBatteryData;
end


