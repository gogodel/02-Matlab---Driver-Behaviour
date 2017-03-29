clear all %#ok<CLALL>
close all
clc

%% Load new data for classification
% load Overtake_extended0.mat
% load Detenerse_extended0.mat
% load Detenerse_semaforo_extended0.mat
% load Distancia_seguridad_extended0.mat

listOfFiles = {'Overtake_extended0.mat', 'Detenerse_extended0.mat', ...
               'Detenerse_semaforo_extended0.mat', 'Distancia_seguridad_extended0.mat'};
% listOfFiles = {'Detenerse_semaforo_extended0.mat'};
% X = [SpeedDiff_f, RPMDiff_f, SteeringWheel_f, GasPedal_f, BrakePedal_f, ClutchPedal_f, GearChange_f];
%% EVOLVE PARAMETERS
c_max = 10;
Tasks           = EvolveRECCo();
Tasks.dimension = 7;
Tasks.EvolveParam.n_add    = 20;    % Delay adding new clouds
Tasks.EvolveParam.gama_max = 0.25;  % EVOLVING PARAMETER (between 0.45 and 0.73)
Tasks.EvolveParam.c_max    = c_max;    % MAXIMAL NUMBER OF CLOUDS

%% EVOLVE PROCEDURE
N_wind     = 1;
delayTasks = 4;
countTasks = 0;
lastTask=-1;
beta=[]; Density=[]; nIter=0; ManeuversRegions=1; ManeuversSequences=cell(length(listOfFiles),1);  

for nFile = 1:length(listOfFiles)
    % Load maneuver's data
    load(listOfFiles{nFile})  
    disp(['Maneuver: ' listOfFiles{nFile}])
    
    % Preallocation
    beta=[beta; zeros(length(X), c_max)]; Density=[Density; zeros(length(X), c_max)]; %#ok<*AGROW>
    ManeuversRegions = [ManeuversRegions length(X)+ManeuversRegions(end)];
    countTasks = 0;
    for nX=N_wind:length(X)
        nIter = nIter + 1;
        currDataCenter = mean(X(nX-N_wind+1:nX,:),1);

        % EVOLVING MECHANISM
        Tasks    = Tasks.addPoint(currDataCenter,nIter);
        cTasks   = length(Tasks.membershipList);
        beta(nIter,1:cTasks)    = Tasks.membershipList;
        Density(nIter,1:cTasks) = Tasks.densityList;
        
        [~,tempTask] = max(Tasks.membershipList);
        if tempTask~=lastTask
            countTasks = countTasks + 1;
            if countTasks > delayTasks
                ManeuversSequences{nFile} = [ManeuversSequences{nFile} tempTask];
                lastTask   = tempTask;
                countTasks = 0;
            end       
        else
            countTasks   = 0;
        end
    end
end
figure, plot(beta)
figure, plot(Density)

figure, plot(Tasks.memberHistory), hold on
        stairs(ManeuversRegions, 1:length(ManeuversRegions))

save xTasks.mat ManeuversSequences Tasks


