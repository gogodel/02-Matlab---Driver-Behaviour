function [iManeuver, minDist, dist] = validateManeverSequence(ManeuversBase, ManeuversDetected)

minDist   = 0.351;
iManeuver = 0;
for idx=1:length(ManeuversBase)    
    if length(ManeuversDetected)>=length(ManeuversBase{idx})
        k = 0;
        for nStep=1:(length(ManeuversDetected)-length(ManeuversBase{idx}))+1
            k     = k + 1;
            Start = k;
            End   = k + length(ManeuversBase{idx}) - 1;
            dist{idx}(nStep) = sum((ManeuversBase{idx}-ManeuversDetected(Start:End))~=0)...
                               /length(ManeuversBase{idx}); %#ok<*AGROW>
        end
    else
        dist{idx} = inf;
    end
    if min(dist{idx})<minDist
        iManeuver = idx;
        minDist   = min(dist{idx});
    end
end
