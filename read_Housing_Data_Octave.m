
if isempty(version('-release'))
    %disp('Using Octave');
    load('housingData_prep.mat');
   
    str = 'Hoonah-Angoon Census Area';
    k = find(strncmp(Geography, str,length(str)));
    %if k~=
    Housing_Data(k,[]);

%     
%     Id(k) = [];
%     Id2(k) = [];
%     Geography(k) = [];
%     totalHousing(k) = [];
%     detachedHousing(k) = [];
%     occupiedHousing(k) = [];
%     elecHeatingOccupiedHousing(k) = [];

    load('housingData_prep.mat');
    str = 'Petersburg Census Area';
    k = find(strncmp(Geography, str,length(str)));
    Housing_Data(k,[]);
    load('housingData_prep.mat');
%     save('housingData_prep.mat','Id','Id2','Geography','totalHousing',...
%        'detachedHousing','occupiedHousing','elecHeatingOccupiedHousing','-v7')  
    
%     Id(k) = [];
%     Id2(k) = [];
%     Geography(k) = [];
%     totalHousing(k) = [];
%     detachedHousing(k) = [];
%     occupiedHousing(k) = [];
%     elecHeatingOccupiedHousing(k) = [];
%     
%     save('housingData_prep.mat','Id','Id2','Geography','totalHousing',...
%        'detachedHousing','occupiedHousing','elecHeatingOccupiedHousing','-v7')
else
   load('housingData_all.mat');
   usedColumns = [1,2,3,4,28,244,256];
   housingData = housingData(:,usedColumns);
   Id = housingData(:,1);                                  %housingData(:,1)
   Id = table2array(Id);                       
   Id2 = housingData(:,2);                                 %housingData(:,2)
   Id2 = table2array(Id2);
   Geography = housingData(:,3);                           %housingData(:,3)
   Geography = table2array(Geography);
   totalHousing = housingData(:,4);                        %housingData(:,4)
   totalHousing = table2array(totalHousing);
   detachedHousing = housingData(:,5);                     %housingData(:,5)
   detachedHousing = table2array(detachedHousing);
   occupiedHousing = housingData(:,6);                     %housingData(:,6)
   occupiedHousing = table2array(occupiedHousing);
   elecHeatingOccupiedHousing = housingData(:,7);          %housingData(:,7)
   elecHeatingOccupiedHousing = table2array(elecHeatingOccupiedHousing);
   save('housingData_prep.mat','Id','Id2','Geography','totalHousing',...
       'detachedHousing','occupiedHousing','elecHeatingOccupiedHousing','-v7')  
end

