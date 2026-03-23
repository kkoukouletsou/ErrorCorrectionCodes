function bin = gray2binfun(gray, k)
    % gray : column vector με Gray integers (0..M-1)
    % k : number of bits per symbol
    bin = zeros(size(gray));
    for i = 1:length(gray)
        g = gray(i);
        b = 0;
        for j = k-1:-1:0
            if j == k-1
                % MSB remains the same
                b = bitset(b, j+1, bitget(g, j+1));
            else
                % XOR με το προηγούμενο bit
                b = bitset(b, j+1, bitxor(bitget(g, j+1), bitget(b, j+2)));
            end
        end
        bin(i) = b;
    end
end
