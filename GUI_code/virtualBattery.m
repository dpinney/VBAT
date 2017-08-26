function varargout = virtualBattery(varargin)
% VIRTUALBATTERY MATLAB code for virtualBattery.fig
%      VIRTUALBATTERY, by itself, creates a new VIRTUALBATTERY or raises the existing
%      singleton*.
%
%      H = VIRTUALBATTERY returns the handle to a new VIRTUALBATTERY or the handle to
%      the existing singleton*.
%
%      VIRTUALBATTERY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VIRTUALBATTERY.M with the given input arguments.
%
%      VIRTUALBATTERY('Property','Value',...) creates a new VIRTUALBATTERY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before virtualBattery_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to virtualBattery_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help virtualBattery

% Last Modified by GUIDE v2.5 16-Sep-2016 12:45:40

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @virtualBattery_OpeningFcn, ...
                   'gui_OutputFcn',  @virtualBattery_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% End initialization code - DO NOT EDIT


% --- Executes just before virtualBattery is made visible.
function virtualBattery_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to virtualBattery (see VARARGIN)

% Choose default command line output for virtualBattery
handles.output = hObject;

pnnl=imread('pnnl13.png');
axes(handles.axeslogo);
imshow(pnnl);%,'InitialMagnification', 200);%'Border','tight','InitialMagnification', 200)

% load virtual battery data 
% if you are using WINDOWS
% dataFile = '\\pnl\projects\LDRD_SEED\data\virtualBatteryData.mat';
% if you are using MAC
dataFile = 'virtualBatteryData.mat';

if(exist(dataFile, 'file'))
    load(dataFile);
    moveOn = 1;
else
    errordlg('Virtual Battery Data is not in the folder');
    % need to add code for a user to select a folder
    moveOn = 0;
end

if(moveOn)
    handles.data = virtualBatteryData;
    handles.country = {'US'};
    % EIA 9 us regions
    handles.region = {'Pacific'; 
        'Montain'; 
        'West North Central'; 
        'West South Central'; 
        'East North Central';
        'East South Central';
        'New England';
        'Middle Atlantic';
        'South Atlantic';
        };
    
    % states
    handles.state = {virtualBatteryData.state};
    
    % county
    nCounties = sum([virtualBatteryData.nCounty]);
    allCounty = cell(nCounties,1);
    counter = 0;
    for i = 1:length(virtualBatteryData)
        state = virtualBatteryData(i).stateCode;
        stateCounts = virtualBatteryData(i).county;
        for j = 1:virtualBatteryData(i).nCounty
            currCounty = stateCounts{j};
            currCounty = [state,':', currCounty];            
            counter = counter+1;            
            allCounty{counter} = currCounty;
        end
    end 
    
    handles.county = allCounty;    
end
    
set(handles. popupmenu_category,'value',1);
set(handles.listbox_region,'value',1); %48 for washington
set(handles.listbox_region,'string',handles.country);
% set(handles.listbox_region,'string',handles.state);

set(handles.listbox_type,'value',1);

