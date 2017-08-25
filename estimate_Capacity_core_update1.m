% Code was modified from estimate_Capacity_v1
%
% Author: He Hao
% Last update time: June 12, 2013
% This script is to estimate the power and energy capacities for a
% population of TCLs

% External script: readPriceData.m in the price folder and readTempData.m in the temperature folder
% 
% 11/28/2016 
%   modified from estimate_Capacity_core.m to improve computational speed
%
% 1/16/2016
%   added appliance saturation rate as input
%

function [e_lower, e_upper, e_int] = estimate_Capacity_core_update1(N, temp_mat,saturationRate)

% theta_a is the ambient temperature
theta_a = temp_mat(:,:);
[nRow,nCol] = size(theta_a);
theta_a = reshape(theta_a,nRow*nCol,1);

%%
%%%%%%%%%%%%%%%%%%      This part is for AC      %%%%%%%%%%%%%%%%%%%%%%%%
% N_ac is the number of air conditioners
saturationRate_AC = saturationRate.ac;
%N_ac = round(0.465*N);
N_ac = round(saturationRate_AC*N);
% C is the termal capacitance
C_ac = 2*ones(N_ac,1);
% R is the thermal resistance
R_ac = 2*ones(N_ac,1);
% P is the rated power (kW) of each TCL
P_ac = 14*ones(N_ac,1);
% eta is the coefficient of performance
eta_ac = 2.5;
% delta is the deadband
delta_ac = 0.625*ones(N_ac,1);
% theta_s is the setpoint temperature
theta_s_ac = 22.5*ones(N_ac,1);
% theta_lower is the temperature lower bound
theta_lower_ac = theta_s_ac - delta_ac/2;
% theta_upper is the temperature upper bound
theta_upper_ac = theta_s_ac + delta_ac/2;
 
Ta_ac = 20:0.5:45;

participation_ac =  (atan(theta_a-27) - atan(Ta_ac(1)-27))/((atan(Ta_ac(end)-27) - atan(Ta_ac(1)-27)));
k = find(participation_ac < 0);
if(~isempty(k))
    participation_ac(k)=0;
end
k = find(participation_ac >1);
if(~isempty(k))
    participation_ac(k) =1;
end
P0_ac = (theta_a - mean(theta_s_ac))./mean(R_ac); % kw needed to get to the set temperature
P0_ac = P0_ac/mean(eta_ac);         % kw needed from the grid
e_lower_ac = N_ac*participation_ac.*P0_ac;
k = find(e_lower_ac < 0);
if(~isempty(k))
    e_lower_ac(k) =0;
end
e_upper_ac = N_ac*participation_ac.*(mean(P_ac./mean(eta_ac)) - P0_ac);
k = find(e_upper_ac < 0);
if(~isempty(k))
    e_upper_ac =0;
end
e_int_ac = N_ac*participation_ac.*(mean(C_ac)./mean(eta_ac).*mean(delta_ac)/2);

% format the data
e_lower_ac = reshape(e_lower_ac,nRow,nCol);
e_upper_ac = reshape(e_upper_ac,nRow,nCol);
e_int_ac = reshape(e_int_ac,nRow,nCol);

%%
%%%%%%%%%%%%%%%%%%    This part is for Heat Pump    %%%%%%%%%%%%%%%%%%%%%%%
% N_hp is the number of heat pumps
saturationRate_hp = saturationRate.hp;
%N_hp = round(0.01*N);
N_hp = round(saturationRate_hp*N);
% C is the termal capacitance
C_hp = 2*ones(N_hp,1);
% R is the thermal resistance
R_hp = 2*ones(N_hp,1);
% P is the rated power (kW) of each TCL
P_hp = 19.6*ones(N_hp,1);
% eta is the coefficient of performance
eta_hp = 3.5;
% delta is the deadband
delta_hp =  0.625*ones(N_hp,1);
% theta_s is the setpoint temperature
theta_s_hp = 19.5*ones(N_hp,1);
% theta_lower is the temperature lower bound
theta_lower_hp = theta_s_hp - delta_hp/2;
% theta_upper is the temperature upper bound
theta_upper_hp = theta_s_hp + delta_hp/2;

Ta_hp = 0:0.5:25;
    
participation_hp = 1-(atan(theta_a-10) - atan(Ta_hp(1)-10))/((atan(Ta_hp(end)-10) - atan(Ta_hp(1)-10)));
k = find(participation_hp < 0);
if(~isempty(k))
    participation_hp(k)=0;
