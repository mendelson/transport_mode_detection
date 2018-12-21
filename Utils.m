classdef Utils
    methods(Static)
        function setupParallelPool
            p = gcp('nocreate'); % If no pool, do not create new one.
            
            if isempty(p)
                poolsize = 4;
                distcomp.feature('LocalUseMpiexec', false);
                parpool(poolsize);
            end
        end
        
        function list = getListOfFiles(path)
            list = dir(path);
            list = list(3:end);
        end
        
        function hitRate = getHitRateFromFileName(name)
            fileBase = 'validated_net_';
            
            ini = strfind(name, fileBase);
            fin = strfind(name, 'hit_');
            
            hitRate = name(ini + length(fileBase):fin - 1);
            hitRate = str2double(hitRate);
        end
        
        function [name, hitRate] = getFileNameWithBestHitRate(path)
            list = Utils.getListOfFiles(path);
            
            hitRate = 0;
            for i = 1:size(list, 1)
                currentHitRate = Utils.getHitRateFromFileName(list(i).name);
                
                if currentHitRate > hitRate
                    name = list(i).name;
                    hitRate = currentHitRate;
                end
            end
        end
        
        function [name] = getFileNameThatContains(path, str)
            list = Utils.getListOfFiles(path);
            
            for i = 1:size(list, 1)
                if strfind(list(i).name, str)
                    name = list(i).name;
                    break;
                end
            end
        end
        
        function out = fillTargets(targets, target, howMany)
            out = targets;
            
            last = size(out, 1) + 1;
            for i = last:last + howMany - 1
                out(i, 1:size(target, 2)) = target;
            end
        end
        
        function confMatrix = calcConfMatrix(net, inputs, targets)
            %% Each sample must be formated for nnet, that is, each sample
            %  must be a column (either for inputs and targets).
            
            % Simulate outputs
            simOutputs = net(inputs);
            
            for i = 1:size(simOutputs, 2)
                simOutputs(:, i) = Utils.setOutput(simOutputs(:, i));
            end
            
            % Get correspondent subset of TARGETS
            numModes = size(unique(targets', 'rows'), 1);
            confMatrix = zeros(numModes, numModes);
            
            % Construct confusion matrix
            if numModes == 2
                for i = 1:size(simOutputs, 2)
                    predOutput = simOutputs(:, i);
                    actualTarget = targets(:, i);
                    
                    if predOutput == 1 && actualTarget == 1
                        confMatrix(1, 1) = confMatrix(1, 1) + 1;
                    elseif predOutput == 1 && actualTarget == -1
                        confMatrix(2, 1) = confMatrix(2, 1) + 1;
                    elseif predOutput == -1 && actualTarget == 1
                        confMatrix(1, 2) = confMatrix(1, 2) + 1;
                    elseif predOutput == -1 && actualTarget == -1
                        confMatrix(2, 2) = confMatrix(2, 2) + 1;
                    end
                end
            else
                for i = 1:size(simOutputs, 2)
                    predOutput = simOutputs(:, i);
                    actualTarget = targets(:, i);
                    pred = find(predOutput == 1);
                    act = find(actualTarget == 1);
                    confMatrix(act, pred) = confMatrix(act, pred) + 1;
                end
            end
            
            confMatrix = (confMatrix/size(simOutputs, 2))*100;
        end
        
        function out = setOutput(in)
            if length(in) == 1
                %% Set to 1 or -1
                if in >= 0
                    out = 1;
                else
                    out = -1;
                end
            else
                %% Winner takes all
                [idx, idx] = max(in);
                
                out(1:size(in, 1), 1:size(in, 2)) = -1;
                out(idx) = 1;
            end
        end
    end
    
end

