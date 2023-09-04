function writeArr2json(fname, keys, values, types)
[fpath, ~, ~] = fileparts(fname);
if(~exist(fpath, 'file'))
    mkdir(fpath);
end

fid = fopen(fname, 'w');
n = length(keys);
fprintf(fid, '{');
for i = 1:n
    fprintf(fid, '"%s": %s', keys{i}, Arr2Str(values{i}, types{i}));
    if(i<n)
        fprintf(fid, ', ');
    end
end
fprintf(fid, '}');
fclose(fid);

function s = Arr2Str(X, type)
sz = size(X);
if(sz(1)==1 || sz(2)==1)
    s = Array1DString(X, type);
else
    s = Array2DString(X, type);
end

function s = Array1DString(X, type)
s = '[';
switch lower(type)
    case 'i',
        stemp = sprintf('%d, ', X);
    case 'f',
        stemp = sprintf('%14.7e, ', X);
    case 'd',
        stemp = sprintf('%22.15e, ', X');
end
s = [s, stemp(1:end-2), ']'];

function s = Array2DString(X, type)
s = '[';
n = size(X, 2);
for i = 1:n
    s = [s, Array1DString(X(:, i), type) ', '];
end
s = [s(1:end-2), ']'];