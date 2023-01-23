function data_norm = zscoreNorm(data)
%ZSCORENORM 
% Takes cell array as input, turns into matrix to perform zscore matlab 
% function and then puts normalized data back into cell array where each 
% cell contains a 3xN matrix.

[m,n] = size(data);
data_temp = zeros(size(data,1)*3, size(data{1},2)); % temporary data
count = 1;
for i=1:m
    data_temp(count:count+2,:) = cell2mat(data(i));
    count = count + 3;
end

data_temp = zscore(data_temp,[],2);

data_norm = cell(m,n);
count = 1;
for i = 1:m
    data_norm{i} = data_temp(count:count+2,:);
    count = count + 3;
end
end