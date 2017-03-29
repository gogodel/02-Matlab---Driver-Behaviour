% Learning centers for atomic actions
clear variables
close all
clc

set(0,'defaulttextinterpreter','latex','defaultLineLineWidth',1.2,'defaultAxesFontSize',11);

%% DATA - Load list of files
listOfFiles = {'01_Overtake_new.mat', '02_Detenerse_new.mat', ...
               '03_Detenerse_semaforo_new.mat', '04_Distancia_seguridad_new.mat'};

for idxMain=1:length(listOfFiles)
    load(listOfFiles{idxMain})           

    %% Data preprocessing:
    SpeedDiff_f     = dataPreProcessing(1,SpeedDifference, 0);                 % [-100, 0, 100]
    RPMDiff_f       = dataPreProcessing(1,RPMDifference, 0);                   % [-100, 0, 100]
    SteeringWheel_f = dataPreProcessing(1,swDifference, 0.00001);              % [-100, 0, 100]
    GasPedal_f      = dataPreProcessing(2,gaspedal, 0.0001);                   % [0, 100]
    BrakePedal_f    = dataPreProcessing(2,brakepedal, 0.0001);                 % [0, 100]
    ClutchPedal_f   = dataPreProcessing(3,clutchpedal, 0.0001);                % [0, 100]
    GearChange_f    = dataPreProcessing(4,gear, 0);                            % [-100, 0, 100]
    
    %% Regression vector:
    if idxMain==1
        % Data vector
        X = [SpeedDiff_f, RPMDiff_f, SteeringWheel_f, GasPedal_f, BrakePedal_f, ClutchPedal_f, GearChange_f];
        
        % EVOLVING MECHANISM
        AtomicAs           = EvolveRECCo();
        AtomicAs.dimension = size(X,2);
        AtomicAs.EvolveParam.n_add    = 0;      % Delay adding new clouds
        AtomicAs.EvolveParam.gama_max = 0.83;   % EVOLVING PARAMETER (between 0.45 and 0.73)
        AtomicAs.EvolveParam.c_max    = 100;    % MAXIMAL NUMBER OF CLOUDS
        
        startIdx = 1;                           % Starting index of the new maneuvr
        uniqueAAs = unique(AtomicAction1);
        definedAAs   = AtomicAction1;
    else
        startIdx   = length(X) + 1;             % Starting index of the new maneuvr
        uniqueAAs  = unique([AtomicAction1; uniqueAAs]);
        definedAAs = [definedAAs; AtomicAction1];
        % Data vector
        X = [X; SpeedDiff_f, RPMDiff_f, SteeringWheel_f, GasPedal_f, BrakePedal_f, ClutchPedal_f, GearChange_f]; %#ok<*AGROW>
    end
    %% PREALOCATION    
        maximo = length(X);
        maneuverRange(idxMain) = startIdx;   %#ok<*SAGROW> % Stores the indexes when new maneuver starts

    %% LEARNING PHASE
    for kk=startIdx:maximo
        currentData = X(kk,:);

        % EVOLVING MECHANISM
        AtomicAs    = AtomicAs.addPoint(currentData,kk);
    end
    length(AtomicAs.membershipList)
    identifiedAAs = (AtomicAs.memberHistory'-1); % -1 because clouds starts
                                                 % from value 1, but AAs
                                                 % start from 0
end
center_AAs    = getCenters(AtomicAs);
maneuverRange = [maneuverRange maximo];
%% RESULTS
fprintf('\nNumber of identified Atomic Actions: %d \n', length(AtomicAs.membershipList));

%% SAVE Detected atomic actions
save xAAs.mat AtomicAs