end
k = find(participation_hp >1);
if(~isempty(k))
    participation_hp(k) =1;
end
P0_hp = -(theta_a - mean(theta_s_hp))./(mean(eta_hp).*mean(R_hp));  % a(theta_-theta_t)/b and a = 1/(CR), b = eta/C
e_lower_hp = N_hp*participation_hp.*P0_hp;
k = find(e_lower_hp < 0);
if(~isempty(k))
    e_lower_hp(k) =0;
end
e_upper_hp = N_hp*participation_hp.*(mean(P_hp)./mean(eta_hp) - P0_hp);
k = find(e_upper_hp < 0);
if(~isempty(k))
    e_upper_hp =0;
end
e_int_hp = N_hp*participation_hp.*(mean(C_hp)./mean(eta_hp).*mean(delta_hp)/2);

% format the data
e_lower_hp = reshape(e_lower_hp,nRow,nCol);
e_upper_hp = reshape(e_upper_hp,nRow,nCol);
e_int_hp = reshape(e_int_hp,nRow,nCol);



%%
%%%%%%%%%%%%%      This part is for Refrigerators      %%%%%%%%%%%%%%%%%%
% N_rg is the number of refrigerators
saturationRate_rg = saturationRate.rg;
%N_rg = round(1.2225*N);
N_rg = round(saturationRate_rg*N);
% C is the termal capacitance
C_rg = 0.6*ones(N_rg,1);
% R is the thermal resistance
R_rg = 90*ones(N_rg,1);
% P is the rated power (kW) of each TCL
P_rg = 0.6*ones(N_rg,1);
% eta is the coefficient of performance
eta_rg = 2;
% delta is the deadband
delta_rg = 1.5*ones(N_rg,1);
% theta_s is the setpoint temperature
theta_s_rg = 2.5*ones(N_rg,1);
% theta_lower is the temperature lower bound
theta_lower_rg = theta_s_rg - delta_rg/2;
% theta_upper is the temperature upper bound
theta_upper_rg = theta_s_rg + delta_rg/2;

P0_rg = (20 - mean(theta_s_rg))./(mean(eta_rg).*mean(R_rg));
e_lower_rg = N_rg.*P0_rg;
e_upper_rg = N_rg*(mean(P_rg)./mean(eta_rg) - P0_rg);
e_int_rg = N_rg*(mean(C_rg)./mean(eta_rg).*mean(delta_rg)/2);

% format the data
e_lower_rg = e_lower_rg*ones(nRow,nCol);
e_upper_rg = e_upper_rg*ones(nRow,nCol);
e_int_rg = e_int_rg*ones(nRow,nCol);

%%
%%%%%%%%%%%%%      This part is for Water Heaters      %%%%%%%%%%%%%%%%%%
% N_wh is the number of water heaters
saturationRate_wh = saturationRate.wh;
%N_wh = round(0.065*N);
N_wh = round(saturationRate_wh*N);
% C is the termal capacitance
C_wh = 0.4*ones(N_wh,1);
% R is the thermal resistance
R_wh = 120*ones(N_wh,1);
% P is the rated power (kW) of each TCL
P_wh = 4.5*ones(N_wh,1);
% eta is the coefficient of performance
eta_wh = 1;
% delta is the deadband
delta_wh = 3*ones(N_wh,1);
% theta_s is the setpoint temperature
theta_s_wh = 48.5*ones(N_wh,1);
% theta_lower is the temperature lower bound
theta_lower_wh = theta_s_wh - delta_wh/2;
% theta_upper is the temperature upper bound
theta_upper_wh = theta_s_wh + delta_wh/2;

P0_wh = -(20 - mean(theta_s_wh))./(mean(eta_wh).*mean(R_wh));
e_lower_wh = N_wh*P0_wh;
e_upper_wh = N_wh*(mean(P_wh)./mean(eta_wh) - P0_wh);
e_int_wh = N_wh*(mean(C_wh)./mean(eta_wh).*mean(delta_wh)/2);

% format the data
e_lower_wh = e_lower_wh*ones(nRow,nCol); 
e_upper_wh = e_upper_wh*ones(nRow,nCol); 
e_int_wh = e_int_wh*ones(nRow,nCol); 

