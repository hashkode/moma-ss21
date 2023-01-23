% *** PREPARE ENVIRONMENT ***
% Determine computer type to update path

%% update path variable
sysType = computer();

switch sysType
    case 'PCWIN64'
        disp("PCWIN64")        
        updatePath();
    case 'MACI64'
        disp("MACI64")
        updatePath();
    case 'GLNXA64'
        disp("GLNXA64")
        updatePath();
    otherwise
        disp("unknown computer type")        
end

function updatePath()
    addpath(genpath(pwd));
end