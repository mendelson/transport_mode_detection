function [ mask ] = FillCircle(matrix, r, xc, yc)

mask = zeros(size(matrix, 1), size(matrix, 2));

for i = 1:size(matrix, 1)
    for j = 1:size(matrix, 2)
        mask(i, j) = ((i - yc).^2 + (j - xc).^2 <= r.^2);
    end
end

mask = uint8(mask);

end

 