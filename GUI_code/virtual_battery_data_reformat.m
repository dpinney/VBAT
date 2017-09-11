load('virtualBatteryData.mat')

ac = struct('minPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.ac(:)/1e6,...
    'maxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.ac(:)/1e6,...
    'minEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.ac(:)/1e6,...
    'maxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.ac(:)/1e6);

% ac = struct2cell(ac);

ac = struct2array(ac);
% ac = num2str(ac);


% ac1 = ones(8761,4);
% ac1(2:8761,:) = ac;
% ac1(1,:) = ('p','P','e','E');

hp = struct('minPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.hp(:)/1e6,...
    'maxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.hp(:)/1e6,...
    'minEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.hp(:)/1e6,...
    'maxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.hp(:)/1e6);

hp = struct2array(hp);
% hp = num2str(hp);

office = struct('minPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.office(:)/1e6,...
    'maxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.office(:)/1e6,...
    'minEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.office(:)/1e6,...
    'maxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.office(:)/1e6);

office = struct2array(office);
% office = num2str(office);

rg = struct('minPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.rg(:)/1e6,...
    'maxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.rg(:)/1e6,...
    'minEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.rg(:)/1e6,...
    'maxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.rg(:)/1e6);

rg = struct2array(rg);
% rg = num2str(rg);

wh = struct('minPData',-virtualBatteryData(5).cap_60_minute.minPCapTotal.wh(:)/1e6,...
    'maxPData',-virtualBatteryData(5).cap_60_minute.maxPCapTotal.wh(:)/1e6,...
    'minEData',-virtualBatteryData(5).cap_60_minute.minECapTotal.wh(:)/1e6,...
    'maxEData',-virtualBatteryData(5).cap_60_minute.maxECapTotal.wh(:)/1e6);

wh = struct2array(wh);
% wh = num2str(wh);

California = struct('ac',ac,'hp',hp,'office',office,'rg',rg,'wh',wh);

save('virtualBatteryDataReformat.mat','California')

California = struct2cell(California);

% x = string({'AC:minPData','AC:maxPData','AC:minEData','AC:maxEData'});
% x = {'AC:minPData','AC:maxPData','AC:minEData','AC:maxEData'};
% x = ['AC:minPData';'AC:maxPData';'AC:minEData';'AC:maxEData'];

% fileID = fopen('virtualBatteryDataReformat.txt','w');
fileID = fopen('virtualBatteryDataReformat.csv','w');

fprintf(fileID,'%s\n','AC');
fprintf(fileID,'%s, %s, %s, %s,\n','minPCapTotal','maxPCapTotal',...
    'minECapTotal','maxECapTotal');
fprintf(fileID,'%f, %f, %f, %f,\n',ac);

fprintf(fileID,'%s\n','HP');
fprintf(fileID,'%s, %s, %s, %s,\n','minPCapTotal','maxPCapTotal',...
    'minECapTotal','maxECapTotal');
fprintf(fileID,'%f, %f, %f, %f,\n',hp);

fprintf(fileID,'%s\n','Office');
fprintf(fileID,'%s, %s, %s, %s,\n','minPCapTotal','maxPCapTotal',...
    'minECapTotal','maxECapTotal');
fprintf(fileID,'%f, %f, %f, %f,\n',office);

fprintf(fileID,'%s\n','RG');
fprintf(fileID,'%s, %s, %s, %s,\n','minPCapTotal','maxPCapTotal',...
    'minECapTotal','maxECapTotal');
fprintf(fileID,'%f, %f, %f, %f,\n',rg);

fprintf(fileID,'%s\n','WH');
fprintf(fileID,'%s, %s, %s, %s,\n','minPCapTotal','maxPCapTotal',...
    'minECapTotal','maxECapTotal');
fprintf(fileID,'%f, %f, %f, %f,\n',wh);

fclose(fileID);

% csvwrite('virtualBatteryDataReformat.csv',California)

% csvwrite('virtualBatteryDataReformat.csv',California,1,0)
% dlmwrite('virtualBatteryDataReformat.csv',California,'-append')%,1,0)
