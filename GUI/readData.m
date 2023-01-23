function readData(obj)
% Callback function to import raw data into the GUI and use it for training
% purposes

%% Get the Path of the data collected
d = uiprogressdlg(obj.UIFigure,'Title','Reading raw data...',...
    'Indeterminate','on');

path = uigetdir;
figure(obj.UIFigure);
if ~path
    return
else
    obj.RawDataURL = path;
    obj.SplitButton.Enable = 'on';
    obj.SplitLabel.Text = 'Split not accomplished!';
    obj.DataSplit = false;
    obj.TrainingLabel.Visible = 'on';
    trainModelDropdownCb(obj);
end
f = fullfile(path,'Group*.mat');
list = dir(f);

%% Get a list of the used types of walks and their frequency
categories = {'Normal Walk', 'Silly Walk: Video','Silly Walk: Personal'};

% Array for the total number of seconds for each type of walk
dataTimes = containers.Map(categories,[0 0 0]);

% Array for the total number of walks for each type of walk
dataCount = containers.Map(categories,[0 0 0]);

% Array for the total number of files for each type of walk
data = containers.Map(categories,[0 0 0]);

% Array for the team members and their recorded walks
team = [1, 2, 3, 4];
teamNames = {'Alex. S','Tobias. H','Rayene. M','Tobias. K'};
dataTeam = containers.Map(team, {[0 0], [0 0], [0 0], [0 0]}); % Arrays in form [#Normal, #Silly]
filenames = {'-'};
for i=1:length(list)
    res = split(list(i).name,'_');
    if length(res) == 3
        % Get the id of the walk
        id = split(res(2),'Walk');
        id = str2double(id{2});
        batchId = rem(id,100);
        
        % Get Team member id
        teamId = fix((id-1)/100)+1;
        % Fix for raw data files with index > 400
        if teamId > 4
            teamId = teamId - 4;
        end
        
        % Get the duration of the walk
        [data_cut,time] = cutData(fullfile(path,list(i).name));
        matFileContent.time = time;
        matFileContent.data = data_cut;
        [X_sample,Y_sample] = extractData(matFileContent,list(i).name,...
            obj.TrainingFrequency.Value, obj.WindowLength.Value);
        numberOfWalks = length(X_sample);
        sec = time(end);
         
        % Determine the type of walk in file
        if (1<=batchId) && (batchId<=40)
            category = categories{1};
        elseif  (41<=batchId) && (batchId<=60)
            category = categories{2};
        else
            category = categories{3}; 
        end
        
        data(category) = data(category) + 1; 
        dataTimes(category) = dataTimes(category) + sec;
        dataCount(category) = dataCount(category) + numberOfWalks;
        
        % Fill the time period arrays of each team member
        walks = dataTeam(team(teamId));
        if (strcmp(category, categories{1}))
            walks(1) = walks(1) + sec;
        else
            walks(2) = walks(2) + sec;
        end
        dataTeam(team(teamId)) = walks;
        
        % Fill drop-down menu 
        filenames{end+1} = list(i).name;
%         obj.DropDown.Item{end+1} = list(i).name;
    end
    
end

%% Assign the data to the View
samples = sum(cell2mat(values(data)));
totalWalks = sum(cell2mat(values(dataCount)));
obj.VizCategories = categories;
obj.TeamMembers = teamNames(team); 
teamResults = values(dataTeam);
teamResults = [teamResults{:}];
obj.VizDataTeam = reshape(teamResults,2,4)';

% Fill drop-down menu
obj.DropDown.Items = filenames;

if samples
    obj.VizData = cell2mat(values(data))./samples*100;
%     obj.VizDataSeconds = cell2mat(values(dataTimes))./samples*100;
    obj.VizDataSeconds = cell2mat(values(dataCount))./totalWalks*100;
    obj.DatanotimportedLamp.Color = [0 1 0];
    obj.DatanotimportedLampLabel.Text = 'Data imported';
else
    obj.VizData = [];
    obj.VizDataSeconds = [];
    obj.DatanotimportedLamp.Color = [1 0 0];
    obj.DatanotimportedLampLabel.Text = 'No data found';
    obj.SplitButton.Enable = 'off';
    obj.SplitLabel.Text = 'No data read!';
    obj.DataSplit = false;
    obj.TrainingLabel.Visible = 'on';
    trainModelDropdownCb(obj);
end
if isvalid(obj.UIAxes)
    cla(obj.UIAxes,'reset');
    obj.UIAxes.Visible = 'off';
end

%% Load available models
loadModels({fullfile(obj.MainPath,'Models','70'),...
    fullfile(obj.MainPath,'Models')},obj);

end