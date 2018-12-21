clear all
close all
clc

%% Parallel setup
% Utils.setupParallelPool();

%% Show time
% parfor windowSize = 1:8
for windowSize = 1:8
    wS = windowSize*2;
    
    %% Initialize object to handle dataset
    data = DataClass(wS);
    
    %% Generate data set
    %         data.generateDataSet();
    
    %% Load data set
    data.loadDataSet();
    
    %% Initialize object to handle classifier
    cl = Classifier();
    
    %% Inner
    area = 'inner';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);

    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% Middle
    area = 'middle';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% External
    area = 'external';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% Inner and middle
    area = 'inner_middle';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% Inner and external
    area = 'inner_external';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% Middle and external
    area = 'middle_external';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    %% All
    area = 'all';
    
    % Movement or not
    outPath = sprintf('\\isMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getIsMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Class of movement
    outPath = sprintf('\\classOfMovement\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getClassOfMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Car
    outPath = sprintf('\\car\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getCarMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Bike
    outPath = sprintf('\\bike\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getBikeMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    % Foot
    outPath = sprintf('\\foot\\%s\\%02dsecWindow', area, data.getWindowSize());
    [sepData, sepTargets, inpData, targets] = data.getFootMovementSets(area);
    cl.train(outPath, inpData, targets);
    cl = cl.loadFromFile(sprintf('net\\%s\\%s', outPath, Utils.getFileNameWithBestHitRate(sprintf('net\\%s', outPath))));
    cl.evaluate(sepData, sepTargets);
    
    close all
end