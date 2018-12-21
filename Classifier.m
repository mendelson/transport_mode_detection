classdef Classifier < handle
    properties
        %% Folder
        rootFolder
        folderLabel
        
        %% Training params
        trainProp
        valProp
        testProp
        epoch
        contMax
        numRepet % Number of Monte Carlo repetitions
        
        %% Data
        inpData
        targets
        typesTargets
        
        %% Best net
        bestNet
        bestTrainRecord
        bestPerf
        bestRate
        bestAvgHitRate
        bestAvgMSE
        bestAvgNet
        bestAvgNetTrainRecord
        bestEpoch
        
        %% Current nets
        currentNet
        currentTrainRecord
        currentBestNet
        currentBestTrainRecord
        currentBestPerf
        currentBestRate
        
        %% Others
        numberClasses
        partialResults
        partialResEpochs
        netFile
        confMatrix
        
    end
    
    methods
        function obj = Classifier()
            % Class constructor
            obj.rootFolder = '.\net';
            
            obj.trainProp = 0.7;
            obj.valProp = 0.15;
            obj.testProp = 0.15;
            
            obj.contMax = 10;
            obj.numRepet = 50;
        end
        
        function train(obj, fPath, inputData, targets)
            %train Train a neural network given inputs and targets
            
            obj.bestNet = [];
            obj.bestAvgNet = [];
            obj.currentNet = [];
            obj.currentBestNet = [];
            
            obj.folderLabel = fPath;
            obj.inpData = inputData;
            obj.targets = targets;
            obj.epoch = 0;
            obj.partialResEpochs = [];
            
            obj.bestAvgMSE = Inf;
            obj.bestAvgHitRate = 0;
            perfTest = 0;
            
            AvgRateEvol = [];
            AvgMSEEvol = [];
            
            obj.inpData = obj.inpData';
            obj.targets = obj.targets';
            
            while(1)
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 1. Define initial network architecture %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj.epoch = obj.epoch + 1;
                
                disp(['epoch: ' num2str(obj.epoch)]);
                fprintf('1. Define initial network architecture: %s\n', obj.folderLabel);
                
                % Architecture
                % Test different number os neurons in hidden layers 1 and 2.
                % Pick the best. Train with different random initializations (contMax).
                
                obj.detNetArch();
                obj.partialResEpochs = [obj.partialResEpochs; obj.partialResults];
                obj.partialResEpochs
                obj.confMatrix = Utils.calcConfMatrix(obj.bestNet, obj.inpData(:, obj.bestTrainRecord.testInd), obj.targets(:, obj.bestTrainRecord.testInd));
                obj.writeToFile(sprintf('\\arch_net_%fhit_%dh1_%dh2.mat', obj.partialResEpochs(end, 5), obj.partialResEpochs(end, 2), obj.partialResEpochs(end, 3)));

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                % 2. Perform model validation %
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                obj = obj.loadFromFile(obj.netFile);
                
                disp('2. Perform model validation')
                
                % Validate model %
                %%%%%%%%%%%%%%%%%%
                % Take the best arquitecture and apply Monte Carlo.
                % Number of Monte Carlo repetitions = numRepet.
                % For each numRepet initialize contMax times and keep the best.
                % This is the best performance for that Monte Carlo round.
                % Each Monte Carlo round samples training, validation and test sets
                % randomly.
                
                [AvgMSE, AvgHitRate] = obj.validModel();
                
                if AvgHitRate > obj.bestAvgHitRate
                    
                    % Net improved by 5%
                    if AvgHitRate >= 0.05*obj.bestAvgHitRate
                        perfTest = 0;
                    else
                        perfTest = perfTest + 1;
                    end
                    
                    obj.bestAvgHitRate = AvgHitRate;
                    obj.bestAvgMSE = AvgMSE;
                    obj.bestAvgNet = obj.bestNet;
                    obj.bestAvgNetTrainRecord = obj.bestTrainRecord;
                    obj.bestEpoch = obj.epoch;
                    obj.confMatrix = Utils.calcConfMatrix(obj.bestAvgNet, obj.inpData(:, obj.bestAvgNetTrainRecord.testInd), obj.targets(:, obj.bestAvgNetTrainRecord.testInd));
                    obj.writeToFile(sprintf('\\validated_net_%fhit_%dh1_%dh2.mat', obj.bestAvgHitRate, obj.bestAvgNet.layers{1}.size, obj.bestAvgNet.layers{2}.size));
                else
                    perfTest = perfTest + 1;
                end
                
                AvgRateEvol(1, obj.epoch) = obj.epoch;
                AvgRateEvol(2, obj.epoch) = obj.bestNet.layers{1}.size;
                AvgRateEvol(3, obj.epoch) = obj.bestNet.layers{2}.size;
                AvgRateEvol(4, obj.epoch) = AvgHitRate;
                AvgMSEEvol(obj.epoch) = AvgMSE;
                
                txt = sprintf('\nmain (best average performance): %5i\t%5s\t%5s\t%10s\t%10s\n', obj.epoch,...
                    num2str(obj.bestNet.layers{1}.size),...
                    num2str(obj.bestNet.layers{2}.size),...
                    num2str(AvgMSE),...
                    num2str(AvgHitRate));
                disp(txt)
                