e_lower.rg = e_lower_rg;
e_lower.wh = e_lower_wh;
e_lower.hp = e_lower_hp;
e_lower.ac = e_lower_ac;

e_upper.rg = e_upper_rg;
e_upper.wh = e_upper_wh;
e_upper.hp = e_upper_hp;
e_upper.ac = e_upper_ac;

e_int.rg = e_int_rg;
e_int.wh = e_int_wh;
e_int.hp = e_int_hp;
e_int.ac = e_int_ac;


% figure
% area([mean(e_lower_rg)',mean(e_lower_wh)',mean(e_lower_hp)',mean(e_lower_ac)']/1000)
% set(gca,'fontsize', 16);
% axis([1 24 0 20])
% xlabel('Hour (h)');
% set(gca,'XTick',[05 10 15 20])
% set(gca,'XTickLabel',{'05' '10' '15' '20'})
% ylabel('Capacity (GW)');
% legend('Refrigerator', 'Water Heater','Heat Pump','Air Conditioner',2)
% 
% % colormap(vivid(256));
% set(gca, ...
% 'FontName'    , 'Helvetica', ...
% 'Box'         , 'off'     , ...
% 'TickDir'     , 'out'     , ...
% 'TickLength'  , [.02 .02] , ...
% 'XMinorTick'  , 'on'      , ...
% 'YMinorTick'  , 'on'      , ...
% 'YGrid'       , 'on'      , ...
% 'XColor'      , [.3 .3 .3], ...
% 'YColor'      , [.3 .3 .3], ...
% 'LineWidth'   , 1         );
% 
% 
% 
% 
% figure
% area([mean(e_upper_rg)',mean(e_upper_wh)',mean(e_upper_hp)', mean(e_upper_ac)']/1000)
% set(gca,'fontsize', 16);
% axis([1 24 0 20])
% xlabel('Hour (h)');
% set(gca,'XTick',[05 10 15 20])
% set(gca,'XTickLabel',{'05' '10' '15' '20'})
% ylabel('Capacity (GW)');
% legend('Refrigerator', 'Water Heater','Heat Pump','Air Conditioner',2)
% 
% % colormap(vivid(256));
% set(gca, ...
% 'FontName'    , 'Helvetica', ...
% 'Box'         , 'off'     , ...
% 'TickDir'     , 'out'     , ...
% 'TickLength'  , [.02 .02] , ...
% 'XMinorTick'  , 'on'      , ...
% 'YMinorTick'  , 'on'      , ...
% 'YGrid'       , 'on'      , ...
% 'XColor'      , [.3 .3 .3], ...
% 'YColor'      , [.3 .3 .3], ...
% 'LineWidth'   , 1         );
% 
% 
% figure
% area([mean(e_int_rg)',mean(e_int_wh)',mean(e_int_hp)', mean(e_int_ac)']/1000)
% set(gca,'fontsize', 16);
% axis([1 24 0 20])
% xlabel('Hour (h)');
% set(gca,'XTick',[05 10 15 20])
% set(gca,'XTickLabel',{'05' '10' '15' '20'})
% ylabel('Capacity (GWh)');
% legend('Refrigerator', 'Water Heater','Heat Pump','Air Conditioner',2)
% 
% % colormap(vivid(256));
% set(gca, ...
% 'FontName'    , 'Helvetica', ...
% 'Box'         , 'off'     , ...
% 'TickDir'     , 'out'     , ...
% 'TickLength'  , [.02 .02] , ...
% 'XMinorTick'  , 'on'      , ...
% 'YMinorTick'  , 'on'      , ...
% 'YGrid'       , 'on'      , ...
% 'XColor'      , [.3 .3 .3], ...
% 'YColor'      , [.3 .3 .3], ...
% 'LineWidth'   , 1         );


