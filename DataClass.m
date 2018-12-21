classdef DataClass < handle
    %DATACLASS to handle data read from files
    %   This class handles all operations over the dataset
    
    %% Private
    properties(Access = private)
        %     properties
        %% Data holders
        rawData
        inner
        middle
        external
        idPath
        
        %% Classes data holders
        innerCarMoving
        middleCarMoving
        externalCarMoving
        innerBikeMoving
        middleBikeMoving
        externalBikeMoving
        innerFootMoving
        middleFootMoving
        externalFootMoving
        innerMoving
        middleMoving
        externalMoving
        sepIdx
        
        %% System properties
        fps
        minutesLimit
        timeLimit
        windowSize
        acquisitionsInWindow
        amountOfClasses
        neededAcquisitions
        preparationTime
        
        %% Path variables
        rootFolder
        outputRootFolder
        % Transport mode
        car
        bike
        foot
        % Device holder
        hand
        pocket
        panel
        % Holder status
        engaged
        talking
        % Motion status
        moving
        notMoving
        % File name
        file
        % Field delimiter
        delimiter
    end
    
    methods
        function obj = DataClass(wSize)
            %% Class constructor
            
            obj.fps = 500;
            obj.minutesLimit = 18;
            obj.timeLimit = obj.minutesLimit*60; % second(s)
            obj.windowSize = wSize; % second(s)
            obj.acquisitionsInWindow = obj.windowSize*obj.fps; % number of acquisitions in one window
            obj.amountOfClasses = 18;
            obj.preparationTime = 5; % second(s)
            
            %% Define path variables
            obj.rootFolder = '.\samples';
            obj.outputRootFolder = '.\dataset';
            % Transport mode
            obj.car = '\car';
            obj.bike = '\bike';
            obj.foot = '\foot';
            % Device holder
            obj.hand = '\hand';
            obj.pocket = '\pocket';
            obj.panel = '\panel';
            % Holder status
            obj.engaged = '\engaged';
            obj.talking = '\talking';
            % Motion status
            obj.moving = '\moving';
            obj.notMoving = '\not moving';
            % File name
            obj.file = '\data';
            % Field delimiter
            obj.delimiter = ';';
            
            %% Fill matrix with class' ids and respective paths
            obj.idPath = cell(obj.amountOfClasses, 1);
            obj.idPath{1} = strcat(obj.rootFolder, obj.car, obj.hand, obj.moving, obj.engaged, obj.file, '.txt');
            obj.idPath{2} = strcat(obj.rootFolder, obj.car, obj.hand, obj.moving, obj.talking, obj.file, '.txt');
            obj.idPath{3} = strcat(obj.rootFolder, obj.car, obj.hand, obj.notMoving, obj.engaged, obj.file, '.txt');
            obj.idPath{4} = strcat(obj.rootFolder, obj.car, obj.hand, obj.notMoving, obj.talking, obj.file, '.txt');
            obj.idPath{5} = strcat(obj.rootFolder, obj.car, obj.panel, obj.moving, obj.file, '.txt');
            obj.idPath{6} = strcat(obj.rootFolder, obj.car, obj.panel, obj.notMoving, obj.file, '.txt');
            obj.idPath{7} = strcat(obj.rootFolder, obj.bike, obj.hand, obj.moving, obj.engaged, obj.file, '.txt');
            obj.idPath{8} = strcat(obj.rootFolder, obj.bike, obj.hand, obj.notMoving, obj.engaged, obj.file, '.txt');
            obj.idPath{9} = strcat(obj.rootFolder, obj.bike, obj.panel, obj.moving, obj.file, '.txt');
            obj.idPath{10} = strcat(obj.rootFolder, obj.bike, obj.panel, obj.notMoving, obj.file, '.txt');
            obj.idPath{11} = strcat(obj.rootFolder, obj.bike, obj.pocket, obj.moving, obj.file, '.txt');
            obj.idPath{12} = strcat(obj.rootFolder, obj.bike, obj.pocket, obj.notMoving, obj.file, '.txt');
            obj.idPath{13} = strcat(obj.rootFolder, obj.foot, obj.hand, obj.moving, obj.engaged, obj.file, '.txt');
            obj.idPath{14} = strcat(obj.rootFolder, obj.foot, obj.hand, obj.moving, obj.talking, obj.file, '.txt');
            obj.idPath{15} = strcat(obj.rootFolder, obj.foot, obj.hand, obj.notMoving, obj.engaged, obj.file, '.txt');
            obj.idPath{16} = strcat(obj.rootFolder, obj.foot, obj.hand, obj.notMoving, obj.talking, obj.file, '.txt');
            obj.idPath{17} = strcat(obj.rootFolder, obj.foot, obj.pocket, obj.moving, obj.file, '.txt');
            obj.idPath{18} = strcat(obj.rootFolder, obj.foot, obj.pocket, obj.notMoving, obj.file, '.txt');
        end
        
        function generateDataSet(obj)
            %generateDataSet Generate data set
            % Use this function to generate the entire data set
            obj.loadFiles();
            obj.separateWindows();
            obj.writeDataSetToFiles();
            obj.separateInClasses();
        end
        
        function loadDataSet(obj)
            %loadDataSet Load data set
            % Use this function if you already have the data set files
            % generated
            
            obj.inner = [];
            obj.middle = [];
            obj.external =[];
            
            fprintf('\n\n===== Loading data set from files =====\n');
            for i = 1:obj.amountOfClasses
                fprintf('Current class #: %d/%d\n', i, obj.amountOfClasses);
                
                innerPath = strcat(obj.outputRootFolder, '\', num2str(i), '\inner', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat');
                middlePath = strcat(obj.outputRootFolder, '\', num2str(i), '\middle', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat');
                externalPath = strcat(obj.outputRootFolder, '\', num2str(i), '\external', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat');
                
                innerTemp = load(innerPath);
                innerTemp = innerTemp.innerDataSet;
                obj.inner = [obj.inner; innerTemp];
                
                middleTemp = load(middlePath);
                middleTemp = middleTemp.middleDataSet;
                obj.middle = [obj.middle; middleTemp];
                
                externalTemp = load(externalPath);
                externalTemp = externalTemp.externalDataSet;
                obj.external = [obj.external; externalTemp];
            end
            
            obj.separateInClasses();
        end
        
        function setWindowSize(obj, ws)
            obj.windowSize = ws;
            obj.acquisitionsInWindow = obj.windowSize*obj.fps;
        end
        
        %% Getters for data
        %% Car
        function [sepData, sepTargets, data, targets] = getCarMovementSets(obj, area)
            %getCarMovementSets Setup data and targets for carMoving scenario
            % Gets balanced data, targets and idx for car->moving considering
            % only two classes: danger (hand engaged and talking) and notDanger
            % (panel)
            
            sepData = [];
            sepTargets = [];
            data = [];
            targets = [];
            
            dangerIdx = [];
            notDangerIdx = [];
            
            sepDataDangerIdx = [];
            sepDataNotDangerIdx = [];
            
            %% Pick 15% of each class to be separated from the nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 1 || obj.inner(obj.sepIdx(i), 1) == 2
                    %% engaged and talking
                    sepDataDangerIdx = [sepDataDangerIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 5
                    %% panel
                    sepDataNotDangerIdx = [sepDataNotDangerIdx obj.sepIdx(i)];
                end
            end

            %% Balance classes
            sepDataDangerIdx = downsample(sepDataDangerIdx, 2);
            
            sepSize = length(sepDataDangerIdx);
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.inner(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.middle(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.external(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
            
            %% Set data and targets for nnet
            for i = 1:size(obj.inner, 1)
                if obj.inner(i, 1) == 1 || obj.inner(i, 1) == 2
                    %% engaged and talking
                    dangerIdx = [dangerIdx i];
                elseif obj.inner(i, 1) == 5
                    %% panel
                    notDangerIdx = [notDangerIdx i];
                end
            end
            
            % Remove data that belongs to sep data
            idx = [];
            for i = 1:size(dangerIdx, 2)
                if sum(ismember(sepDataDangerIdx, dangerIdx(i)))
                    idx = [idx i];
                end
            end
            dangerIdx(idx) = [];
            % Balance class
            dangerIdx = downsample(dangerIdx, 2);
            
            idx = [];
            for i = 1:size(notDangerIdx, 2)
                if sum(ismember(sepDataNotDangerIdx, notDangerIdx(i)))
                    idx = [idx i];
                end
            end
            notDangerIdx(idx) = [];
            
            % Mount data and targets
            if strcmp(area, 'inner') == 1
                data = obj.inner(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.inner(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle') == 1
                data = obj.middle(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.middle(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'external') == 1
                data = obj.external(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.external(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_middle') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_external') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle_external') == 1
                data = [obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'all') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            else
                error('Invalid data area!')
            end
        end
        
        %% Bike
        function [sepData, sepTargets, data, targets] = getBikeMovementSets(obj, area)
            %getBikeMovementSets Setup classifier for bikeMoving scenario
            % Sets balanced data, targets and idx for bike->moving considering
            % only two classes: danger (hand engaged) and notDanger
            % (panel and pocket)
            
            sepData = [];
            sepTargets = [];
            data = [];
            targets = [];
            
            dangerIdx = [];
            notDangerIdx = [];
            
            sepDataDangerIdx = [];
            sepDataNotDangerIdx = [];
            
            %% Pick 15% of each class to be separated from the nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 7
                    %% engaged
                    sepDataDangerIdx = [sepDataDangerIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 9 || obj.inner(obj.sepIdx(i), 1) == 11
                    %% panel and pocket
                    sepDataNotDangerIdx = [sepDataNotDangerIdx obj.sepIdx(i)];
                end
            end

            %% Balance classes
            sepDataNotDangerIdx = downsample(sepDataNotDangerIdx, 2);
            
            sepSize = length(sepDataDangerIdx);
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.inner(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.middle(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.external(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
            
            %% Set data and targets for nnet
            for i = 1:size(obj.inner, 1)
                if obj.inner(i, 1) == 7
                    %% engaged
                    dangerIdx = [dangerIdx i];
                elseif obj.inner(i, 1) == 9 || obj.inner(i, 1) == 11
                    %% panel and pocket
                    notDangerIdx = [notDangerIdx i];
                end
            end
            
            % Remove data that belongs to sep data
            idx = [];
            for i = 1:size(dangerIdx, 2)
                if sum(ismember(sepDataDangerIdx, dangerIdx(i)))
                    idx = [idx i];
                end
            end
            dangerIdx(idx) = [];
            
            idx = [];
            for i = 1:size(notDangerIdx, 2)
                if sum(ismember(sepDataNotDangerIdx, notDangerIdx(i)))
                    idx = [idx i];
                end
            end
            notDangerIdx(idx) = [];
            % Balance class
            notDangerIdx = downsample(notDangerIdx, 2);
            
            % Mount data and targets
            if strcmp(area, 'inner') == 1
                data = obj.inner(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.inner(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle') == 1
                data = obj.middle(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.middle(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'external') == 1
                data = obj.external(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.external(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_middle') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_external') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle_external') == 1
                data = [obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'all') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            else
                error('Invalid data area!')
            end
        end
        
        %% Foot
        function [sepData, sepTargets, data, targets] = getFootMovementSets(obj, area)
            %getFootMovementSets Setup classifier for footMoving scenario
            % Sets balanced data, targets and idx for foot->moving considering
            % only two classes: danger (hand engaged and talking) and notDanger
            % (pocket)
            
            sepData = [];
            sepTargets = [];
            data = [];
            targets = [];
            
            dangerIdx = [];
            notDangerIdx = [];
            
            sepDataDangerIdx = [];
            sepDataNotDangerIdx = [];
            
            %% Pick 15% of each class to be separated from the nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 13 || obj.inner(obj.sepIdx(i), 1) == 14
                    %% engaged and talking
                    sepDataDangerIdx = [sepDataDangerIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 17
                    %% pocket
                    sepDataNotDangerIdx = [sepDataNotDangerIdx obj.sepIdx(i)];
                end
            end

            %% Balance classes
            sepDataDangerIdx = downsample(sepDataDangerIdx, 2);
            
            sepSize = length(sepDataDangerIdx);
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.inner(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.middle(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.external(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
            
            %% Set data and targets for nnet
            for i = 1:size(obj.inner, 1)
                if obj.inner(i, 1) == 13 || obj.inner(i, 1) == 14
                    %% engaged and talking
                    dangerIdx = [dangerIdx i];
                elseif obj.inner(i, 1) == 17
                    %% panel
                    notDangerIdx = [notDangerIdx i];
                end
            end
            
            % Remove data that belongs to sep data
            idx = [];
            for i = 1:size(dangerIdx, 2)
                if sum(ismember(sepDataDangerIdx, dangerIdx(i)))
                    idx = [idx i];
                end
            end
            dangerIdx(idx) = [];
            % Balance class
            dangerIdx = downsample(dangerIdx, 2);
            
            idx = [];
            for i = 1:size(notDangerIdx, 2)
                if sum(ismember(sepDataNotDangerIdx, notDangerIdx(i)))
                    idx = [idx i];
                end
            end
            notDangerIdx(idx) = [];
            
            % Mount data and targets
            if strcmp(area, 'inner') == 1
                data = obj.inner(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.inner(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle') == 1
                data = obj.middle(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.middle(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'external') == 1
                data = obj.external(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.external(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_middle') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_external') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle_external') == 1
                data = [obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'all') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            else
                error('Invalid data area!')
            end
        end
        
        %% Is movement
        function [sepData, sepTargets, data, targets] = getIsMovementSets(obj, area)
            %getIsMovementSets Setup classifier for isMovement scenario
            % Sets balanced data, targets and idx
            
            sepData = [];
            sepTargets = [];
            data = [];
            targets = [];
            
            dangerIdx = [];
            notDangerIdx = [];
            
            sepDataDangerIdx = [];
            sepDataNotDangerIdx = [];
            
            %% Pick 15% of each class to be separated from the nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 1 ||...
                        obj.inner(obj.sepIdx(i), 1) == 2 ||...
                        obj.inner(obj.sepIdx(i), 1) == 5 ||...
                        obj.inner(obj.sepIdx(i), 1) == 7 ||...
                        obj.inner(obj.sepIdx(i), 1) == 9 ||...
                        obj.inner(obj.sepIdx(i), 1) == 11 ||...
                        obj.inner(obj.sepIdx(i), 1) == 13 ||...
                        obj.inner(obj.sepIdx(i), 1) == 14 ||...
                        obj.inner(obj.sepIdx(i), 1) == 17
                    %% moving
                    sepDataDangerIdx = [sepDataDangerIdx obj.sepIdx(i)];
                else
                    %% not moving
                    sepDataNotDangerIdx = [sepDataNotDangerIdx obj.sepIdx(i)];
                end
            end
            
            sepSize = length(sepDataDangerIdx);
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.inner(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.middle(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataDangerIdx, 2:end);
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = obj.external(sepDataNotDangerIdx, 2:end);
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataDangerIdx, 2:end) obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                s1 = size(sepData, 1);
                sepTargets(1:s1, 1) = 1;
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                s2 = size(temp, 1);
                sepTargets(s1 + 1:s1 + s2, 1) = -1;
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
            
            %% Set data and targets for nnet
            for i = 1:size(obj.inner, 1)
                if obj.inner(i, 1) == 1 ||...
                        obj.inner(i, 1) == 2 ||...
                        obj.inner(i, 1) == 5 ||...
                        obj.inner(i, 1) == 7 ||...
                        obj.inner(i, 1) == 9 ||...
                        obj.inner(i, 1) == 11 ||...
                        obj.inner(i, 1) == 13 ||...
                        obj.inner(i, 1) == 14 ||...
                        obj.inner(i, 1) == 17
                    %% moving
                    dangerIdx = [dangerIdx i];
                else
                    %% not moving
                    notDangerIdx = [notDangerIdx i];
                end
            end
            
            % Remove data that belongs to sep data
            idx = [];
            for i = 1:size(dangerIdx, 2)
                if sum(ismember(sepDataDangerIdx, dangerIdx(i)))
                    idx = [idx i];
                end
            end
            dangerIdx(idx) = [];
            
            idx = [];
            for i = 1:size(notDangerIdx, 2)
                if sum(ismember(sepDataNotDangerIdx, notDangerIdx(i)))
                    idx = [idx i];
                end
            end
            notDangerIdx(idx) = [];
            
            % Mount data and targets
            if strcmp(area, 'inner') == 1
                data = obj.inner(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.inner(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle') == 1
                data = obj.middle(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.middle(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'external') == 1
                data = obj.external(dangerIdx, 2:end);
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = obj.external(notDangerIdx, 2:end);
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_middle') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'inner_external') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'middle_external') == 1
                data = [obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            elseif strcmp(area, 'all') == 1
                data = [obj.inner(dangerIdx, 2:end) obj.middle(dangerIdx, 2:end) obj.external(dangerIdx, 2:end)];
                s1 = size(data, 1);
                targets(1:s1, 1) = 1;
                temp = [obj.inner(notDangerIdx, 2:end) obj.middle(notDangerIdx, 2:end) obj.external(notDangerIdx, 2:end)];
                s2 = size(temp, 1);
                targets(s1 + 1:s1 + s2, 1) = -1;
                data = [data; temp];
            else
                error('Invalid data area!')
            end
        end
        
        %% Class of movement
        function [sepData, sepTargets, data, targets] = getClassOfMovementSets(obj, area)
            %getClassOfMovementSets Setup classifier for classOfMovement scenario
            % Sets balanced data, targets and idx
            
            sepData = [];
            sepTargets = [];
            data = [];
            targets = [];
            
            carIdx = [];
            bikeIdx = [];
            footIdx = [];

            sepDataCarIdx = [];
            sepDataBikeIdx = [];
            sepDataFootIdx = [];
            
            %% Pick 15% of each class to be separated from the nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 1 ||...
                        obj.inner(obj.sepIdx(i), 1) == 2 ||...
                        obj.inner(obj.sepIdx(i), 1) == 5
                    %% Car->moving
                    sepDataCarIdx = [sepDataCarIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 7 ||...
                        obj.inner(obj.sepIdx(i), 1) == 9 ||...
                        obj.inner(obj.sepIdx(i), 1) == 11
                    %% Bike->moving
                    sepDataBikeIdx = [sepDataBikeIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 13 ||...
                        obj.inner(obj.sepIdx(i), 1) == 14 ||...
                        obj.inner(obj.sepIdx(i), 1) == 17
                    %% Foot->moving
                    sepDataFootIdx = [sepDataFootIdx obj.sepIdx(i)];
                end
            end
            
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataCarIdx, 2:end);
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.inner(sepDataBikeIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = obj.inner(sepDataFootIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataCarIdx, 2:end);
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.middle(sepDataBikeIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = obj.middle(sepDataFootIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataCarIdx, 2:end);
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.external(sepDataBikeIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = obj.external(sepDataFootIdx, 2:end);
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataCarIdx, 2:end) obj.middle(sepDataCarIdx, 2:end)];
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(sepDataBikeIdx, 2:end) obj.middle(sepDataBikeIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = [obj.inner(sepDataFootIdx, 2:end) obj.middle(sepDataFootIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataCarIdx, 2:end) obj.external(sepDataCarIdx, 2:end)];
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(sepDataBikeIdx, 2:end) obj.external(sepDataBikeIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = [obj.inner(sepDataFootIdx, 2:end) obj.external(sepDataFootIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataCarIdx, 2:end) obj.external(sepDataCarIdx, 2:end)];
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.middle(sepDataBikeIdx, 2:end) obj.external(sepDataBikeIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = [obj.middle(sepDataFootIdx, 2:end) obj.external(sepDataFootIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataCarIdx, 2:end) obj.middle(sepDataCarIdx, 2:end) obj.external(sepDataCarIdx, 2:end)];
                s = size(sepData, 1);
                sepTargets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(sepDataBikeIdx, 2:end) obj.middle(sepDataBikeIdx, 2:end) obj.external(sepDataBikeIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                sepData = [sepData; temp];
                temp = [obj.inner(sepDataFootIdx, 2:end) obj.middle(sepDataFootIdx, 2:end) obj.external(sepDataFootIdx, 2:end)];
                s = size(temp, 1);
                sepTargets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
            
            %% Set data and targets for nnet
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 1 ||...
                        obj.inner(obj.sepIdx(i), 1) == 2 ||...
                        obj.inner(obj.sepIdx(i), 1) == 5
                    %% Car->moving
                    carIdx = [carIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 7 ||...
                        obj.inner(obj.sepIdx(i), 1) == 9 ||...
                        obj.inner(obj.sepIdx(i), 1) == 11
                    %% Bike->moving
                    bikeIdx = [bikeIdx obj.sepIdx(i)];
                elseif obj.inner(obj.sepIdx(i), 1) == 13 ||...
                        obj.inner(obj.sepIdx(i), 1) == 14 ||...
                        obj.inner(obj.sepIdx(i), 1) == 17
                    %% Foot->moving
                    footIdx = [footIdx obj.sepIdx(i)];
                end
            end
            
            % Remove data that belongs to sep data
            idx = [];
            for i = 1:size(carIdx, 2)
                if sum(ismember(sepDataCarIdx, carIdx(i)))
                    idx = [idx i];
                end
            end
            carIdx(idx) = [];
            
            idx = [];
            for i = 1:size(bikeIdx, 2)
                if sum(ismember(sepDataBikeIdx, bikeIdx(i)))
                    idx = [idx i];
                end
            end
            bikeIdx(idx) = [];

            idx = [];
            for i = 1:size(footIdx, 2)
                if sum(ismember(sepDataFootIdx, footIdx(i)))
                    idx = [idx i];
                end
            end
            footIdx(idx) = [];
            
            % Mount data and targets
            if strcmp(area, 'inner') == 1
                data = obj.inner(carIdx, 2:end);
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.inner(bikeIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = obj.inner(footIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                data = obj.middle(carIdx, 2:end);
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.middle(bikeIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = obj.middle(footIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                data = obj.external(carIdx, 2:end);
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = obj.external(bikeIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = obj.external(footIdx, 2:end);
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                data = [obj.inner(carIdx, 2:end) obj.middle(carIdx, 2:end)];
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(bikeIdx, 2:end) obj.middle(bikeIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = [obj.inner(footIdx, 2:end) obj.middle(footIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                data = [obj.inner(carIdx, 2:end) obj.external(carIdx, 2:end)];
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(bikeIdx, 2:end) obj.external(bikeIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = [obj.inner(footIdx, 2:end) obj.external(footIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                data = [obj.middle(carIdx, 2:end) obj.external(carIdx, 2:end)];
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.middle(bikeIdx, 2:end) obj.external(bikeIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = [obj.middle(footIdx, 2:end) obj.external(footIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                data = [obj.inner(carIdx, 2:end) obj.middle(carIdx, 2:end) obj.external(carIdx, 2:end)];
                s = size(sepData, 1);
                targets = Utils.fillTargets(sepTargets, [1 -1 -1], s);
                temp = [obj.inner(bikeIdx, 2:end) obj.middle(bikeIdx, 2:end) obj.external(bikeIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 1 -1], s);
                data = [sepData; temp];
                temp = [obj.inner(footIdx, 2:end) obj.middle(footIdx, 2:end) obj.external(footIdx, 2:end)];
                s = size(temp, 1);
                targets = Utils.fillTargets(sepTargets, [-1 -1 1], s);
                data = [sepData; temp];
            else
                error('Invalid data area!')
            end
        end
        
        function sepData = getSepData(obj, area)
            sepTargets = [];
            
            sepDataDangerIdx = [];
            sepDataNotDangerIdx = [];
            
            %% Pick 15% of each class
            for i = 1:size(obj.sepIdx, 2)
                if obj.inner(obj.sepIdx(i), 1) == 1 ||...
                        obj.inner(obj.sepIdx(i), 1) == 2 ||...
                        obj.inner(obj.sepIdx(i), 1) == 5 ||...
                        obj.inner(obj.sepIdx(i), 1) == 7 ||...
                        obj.inner(obj.sepIdx(i), 1) == 9 ||...
                        obj.inner(obj.sepIdx(i), 1) == 11 ||...
                        obj.inner(obj.sepIdx(i), 1) == 13 ||...
                        obj.inner(obj.sepIdx(i), 1) == 14 ||...
                        obj.inner(obj.sepIdx(i), 1) == 17
                    %% moving
                    sepDataDangerIdx = [sepDataDangerIdx obj.sepIdx(i)];
                else
                    %% not moving
                    sepDataNotDangerIdx = [sepDataNotDangerIdx obj.sepIdx(i)];
                end
            end
            
            if strcmp(area, 'inner') == 1
                sepData = obj.inner(sepDataDangerIdx, :);
                temp = obj.inner(sepDataNotDangerIdx, :);
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle') == 1
                sepData = obj.middle(sepDataDangerIdx, :);
                temp = obj.middle(sepDataNotDangerIdx, :);
                sepData = [sepData; temp];
            elseif strcmp(area, 'external') == 1
                sepData = obj.external(sepDataDangerIdx, :);
                temp = obj.external(sepDataNotDangerIdx, :);
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_middle') == 1
                sepData = [obj.inner(sepDataDangerIdx, :) obj.middle(sepDataDangerIdx, 2:end)];
                temp = [obj.inner(sepDataNotDangerIdx, :) obj.middle(sepDataNotDangerIdx, 2:end)];
                sepData = [sepData; temp];
            elseif strcmp(area, 'inner_external') == 1
                sepData = [obj.inner(sepDataDangerIdx, :) obj.external(sepDataDangerIdx, 2:end)];
                temp = [obj.inner(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                sepData = [sepData; temp];
            elseif strcmp(area, 'middle_external') == 1
                sepData = [obj.middle(sepDataDangerIdx, :) obj.external(sepDataDangerIdx, 2:end)];
                temp = [obj.middle(sepDataNotDangerIdx, :) obj.external(sepDataNotDangerIdx, 2:end)];
                sepData = [sepData; temp];
            elseif strcmp(area, 'all') == 1
                sepData = [obj.inner(sepDataDangerIdx, :) obj.middle(sepDataDangerIdx, 2:end) obj.external(sepDataDangerIdx, 2:end)];
                temp = [obj.inner(sepDataNotDangerIdx, :) obj.middle(sepDataNotDangerIdx, 2:end) obj.external(sepDataNotDangerIdx, 2:end)];
                sepData = [sepData; temp];
            else
                error('Invalid data area!')
            end
        end
        
        %% Window size getter
        function out = getWindowSize(obj)
            out = obj.windowSize;
        end
        
    end
    methods(Access = private)
        %% Load data files to memory
        function loadFiles(obj)
            fprintf('\n\n===== Reading files =====\n');
            obj.rawData = [];
            temp = [];
            for i = 1:obj.amountOfClasses
                fprintf('Reading file %s\n', obj.idPath{i});
                temp = dlmread(obj.idPath{i}, obj.delimiter);
                temp = obj.removeUnnecessaryAcquisitions(temp);
                classCol(1:size(temp), 1) = i;
                temp = [classCol temp];
                obj.rawData = [obj.rawData; temp];
            end
            clear temp;
            clear classCol;
        end
        
        function m = removeUnnecessaryAcquisitions(obj, m)
            %% Remove unnecessary column
            m(:, end) = [];
            %% Remove first 3 seconds of recording due to phone preparation usage
            m(1:obj.preparationTime*obj.fps, :) = [];
            %% Calculate amount of acquisitions necessary to fill time window
            obj.neededAcquisitions = obj.acquisitionsInWindow*ceil((obj.timeLimit*obj.fps)/obj.acquisitionsInWindow);
            if obj.neededAcquisitions > size(m, 1)
                error('Not enough acquisitions in input file. Needed: %d => Available: %d', obj.neededAcquisitions, size(m, 1))
            end
            %% Remove acquisitions outside the time limit
            m(obj.neededAcquisitions + 1:end, :) = [];
        end
        
        function separateWindows(obj)
            fprintf('\n\n===== Calculating neural net inputs with %d second(s) window =====\n', obj.windowSize);
            obj.inner = [];
            obj.middle = [];
            obj.external =[];
            lastLineLength = 0;
            amountOfWindows = ceil(size(obj.rawData, 1)/obj.acquisitionsInWindow);
            
            for currentWindow = 1:amountOfWindows
                %% Screen output
                for j=1:lastLineLength
                    fprintf('\b');
                end
                lastLineLength = fprintf('Current window #: %d/%d', currentWindow, amountOfWindows);
                
                %% Mount data for neural net
                firstLine = obj.acquisitionsInWindow*(currentWindow - 1) + 1;
                [innerTemp, middleTemp, externalTemp] = obj.getNetInput(obj.rawData(firstLine:firstLine + obj.acquisitionsInWindow - 1, 2:end));
                
                obj.inner = [obj.inner; obj.rawData(firstLine, 1) innerTemp];
                obj.middle = [obj.middle; obj.rawData(firstLine, 1) middleTemp];
                obj.external = [obj.external; obj.rawData(firstLine, 1) externalTemp];
                
                %                 if currentWindow == 137 || currentWindow == 138 || currentWindow == 139
                %                     fprintf('oi')
                %                 end
                
            end
        end
        
        function [ inputInner, inputMiddle, inputExternal ] = getNetInput(obj, window)
            % Calculate the input for the neural net given a window.
            % The format of each input___ is as follows (assuming 3 axes):
            % input___ = [___ConMean(1) ___ConMean(2) ___ConMean(3) ...
            %             ___CorMean(1) ___CorMean(2) ___CorMean(3) ...
            %             ___EnMean(1)  ___EnMean(2)  ___EnMean(3) ...
            %             ___HoMean(1)  ___HoMean(2)  ___HoMean(3)]
            
            %% Pre-do-things-and-stuff
            myfun = @(block_struct) 128+((block_struct.data-mean(block_struct.data))/std(block_struct.data));
            
            innerConMean = zeros(size(window, 2));
            innerCorMean = zeros(size(window, 2));
            innerEnMean = zeros(size(window, 2));
            innerHoMean = zeros(size(window, 2));
            middleConMean = zeros(size(window, 2));
            middleCorMean = zeros(size(window, 2));
            middleEnMean = zeros(size(window, 2));
            middleHoMean = zeros(size(window, 2));
            externalConMean = zeros(size(window, 2));
            externalCorMean = zeros(size(window, 2));
            externalEnMean = zeros(size(window, 2));
            externalHoMean = zeros(size(window, 2));
            
            inputInner = zeros(1, size(window, 2)*4);
            inputMiddle = zeros(1, size(window, 2)*4);
            inputExternal = zeros(1, size(window, 2)*4);
            
            %% Calculate what I want... It's 3am
            for axis = 1:size(window, 2)
                %% Select axis
                x = window(:, axis);
                
                %% Crop 1D signal
                % k  = 58;
                k = floor(sqrt(size(window, 1)));
                x  = x(1:k*k);
                % Show croped 1D signal
                %     figure
                %     plot(x)
                
                %% Normalize input signal
                % minx = min(x)
                % maxx = max(x)
                y  = x - min(x);
                y2 = y/max(y);
                %     plot(y2)
                y3 = 255*y2;
                % y  = x - minx
                % y2 = y/(maxx - minx)
                % plot(y2)
                % y3 = 255*y2
                
                %     figure
                %     plot(y3)
                
                y3 = uint8(blockproc(y3,[58 1],myfun));
                % Show normalized input signal
                %     figure
                %     plot(y3)
                
                %% Transform 1D signal into 2D signal
                i  = vec2mat(y3, k);
                % Show 2D signal as image
                %     figure
                %     imshow(i,[])
                
                %% Perform shift in frequency domain
                I  = fftshift(fft2(i));
                
                %% Normalize spectrum
                Iabs = log(abs(I));
                maxIabs = max(Iabs(:));
                IabsNorm = uint8(255*Iabs/maxIabs);
                % Show normalized spectrum
                %     figure
                %     imshow(IabsNorm)
                
                %% Define masks
                % close all
                
                %     mask = zeros(k);
                innerMask = FillCircle(zeros(k), floor(k/6), floor(k/2), floor(k/2));
                middleMask = FillCircle(zeros(k), floor(2*k/6), floor(k/2), floor(k/2));
                externalMask = FillCircle(zeros(k), k/2, floor(k/2), floor(k/2));
                
                externalMask = externalMask - middleMask;
                middleMask = middleMask - innerMask;
                
                
                %     figure('Name', 'Inner Mask', 'NumberTitle', 'Off'), imshow(255*innerMask);
                %     figure('Name', 'Middle Mask', 'NumberTitle', 'Off'), imshow(255*middleMask);
                %     figure('Name', 'External Mask', 'NumberTitle', 'Off'), imshow(255*externalMask);
                
                %% Define ROI - for test purposes only
                %     innerData = IabsNorm.*innerMask;
                %     figure('Name', 'Inner Data', 'NumberTitle', 'Off'), imshow(innerData);
                %
                %     middleData = IabsNorm.*middleMask;
                %     figure('Name', 'Middle Data', 'NumberTitle', 'Off'), imshow(middleData);
                %
                %     externalData = IabsNorm.*externalMask;
                %     figure('Name', 'External Data', 'NumberTitle', 'Off'), imshow(externalData);
                
                %% Calculate 8 glcm
                %     [glcm, SI] = graycomatrix(IabsNorm, 'Offset', [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1], 'NumLevels', 256);
                innerGlcm = getGlcmOfArea(IabsNorm, innerMask, [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1], 256);
                middleGlcm = getGlcmOfArea(IabsNorm, middleMask, [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1], 256);
                externalGlcm = getGlcmOfArea(IabsNorm, externalMask, [-1 -1; -1 0; -1 1; 0 -1; 0 1; 1 -1; 1 0; 1 1], 256);
                
                %% Calculate metrics for each glcm
                innerStats = graycoprops(innerGlcm);
                middleStats = graycoprops(middleGlcm);
                externalStats = graycoprops(externalGlcm);
                
                %% Calculate mean of each metric for the inner area
                innerConMean(axis) = mean(innerStats.Contrast);
                innerCorMean(axis) = mean(innerStats.Correlation);
                innerEnMean(axis) = mean(innerStats.Energy);
                innerHoMean(axis) = mean(innerStats.Homogeneity);
                
                %% Calculate mean of each metric for the middle area
                middleConMean(axis) = mean(middleStats.Contrast);
                middleCorMean(axis) = mean(middleStats.Correlation);
                middleEnMean(axis) = mean(middleStats.Energy);
                middleHoMean(axis) = mean(middleStats.Homogeneity);
                
                %% Calculate mean of each metric for the external area
                externalConMean(axis) = mean(externalStats.Contrast);
                externalCorMean(axis) = mean(externalStats.Correlation);
                externalEnMean(axis) = mean(externalStats.Energy);
                externalHoMean(axis) = mean(externalStats.Homogeneity);
                
                %% Set neural net input
                inputInner(axis) = innerConMean(axis);
                inputInner(axis + size(window, 2)) = innerCorMean(axis);
                inputInner(axis + size(window, 2)*2) = innerEnMean(axis);
                inputInner(axis + size(window, 2)*3) = innerHoMean(axis);
                
                inputMiddle(axis) = middleConMean(axis);
                inputMiddle(axis + size(window, 2)) = middleCorMean(axis);
                inputMiddle(axis + size(window, 2)*2) = middleEnMean(axis);
                inputMiddle(axis + size(window, 2)*3) = middleHoMean(axis);
                
                inputExternal(axis) = externalConMean(axis);
                inputExternal(axis + size(window, 2)) = externalCorMean(axis);
                inputExternal(axis + size(window, 2)*2) = externalEnMean(axis);
                inputExternal(axis + size(window, 2)*3) = externalHoMean(axis);
            end
        end
        
        %% Output data set to files
        function writeDataSetToFiles(obj)
            for i = 1:obj.amountOfClasses
                %% Separate among classes
                innerDataSet = obj.inner((obj.inner(:,1) == i), :);
                middleDataSet = obj.middle((obj.middle(:,1) == i), :);
                externalDataSet = obj.external((obj.external(:,1) == i), :);
                
                %% Inner
                if exist(strcat(obj.outputRootFolder, '\', num2str(i), '\inner', '\', num2str(obj.windowSize), 'secWindow'), 'dir') ~= 7
                    mkdir(strcat(obj.outputRootFolder, '\', num2str(i), '\inner', '\', num2str(obj.windowSize), 'secWindow'));
                end
                
                %% Middle
                if exist(strcat(obj.outputRootFolder, '\', num2str(i), '\middle', '\', num2str(obj.windowSize), 'secWindow'), 'dir') ~= 7
                    mkdir(strcat(obj.outputRootFolder, '\', num2str(i), '\middle', '\', num2str(obj.windowSize), 'secWindow'));
                end
                
                %% External
                if exist(strcat(obj.outputRootFolder, '\', num2str(i), '\external', '\', num2str(obj.windowSize), 'secWindow'), 'dir') ~= 7
                    mkdir(strcat(obj.outputRootFolder, '\', num2str(i), '\external', '\', num2str(obj.windowSize), 'secWindow'));
                end
                
                %% Write to file
                save(strcat(obj.outputRootFolder, '\', num2str(i), '\inner', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat'), 'innerDataSet');
                save(strcat(obj.outputRootFolder, '\', num2str(i), '\middle', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat'), 'middleDataSet');
                save(strcat(obj.outputRootFolder, '\', num2str(i), '\external', '\', num2str(obj.windowSize), 'secWindow', obj.file, '.mat'), 'externalDataSet');
            end
        end
        
        %% Separate data into desired classes
        function separateInClasses(obj)
            obj.innerCarMoving = [];
            obj.middleCarMoving = [];
            obj.externalCarMoving = [];
            obj.innerBikeMoving = [];
            obj.middleBikeMoving = [];
            obj.externalBikeMoving = [];
            obj.innerFootMoving = [];
            obj.middleFootMoving = [];
            obj.externalFootMoving = [];
            obj.innerMoving = [];
            obj.middleMoving = [];
            obj.externalMoving = [];
            obj.sepIdx = [];
            
            % Separated data
            sepDataPerc = 0.15;
            [obj.sepIdx, discard, discard] = divideint(size(obj.inner, 1), sepDataPerc , 0.15, 0.7);
            
            for i = 1:size(obj.inner, 1)
                %% Car moving
                if obj.inner(i, 1) == 1 || obj.inner(i, 1) == 2 || obj.inner(i, 1) == 5
                    obj.innerCarMoving = [obj.innerCarMoving; obj.inner(i, :)];
                    obj.middleCarMoving = [obj.middleCarMoving; obj.middle(i, :)];
                    obj.externalCarMoving = [obj.externalCarMoving; obj.external(i, :)];
                end
                
                %% Bike moving
                if obj.inner(i, 1) == 7 || obj.inner(i, 1) == 9 || obj.inner(i, 1) == 11
                    obj.innerBikeMoving = [obj.innerBikeMoving; obj.inner(i, :)];
                    obj.middleBikeMoving = [obj.middleBikeMoving; obj.middle(i, :)];
                    obj.externalBikeMoving = [obj.externalBikeMoving; obj.external(i, :)];
                end
                
                %% Foot moving
                if obj.inner(i, 1) == 13 || obj.inner(i, 1) == 14 || obj.inner(i, 1) == 17
                    obj.innerFootMoving = [obj.innerFootMoving; obj.inner(i, :)];
                    obj.middleFootMoving = [obj.middleFootMoving; obj.middle(i, :)];
                    obj.externalFootMoving = [obj.externalFootMoving; obj.external(i, :)];
                end
                
                %% Moving
                if obj.inner(i, 1) == 1 ||...
                        obj.inner(i, 1) == 2 ||...
                        obj.inner(i, 1) == 5 ||...
                        obj.inner(i, 1) == 7 ||...
                        obj.inner(i, 1) == 9 ||...
                        obj.inner(i, 1) == 11 ||...
                        obj.inner(i, 1) == 13 ||...
                        obj.inner(i, 1) == 14 ||...
                        obj.inner(i, 1) == 17
                    obj.innerMoving = [obj.innerMoving; obj.inner(i, :)];
                    obj.middleMoving = [obj.middleMoving; obj.middle(i, :)];
                    obj.externalMoving = [obj.externalMoving; obj.external(i, :)];
                end
            end
        end
        
    end
    
end