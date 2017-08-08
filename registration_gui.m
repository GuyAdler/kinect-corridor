function varargout = registration_gui(varargin)
% REGISTRATION_GUI MATLAB code for registration_gui.fig
%      REGISTRATION_GUI, by itself, creates a new REGISTRATION_GUI or raises the existing
%      singleton*.
%
%      H = REGISTRATION_GUI returns the handle to a new REGISTRATION_GUI or the handle to
%      the existing singleton*.
%
%      REGISTRATION_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in REGISTRATION_GUI.M with the given input arguments.
%
%      REGISTRATION_GUI('Property','Value',...) creates a new REGISTRATION_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before registration_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to registration_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help registration_gui

% Last Modified by GUIDE v2.5 13-Mar-2017 17:54:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @registration_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @registration_gui_OutputFcn, ...
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


% --- Executes just before registration_gui is made visible.
function registration_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to registration_gui (see VARARGIN)

% Choose default command line output for registration_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes registration_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = registration_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function kinectnum_Callback(hObject, eventdata, handles)
% hObject    handle to kinectnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of kinectnum as text
%        str2double(get(hObject,'String')) returns contents of kinectnum as a double


% --- Executes during object creation, after setting all properties.
function kinectnum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to kinectnum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonLoad.
function buttonLoad_Callback(hObject, eventdata, handles)
      KinectText = findobj('Tag', 'kinectnum');
      NumOfKinects = str2double(KinectText.String);
      handles.original_pcds = [];
      for i = 1:NumOfKinects
          [filename, dirname] = uigetfile({'*.pcd'});
          data = loadpcd(strcat(dirname, filename)) ; 
          handles.original_pcds{i} = pointCloud(data(1:3,:)','Color',data(4:6,:)');
      end
      Loaded = findobj('Tag', 'frames_loaded');
      Loaded.String = [num2str(NumOfKinects) ' frames loaded'];
      guidata(hObject, handles);


function frames_loaded_Callback(hObject, eventdata, handles)
% hObject    handle to frames_loaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of frames_loaded as text
%        str2double(get(hObject,'String')) returns contents of frames_loaded as a double


% --- Executes during object creation, after setting all properties.
function frames_loaded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frames_loaded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonDispFrame.
function buttonDispFrame_Callback(hObject, eventdata, handles)
    DispNumObj = findobj('Tag', 'DispFrame');
    DispNum = str2double(DispNumObj.String);
    figure_title = ['Camera ' num2str(DispNum) ' pre transformation'];
    handles.current_data = handles.original_pcds{DispNum};
    figure; pcshow(handles.current_data); title(figure_title); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 
    guidata(hObject, handles);


function DispFrame_Callback(hObject, eventdata, handles)
% hObject    handle to DispFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DispFrame as text
%        str2double(get(hObject,'String')) returns contents of DispFrame as a double


% --- Executes during object creation, after setting all properties.
function DispFrame_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DispFrame (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in buttonRegister.
function buttonRegister_Callback(hObject, eventdata, handles)
    [handles.merged_pcd, handles.tforms] = transformation_var(handles.original_pcds, 2, affine3d([ 1 0 0 0; 0 1 0 0; 0 0 1 0 ; 0 0.76 0.9 1]));
    guidata(hObject, handles);


% --- Executes on button press in buttonDispRegist.
function buttonDispRegist_Callback(hObject, eventdata, handles)
    figure_title = ['Merged Point Clouds'];
    handles.current_data = handles.merged_pcd;
    figure; pcshow(handles.current_data); title(figure_title); xlabel('x[m]'); ylabel('y[m]'); zlabel('z[m]'); 
    guidata(hObject, handles);


% --- Executes on mouse press over axes background.
function PCLdisp_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to PCLdisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in buttonSave.
function buttonSave_Callback(hObject, eventdata, handles)
    tforms = handles.tforms;
    save('tforms.mat', 'tforms');