% pro_RU(287,1)=300; pro_RU(280,3)=300;
% pro_RD(358,:) = pro_RD(357,:); pro_RD(290)=300; pro_RD(290,1)=300; pro_RD(292,3)=300;
% 
% 
% 
% disp('------------------------- Air Conditioner');
% revenue_lower_ac = e_lower_ac.*price_RU+e_lower_ac./pro_RU.*price_RMU.*pro_RMU;
% revenue_lower_ac(isnan(revenue_lower_ac))=0;
% revenue_lower_ac(isinf(revenue_lower_ac))=0;
% mean(mean(e_lower_ac.*price_RU))/N_ac/1000*24*365
% mean(mean(e_lower_ac./pro_RU.*price_RMU.*pro_RMU))/N_ac/1000*24*365
% 
% 
% revenue_upper_ac = e_upper_ac.*price_RD+e_upper_ac./pro_RD.*price_RMD.*pro_RMD;
% revenue_upper_ac(isnan(revenue_upper_ac))=0;
% revenue_upper_ac(isinf(revenue_upper_ac))=0;
% mean(mean(e_upper_ac.*price_RD))/N_ac/1000*24*365
% mean(mean(e_upper_ac./pro_RD.*price_RMD.*pro_RMD))/N_ac/1000*24*365
% mean(mean(revenue_lower_ac))/N_ac/1000*24*365+mean(mean(revenue_upper_ac))/N_ac/1000*24*365
% 
% 
% 
% disp('------------------------- Heat Pump');
% revenue_lower_hp = e_lower_hp.*price_RU+e_lower_hp./pro_RU.*price_RMU.*pro_RMU;
% revenue_lower_hp(isnan(revenue_lower_hp))=0;
% revenue_lower_hp(isinf(revenue_lower_hp))=0;
% mean(mean(e_lower_hp.*price_RU))/N_hp/1000*24*365
% mean(mean(e_lower_hp./pro_RU.*price_RMU.*pro_RMU))/N_hp/1000*24*365
% 
% revenue_upper_hp = e_upper_hp.*price_RD+e_upper_hp./pro_RD.*price_RMD.*pro_RMD;
% revenue_upper_hp(isnan(revenue_upper_hp))=0;
% revenue_upper_hp(isinf(revenue_upper_hp))=0;
% mean(mean(e_upper_hp.*price_RD))/N_hp/1000*24*365
% mean(mean(e_upper_hp./pro_RD.*price_RMD.*pro_RMD))/N_hp/1000*24*365
% mean(mean(revenue_lower_hp))/N_hp/1000*24*365+mean(mean(revenue_upper_hp))/N_hp/1000*24*365
% 
% 
% disp('------------------------- Refrigerator');
% revenue_lower_rg = e_lower_rg.*price_RU+e_lower_rg./pro_RU.*price_RMU.*pro_RMU;
% revenue_lower_rg(isnan(revenue_lower_rg))=0;
% revenue_lower_rg(isinf(revenue_lower_rg))=0;
% mean(mean(e_lower_rg.*price_RU))/N_rg/1000*24*365
% mean(mean(e_lower_rg./pro_RU.*price_RMU.*pro_RMU))/N_rg/1000*24*365
% 
% 
% revenue_upper_rg = e_upper_rg.*price_RD+e_upper_rg./pro_RD.*price_RMD.*pro_RMD;
% revenue_upper_rg(isnan(revenue_upper_rg))=0;
% revenue_upper_rg(isinf(revenue_upper_rg))=0;
% mean(mean(e_upper_rg.*price_RD))/N_rg/1000*24*365
% mean(mean(e_upper_rg./pro_RD.*price_RMD.*pro_RMD))/N_rg/1000*24*365
% mean(mean(revenue_lower_rg))/N_rg/1000*24*365+mean(mean(revenue_upper_rg))/N_rg/1000*24*365
% 
% 
% 
% disp('------------------------- Water Heater');
% revenue_lower_wh = e_lower_wh.*price_RU+e_lower_wh./pro_RU.*price_RMU.*pro_RMU;
% revenue_lower_wh(isnan(revenue_lower_wh))=0;
% revenue_lower_wh(isinf(revenue_lower_wh))=0;
% mean(mean(e_lower_wh.*price_RU))/N_wh/1000*24*365
% mean(mean(e_lower_wh./pro_RU.*price_RMU.*pro_RMU))/N_wh/1000*24*365
% 
% 
% revenue_upper_wh = e_upper_wh.*price_RD+e_upper_wh./pro_RD.*price_RMD.*pro_RMD;
% revenue_upper_wh(isnan(revenue_upper_wh))=0;
% revenue_upper_wh(isinf(revenue_upper_wh))=0;
% mean(mean(e_upper_wh.*price_RD))/N_wh/1000*24*365
% mean(mean(e_upper_wh./pro_RD.*price_RMD.*pro_RMD))/N_wh/1000*24*365
% mean(mean(revenue_lower_wh))/N_wh/1000*24*365+mean(mean(revenue_upper_wh))/N_wh/1000*24*365




