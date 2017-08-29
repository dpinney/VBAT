%%%%
% update virtual battery capacity for the specified state using NCDC temeprature data
% 
% Input:
%   virtualBatteryMat: virtual battery data strudture 
%   State: state of the input temperature file
%   deltaT: time interval for interpolated temperature data
%
% Ouput:
%   a data structure including all calculated capacities
%

function capData = updateVB_capacity_Temperrature_data(virtualBatteryMat, state,deltaT)
if(nargin < 3)
    % not temperature interpolation
    T_interp = 0;
else
    T_interp = 1;
end

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

%% update virtual battery capacity for each county in the state
stateData = virtualBatteryData(stateIdx);
saturationRate = virtualBatteryData(stateIdx).saturationRate ; % saturation rates of appliances
temperature_NCDC = stateData.temperature_NCDC;
nTemperature = length(temperature_NCDC);
for i = 1:nTemperature
    str = ['Temperature Data # ',num2str(i), ' of ', num2str(nTemperature)];
    disp(str);
    nHousing = 1000; % using 1000 houses as reference
     
    temperatureData = temperature_NCDC(i).data;
    if(T_interp)
        % interpolate temperature data
        temperatureData = temperature_interpolation(temperatureData, deltaT);
    end
    [minPCap, maxPCap, ECap] = estimate_Capacity_core_update1(nHousing, temperatureData,saturationRate);
        
    % update water heater results with He Hao's new model
    [minPCap_WH, maxPCap_WH, ECap_WH] = estimate_Capacity_core_update2_WH(nHousing, saturationRate);
    % extract data from output minute data
    usedMinutes = 0:deltaT:1440;
    usedMinutes = usedMinutes+1;
    idx = usedMinutes(1:end-1);
    minPCap.wh = minPCap_WH(idx,:);
    maxPCap.wh = maxPCap_WH(idx,:);
    ECap.wh = ECap_WH(idx,:);

    % set NaN to 0 for now for ac and hp, which were due to the lack of temperature measurements
    nanIdx = find(isnan(ECap.ac));
    if(~isempty(nanIdx))
        debug = 1;
    end
    ECap.ac(isnan(ECap.ac)) = 0;
    ECap.hp(isnan(ECap.hp)) = 0;
    minPCap.ac(isnan(minPCap.ac)) = 0;
    minPCap.hp(isnan(minPCap.hp)) = 0;
    maxPCap.ac(isnan(maxPCap.ac)) = 0;
    maxPCap.hp(isnan(maxPCap.hp)) = 0;
    
    minECap.rg = -ECap.rg;
    minECap.wh = -ECap.wh;
    minECap.hp = -ECap.hp;
    minECap.ac = -ECap.ac;
    
    maxECap = ECap;
    
    minPCapAll(i) = minPCap;
    maxPCapAll(i) = maxPCap;
    minECapAll(i) = minECap;
    maxECapAll(i) = maxECap;

         
end

capData.minPCap = minPCapAll;
capData.maxPCap = maxPCapAll;
capData.minECap = minECapAll;
capData.maxECap = maxECapAll;


% total capacity for the state
nCounties = length(stateData.county);
temperatureIdx = stateData.countyTemperatureIdx; % mapping between counties and temperature data
for i = 1:nCounties
    idx = temperatureIdx(i);
    nHouse = stateData.detachedHousing(i); % number of detached houses in the county
    factor = nHouse/1000; % the capacity for each temperature is for 1000 houses
    if(i == 1)
        minPCapTotal.rg = minPCapAll(idx).rg*factor;
        minPCapTotal.wh = minPCapAll(idx).wh*factor;
        minPCapTotal.hp = minPCapAll(idx).hp*factor;
        minPCapTotal.ac = minPCapAll(idx).ac*factor;
        
        maxPCapTotal.rg = maxPCapAll(idx).rg*factor;
        maxPCapTotal.wh = maxPCapAll(idx).wh*factor;
        maxPCapTotal.hp = maxPCapAll(idx).hp*factor;
        maxPCapTotal.ac = maxPCapAll(idx).ac*factor;
        
        minECapTotal.rg = minECapAll(idx).rg*factor;
        minECapTotal.wh = minECapAll(idx).wh*factor;
        minECapTotal.hp = minECapAll(idx).hp*factor;
        minECapTotal.ac = minECapAll(idx).ac*factor;
        
        maxECapTotal.rg = maxECapAll(idx).rg*factor;
        maxECapTotal.wh = maxECapAll(idx).wh*factor;
        maxECapTotal.hp = maxECapAll(idx).hp*factor;
        maxECapTotal.ac = maxECapAll(idx).ac*factor;
        
        
    else
        minPCapTotal.rg = minPCapTotal.rg+minPCapAll(idx).rg*factor;
        minPCapTotal.wh = minPCapTotal.wh+minPCapAll(idx).wh*factor;
        minPCapTotal.hp = minPCapTotal.hp+minPCapAll(idx).hp*factor;
        minPCapTotal.ac = minPCapTotal.ac+minPCapAll(idx).ac*factor;
        
        maxPCapTotal.rg = maxPCapTotal.rg+maxPCapAll(idx).rg*factor;
        maxPCapTotal.wh = maxPCapTotal.wh+maxPCapAll(idx).wh*factor;
        maxPCapTotal.hp = maxPCapTotal.hp+maxPCapAll(idx).hp*factor;
        maxPCapTotal.ac = maxPCapTotal.ac+maxPCapAll(idx).ac*factor;
        
        minECapTotal.rg = minECapTotal.rg+minECapAll(idx).rg*factor;
        minECapTotal.wh = minECapTotal.wh+minECapAll(idx).wh*factor;
        minECapTotal.hp = minECapTotal.hp+minECapAll(idx).hp*factor;
        minECapTotal.ac = minECapTotal.ac+minECapAll(idx).ac*factor;
        
        maxECapTotal.rg = maxECapTotal.rg+maxECapAll(idx).rg*factor;
        maxECapTotal.wh = maxECapTotal.wh+maxECapAll(idx).wh*factor;
        maxECapTotal.hp = maxECapTotal.hp+maxECapAll(idx).hp*factor;
        maxECapTotal.ac = maxECapTotal.ac+maxECapAll(idx).ac*factor;
        
    end
end
capData.minPCapTotal = minPCapTotal;
capData.maxPCapTotal = maxPCapTotal;
capData.minECapTotal = minECapTotal;
capData.maxECapTotal = maxECapTotal;






