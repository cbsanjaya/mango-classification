function varargout = app(varargin)
% APP MATLAB code for app.fig
%      APP, by itself, creates a new APP or raises the existing
%      singleton*.
%
%      H = APP returns the handle to a new APP or the handle to
%      the existing singleton*.
%
%      APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in APP.M with the given input arguments.
%
%      APP('Property','Value',...) creates a new APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before app_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to app_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help app

% Last Modified by GUIDE v2.5 19-Sep-2018 01:57:19

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @app_OpeningFcn, ...
                   'gui_OutputFcn',  @app_OutputFcn, ...
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


% --- Executes just before app is made visible.
function app_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to app (see VARARGIN)

% Choose default command line output for app
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
movegui(hObject,'center');

% UIWAIT makes app wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = app_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in PbLoad.
function PbLoad_Callback(hObject, eventdata, handles)
% hObject    handle to PbLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename,pathname] = uigetfile('*.jpg');

if ~isequal(filename,0)
    Img = imread(fullfile(pathname,filename));
    axes(handles.AxMango);
    imshow(Img);
    title(strcat('Mango Image: ', filename));
    set(handles.PbCheck, 'Enable', 'on');
    set(handles.TxResult, 'String', 'Undefined');
else
    return
end

handles.Img = Img;
guidata(hObject, handles)


% --- Executes on button press in PbCheck.
function PbCheck_Callback(hObject, eventdata, handles)
% hObject    handle to PbCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Img = handles.Img;
ciri_image = GetCiri(Img);

% add lssvm to path
lssvmPath = strcat(pwd, '\lssvm');
addpath(lssvmPath);

% type of lssvm is classification
type = 'classification';

% load data_training
load('data_training.mat');

% L_fold = 10;
% [gam,sig2] = tunelssvm({ciri_database, ciri_mapping, type, [], [], 'RBF_kernel'}, 'simplex', 'crossvalidatelssvm', {L_fold, 'misclass'});
gam = 355.9552;
sig2 = 12.06779;

% [alpha,b] = trainlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'});
model = trainlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'});

% test image
% image_result = simlssvm({ciri_database, ciri_mapping, type, gam, sig2, 'RBF_kernel'}, {alpha, b}, ciri_image);
image_result = simlssvm(model, ciri_image);

if image_result == 1
    result = 'MATURE';
else
    result = 'RAW';
end

set(handles.TxResult, 'String', result);

function ciri = GetCiri(Img)
% Color-Based Segmentation Using K-Means Clustering
cform = makecform('srgb2lab');
lab = applycform(Img,cform);

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);

nColors = 2;
[cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
    'Replicates',3);

pixel_labels = reshape(cluster_idx,nrows,ncols);

segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);

for k = 1:nColors
    color = Img;
    color(rgb_label ~= k) = 0;
    segmented_images{k} = color;
end

area_cluster1 = sum(find(pixel_labels==1));
area_cluster2 = sum(find(pixel_labels==2));

[~,cluster_min] = min([area_cluster1,area_cluster2]);

Img_bw = (pixel_labels==cluster_min);
Img_bw = imfill(Img_bw,'holes');
Img_bw = bwareaopen(Img_bw,50);

stats = regionprops(Img_bw,'Area','Perimeter','Eccentricity');
area = stats.Area;
perimeter = stats.Perimeter;
metric = 4*pi*area/(perimeter^2);
eccentricity = stats.Eccentricity;

Img_gray = rgb2gray(Img);
Img_gray(~Img_bw) = 0;

pixel_dist = 1;
GLCM = graycomatrix(Img_gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
Contrast = mean(stats.Contrast);
Correlation = mean(stats.Correlation);
Energy = mean(stats.Energy);
Homogeneity = mean(stats.Homogeneity);

ciri = [metric,eccentricity,Contrast,Correlation,Energy,Homogeneity];
