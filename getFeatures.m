function Features = getFeatures(X, featureType, ifSort, ifParFor)
% GETFEATURES
% This function extracts features from given input data X.
% Second Input: featureType
% 'default' for standard features (81): SE + AR + WV + Mean + STD
% 'extended' for extended features (87: default + WL
% 'superextended' for all possible features (102): extended + skew + rms
%                                                  + max + mad + min
% 'minor' for smaller feature vector: SE + AR + WV
%
% Third Input: ifSort (bool)
%  true: sort axes by magnitude of mean
%  false: leave axes unchanged
%
% Fourth Input: ifParFor (bool)
%  true: use parfor instead of for-loop
%  false: use default for-loop
%  Execution by setting number of workers for parfor loop
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Features per Dimension:
% (16): Shannon entropy (SE) values for the maximal overlap discrete wavelet
%               packet transform (MODPWT) at level 4 (default)
% (4): Autoregressive model (AR) coefficients of order 4 (default)
% (5): Wavelet Variance: Wavelet variance measures variability in a signal by
%                   scale or equivalently variability in a signal over
%                   octave-band frequency intervals (default)
% (2): Multifractal wavelet leader estimates of the second cumulant of
%                   the scaling exponents and the range of Holder
%                   exponents, or singularity spectrum
% (1): Mean (default)
% (1): Standard Deviation (default)
% (1): Skewness
% (1): Root Mean Square
% (1): Median Absolute Value
% (1): Maximum Value
% (1): Minimum Value
% => 34 features per dimension (default: 27)
% 102 total featurs per sample (default: 81)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%
if ifParFor
    parforArg = Inf; % use parallel for-loop -> maximum amount of parallel workers
else
    parforArg = 0; % use default for-loop
end

% Reorder Data for X/Y/Z-Dimension
[n,~] = size(X);
m = size(X{1,1},2);
acceleration_x = zeros(n,m); % speeds up process
acceleration_y = zeros(n,m);
acceleration_z = zeros(n,m);

% Normalize data matrix
if ifSort
    for i = 1:n
        acc{1} = normalize(X{i}(1,:));
        acc{2} = normalize(X{i}(2,:));
        acc{3} = normalize(X{i}(3,:));
        
        meanAccX = abs(mean(acc{1}, 'all'));
        meanAccY = abs(mean(acc{2}, 'all'));
        meanAccZ = abs(mean(acc{3}, 'all'));
        
        % sort axes by magnitude of mean value if selected
        [~, sorting] = sort([meanAccX, meanAccY, meanAccZ]);
        acceleration_x(i,:) = acc{sorting(1)};
        acceleration_y(i,:) = acc{sorting(2)};
        acceleration_z(i,:) = acc{sorting(3)};
    end
else
    % Assign values according to x/y/z-dimension
    parfor (i = 1:n,parforArg)
        acceleration_x(i,:) = normalize(X{i}(1,:));
        acceleration_y(i,:) = normalize(X{i}(1,:));
        acceleration_z(i,:) = normalize(X{i}(1,:));
    end
end

timeWindow = m; % Number of samples per dimension
ARorder = 4; % Autoregressive model (AR) coefficients of order 4
MODWPTlevel = 4; % Shannon entropy (SE) values for the maximal overlap discrete wavelet packet transform (MODPWT) at level 4

% x-dimension
Features_x = ...
    helperExtractFeatures(acceleration_x,...
    timeWindow,ARorder,MODWPTlevel,featureType,parforArg);

% y-dimension
Features_y = ...
    helperExtractFeatures(acceleration_y,...
    timeWindow,ARorder,MODWPTlevel,featureType,parforArg);

% z-dimension
Features_z = ...
    helperExtractFeatures(acceleration_z,...
    timeWindow,ARorder,MODWPTlevel,featureType,parforArg);

% Put all feature vectors together
Features = [Features_x,Features_y,Features_z];
end

% local function to extract actual features
function trainFeatures = helperExtractFeatures(trainData,T,AR_order,level,featureType,parforArg)
n = size(trainData,1); % Number of samples

% Create empty matrices according to desired feature matrix size
switch featureType
    case 'default'
        trainFeatures = zeros(n,27); % 27 + 27 + 27 = 81 Features
    case 'extended'
        trainFeatures = zeros(n,29); % 29 + 29 + 29 = 87 Features
    case 'superextended'
        trainFeatures = zeros(n,34); % 34 + 34 + 34 = 102 Features
    case 'minor'
        trainFeatures = zeros(n,25); % 25 + 25 + 25 = 75 Features
    otherwise
        disp("unknown feature type in getFeatures Input")
end

parfor (idx =1:n,parforArg)
    x = trainData(idx,:);
    x_leader = interp(x,2); % increase number of samples by factor 2
    % to make data suitable for leaders()
    x = detrend(x,0);
    x_leader = detrend(x_leader,0);
    
    arcoefs = blockAR(x,AR_order,T);                % AR model coefficients
    se = shannonEntropy(x,T,level);                 % Shannon Entropy
    [cp,rh] = leaders(x_leader,T*2);                % Wavelet Leader
    wvar = modwtvar(modwt(x,'db2'),'db2');          % Wavelet Variance
    mean_acc = mean(x);                             % Mean Value
    std_acc = std(x);                               % Standard Deviation
    skew_acc = skewness(x);                         % Skewness
    rms_acc = rms(x);                               % Root mean square
    mad_acc = mad(x);                               % Median Absolute Value
    max_acc = max(x);                               % Maximum Value
    min_acc = min(x);                               % Minimum Value
    
    % Assign values according to feature Type
    switch featureType
        case 'default'
            trainFeatures(idx,:) = [se(1:16) arcoefs(1:4) ...
                wvar(1:5)' mean_acc std_acc]; % 27  Features per Dimension
        case 'extended'
            trainFeatures(idx,:) = [se(1:16) arcoefs(1:4) cp rh...
                wvar(1:5)' mean_acc std_acc]; % 29 Features per Dimension
        case 'superextended'
            trainFeatures(idx,:) = [se(1:16) arcoefs(1:4) cp rh...
                wvar(1:5)' mean_acc std_acc skew_acc rms_acc...
                mad_acc max_acc min_acc]; % 34 Features per Dimension
        case 'minor'
            trainFeatures(idx,:) = [se(1:16) arcoefs(1:4) wvar(1:5)'];
            % 25 Features per Dimension
        otherwise
            disp("unknown feature type in getFeatures Input")
    end
end
end


% *** Helper Function ***
% Shannon Entropy
function se = shannonEntropy(x,numbuffer,level)
numwindows = numel(x)/numbuffer;
y = buffer(x,numbuffer);
se = zeros(2^level,size(y,2));
for kk = 1:size(y,2)
    wpt = modwpt(y(:,kk),level);
    % Sum across time
    E = sum(wpt.^2,2);
    Pij = wpt.^2./E;
    % The following is eps(1)
    se(:,kk) = -sum(Pij.*log(Pij+eps),2);
end
se = reshape(se,2^level*numwindows,1);
se = se';
end

% *** Helper Function ***
% Autoregressive Model
function arcfs = blockAR(x,order,numbuffer)
numwindows = numel(x)/numbuffer;
y = buffer(x,numbuffer);
arcfs = zeros(order,size(y,2));
for kk = 1:size(y,2)
    artmp =  arburg(y(:,kk),order);
    arcfs(:,kk) = artmp(2:end);
end
arcfs = reshape(arcfs,order*numwindows,1);
arcfs = arcfs';
end

% *** Helper Function ***
% Wavelet Leader Estimation
function [cp,rh] = leaders(x,numbuffer)
y = buffer(x,numbuffer);
cp = zeros(1,size(y,2));
rh = zeros(1,size(y,2));
for kk = 1:size(y,2)
    [~,h,cptmp] = dwtleader(y(:,kk));
    cp(kk) = cptmp(2);
    rh(kk) = range(h);
end
end