% selections
handles.categoryIdx = 1;
handles.regionIdx = 1;
handles.applianceIdx = 1;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes virtualBattery wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = virtualBattery_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in popupmenu_category.
function popupmenu_category_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_category (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_category contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_category
 idx = get(hObject,'Value');
 handles.categoryIdx = idx;
 if(idx == 1)
     % US
     set(handles.listbox_region,'value',1);
     set(handles.listbox_region,'string',handles.country);
 elseif(idx == 2)
     % Region
     set(handles.listbox_region,'value',1);
     set(handles.listbox_region,'string',handles.region);
 elseif(idx == 3)
     % State
     set(handles.listbox_region,'value',1);
     set(handles.listbox_region,'string',handles.state);
 elseif(idx == 4)
     % County     
     set(handles.listbox_region,'value',1);
     set(handles.listbox_region,'string',handles.county);
 end
    
% Update handles structure
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function popupmenu_category_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_category (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_region.
function listbox_region_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_region contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_region

idx = get(hObject,'Value');
handles.regionIdx = idx;

% Update handles structure
guidata(hObject, handles);




% --- Executes during object creation, after setting all properties.
function listbox_region_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_region (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox_type.
function listbox_type_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_type
idx = get(hObject,'Value');
handles.applianceIdx = idx;

% Update handles structure
guidata(hObject, handles);



% --- Executes during object creation, after setting all properties.
function listbox_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_plot.
function pushbutton_plot_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% for now, only Washington, CA,  and Oregon data are available
dataAvailable = 0;
if(handles.categoryIdx == 3) %state
    if(handles.regionIdx == 48 || handles.regionIdx == 38 || handles.regionIdx == 5) % WA: 48; OR: 38; CA:
        dataAvailable = 1;
        data = handles.data(handles.regionIdx);  
        applianceIdx = handles.applianceIdx;
        % some plotting
        countyIdx = 0;
        plot_data(handles, data,applianceIdx,countyIdx);
        
    end
elseif(handles.categoryIdx == 4) % county
    idx = handles.regionIdx;
    currCounty = handles.county{idx};
    k1 = strfind(currCounty, 'CA:');
    k2 = strfind(currCounty, 'WA:');
    k3 = strfind(currCounty, 'OR:');
    
    if(~isempty(k1))
        %CA counties
        dataAvailable = 1;
        handles.regionIdx = 5;
    end
    
    if(~isempty(k2))
        %WA counties
        dataAvailable = 1;
        handles.regionIdx = 48;
    end
    
    if(~isempty(k3))
        %OR counties
        dataAvailable = 1;
        handles.regionIdx = 38;
    end

    
    if(dataAvailable)
        data = handles.data(handles.regionIdx);        
        applianceIdx = handles.applianceIdx;
        currCounty = currCounty(4:end);
        allCounties = data.county;
        countyIdx = find(strcmp(currCounty,allCounties));
        % some plotting
        plot_data(handles, data,applianceIdx,countyIdx);
        
        
    end
    
    
    
end

if(~dataAvailable)
    errordlg('Sorry, Data is not Available for the Selected Region!', 'No Data Error');
end





function plot_data(handles, data,applianceIdx,countyIdx)

%% getting the data
% we are using 10-minute data for plotting
if(countyIdx == 0)
    % plot the state
    minPCapTotal = data.cap_60_minute.minPCapTotal;
    maxPCapTotal = data.cap_60_minute.maxPCapTotal;
    minECapTotal = data.cap_60_minute.minECapTotal;
    maxECapTotal = data.cap_60_minute.maxECapTotal;

else
    % plot a county
%     minPCapTotal = data.cap_60_minute.minPCap(countyIdx);
%     maxPCapTotal = data.cap_60_minute.maxPCap(countyIdx);
%     minECapTotal = data.cap_60_minute.minECap(countyIdx);
%     maxECapTotal = data.cap_60_minute.maxECap(countyIdx);
    
[minPCapTotal, maxPCapTotal, minECapTotal, maxECapTotal] = getCountyCapacity(data,countyIdx);

end

stateCode = data.stateCode;

%% appliance index
if(applianceIdx == 1)
    %AC
    minPData = minPCapTotal.ac;
    maxPData = maxPCapTotal.ac;
    minEData = minECapTotal.ac;
    maxEData = maxECapTotal.ac;
elseif(applianceIdx == 2)
    %heat pump
    minPData = minPCapTotal.hp;
    maxPData = maxPCapTotal.hp;
    minEData = minECapTotal.hp;
    maxEData = maxECapTotal.hp;
elseif(applianceIdx == 3)
    %refrigerator
    minPData = minPCapTotal.rg;
    maxPData = maxPCapTotal.rg;
    minEData = minECapTotal.rg;
    maxEData = maxECapTotal.rg;
elseif(applianceIdx == 4)
    %water heater
    minPData = minPCapTotal.wh;
    maxPData = maxPCapTotal.wh;
    minEData = minECapTotal.wh;
    maxEData = maxECapTotal.wh;
elseif(applianceIdx == 5)
    %office buildings
    if(strcmp(stateCode,'CA'))
        minPData = minPCapTotal.office;
        maxPData = maxPCapTotal.office;
        minEData = minECapTotal.office;
        maxEData = maxECapTotal.office;
    else
        minPData = [];
        maxPData = [];
        minEData = [];
        maxEData = [];
    end
end

%% make sure data is available before the plotting
if(isempty(minPData))
    if(applianceIdx == 5)
        str = ['Sorry, Office Building data for ', stateCode, ' is not available!'];
        errordlg(str, 'No Data Error');
    end
    return;
end


if(applianceIdx < 5)
    minPData = -minPData;
end
    
% convert data from a matrix into a vector
% [m,n] = size(minData);
% n = m*n;
% 
% minData = reshape(minData,n,1);
% maxData = reshape(maxData,n,1);
% meanData = reshape(meanData,n,1);

% plot daily sum with unit GW
%minData = sum(minData)/1000000;
%maxData = sum(maxData)/1000000;
%meanData = sum(meanData)/1000000;

%minData = minData';
%maxData = maxData';
%meanData = meanData';

%% reshape data from a matrix to a vector and convert them from kW  to GW
minPData = minPData(:)/1e6;
maxPData = maxPData(:)/1e6;
minEData = minEData(:)/1e6;
maxEData = maxEData(:)/1e6;


%dates1 = datenum('1-Jan-2013 00:00:00'):1/24:datenum('31-Dec-2013 23:59:59'); % for hourly data
dates1 = datenum('1-Jan-2013 00:00:00'):1/24:datenum('31-Dec-2013 23:50:00'); % for 60-minute data

ax=[handles.ax11 handles.ax22];

axes(handles.ax11);
plot(dates1, maxPData, 'r');
hold on
plot(dates1, minPData, 'b');
legend('Max Capacity','Min Capacity')
ylabel('Power (GW)');
hold off

axes(handles.ax22);
plot(dates1, maxEData,'r');
hold on
plot(dates1, minEData, 'b');
legend('Max Capacity','Min Capacity')
ylabel('Energy (GWh)');
hold off

linkaxes(ax, 'x');
for i=1:2
datetick(ax(i), 'x');
end
hzoom = zoom(handles.ax11);
set(hzoom,'ActionPostCallback',{@mylabel,ax});

%% get the capacity for a county    
function    [minPCapTotal, maxPCapTotal, minECapTotal, maxECapTotal] = getCountyCapacity(stateData,countyIdx)
%% CA data and WA/OR data are stored differently
if(strcmp(stateData.stateCode,'CA'))
    % CA
    temperatureIdx = stateData.countyTemperatureIdx; % mapping between counties and temperature data
    idx = temperatureIdx(countyIdx);
    
    % factor for AC, HP, RG, and WH
    nHouse = stateData.detachedHousing(countyIdx); % number of detached houses in the county
    factor_1 = nHouse/1000; % the capacity for each temperature is for 1000 houses
    
    % factor for the office building
    factor_2 = stateData.county_office_building_ratio(countyIdx);
else
    %% WA and OR
    % county data has been calcualted using county housing 
    factor_1 = 1;
    factor_2 = 1;
    idx = countyIdx;
    
end

minPCapAll = stateData.cap_60_minute.minPCap;
maxPCapAll = stateData.cap_60_minute.maxPCap;
minECapAll = stateData.cap_60_minute.minECap;
maxECapAll = stateData.cap_60_minute.maxECap;

minPCapTotal.rg = minPCapAll(idx).rg*factor_1;
minPCapTotal.wh = minPCapAll(idx).wh*factor_1;
minPCapTotal.hp = minPCapAll(idx).hp*factor_1;
minPCapTotal.ac = minPCapAll(idx).ac*factor_1;


maxPCapTotal.rg = maxPCapAll(idx).rg*factor_1;
maxPCapTotal.wh = maxPCapAll(idx).wh*factor_1;
maxPCapTotal.hp = maxPCapAll(idx).hp*factor_1;
maxPCapTotal.ac = maxPCapAll(idx).ac*factor_1;

minECapTotal.rg = minECapAll(idx).rg*factor_1;
minECapTotal.wh = minECapAll(idx).wh*factor_1;
minECapTotal.hp = minECapAll(idx).hp*factor_1;
minECapTotal.ac = minECapAll(idx).ac*factor_1;

maxECapTotal.rg = maxECapAll(idx).rg*factor_1;
maxECapTotal.wh = maxECapAll(idx).wh*factor_1;
maxECapTotal.hp = maxECapAll(idx).hp*factor_1;
maxECapTotal.ac = maxECapAll(idx).ac*factor_1;

%% only CA has office data for now.
if(strcmp(stateData.stateCode,'CA'))
    minPCapTotal.office  = minPCapAll(idx).office*factor_2;
    maxPCapTotal.office = maxPCapAll(idx).office*factor_2;
    minECapTotal.office = minECapAll(idx).office*factor_2;
    maxECapTotal.office = maxECapAll(idx).office*factor_2;
else
    minPCapTotal.office  = [];
    maxPCapTotal.office = [];
    minECapTotal.office = [];
    maxECapTotal.office = [];    
end



