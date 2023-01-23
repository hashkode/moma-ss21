function vizFiles(obj)
% Callback function to visualize captured data distribution in GUI
lampColor = obj.DatanotimportedLamp.Color(1);
if ~lampColor
h = pie3(obj.UIAxes,obj.VizData,[1 1 1]);
labels = obj.VizCategories;
legend(obj.UIAxes,labels, 'Location','south','FontSize',12);
title(obj.UIAxes, 'Distribution of the number of recorded files')

end
end