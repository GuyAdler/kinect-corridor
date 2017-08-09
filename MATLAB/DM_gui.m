function varargout = DM_gui(varargin)
% DM_GUI MATLAB code for DM_gui.fig
%      DM_GUI, by itself, creates a new DM_GUI or raises the existing
%      singleton*.
%
%      H = DM_GUI returns the handle to a new DM_GUI or the handle to
%      the existing singleton*.
%
%      DM_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DM_GUI.M with the given input arguments.
%
%      DM_GUI('Property','Value',...) creates a new DM_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DM_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DM_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DM_gui

% Last Modified by GUIDE v2.5 07-Jul-2017 18:44:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @DM_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @DM_gui_OutputFcn, ...
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


% --- Executes just before DM_gui is made visible.
function DM_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DM_gui (see VARARGIN)

% Choose default command line output for DM_gui
handles.output = hObject;
set(handles.epsilontext,'String','e','FontName','symbol');
handles.loaded = 0;
handles.metric = 'euclidean';
handles.dim = 2;
handles.epsilon = 20;
handles.t = 1;
handles.shownums = 0;

set(gcf,'toolbar','figure');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes DM_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DM_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in loaddata.
function loaddata_Callback(hObject, eventdata, handles)
filename = uigetfile;

LoadMat = load(filename);
fn = fieldnames(LoadMat);
Data = LoadMat.(fn{1}) ; 
handles.group_lengths = LoadMat.lengths;
handles.SkelPoints = LoadMat.SkelPoints;
handles.loaded = 1;

handles.Data = squareform(pdist(Data, handles.metric));

set(handles.loaded_text, 'String', filename);

guidata(hObject, handles);


% --- Executes on selection change in metric_menu.
function metric_menu_Callback(hObject, eventdata, handles)
% hObject    handle to metric_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns metric_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from metric_menu
contents = cellstr(get(hObject,'String'));
value = contents{get(hObject,'Value')};

switch value
    case 'Euclidean'
        handles.metric = 'euclidean';
    case 'Normalized Euclidean'
        handles.metric = 'seuclidean';
    case 'City block'
        handles.metric = 'cityblock';
    case 'Mahalanobis'
        handles.mteric = 'mahalanobis';
    case 'Minkowski'
        handles.metric = 'minkowski';
    case 'Cosine'
        handles.metric = 'cosine';
    case 'Correlation'
        handles.metric = 'correlation';
    otherwise
        handles.metric = 'euclidean';
end

if handles.loaded == 1
    handles.Data = squareform(pdist(handles.Data, handles.metric));
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function metric_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to metric_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function epsilonvalue_Callback(hObject, eventdata, handles)
% hObject    handle to epsilonvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of epsilonvalue as text
%        str2double(get(hObject,'String')) returns contents of epsilonvalue as a double
handles.epsilon = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function epsilonvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to epsilonvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function tvalue_Callback(hObject, eventdata, handles)
% hObject    handle to tvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of tvalue as text
%        str2double(get(hObject,'String')) returns contents of tvalue as a double
handles.t = str2double(get(hObject,'String'));
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function tvalue_CreateFcn(hObject, eventdata, handles)
% hObject    handle to tvalue (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in dim_menu.
function dim_menu_Callback(hObject, eventdata, handles)
% hObject    handle to dim_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns dim_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from dim_menu
contents = cellstr(get(hObject,'String'));
switch contents{get(hObject,'Value')}
    case '2D'
        handles.dim = 2;
    case '3D'
        handles.dim = 3;
end

guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function dim_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dim_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in eigenbutton.
function eigenbutton_Callback(hObject, eventdata, handles)
% hObject    handle to eigenbutton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = handles.t;
e = handles.epsilon;
D = handles.Data;
neigen = 6;

if handles.loaded == 1
    cla
    [~, eigenvals, ~, ~] = diffuse(D,e,neigen,t);
    
    stem(1:length(eigenvals),eigenvals)
    xlim([0 length(eigenvals)+1]);
    for k = 1:length(eigenvals)
        text(k , eigenvals(k)+0.05, num2str(eigenvals(k)));
    end
    
    xlim([0 neigen+1]); ylim([0 1.1]);
    title(['Eigenvalues, t = ' num2str(t) ', \epsilon = ' num2str(e)]);
end


% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes on button press in numscheckbox.
function numscheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to numscheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of numscheckbox
handles.shownums = get(hObject, 'Value');
guidata(hObject, handles);


% --- Executes on button press in DM_button.
function DM_button_Callback(hObject, eventdata, handles)
% hObject    handle to DM_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
t = handles.t;
e = handles.epsilon;
D = handles.Data;
neigen = 6;

colors = {'blue', 'red', 'black', 'green', 'yellow', 'cyan', 'magenta'};
signs = {'o', '+', 'x', '*', 'x', 'd', 'h'};

if handles.loaded == 1
    groups_acc = cumsum(handles.group_lengths);
    [X, ~, ~, ~] = diffuse(D,e,neigen,t);
    
    axes(handles.axes1);
    if handles.dim == 2
        for k = 1:groups_acc(end);
            group = find ( groups_acc >= k, 1);
            plot(X(k,1), X(k,2),signs{group},'color',colors{group}); hold on;
            if handles.shownums == 1
                text(X(k,1), X(k,2),num2str(k),'HorizontalAlignment','right');
            end
        end
    else
        for k = 1:groups_acc(end);
            group = find ( groups_acc >= k, 1);
            scatter3(X(k,1), X(k,2),X(k,3),signs{group},'MarkerEdgeColor', colors{group}); hold on;
            if handles.shownums == 1
                text(X(k,1), X(k,2),num2str(k),'HorizontalAlignment','right');
            end
        end
    end
    
    x_min = min(X(:,1)) ; x_max = max(X(:,1)) ; y_min = min(X(:,2)) ; y_max = max(X(:,2)) ; z_min = min(X(:,3)) ; z_max = max(X(:,3)) ;
  	axis([1.1*x_min, 1.1*x_max, 1.1*y_min, 1.1*y_max, 1.1*z_min, 1.1*z_max]) ; 
    title(['t = ' num2str(t) ', \epsilon = ' num2str(e)]);
end
