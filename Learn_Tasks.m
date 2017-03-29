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

% X = [SpeedDiff_f, RPMDiff_f, SteeringWheel_f, GasPedal_f, BrakePedal_f, ClutchPedal_f, GearChange_f];
%% EVOLVE PARAMETERS
Tasks           = EvolveRECCo();
Tasks.dimension = size(X,2);
Tasks.EvolveParam.n_add    = 10;    % Delay adding new clouds
Tasks.EvolveParam.gama_max = 0.2;  % EVOLVING PARAMETER (between 0.45 and 0.73)
Tasks.EvolveParam.c_max    = 10;    % MAXIMAL NUMBER OF CLOUDS

%% EVOLVE PROCEDURE
beta=[]; Density=[];
for nFile = 1:length(listOfFiles)
    load(listOfFiles{nFile})  
    beta=[beta; zeros(size(X))]; Density=[Density; zeros(size(X))]; %#ok<*AGROW>
    for nIter=1:length(X)
        currDataCenter = X(nIter,:);

        % EVOLVING MECHANISM
        Tasks    = Tasks.addPoint(currDataCenter,nIter);
        cTasks   = length(Tasks.membershipList);
        beta(nIter,1:cTasks)    = Tasks.membershipList;
        Density(nIter,1:cTasks) = Tasks.densityList;
    end
end
figure, plot(beta)
% figure, plot(beta, '.')
figure, plot(Density)


