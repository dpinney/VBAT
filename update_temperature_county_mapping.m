%% 
% update county temperature for a state by mapping measured station data to counties
% Input:
%   virtualBatteryData: virutal battery data structure
%   stateIdx: index of the state in the virtualBatteryData structure
%   tempDataFie: NCDC temperature data file from all stations in the state            
%   dataLinkFile: link between NCDC observation stations and counties
%   countyTempMapFile: link between counties and NCDC 
%   



function virtualBatteryData_out = update_temperature_county_mapping(virtualBatteryData, stateIdx, tempDataFile, dataLinkFile, countyTempMapFile)

% read in temperature data
tempData = readtable(tempDataFile);

% read in the link file between counties and stations
dataLink = readtable(dataLinkFile);


%% get the temperature zone for each station
allCounties = virtualBatteryData(stateIdx).county;
stationCounties = dataLink.County;
% use a loop since there are two Los Angles
%[a,ia,ib] = intersect(stationCounties,allCounties,'stable');
countyIdx = zeros(length(stationCounties),1);

for i = 1:length(stationCounties)
    currCounty = stationCounties{i};
    k = find(strcmp(allCounties,currCounty));
    countyIdx(i) = k;
end

dataLink.countyIdx = countyIdx;
tempZones = virtualBatteryData(stateIdx).IECCClimateZone;
dataLink.tempZone = tempZones(countyIdx);

%% plot temperature for two Los Angels stations
if(strcmp(virtualBatteryData(stateIdx).stateCode, 'CA'))
    k1 = find(strcmp(tempData.STATION_NAME,dataLink.STATION_NAME{2}));
    k2 = find(strcmp(tempData.STATION_NAME,dataLink.STATION_NAME{8}));
    T1 = tempData.DATE(k1);
    data1 = tempData.HLY_TEMP_NORMAL(k1);
    T2 = tempData.DATE(k2);
    data2 = tempData.HLY_TEMP_NORMAL(k2);
    figure;
    hold on;
    T1 = datenum(T1,'yyyymmdd HH:MM');
    plot(T1,data1);
    T2 = datenum(T2,'yyyymmdd HH:MM');
    plot(T2,data2);
end

%create a county temperature in virtual battery data structure
% nCounty = length(allCounties);
% for i = 1:nCounty
%     tmpStruct{i} = [];
% end

%% save county temperature into a structure
for i = 1:length(stationCounties)
    k = find(strcmp(tempData.STATION_NAME,dataLink.STATION_NAME{i}));
    %if(k >= 8759) % 8759 is the default # of measurements
    data = tempData.HLY_TEMP_NORMAL(k);
    T0 = tempData.DATE(k);
    T = datenum(T0,'yyyymmdd HH:MM');
    countyTemperature_NCDC(i).station = dataLink.STATION_NAME{i};
    countyTemperature_NCDC(i).count = dataLink.County{i};
    idx = dataLink.countyIdx(i);
    countyTemperature_NCDC(i).countyIdx = idx;
    countyTemperature_NCDC(i).climateZone = dataLink.tempZone(i);
    countyTemperature_NCDC(i).time = T;
    
    tempOut = temperatureFormatConversion_NCDC(data,T0);
    countyTemperature_NCDC(i).data = tempOut;
%     if(i ~= 8)
%         % not using station #8
%         tmpStruct{idx} = tempOut;
%     end
%     
%     % update climate zone data
%     if(i == 1)
%         virtualBatteryData(stateIdx).temperatureData{3} = tempOut;
%     end
%     
%     if(i == 9)
%         virtualBatteryData(stateIdx).temperatureData{4} = tempOut;
%     end
    
end

virtualBatteryData(stateIdx).temperature_NCDC = countyTemperature_NCDC;

%% update temperature data index for each county
countyTempMap = readtable(countyTempMapFile);
countyTemperatureIdx = zeros(length(allCounties),1);
for i = 1:length(allCounties)
    if(i == 19)
        debug = 1;
    end
    currCounty = allCounties{i};
    k = find(strcmp(countyTempMap.county,currCounty));
    tempIdx = countyTempMap.Station(k); % temperature station index
    %if(isempty(tmpStruct{i}))
    %    tmpStruct{i} = countyTemperature(tempIdx).data;
    %end
    countyTemperatureIdx(i) = tempIdx;
end
%virtualBatteryData(stateIdx).countyTemperature = tmpStruct;


virtualBatteryData(stateIdx).countyTemperatureIdx = countyTemperatureIdx;

virtualBatteryData_out = virtualBatteryData;



