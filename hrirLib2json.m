hrdb = load('../../../library/HRTF/PKU/hrir_small_44100.mat');
hrdb = hrdb.hrirDb;
hrir = hrdb.hrir;
distance = hrdb.dist([1 4 8]);
elevation = hrdb.elevation;
azimuth = hrdb.azimuth;

azimuth = azimuth(1:2:end);
hrir = hrir(:, :, :, 1:2:end, :);
nd = length(distance);
ne = length(elevation);
na = length(azimuth);

fname = './hrir_small_44100.json';
keys = cell(3+nd*ne*na, 1);
values = keys;
types = keys;
keys(1:3) = {'distance', 'elevation', 'azimuth'};
values(1:3) = {distance, elevation, azimuth};
types(1:3) = {'i', 'i', 'i'};
cnt = 3;
for id = 1:nd
    for ie = 1:ne
        for ia = 1:na
            cnt = cnt + 1;
            keys{cnt} = sprintf('d%d_e%d_a%d', distance(id), elevation(ie), azimuth(ia));
            values{cnt} = hrir(:, :, ie, ia, id);
            types{cnt} = 'f';
        end
    end
end
writeArr2json(fname, keys, values, types);