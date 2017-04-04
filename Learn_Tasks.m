% clear all %#ok<CLALL>
% close all
% clc

%% Load new data for classification
listOfFiles = {'Overtake_extended0.mat', 'Detenerse_extended0.mat', ...
               'Detenerse_semaforo_extended0.mat', 'Distancia_seguridad_extended0.mat'};
% listOfFiles = {'Overtake_extended0.mat'};
% listOfFiles = {'Detenerse_extended0.mat'};
% listOfFiles = {'Detenerse_semaforo_extended1.mat'};
% listOfFiles = {'Distancia_seguridad_extended0.mat'};
% X = [SpeedDiff_f, RPMDiff_f, SteeringWheel_f, GasPedal_f, BrakePedal_f, ClutchPedal_f, GearChange_f];
%% EVOLVE PARAMETERS
c_max = 10;
Tasks           = EvolveRECCo();
Tasks.dimension = 7;
Tasks.EvolveParam.n_add    = 20;        % Delay adding new clouds
Tasks.EvolveParam.gama_max = 0.25;      % EVOLVING PARAMETER (between 0.45 and 0.73)
Tasks.EvolveParam.c_max    = c_max;     % MAXIMAL NUMBER OF CLOUDS
allTasks = Tasks; allTasks.cloudList=[];
%% EVOLVE PROCEDURE
N_wind     = 4;
delayTasks = 7;
countTasks = 0;
lastTask=-1;
beta=[]; Density=[]; nIter=0; ManeuversRegions=1; ManeuversBase=cell(length(listOfFiles),1);  
allIter=0;
for nFile = 1:length(listOfFiles)
    % Load maneuver's data
    load(listOfFiles{nFile})  
    disp(['Maneuver: ' listOfFiles{nFile}])
    
    % Preallocation
    beta=[beta; zeros(length(X), c_max)]; Density=[Density; zeros(length(X), c_max)]; %#ok<*AGROW>
    ManeuversRegions = [ManeuversRegions length(X)+ManeuversRegions(end)];
    countTasks = 0;
    for nX=N_wind:length(X)
        nIter   = nIter + 1;
        allIter = allIter + 1;
        currDataCenter = mean(X(nX-N_wind+1:nX,:),1);

        % EVOLVING MECHANISM
        Tasks    = Tasks.addPoint(currDataCenter,nIter);
        cTasks   = length(Tasks.membershipList);
        beta(allIter,1:cTasks)    = Tasks.membershipList;
        Density(allIter,1:cTasks) = Tasks.densityList;
        
        [~,tempTask] = max(Tasks.membershipList);
        if tempTask~=lastTask
            countTasks = countTasks + 1;
            if countTasks > delayTasks
                ManeuversBase{nFile} = [ManeuversBase{nFile} tempTask];
                lastTask   = tempTask;
                countTasks = 0;
            end       
        else
            countTasks   = 0;
        end
    end
end


figure, plot(Tasks.memberHistory), hold on
        stairs(ManeuversRegions, 1:length(ManeuversRegions))

save resultTasks.mat ManeuversBase Tasks N_wind delayTasks

clearvars -except AAs identifiedAAs ManeuversBase Tasks N_wind delayTasks

% RUN Learn_Tasks
Validate_Maneuvers


