classdef View < handle

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure;
        FileMenu                  matlab.ui.container.Menu;
        ImportMenu                    matlab.ui.container.Menu
        ExitMenu                      matlab.ui.container.Menu
        EditMenu                      matlab.ui.container.Menu
        ClearMenu                     matlab.ui.container.Menu
        Toolbar                   matlab.ui.container.Toolbar;
        ImportPushTool            matlab.ui.container.toolbar.PushTool;
        ClearPushTool            matlab.ui.container.toolbar.PushTool;
        TabGroup                  matlab.ui.container.TabGroup;
        DataVizualizerTab         matlab.ui.container.Tab;
        DistributionPanel         matlab.ui.container.Panel;
        UIAxes                    matlab.ui.control.UIAxes;
        ImportDataPanel           matlab.ui.container.Panel;
        ImportButton              matlab.ui.control.Button;
        DatanotimportedLampLabel  matlab.ui.control.Label;
        DatanotimportedLamp       matlab.ui.control.Lamp;
        SplitterTab                matlab.ui.container.Tab;
        DataVisiualizationPanel       matlab.ui.container.Panel
        NumberofsavedfilesButton      matlab.ui.control.Button
        LengthofrecordeddataButton    matlab.ui.control.Button
        CollecteddataperpersonButton  matlab.ui.control.Button
        DropDown                      matlab.ui.control.DropDown
        DropDownLabel                 matlab.ui.control.Label
        PlotTypeSwitchLabel           matlab.ui.control.Label
        PlotTypeSwitch                matlab.ui.control.Switch
        TrainParameters         matlab.ui.container.Panel
        SplitParameters         matlab.ui.container.Panel
        SplitRatioSliderLabel         matlab.ui.control.Label
        SplitRatioSlider              matlab.ui.control.Slider
        EditField                     matlab.ui.control.NumericEditField
        SplitButton                   matlab.ui.control.Button
        SplitLabel        matlab.ui.control.Label
        TrainandClassifyTab           matlab.ui.container.Tab
        ModelPanel            matlab.ui.container.Panel
        VisualizationPanel            matlab.ui.container.Panel
        UIAxes_Train                      matlab.ui.control.UIAxes
        ErrorPanel                    matlab.ui.container.Panel
        TrainButton                 matlab.ui.control.Button
        ModelDropDownLabel          matlab.ui.control.Label
        ModelDropDown               matlab.ui.control.DropDown
        ConfusionMatrixButton         matlab.ui.control.Button
        ErrorCurvesButton             matlab.ui.control.Button
        EffeciencyButton              matlab.ui.control.Button
        ClassifyPanel                 matlab.ui.container.Panel
        ImportFileButton              matlab.ui.control.Button
        ClassifyButton                matlab.ui.control.Button
        ExtractDataLabel              matlab.ui.control.Label
        TrainingFrequency              matlab.ui.control.NumericEditField
        WindowLength                    matlab.ui.control.NumericEditField
        WindowLengthLabel                matlab.ui.control.Label
        ModelDropDownTrainLabel     matlab.ui.control.Label
        ModelDropDownTrain             matlab.ui.control.DropDown
        TrainingButton                  matlab.ui.control.Button
        TestDropDown                    matlab.ui.control.DropDown
        TestDropDownLabel               matlab.ui.control.Label
        TrainingLabel                   matlab.ui.control.Label
        KnobLabel                     matlab.ui.control.Label
        Knob                          matlab.ui.control.DiscreteKnob
        RefreshButton                   matlab.ui.control.Button
        AccuracyLabel                   matlab.ui.control.Label
        BalancedAccuracyLabel           matlab.ui.control.Label
        ClassifyDropDown             matlab.ui.control.DropDown
        ConfusionTestButton                   matlab.ui.control.Button
    end
    
    properties (SetObservable, AbortSet)
        VizCategories = {};
        VizData = [];
        VizDataSeconds = [];
        VizDataTeam;
        TeamMembers;
        RawDataURL;
        ClassificationModel;
        ToClassifyName;
        ToClassifyData;
        TrainingModel;
        ErrorData = {};
        DataSplit = false;
        MainPath = fullfile(fileparts(mfilename('fullpath')),'..');
        ConfMatrix;
        ConfChart;
        YTest;
        YPred;
        XTest;
        Model='';
        Models;
        ClassificationPath;
        YTestUnseen;
        YPredUnseen;
        XTestUnseen;
        ModelPath;
        BalancedAccuracy;
        Accuracy;
        BalancedAccuracyUnseen;
        AccuracyUnseen;
        UnseenSize;
        TrainingParameters;
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function setupLayout(app)            
            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off','Renderer','opengl');
            app.UIFigure.Position = [100 100 800 600];
            app.UIFigure.Name = 'Normal/Silly walk interface';
            app.UIFigure.Resize = 'off';
            
            % Create FileMenu
            app.FileMenu = uimenu(app.UIFigure);
            app.FileMenu.Tooltip = {'File menu'};
            app.FileMenu.Text = 'File';
            
            % Create ImportMenu
            app.ImportMenu = uimenu(app.FileMenu);
            app.ImportMenu.Text = 'Import';
            app.ImportMenu.Tooltip = {'Import raw data'};
            app.ImportMenu.MenuSelectedFcn = @(~,~) readData(app);

            % Create ExitMenu
            app.ExitMenu = uimenu(app.FileMenu);
            app.ExitMenu.Text = 'Exit';
            app.ExitMenu.Tooltip = {'Exit the app'};
            app.ExitMenu.MenuSelectedFcn = @(~,~) closereq();
            
            % Create EditMenu
            app.EditMenu = uimenu(app.UIFigure);
            app.EditMenu.Tooltip = {'Edit menu'};
            app.EditMenu.Text = 'Edit';

            % Create ClearMenu
            app.ClearMenu = uimenu(app.EditMenu);
            app.ClearMenu.Text = 'Clear';
            app.ClearMenu.Tooltip = {'Clear imported data'};
            app.ClearMenu.MenuSelectedFcn = @(~,~) clearCb(app);
            
            % Create Toolbar
            app.Toolbar = uitoolbar(app.UIFigure);

            % Create ImportPushTool
            app.ImportPushTool = uipushtool(app.Toolbar);
            app.ImportPushTool.Icon = 'Icons/import.png';
            app.ImportPushTool.ClickedCallback = @(~,~) readData(app);
            app.ImportPushTool.Tooltip = {'Import'};
            
            % Create ClearPushTool
            app.ClearPushTool = uipushtool(app.Toolbar);
            app.ClearPushTool.Icon = 'Icons/clear.png';
            app.ClearPushTool.ClickedCallback = @(~,~) clearCb(app);
            app.ClearPushTool.Tooltip = {'Clear'};
            
            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [4 -47 797 648];

            % Create DataVizualizerTab
            app.DataVizualizerTab = uitab(app.TabGroup);
            app.DataVizualizerTab.Title = 'Data Vizualizer';
            app.DataVizualizerTab.BackgroundColor = [0.9412 0.9412 0.9412];

            %% Create DistributionPanel
            app.DistributionPanel = uipanel(app.DataVizualizerTab);
            app.DistributionPanel.Title = 'Distribution';
