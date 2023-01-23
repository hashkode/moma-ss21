function loadModels(paths,obj)
% Callback function to load trained models from given input path

obj.ModelDropDown.Items = {'-','Final'};
names = {};
folders = {};
for i=1:length(paths)
    path = paths{i};
    f = fullfile(path,'*.mat');
    list = dir(f);
    names = [names {list.name}];
    folders = [folders {list.folder}];
end
obj.ModelDropDown.Items = [obj.ModelDropDown.Items,names];
obj.Models = containers.Map(names,folders);
end