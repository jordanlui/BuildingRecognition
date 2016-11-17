for i = 1 :10
    test(i,1) = i;
    test(i,2) = ceil(i/2);
    test(i,3) = i-2*ceil(i/2)+1;
end
test