%             app.DistributionPanel.Units = 'Normalized';
%             app.DistributionPanel.Position = [0.35 0.1 0.62 0.88];
            app.DistributionPanel.Position = [244 70 536 540];

            % Create UIAxes
            app.UIAxes = uiaxes(app.DistributionPanel);
            lgd = legend(app.UIAxes);
            lgd.Visible = 'off';
            app.UIAxes.Visible = 'off';
            
            app.UIAxes.Units = 'Normalized';
            app.UIAxes.Position = [0.01 0.05 0.98 0.95];

            %% Create ImportDataPanel
            app.ImportDataPanel = uipanel(app.DataVizualizerTab);
            app.ImportDataPanel.Title = 'Import Data';
            app.ImportDataPanel.Position = [17 492 214 118];

            % Create ImportButton
            app.ImportButton = uibutton(app.ImportDataPanel, 'push');
            app.ImportButton.Position = [8 43 78 34];
            app.ImportButton.Text = 'Import';
            app.ImportButton.ButtonPushedFcn = @(~,~) readData(app);
            
            % Create DatanotimportedLampLabel
            app.DatanotimportedLampLabel = uilabel(app.ImportDataPanel);
            app.DatanotimportedLampLabel.HorizontalAlignment = 'right';
            app.DatanotimportedLampLabel.Position = [95 18 100 26];
            app.DatanotimportedLampLabel.Text = 'Data not imported';
            
            % Create DatanotimportedLamp
            app.DatanotimportedLamp = uilamp(app.ImportDataPanel);
            app.DatanotimportedLamp.Position = [136 55 30 30];
            app.DatanotimportedLamp.Color = [1 0 0];
            
            %% Create DataVisiualizationPanel
            app.DataVisiualizationPanel = uipanel(app.DataVizualizerTab);
            app.DataVisiualizationPanel.Title = 'Data Visiualization';
            app.DataVisiualizationPanel.Position = [17 70 214 400];
            
             % Create NumberofsavedfilesButton
            app.NumberofsavedfilesButton = uibutton(app.DataVisiualizationPanel, 'push');
            app.NumberofsavedfilesButton.Position = [30 325 153 34];
            app.NumberofsavedfilesButton.Text = 'Number of saved  files';
            app.NumberofsavedfilesButton.ButtonPushedFcn = @(~,~) vizFiles(app);

            % Create LengthofrecordeddataButton
            app.LengthofrecordeddataButton = uibutton(app.DataVisiualizationPanel, 'push');
            app.LengthofrecordeddataButton.Position = [30 275 153 34];
            app.LengthofrecordeddataButton.Text = 'Number of recorded walks';
            app.LengthofrecordeddataButton.ButtonPushedFcn = @(~,~) vizSeconds(app);
    
            % Create CollecteddataperpersonButton
            app.CollecteddataperpersonButton = uibutton(app.DataVisiualizationPanel, 'push');
            app.CollecteddataperpersonButton.Position = [30 225 153 34];
            app.CollecteddataperpersonButton.Text = 'Collected data per person';
            app.CollecteddataperpersonButton.ButtonPushedFcn = @(~,~) vizTeam(app);
            
            % Create DropDown
            app.DropDown = uidropdown(app.DataVisiualizationPanel);
            app.DropDown.Position = [97 150 100 22];
            app.DropDown.Items = {};
            app.DropDown.ValueChangedFcn = @(~,~) vizAcceleration(app);
            
            % Create DropDownLabel
            app.DropDownLabel = uilabel(app.DataVisiualizationPanel);
            app.DropDownLabel.HorizontalAlignment = 'right';
            app.DropDownLabel.Position = [16 150 66 22];
            app.DropDownLabel.Text = 'Plot sample';
            
            % Create PlotTypeSwitchLabel
            app.PlotTypeSwitchLabel = uilabel(app.DataVisiualizationPanel);
            app.PlotTypeSwitchLabel.HorizontalAlignment = 'center';
            app.PlotTypeSwitchLabel.Position = [83 70 55 22];
            app.PlotTypeSwitchLabel.Text = 'Plot Type';

            % Create PlotTypeSwitch
            app.PlotTypeSwitch = uiswitch(app.DataVisiualizationPanel, 'slider');
            app.PlotTypeSwitch.Items = {'Original', 'Cut'};
            app.PlotTypeSwitch.Position = [87 100 45 20];
            app.PlotTypeSwitch.Value = 'Original';
            app.PlotTypeSwitch.ValueChangedFcn = @(~,~) vizAcceleration(app);
            % Create SplitterTab
            app.SplitterTab = uitab(app.TabGroup);
            app.SplitterTab.Title = 'Split and Train';
            
            %% Create SplitParameters
            app.SplitParameters = uipanel(app.SplitterTab);
            app.SplitParameters.Title = 'Split Parameters';
            app.SplitParameters.Position = [17 450 763 160];
            
            % Create SplitRatioSliderLabel
            app.SplitRatioSliderLabel = uilabel(app.SplitParameters);
            app.SplitRatioSliderLabel.FontSize = 15;
            app.SplitRatioSliderLabel.WordWrap = 'on';
            app.SplitRatioSliderLabel.HorizontalAlignment = 'center';
            app.SplitRatioSliderLabel.FontWeight = 'bold';
            app.SplitRatioSliderLabel.Position = [10 50 110 50];
            app.SplitRatioSliderLabel.Text = 'Split Ratio (Training Data)';

            % Create SplitRatioSlider
            app.SplitRatioSlider = uislider(app.SplitParameters);
            app.SplitRatioSlider.Position = [145 113 280 3];
            app.SplitRatioSlider.Value = 70;
            app.SplitRatioSlider.ValueChangingFcn = @(~,event) slideSplitCb(event,app);

            % Create EditField
            app.EditField = uieditfield(app.SplitParameters, 'numeric');
            app.EditField.Position = [147 39 284 19];
            app.EditField.Value = 70;
            app.EditField.ValueChangedFcn = @(~,~) editSplitCb(app);
            app.EditField.RoundFractionalValues = 'on';
            app.EditField.Limits = [0 100];

            % Create SplitButton
            app.SplitButton = uibutton(app.SplitParameters, 'push');
            app.SplitButton.FontSize = 14;
            app.SplitButton.FontWeight = 'bold';
            app.SplitButton.Position = [527 86 166 36];
            app.SplitButton.Text = 'Split';
            app.SplitButton.ButtonPushedFcn = @(~,~) splitCb(app);
            app.SplitButton.Enable = 'off';
            
            % Create SplitLabel
            app.SplitLabel = uilabel(app.SplitParameters);
            app.SplitLabel.FontSize = 15;
            app.SplitLabel.WordWrap = 'on';
            app.SplitLabel.HorizontalAlignment = 'center';
            app.SplitLabel.FontWeight = 'bold';
            app.SplitLabel.Position = [527 21 166 50];
            app.SplitLabel.Text = 'Raw data not imported';
            app.SplitLabel.FontColor = 'red';
            
            %% Create TrainParameters
            app.TrainParameters = uipanel(app.SplitterTab);
            app.TrainParameters.Title = 'Train Parameters';
            app.TrainParameters.Position = [17 70 763 365];

            % Create ExtractDataLabel
            app.ExtractDataLabel = uilabel(app.TrainParameters);
            app.ExtractDataLabel.FontSize = 15;
            app.ExtractDataLabel.WordWrap = 'on';
            app.ExtractDataLabel.FontWeight = 'bold';
            app.ExtractDataLabel.Position = [14 250 220 50];
            app.ExtractDataLabel.Text = 'ExtractData Frequency (Hz)';
 
            % Create TrainingFrequency
            app.TrainingFrequency = uieditfield(app.TrainParameters, 'numeric');
            app.TrainingFrequency.Position = [247 255 284 39];
            app.TrainingFrequency.Value = 50;
            app.TrainingFrequency.Limits = [0 inf];
            
            % Create WindowLengthLabel
            app.WindowLengthLabel = uilabel(app.TrainParameters);
            app.WindowLengthLabel.FontSize = 15;
            app.WindowLengthLabel.WordWrap = 'on';
            app.WindowLengthLabel.FontWeight = 'bold';
            app.WindowLengthLabel.Position = [14 150 220 50];
            app.WindowLengthLabel.Text = 'ExtractData window length (s)';
 
            % Create WindowLength
            app.WindowLength = uieditfield(app.TrainParameters, 'numeric');
            app.WindowLength.Position = [247 155 284 39];
            app.WindowLength.Value = 3.4;
            app.WindowLength.Limits = [1 inf];
            
            % Create ModelDropDownTrainLabel
            app.ModelDropDownTrainLabel = uilabel(app.TrainParameters);
            app.ModelDropDownTrainLabel.FontSize = 15;
            app.ModelDropDownTrainLabel.FontWeight = 'bold';
            app.ModelDropDownTrainLabel.Position = [14 50 220 22];
            app.ModelDropDownTrainLabel.Text = 'Select classification model';

            % Create ModelDropDownTrain
            app.ModelDropDownTrain = uidropdown(app.TrainParameters);
            app.ModelDropDownTrain.Items = {'-','Final','SVM','RF','LSTM_36',...
                'LSTM_213','LSTM_378'};
            app.ModelDropDownTrain.Value = '-';
            app.ModelDropDownTrain.Position = [247 50 150 30];
            app.ModelDropDownTrain.ValueChangedFcn = @(~,~) trainModelDropdownCb(app);
            
            % Create TrainingButton
            app.TrainingButton = uibutton(app.TrainParameters, 'push');
            app.TrainingButton.FontWeight = 'bold';
            app.TrainingButton.Position = [451 50 80 42];
            app.TrainingButton.Text = 'Train';
            app.TrainingButton.Enable = 'off';
            app.TrainingButton.ButtonPushedFcn = @(~,~) trainCb(app);
            
            % Create TrainingLabel
            app.TrainingLabel = uilabel(app.TrainParameters);
            app.TrainingLabel.FontSize = 14;
            app.TrainingLabel.FontWeight = 'bold';
            app.TrainingLabel.Position = [570 50 670 42];
            app.TrainingLabel.FontColor = 'red';
            app.TrainingLabel.Text = 'Data not yet split';
            %% Create TrainandClassifyTab
            app.TrainandClassifyTab = uitab(app.TabGroup);
            app.TrainandClassifyTab.Title = 'Error and Classification';

            %% Create VisualizationPanel
            app.VisualizationPanel = uipanel(app.TrainandClassifyTab);
            app.VisualizationPanel.Title = 'Visualization';
            app.VisualizationPanel.Position = [244 70 536 540];

            % Create UIAxes_Train
            app.UIAxes_Train = uiaxes(app.VisualizationPanel);
            app.UIAxes_Train.Visible = 'off';
            app.UIAxes_Train.Units = 'Normalized';
            app.UIAxes_Train.Position = [0.01 0.05 0.98 0.95];

            %% Create ModelPanel
            app.ModelPanel = uipanel(app.TrainandClassifyTab);
            app.ModelPanel.Title = 'Model';
            app.ModelPanel.Position = [17 520 214 90];

            % Create ModelDropDownabel
            app.ModelDropDownLabel = uilabel(app.ModelPanel);
            app.ModelDropDownLabel.HorizontalAlignment = 'center';
            app.ModelDropDownLabel.FontWeight = 'bold';
            app.ModelDropDownLabel.Position = [14 30 186 22];
            app.ModelDropDownLabel.Text = 'Available Models';
            
            % Create RefreshButton
            app.RefreshButton = uibutton(app.ModelPanel, 'push');
            app.RefreshButton.Enable = 'off';
            app.RefreshButton.Text = '';
            app.RefreshButton.Position = [170 35 30 30];
            app.RefreshButton.Icon = 'Icons/refresh.png';
            app.RefreshButton.ButtonPushedFcn = @(~,~) errorModelDropdownCb(app);

            % Create ModelDropDown
            app.ModelDropDown = uidropdown(app.ModelPanel);
            app.ModelDropDown.Items = {'-','Final'};
            app.ModelDropDown.Position = [14 10 186 22];
            app.ModelDropDown.Value = '-';
            app.ModelDropDown.ValueChangedFcn = @(~,~) errorModelDropdownCb(app);

            %% Create ErrorPanel
            app.ErrorPanel = uipanel(app.TrainandClassifyTab);
            app.ErrorPanel.Title = 'Training Error and Statistics';
            app.ErrorPanel.Position = [17 250 214 260];
            app.ErrorPanel.Enable = 'off';
            
            % Create TestDropDownLabel
            app.TestDropDownLabel = uilabel(app.ErrorPanel);
            app.TestDropDownLabel.HorizontalAlignment = 'center';
            app.TestDropDownLabel.FontWeight = 'bold';
            app.TestDropDownLabel.Position = [31 200 154 50];
            app.TestDropDownLabel.Text = 'Erroneous test samples';

            % Create TestDropDown
            app.TestDropDown = uidropdown(app.ErrorPanel);
            app.TestDropDown.Items = {'-'};
            app.TestDropDown.Position = [31 194 154 20];
            app.TestDropDown.Value = '-';
            app.TestDropDown.ValueChangedFcn = @(~,~) vizErroneous(app);
            
            % Create KnobLabel
            app.KnobLabel = uilabel(app.ErrorPanel);
            app.KnobLabel.HorizontalAlignment = 'center';
            app.KnobLabel.Position = [75 80 34 22];
            app.KnobLabel.Text = 'Mode';

            % Create Knob
            app.Knob = uiknob(app.ErrorPanel, 'discrete');
            app.Knob.Items = {'Original','Borders','Bkgd Color'};
            app.Knob.Value = 'Bkgd Color';
            app.Knob.Position = [70 105 50 50];
            app.Knob.ValueChangedFcn = @(~,~) vizErroneous(app);
            
            % Create ConfusionMatrixButton
            app.ConfusionMatrixButton = uibutton(app.ErrorPanel, 'push');
            app.ConfusionMatrixButton.FontWeight = 'bold';
            app.ConfusionMatrixButton.Enable = 'off';
            app.ConfusionMatrixButton.Position = [31 40 154 24];
            app.ConfusionMatrixButton.Text = 'Confusion Matrix';
            app.ConfusionMatrixButton.ButtonPushedFcn = @(~,~) vizConfusion(app,'test');

            % Create StatButton
            app.EffeciencyButton = uibutton(app.ErrorPanel, 'push');
            app.EffeciencyButton.FontWeight = 'bold';
            app.EffeciencyButton.Enable = 'off';
            app.EffeciencyButton.Position = [31 12 154 24];
            app.EffeciencyButton.Text = 'Error Statistics';
            app.EffeciencyButton.ButtonPushedFcn = @(~,~) accuracyCb(app);
            
            % Create AccuracyLabel
            app.AccuracyLabel = uilabel(app.VisualizationPanel);
            app.AccuracyLabel.HorizontalAlignment = 'center';
            app.AccuracyLabel.FontWeight = 'bold';
            app.AccuracyLabel.Position = [50 350 400 70];
            app.AccuracyLabel.Text = '';
            app.AccuracyLabel.FontSize = 20;
            app.AccuracyLabel.Visible = 'off';
            app.AccuracyLabel.WordWrap = 'on';
            
            % Create BalancedAccuracyLabel
            app.BalancedAccuracyLabel = uilabel(app.VisualizationPanel);
            app.BalancedAccuracyLabel.HorizontalAlignment = 'center';
            app.BalancedAccuracyLabel.FontWeight = 'bold';
            app.BalancedAccuracyLabel.FontSize = 20;
            app.BalancedAccuracyLabel.WordWrap = 'on';
            app.BalancedAccuracyLabel.Position = [50 250 400 70];
            app.BalancedAccuracyLabel.Text = '';
            app.BalancedAccuracyLabel.Visible = 'off';
            
            %% Create ClassifyPanel
            app.ClassifyPanel = uipanel(app.TrainandClassifyTab);
            app.ClassifyPanel.Title = 'Classify';
            app.ClassifyPanel.Position = [18 70 214 170];
            app.ClassifyPanel.Enable = 'off';

            % Create ImportFileButton
            app.ImportFileButton = uibutton(app.ClassifyPanel, 'push');
            app.ImportFileButton.Position = [56 108 100 22];
            app.ImportFileButton.Text = 'Select folder';
            app.ImportFileButton.ButtonPushedFcn = @(~,~) readTest(app);

            % Create ClassifyDropDown
            app.ClassifyDropDown = uidropdown(app.ClassifyPanel);
            app.ClassifyDropDown.Position = [10 75 190 22];
            app.ClassifyDropDown.Items = {};

            % Create ClassifyButton
            app.ClassifyButton = uibutton(app.ClassifyPanel, 'push');
            app.ClassifyButton.FontSize = 11;
            app.ClassifyButton.FontWeight = 'bold';
            app.ClassifyButton.Position = [110 10 100 49];
            app.ClassifyButton.Enable = 'off';
            app.ClassifyButton.Text = 'Classify';
            app.ClassifyButton.ButtonPushedFcn = @(~,~) classifyCb(app);
            
            % Create ConfusionTestButton
            app.ConfusionTestButton = uibutton(app.ClassifyPanel, 'push');
            app.ConfusionTestButton.FontSize = 11;
            app.ConfusionTestButton.FontWeight = 'bold';
            app.ConfusionTestButton.Position = [5 10 90 49];
            app.ConfusionTestButton.Enable = 'off';
            app.ConfusionTestButton.Text = 'Confus. Matrix';
            app.ConfusionTestButton.ButtonPushedFcn = @(~,~) vizConfusion(app,'unseen');
            
            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';

        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = View()

            % Add path of folder above GUI folder and subfolder
             abovefolder = app.MainPath;
             addpath(genpath(abovefolder));
            
            % Force MATLAB to use hardware graphics card if GPU is
            % available
            if canUseGPU
                opengl hardwarebasic
            end
            
            % Create UIFigure and components
            setupLayout(app);
            app.TrainingParameters = containers.Map({'-'},{{0,0}});
            % Load Models
            loadModels({fullfile(app.MainPath,'Models','70'),...
    fullfile(app.MainPath,'Models')},app);
        end
    end
end