%                 close all
%                 stem(AvgRateEvol(1,:), AvgRateEvol(4,:),'k')
%                 hold on
%                 stem(obj.bestEpoch, obj.bestAvgHitRate,'r')
                
%                 title(['perfTest: ' num2str(perfTest)])
%                 grid on
%                 xlabel('epoch')
%                 ylabel('Average MSE (Architecture Evaluation)')
                
                for txt = 1:obj.epoch
                    text(AvgRateEvol(1,txt)+0.03, AvgRateEvol(4,txt), ['(' num2str(AvgRateEvol(2,txt)) ', ' num2str(AvgRateEvol(3,txt)) ', ' num2str((round(AvgRateEvol(4,txt)*100))/100) ')'] )
                end
                
                if perfTest >= 2 || obj.epoch >= 20
                    break;
                end
            end
            
            % Test the performance of the best stored neural network
            hitRate = obj.calcRate(obj.bestAvgNet, obj.bestAvgNetTrainRecord)
            hitRate = obj.calcRate(obj.bestNet, obj.bestTrainRecord)
        end
        
        function classifier = loadFromFile(obj, file)
            load(file);
        end
        
        function evaluate(obj, inputData, targets)
            %evaluate Evaluate inputs according to the best average net
            
            obj.inpData = inputData';
            obj.targets = targets';
            
            % Compute the outputs
            hitRate = 0;
            
            for i = 1:size(obj.inpData, 2)
                out = obj.bestAvgNet(obj.inpData(:, i));
                out = obj.setOutput(out);
                
                target = obj.targets(:, i);
                
                if out == target
                    hitRate = hitRate + 1;
                end
            end
            
            hitRate = (hitRate/size(obj.inpData, 2))*100;
            
            fprintf('Hit rate on separated data: %.2f%%\n\n', hitRate);
            
            %% Save to file
            sepFile = strcat(obj.rootFolder, obj.folderLabel, sprintf('\\sep_data_%fhit.mat', hitRate));
            obj.confMatrix = Utils.calcConfMatrix(obj.bestAvgNet, obj.inpData, obj.targets);
            classifier = obj;
            save(sepFile, 'hitRate', 'inputData', 'targets', 'classifier');
        end
    end
    
    methods(Access = private)
        function detNetArch(obj)
            obj.prepareDataAndTargets();
            
            % End training
            endTr = 0;
            
            % Size of training set
            dataSize = size(obj.inpData, 2);
            keyboard;
            
            % Best performance
            obj.bestPerf = Inf;
            obj.bestRate = 0;
            prevRate = 0;
            
            % Minimum number of neurons
            minh1 = sqrt(dataSize/obj.numberClasses);
            
            %%%%%%%%%%%%%%%%%%%%%%%
            % Define architecture %
            %%%%%%%%%%%%%%%%%%%%%%%
            
            % First hidden layer
