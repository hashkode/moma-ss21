function vizSeconds(obj)
% VIZSECONDS  visualize the partition of recorded data
%   based on the time period of all data files

%% Plot the 3D pie-chart and label it correspondingly
lampColor = obj.DatanotimportedLamp.Color(1);
if ~lampColor
    h = pie3(obj.UIAxes,obj.VizDataSeconds,[1 1 1]);
    labels = obj.VizCategories;
    legend(obj.UIAxes,labels, 'Location','south','FontSize',12);
    title(obj.UIAxes, 'Distribution of the extracted walks')
    
end
end