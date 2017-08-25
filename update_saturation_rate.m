%% load saturation rates for states 
%

function virtualBatteryData = update_saturation_rate(virtualBatteryData, saturationRateFile)
data = readtable(saturationRateFile);
allStates = {virtualBatteryData.stateCode};

for i = 1:size(data,1)
    currState = data.State{i};
    stateIdx = find(strcmp(allStates,currState));

    saturationRate.ac = data.ac(i);
    saturationRate.hp = data.hp(i);
    saturationRate.rg = data.rg(i);
    saturationRate.wh = data.wh(i);
    virtualBatteryData(stateIdx).saturationRate = saturationRate;    
end

end