%             i = round(minh1);
%             i = floor(minh1);
            i = round(minh1/2);
            if i <= 0
                i = 1;
            end
            
            % Initialize best_tr and best_net
            obj.currentBestTrainRecord = 0;
            obj.currentBestNet = 0;
            
            % Stores partial results
            obj.partialResults = [];
            resCont = 1;
            
            while (i <= minh1 && ~endTr)
                
                % Second hidden layer
%                 j = round(minh1/3);
                j = round(i/3);
                
%                 while (j <= round(i/1.5) && ~endTr)
                while (j <= round(i/1.5) && ~endTr)
                    if j <= 0
                        j = 1;
                    end

                    obj.currentNet                        = feedforwardnet([i j]);
                    obj.currentNet                        = configure(obj.currentNet, obj.inpData, obj.targets);
                    obj.currentNet.layers{1}.transferFcn  = 'tansig';
                    obj.currentNet.layers{2}.transferFcn  = 'tansig';
                    obj.currentNet.trainParam.epochs      = 200;
                    obj.currentNet.divideFcn              = 'divideint'; % http://www.mathworks.com/help/nnet/ref/divideint.html
                    obj.currentNet.divideParam.trainRatio = obj.trainProp;
                    obj.currentNet.divideParam.valRatio   = obj.valProp;
                    obj.currentNet.divideParam.testRatio  = obj.testProp;
                    obj.currentNet.trainParam.showWindow  = false;
                    
                    fprintf('detNetArch (search for best achitecture):\t%i\t%i\n', i, j);
                    
                    endTr = obj.multipleNNtrain(endTr);
                    
                    % Save best network
                    if obj.bestRate < obj.currentBestRate
                        obj.bestNet = obj.currentBestNet;
                        obj.bestPerf = obj.currentBestPerf;
                        obj.bestRate = obj.currentBestRate;
                        obj.bestTrainRecord = obj.currentBestTrainRecord;
                        
                        txt = sprintf('detNetArch (best performance): %5i\t%5s\t%5s\t%10s\t%10s', obj.epoch, num2str(obj.bestNet.layers{1}.size), num2str(obj.bestNet.layers{2}.size), num2str(obj.bestPerf), num2str(obj.bestRate));
                        disp(txt)
                    end
                    
                    % Stores each better partial result
                    if prevRate ~= obj.bestRate
                        
                        obj.partialResults(resCont, :) = [obj.epoch obj.bestNet.layers{1}.size obj.bestNet.layers{2}.size obj.bestTrainRecord.best_perf obj.bestRate];
                        
                        prevRate = obj.bestRate;
                        
                        resCont = resCont + 1;
                        
                    end
                    
                    % Increment the number of neurons of the second hidden layer
                    j = j + 2;
                    
                end
                
                % Increment the number of neurons of the first hidden layer
                i = i + 2;
            end
        end
        
        function endTr = multipleNNtrain(obj, endTr)
            obj.currentBestNet = [];
            obj.currentTrainRecord = [];
            obj.currentBestRate = 0;
            obj.currentBestPerf = Inf;
            
            % Number of trainings
            count = 0;
            
            % The show begins
            while (count < obj.contMax && ~endTr)
                
                % Counter
                count = count + 1;
                
                % Initialize weights
                obj.currentNet = init(obj.currentNet);
                
                % Begin training
                [obj.currentNet, obj.currentTrainRecord] = train(obj.currentNet, obj.inpData, obj.targets);
                
                % Hit rate
                Rate = obj.calcRate(obj.currentNet, obj.currentTrainRecord);
                
                % Save best network
                if obj.currentBestRate < Rate
                    
                    obj.currentBestPerf = obj.currentTrainRecord.best_perf;
                    obj.currentBestRate = Rate;
                    
                    obj.currentBestNet = obj.currentNet;
                    obj.currentBestTrainRecord = obj.currentTrainRecord;
                    
                    txt = sprintf('multipleNNtrain (best performance): %5i\t%5s\t%5s\t%10s\t%10s', obj.epoch, num2str(obj.currentBestNet.layers{1}.size), num2str(obj.currentBestNet.layers{2}.size), num2str(obj.currentBestPerf), num2str(obj.currentBestRate));
                    disp(txt)
                end
                
                % If performance is 100% stops training completely
                if Rate == 100
                    endTr = 1;
                end
            end
        end
        
        function hitRate = calcRate(obj, net, tr)
            % Compute the outputs for the test set
            hitRate = 0;
            
            for i = 1:size(tr.testInd, 2)
                out = net(obj.inpData(:, tr.testInd(1, i)));
                out = obj.setOutput(out);
                
                target = obj.targets(:, tr.testInd(1, i));
                
                if out == target
                    hitRate = hitRate + 1;
                end
            end
            
            hitRate = (hitRate/length(tr.testInd))*100;
        end
        
        function prepareDataAndTargets(obj)
            obj.inpData = obj.inpData';
            obj.targets = obj.targets';
            
            %% Sort targets and data
            [tempTargets, idx] = sortrows(obj.targets);
            data = obj.inpData(idx, :);
            
            
            %% Randomly permute inside classes
            u = unique(tempTargets, 'rows');
            obj.numberClasses = size(u, 1);
            obj.inpData = [];
            obj.targets = [];
            
            for i = 1:size(u, 1)
                currentTarget = u(i, :);
                flag = ismember(tempTargets, currentTarget, 'rows');
                idx = find(flag);
                
                tempInpData = data(idx, :);
                
                idx = randperm(size(tempInpData, 1));
                obj.inpData = [obj.inpData; tempInpData(idx, :)];
                
                % Update targets
                last = size(obj.targets);
                for j = last + 1:last + size(tempInpData, 1)
                    obj.targets(j, :) = currentTarget;
                end
                
            end
            
            obj.inpData = obj.inpData';
            obj.targets = obj.targets';
        end
        
        function writeToFile(obj, name)
            %% Ensure the existence of the output folder
            classifier = obj;
            
            folder = strcat(obj.rootFolder, obj.folderLabel);
            if exist(folder, 'dir') ~= 7
                mkdir(folder);
            end
            
            %% Save to file
            obj.netFile = strcat(folder, name);
            save(obj.netFile, 'classifier');
        end
        
        function [AvgMSE, AvgHitRate] = validModel(obj)
            % Perform multiple trainings sampling data randomly
            AvgMSE = [];
            AvgHitRate = [];
            
            for i = 1:obj.numRepet
                % Create a network with the same architecture of bestNet
                obj.currentNet = feedforwardnet([obj.bestNet.layers{1}.size obj.bestNet.layers{2}.size]);
                obj.currentNet.layers{1}.transferFcn  = obj.bestNet.layers{1}.transferFcn;
                obj.currentNet.layers{2}.transferFcn  = obj.bestNet.layers{2}.transferFcn;
                obj.currentNet.trainParam.epochs      = obj.bestNet.trainParam.epochs;
                obj.currentNet.divideFcn              = obj.bestNet.divideFcn;
                obj.currentNet.divideParam.trainRatio = obj.bestNet.divideParam.trainRatio;
                obj.currentNet.divideParam.valRatio   = obj.bestNet.divideParam.valRatio;
                obj.currentNet.divideParam.testRatio  = obj.bestNet.divideParam.testRatio;
                obj.currentNet.trainParam.showWindow  = obj.bestNet.trainParam.showWindow;
                
                % Initialize endTr
                endTr = 0;
                
                % Randomize data
                obj.prepareDataAndTargets();
                
                % Begin training
                endTr = obj.multipleNNtrain(endTr);
                
                AvgMSE(i) = obj.currentBestPerf;
                
                % Hit rate
                hitRate = obj.calcRate(obj.currentBestNet, obj.currentBestTrainRecord);
                AvgHitRate(i) = hitRate;
                
                disp(['validModel: ' num2str(100*i/obj.numRepet) '%'])
                
            end
            
            AvgMSE = sum(AvgMSE)/obj.numRepet;
            AvgHitRate = sum(AvgHitRate)/obj.numRepet;
        end
        
        function out = setOutput(obj, in)
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