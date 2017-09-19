%% 
% read housing data downloaded from US Census web site
%
%

function housingData = vbat_read_housing_data() %function housingData = vbat_read_housing_data(housingFile)

load('virtualBattery_intermediate_housing_data.mat');

if isempty(version('-release'))
    load('housingData_prep.mat');
    housingData = table(Id,Id2,Geography,totalHousing,detachedHousing,...
        occupiedHousing,elecHeatingOccupiedHousing);
else
    load('virtualBattery_intermediate_housing_data.mat');  
end

usedColumns = [1,2,3,4,28,244,256];

housingData = housingData(:,usedColumns); 


% check data using Los Angeles data
str = 'Los Angeles';
n = length(str);
idx = find(strncmp(housingData.Geography,str,n));

%dataLA = housingData(idx,:); %can this be commented?

% update table header names
housingData.Properties.VariableNames(4:7) = {'totalHousing', 'detachedHousing',...
    'occupiedHousing', 'elecHeatingOccupiedHousing'};

% need to delete couple counties in Alaske to match climate zone
str = 'Hoonah-Angoon Census Area';
k = find(strncmp(housingData.Geography, str,length(str)));
housingData(k,:) = [];

str = 'Petersburg Census Area';
k = find(strncmp(housingData.Geography, str,length(str)));
housingData(k,:) = [];
end