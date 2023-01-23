function runUnitTests(testType)
%RUNUNITTESTS Run the unit tests provided on MoMa Moodle page
%   This function executes the Monty MATLAB unit tests provided on the
%   Moodle page. Depending on the input parameter, the model is retrained
%   or the pretrained model stored in model.mat is applied.

% update path
run('prepareEnv');
tic
switch testType
    case 'train'
        test = SillyWalkDetectionTest();
        test.run();
    case 'pretrained'
        test = SillyWalkDetectionTest();
        test.LoadModel=true;
        test.run();
    otherwise
        disp("unknown test type")
end
toc
end