function varargout = papsmear(varargin)
% PAPSMEAR MATLAB code for papsmear.fig
%      PAPSMEAR, by itself, creates a new PAPSMEAR or raises the existing
%      singleton*.
%
%      H = PAPSMEAR returns the handle to a new PAPSMEAR or the handle to
%      the existing singleton*.
%
%      PAPSMEAR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PAPSMEAR.M with the given input arguments.
%
%      PAPSMEAR('Property','Value',...) creates a new PAPSMEAR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before papsmear_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to papsmear_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help papsmear

% Last Modified by GUIDE v2.5 10-May-2018 20:41:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @papsmear_OpeningFcn, ...
                   'gui_OutputFcn',  @papsmear_OutputFcn, ...
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


% --- Executes just before papsmear is made visible.
function papsmear_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to papsmear (see VARARGIN)

% Choose default command line output for papsmear
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes papsmear wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = papsmear_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I;
[nama_file, nama_path] = uigetfile('*.bmp','Pilih gambar');
if ~isequal (nama_file,0)
    img = imread(fullfile(nama_path,nama_file));
    I = imresize(img, [200 NaN]);
    guidata(hObject,handles);
    axes(handles.axes2);
    imshow(I)
else
    return;
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global I
global M
H = histeq(I);
M = imgaussfilt3(H);
guidata(hObject,handles);
axes(handles.axes3);
imshow(M)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global M
global BW
global I

cform = makecform('srgb2lab');
lab_M = applycform(M,cform);
nColorsSmear = 3;

ab_smear = double(lab_M(:,:,2:3));
smear_rows = size(ab_smear, 1);
smear_cols = size(ab_smear, 2);
ab_smear = reshape(ab_smear,smear_rows*smear_cols, 2);

[cluster_idx, cluster_center] = kmeans(ab_smear, nColorsSmear, 'distance', 'sqEuclidean', 'Replicates', 3);
pixel_labels = reshape(cluster_idx, smear_rows, smear_cols);

segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1,1,3]);

for k = 1:nColorsSmear
    colors = lab_M; %I;
    colors(rgb_label ~= k) = 0;
    segmented_images{k} = colors;
%     figure, imshow(segmented_images{k});title(['Segmentasi Nukleus : Cluster ', num2str(k)], 'FontName','Calibri','FontSize',14,'FontWeight','bold');
end

nilai_rata_cluster = mean(cluster_center,2);
[tmp, idx] = sort(nilai_rata_cluster);
cluster_smear = idx(1);

L = M(:,:,1);
smear_idx = find(pixel_labels == cluster_smear);
L_smear = L(smear_idx);
segment_smear = imbinarize(L_smear);

smear_labels = repmat(uint8(0),[smear_rows smear_cols]);
smear_labels(smear_idx(segment_smear==false)) = 1;
smear_labels = repmat(smear_labels,[1 1 3]);
nukleus_smear = I;
nukleus_smear(smear_labels ~= 1) = 0;
% figure, imshow(nukleus_smear), title('Hasil Segmentasi K-Means', 'FontName','Calibri','FontSize',14,'FontWeight','bold');

% POST-PROCESSING
BW = rgb2gray(nukleus_smear);
BW = im2bw(BW, graythresh(BW));
BW = imfill(BW, 'holes');
BW = imclearborder(BW);
BW = bwmorph(BW,'erode',1);
BW = bwareaopen(BW, 100);

guidata(hObject,handles);
axes(handles.axes4);
imshow(BW)

% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global smearTest

load classifier.mat

predictedLabels = predict(classifier, smearTest);
hasil = sprintf('Sel %s', predictedLabels);
set(handles.edit1,'String',hasil);

% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global BW
global smearTest
global I

[B,L] = bwboundaries(BW,'noholes');
stats = regionprops(L,'BoundingBox','Centroid','Area','Perimeter','Eccentricity');
hold on ;

[m,n] = size(I);
for k=1:length(B)
    boundary = B{k};
    Area = (stats(k).Area)/(m*n);
    Perimeter = (stats(k).Perimeter)/(2*(m+n));
    Eccentricity = stats(k).Eccentricity;
    Metric = 4*pi*Area/Perimeter^2;
end
data2 = cell(4,2);
data2{1,1} = 'Area';
data2{2,1} = 'Perimeter';
data2{3,1} = 'Eccentricity';
data2{4,1} = 'Metric';
data2{1,2} = Area;
data2{2,2} = Perimeter;
data2{3,2} = Eccentricity;
data2{4,2} = Metric;
    
set(handles.uitable3,'Data',data2,'ForegroundColor',[0 0 0])

% PEMBENTUKAN DATA UJI
smearTest(1) = Area;
smearTest(2) = Perimeter;
smearTest(3) = Metric;
smearTest(4) = Eccentricity;

handles.smearTest = smearTest;
guidata(hObject, handles)

set(handles.edit1,'String','')

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
axes(handles.axes2)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes3)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

axes(handles.axes4)
cla reset
set(gca,'XTick',[])
set(gca,'YTick',[])

set(handles.uitable3,'Data',[])
set(handles.edit1,'String','')


% --- Executes when entered data in editable cell(s) in uitable3.
function uitable3_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to uitable3 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
