function [T, vec, amp] = loadRir(fname)
fid = fopen(fname,'r');
datas = fread(fid, inf, 'double');
datas = reshape(datas, 5, length(datas)/5)';
T = datas(:, 1);
[T, I] = sort(T);
datas = datas(I, :);
vec = datas(:, 2:4);
amp = datas(:, 5);
fclose(fid);