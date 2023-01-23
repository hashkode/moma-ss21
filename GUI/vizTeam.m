function vizTeam(obj)
% VIZTEAM  visualize the partition of recorded data
%   based on the time period of all data files and the
%   team members

%% Plot the 3D pie-chart and label it correspondingly
lampColor = obj.DatanotimportedLamp.Color(1);
if ~lampColor
    cla(obj.UIAxes,'reset')
    b = bar(obj.UIAxes,categorical(obj.TeamMembers),obj.VizDataTeam);
    xlabel(obj.UIAxes,'Team member');
    ylabel(obj.UIAxes,'Total seconds (s)');
    labels = {'Normal','Silly'};
    title(obj.UIAxes, 'Distribution of the of recorded data per team member')
    legend(obj.UIAxes,labels, 'Location','northeast','FontSize',12);
end
end