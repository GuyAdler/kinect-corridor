function varargout = play_gui(varargin)
% PLAY_GUI MATLAB code for play_gui.fig
%      PLAY_GUI, by itself, creates a new PLAY_GUI or raises the existing
%      singleton*.
%
%      H = PLAY_GUI returns the handle to a new PLAY_GUI or the handle to
%      the existing singleton*.
%
%      PLAY_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PLAY_GUI.M with the given input arguments.
%
%      PLAY_GUI('Property','Value',...) creates a new PLAY_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before play_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to play_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help play_gui

% Last Modified by GUIDE v2.5 14-May-2017 14:05:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @play_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @play_gui_OutputFcn, ...
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

% --- Executes just before play_gui is made visible.
function play_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to play_gui (see VARARGIN)

% Choose default command line output for play_gui
handles.output = hObject;

[a,~]=imread('pauseplay.jpg');
[r,c,~]=size(a); 
x=ceil(r/30); 
y=ceil(c/30); 
g=a(1:x:end,1:y:end,:);
g(g==255)=5.5*255;
set(handles.pauseplay,'CData',g);

handles.video_loaded = 0;
handles.video_playing = 0;
handles.az = 0;
handles.el = 90;
handles.play_start = 1;
handles.frame = 1;

play_timer = timer('Name', 'play_timer', 'TimerFcn', {@play_walking,gcf},...
    'StartDelay',0.05,'ExecutionMode', 'fixedSpacing', 'Period', 0.05);

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes play_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = play_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pauseplay.
function pauseplay_Callback(hObject, eventdata, handles)

if (handles.video_loaded)
    handles.video_playing = 1 - handles.video_playing;
end

guidata(hObject, handles);

% --- Executes on button press in loadvideo.
function loadvideo_Callback(hObject, eventdata, handles)
% hObject    handle to loadvideo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

foldername = uigetdir;
handles.walking = LoadAndTransformVideo(foldername);
set(handles.loaded_text, 'String', foldername);
handles.video_loaded = 1;
handles.video_playing = 0;
% handles.pcplayer = pcplayer([(min(min(handles.walking(:,:,1)))-0.5) (max(max(handles.walking(:,:,1)))+0.5)],...
%                   [(min(min(handles.walking(:,:,2)))-0.5) (max(max(handles.walking(:,:,2)))+0.5)],...
%                   [(min(min(handles.walking(:,:,3)))-0.5) (max(max(handles.walking(:,:,3)))+0.5)], 'MarkerSize', 100);
% set(handles.pcplayer, 'Axes', handles.videofigure);

play_timer = timerfind('Name', 'play_timer');
start(play_timer);

guidata(hObject, handles);

%%%%%%
function [] = play_walking(hObject, eventdata, fignum)
handles = guidata(fignum);
str = get(handles.video_type,'String');
val = get(handles.video_type,'Value');

if strcmp(str{val} , 'scatter3')
    play_walking_scatter(hObject, eventdata, fignum);
elseif strcmp(str{val} , 'pcplayer')
    play_walking_pcplayer(hObject, eventdata, fignum);
end

function [] = play_walking_scatter(hObject, eventdata, fignum)
handles = guidata(fignum);
if ~isempty(handles)
    walking = handles.walking;
    play_end = size(walking,1)+1 ;
    i = handles.frame;

    if(handles.video_playing)
        axes(handles.videofigure);
        skel = connect_skeleton(squeeze(walking(i,1:25,:)) );
        scatter3(handles.videofigure,skel(:,1),skel(:,2),skel(:,3), 36, [repmat([0 50 255], 25,1);repmat([0 0 125],190,1)]);
        xlim(handles.videofigure,[(min(min(walking(:,:,1)))-1) (max(max(walking(:,:,1)))+1)]);
        ylim(handles.videofigure,[(min(min(walking(:,:,2)))-1) (max(max(walking(:,:,2)))+1)]);
        zlim(handles.videofigure,[(min(min(walking(:,:,3)))-1) (max(max(walking(:,:,3)))+1)]);
    
        view(handles.videofigure,[handles.az handles.el])
    
        i = i + 1;
        if i == play_end
            i = handles.play_start;
        end
    end

    handles.frame = i;
    guidata(fignum, handles);
end

function [] = play_walking_pcplayer(hObject, eventdata, fignum)
handles = guidata(fignum);
if ~isempty(handles)
    walking = handles.walking;
    play_end = size(walking,1)+1 ;
    i = handles.frame;

    if(handles.video_playing)
        skel = connect_skeleton(squeeze(walking(i,1:25,:)) );
        ptCloud = pointCloud(skel,'Color',[repmat([0 50 255], 25,1);repmat([0 0 125],190,1)]);
        pcshow(ptCloud, 'Parent', handles.videofigure);

        i = i + 1;
        if i == play_end
            i = handles.play_start;
        end
    end
    
    handles.frame = i;
    guidata(fignum, handles);

end


% --- Executes during object deletion, before destroying properties.
function figure1_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
playtimer = timerfind('Name', 'play_timer');
stop(playtimer);
delete(playtimer);


% --- Executes on slider movement.
function az_slider_Callback(hObject, eventdata, handles)
% hObject    handle to az_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.az = handles.az_slider.Value;
set(handles.az_text, 'String', strcat('az = ', num2str(handles.az)));
guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function az_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to az_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function el_slider_Callback(hObject, eventdata, handles)
% hObject    handle to el_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.el = handles.el_slider.Value;
set(handles.el_text, 'String', strcat('el = ', num2str(handles.el)));
guidata(hObject, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function el_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to el_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in video_type.
function video_type_Callback(hObject, eventdata, handles)
% hObject    handle to video_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns video_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from video_type
delay_slider_CreateFcn

function delay_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns video_type contents as cell array
%        contents{get(hObject,'Value')} returns selected item from video_type

function delay_slider_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function video_type_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_type (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'scatter3', 'pcplayer'});
