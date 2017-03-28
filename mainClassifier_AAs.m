% Evolving Classifier for atomic actions
clear variables
close all
clc

set(0,'defaulttextinterpreter','latex','defaultLineLineWidth',1.2,'defaultAxesFontSize',11);

%% DATA - Load files
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
        myEvolve           = EvolveRECCo();
        myEvolve.dimension = size(X,2);
        myEvolve.EvolveParam.n_add    = 0;      % Delay adding new clouds
        myEvolve.EvolveParam.gama_max = 0.83;   % EVOLVING PARAMETER (between 0.45 and 0.73)
        myEvolve.EvolveParam.c_max    = 100;    % MAXIMAL NUMBER OF CLOUDS
        
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
        myEvolve    = myEvolve.addPoint(currentData,kk);
    end
    length(myEvolve.membershipList)
    identifiedAAs = (myEvolve.memberHistory'-1); % -1 because clouds starts
                                                 % from value 1, but AAs
                                                 % start from 0
end
allCenters   = getCenters(myEvolve);
maneuverRange = [maneuverRange maximo];
%% RESULTS
fprintf('\nNumber of identified Atomic Actions: %d', length(myEvolve.membershipList));
fprintf('\nNumber of defined Atomic Actions: %d\n', length(uniqueAAs));

error = definedAAs - identifiedAAs;

for idxMain=1:length(listOfFiles)
    Start = maneuverRange(idxMain);
    End   = maneuverRange(idxMain+1); 
    
    figure, set(gcf,'Name',(listOfFiles{idxMain}))
    subplot(311), plot(Start:End,definedAAs(Start:End), 'r'), hold on
                  title('Predefined Atomic Actions')
                  ylabel('$AA^i$')
                  xlim([Start End]);
    subplot(312), plot(Start:End,identifiedAAs(Start:End), 'g'), hold on
                  title('Detected Atomic Actions (evolving)')
                  ylabel('$AA^i$')
                  xlim([Start End]);
    subplot(313), plot(Start:End,error(Start:End)), ylim([-10 10]), hold on
                  title('Diference between Predefined and Detected AAs')
                  xlabel('$k$')
                  xlim([Start End]);
    
    centers{idxMain} = allCenters(unique(identifiedAAs(Start:End))+1,:);
end

%TEST NEW COMMENTS - 


