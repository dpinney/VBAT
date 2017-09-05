function Housing_Data(x,y)
load('housingData_prep.mat');
Id(x) = y;
Id2(x) = y;
Geography(x) = y;
totalHousing(x) = y;
detachedHousing(x) = y;
occupiedHousing(x) = y;
elecHeatingOccupiedHousing(x) = y;
save('housingData_prep.mat','Id','Id2','Geography','totalHousing',...
       'detachedHousing','occupiedHousing','elecHeatingOccupiedHousing','-v7')  
end