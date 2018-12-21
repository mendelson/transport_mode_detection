classdef HierClassifier
    properties
        %% Nets
        netIsMovement
        netClassOfMovement
        netCar
        netBike
        netFoot
        
        %% Data info
        windowSize
        rootFolder
        area
    end
    
    methods
        function obj = HierClassifier(ar, wS)
            obj.windowSize = wS;
            obj.area = strcat('\\', ar);
            obj.rootFolder = '.\net';
            
            %% Load isMovement net
            obj.netIsMovement = obj.loadNet('\\isMovement');
            obj.netClassOfMovement = obj.loadNet('\\classOfMovement');
            obj.netCar = obj.loadNet('\\car');
            obj.netBike = obj.loadNet('\\bike');
            obj.netFoot = obj.loadNet('\\foot');
        end
        
        function out = evaluate(obj, input)
            % isMovement
            tempOut = obj.evaluateNetIsMovement(input);
            
            if tempOut == 1
                tempOut = obj.evaluateNetClassOfMovement(input);
                
                switch tempOut
                    case 1
                        out = obj.evaluateNetCar(input);
                    case 2
                        out = obj.evaluateNetBike(input);
                    case 3
                        out = obj.evaluateNetFoot(input);
                end
            else
                % no danger
                out = -1;
            end
        end
    end
    
    methods(Access = private)
        function net = loadNet(obj, scenario)
            file = strcat(obj.rootFolder, scenario, obj.area, sprintf('\\%02dsecWindow', obj.windowSize));
            file = strcat(file, '\\', Utils.getFileNameThatContains(file, 'sep_data'));
            load(file);
            
            net = classifier.bestAvgNet;
        end
        
        function out = evaluateNetIsMovement(obj, input)
            out = obj.netIsMovement(input(1, 2:end)');
            out = Utils.setOutput(out);
        end
        
        function out = evaluateNetClassOfMovement(obj, input)
            out = obj.netClassOfMovement(input(1, 2:end)');
            out = Utils.setOutput(out);
            
            out = find(out == 1);
        end
    
        function out = evaluateNetCar(obj, input)
            out = obj.netCar(input(1, 2:end)');
            out = Utils.setOutput(out);
        end
        
        function out = evaluateNetBike(obj, input)
            out = obj.netBike(input(1, 2:end)');
            out = Utils.setOutput(out);
        end
        
        function out = evaluateNetFoot(obj, input)
            out = obj.netFoot(input(1, 2:end)');
            out = Utils.setOutput(out);
        end
        
    end
    
end

