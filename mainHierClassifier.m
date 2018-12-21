clear all
close all
clc

for wS = 2:2:16
    %% Initialize object to handle dataset
    data = DataClass(wS);
    
    %% Load data set
    data.loadDataSet();
    
    %% Define area of interest
    area = 'all';
    
    %% Initialize hierarchical classifier
    hC = HierClassifier(area, wS);
    
    %% Evaluate data
    fprintf('Evaluating %02d seconds window: ', wS);
    hitRate = 0;
    sepData = data.getSepData(area);
    for i = 1:size(sepData, 1)
        input = sepData(i, :);
        out = hC.evaluate(input);
        
        if input(1, 1) == 1 || ...
                input(1, 1) == 2 || ...
                input(1, 1) == 7 || ...
                input(1, 1) == 13 || ...
                input(1, 1) == 14
            expected = 1;
        else
            expected = -1;
        end
        
        if out == expected
            hitRate = hitRate + 1;
        end
    
%         keyboard;
    end
    
    hitRate = hitRate/size(sepData, 1);
    fprintf(' %f%% hit rate\n', 100*hitRate);

    
    %% Delete hierarchical classifier
    clear hC;
end