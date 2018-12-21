function [ glcm ] = getGlcmOfArea(inputMatrix, mask, direction, numLevels)
% Calculate the glcm of inputMatrix according to the area defined by mask.
% Pixels marked with '0' on the mask matrix are not taken into
% consideration either for the pixel of interest and for the neighbor.

%% Initialize glcm
glcm = zeros(numLevels, numLevels, size(direction, 1));
% glcm = zeros(max(max(inputMatrix)) + 1);

%% Fill glcm using only marked pixels
for k = 1:size(direction, 1)
    for i = 1:size(inputMatrix, 1)
        for j = 1:size(inputMatrix, 2)
            neighborRow = i + direction(k, 1);
            neighborCol = j + direction(k, 2);

            if neighborRow > 0 && neighborRow <= size(inputMatrix, 1) ...
                    && neighborCol > 0 ...
                    && neighborCol <= size(inputMatrix, 2) ...
                    && mask(i, j) ...
                    && mask(neighborRow, neighborCol)
                
                glcm(inputMatrix(i, j) + 1, inputMatrix(neighborRow, neighborCol) + 1, k) ... 
                    = glcm(inputMatrix(i, j) + 1, inputMatrix(neighborRow, neighborCol) + 1, k) + 1;

            end
        end
    end
end

end

