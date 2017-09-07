%%%%
% update virtual battery capacity for the specified state after the update
% of temperature data for each county in the state
% 
% Input:
%   virtualBatteryMat: virtual battery data strudture 
%   State: state of the input temperature file
%   deltaT: time interval for interpolated temperature data
%
% Ouput:
%   a data structure including all calculated capacities
%

function capData = updateVB_capacity_State(virtualBatteryMat, state,deltaT)
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
nCounty = length(virtualBatteryData(stateIdx).detachedHousing);
stateData = virtualBatteryData(stateIdx);
saturationRate = virtualBatteryData(stateIdx).saturationRate ; % saturation rates of appliances
for i = 1:nCounty
    str = ['county # ',num2str(i), ' of ', num2str(nCounty)];
    disp(str);
    nHousing = stateData.detachedHousing(i);
    countyTempFlag = 0;
    % use temperature data for the county if it is available
    if(isfield(virtualBatteryData,'countyTemperature'))
        if(~isempty(stateData.countyTemperature))
            countyTemp = stateData.countyTemperature{i};
            if(~isempty(countyTemp))
               temperatureData = countyTemp;
               countyTempFlag = 1;
            end            
        end
    end
    
    if(countyTempFlag == 0)
        % county temperature data is not available
        climateZone = stateData.IECCClimateZone(i);
        temperatureData = stateData.temperatureData{climateZone};  
    end
    if(T_interp)
        % interpolate temperature data
        temperatureData = temperature_interpolation(temperatureData, deltaT);
    end
    [minPCap, maxPCap, ECap] = estimate_Capacity_core_update1(nHousing, temperatureData,saturationRate);
    
    % update water heater results with He Hao's new model
    refHousing = 500; % get capacities for 500 houses and then scale up
    scaleFactor = nHousing/refHousing;
%     [minPCap_WH, maxPCap_WH, ECap_WH] = estimate_Capacity_core_update2_WH(refHousing, saturationRate);
%     minPCap_WH = minPCap_WH*scaleFactor;
%     maxPCap_WH = maxPCap_WH*scaleFactor;
%     ECap_WH = ECap_WH*scaleFactor;
    % extract data from output minute data
    usedMinutes = 0:deltaT:1440;
    usedMinutes = usedMinutes+1;
    idx = usedMinutes(1:end-1);
%     minPCap.wh = minPCap_WH(idx,:);
%     maxPCap.wh = maxPCap_WH(idx,:);
%     ECap.wh = ECap_WH(idx,:);
    
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

    % total capacity for the state
    if(i == 1)
        minPCapTotal.rg = minPCap.rg;
        minPCapTotal.wh = minPCap.wh;
        minPCapTotal.hp = minPCap.hp;
        minPCapTotal.ac = minPCap.ac;
        
        maxPCapTotal.rg = maxPCap.rg;
        maxPCapTotal.wh = maxPCap.wh;
        maxPCapTotal.hp = maxPCap.hp;
        maxPCapTotal.ac = maxPCap.ac;
        
        minECapTotal.rg = minECap.rg;
        minECapTotal.wh = minECap.wh;
        minECapTotal.hp = minECap.hp;
        minECapTotal.ac = minECap.ac;
        
        maxECapTotal.rg = maxECap.rg;
        maxECapTotal.wh = maxECap.wh;
        maxECapTotal.hp = maxECap.hp;
        maxECapTotal.ac = maxECap.ac;

        
    else
        minPCapTotal.rg = minPCapTotal.rg+minPCap.rg;
        minPCapTotal.wh = minPCapTotal.wh+minPCap.wh;
        minPCapTotal.hp = minPCapTotal.hp+minPCap.hp;
        minPCapTotal.ac = minPCapTotal.ac+minPCap.ac;
        
        maxPCapTotal.rg = maxPCapTotal.rg+maxPCap.rg;
        maxPCapTotal.wh = maxPCapTotal.wh+maxPCap.wh;
        maxPCapTotal.hp = maxPCapTotal.hp+maxPCap.hp;
        maxPCapTotal.ac = maxPCapTotal.ac+maxPCap.ac;
                       
        minECapTotal.rg = minECapTotal.rg+minECap.rg;
        minECapTotal.wh = minECapTotal.wh+minECap.wh;
        minECapTotal.hp = minECapTotal.hp+minECap.hp;
        minECapTotal.ac = minECapTotal.ac+minECap.ac;
        
        maxECapTotal.rg = maxECapTotal.rg+maxECap.rg;
        maxECapTotal.wh = maxECapTotal.wh+maxECap.wh;
        maxECapTotal.hp = maxECapTotal.hp+maxECap.hp;
        maxECapTotal.ac = maxECapTotal.ac+maxECap.ac;

    end        
end

capData.minPCap = minPCapAll;
capData.maxPCap = maxPCapAll;
capData.minECap = minECapAll;
capData.maxECap = maxECapAll;

capData.minPCapTotal = minPCapTotal;
capData.maxPCapTotal = maxPCapTotal;
capData.minECapTotal = minECapTotal;
capData.maxECapTotal = maxECapTotal;






