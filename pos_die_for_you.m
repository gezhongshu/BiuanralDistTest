function [pos, timeTag] = pos_die_for_you()
BPM = 134; %
Meter = [4 4]; % 4/4

T0 = 0.04; % start time of the music
M0 = -0.5; % < 0 means an incomplete measure a start

tPerMeasure = 60/BPM*Meter(1);

% measure, dist, azim, elev
mtag = [
    1,      0.5,    -45,    30;
    3,      0.5,    -90,    0;
    5,      0.5,    -135,   30;
    7,      0.5,    -90,    0;
    8.5,    0.5,    -45,    0;
    9,      0.5,    45,     30;
    11,     0.5,    90,     0;
    13,     0.5,    135,    30;
    15,     0.5,    90,     0;
    16.5,   0.5,    45,     0;
    17,     3,      45,     0;
    17.5,   1,      0,      0;
    18,     1.5,    -45,    0;
    18.5,   1.5,    0,      0;
    19,     1.5,    45,     0;
    20,     1.5,    0,      0;
    20.5,   3,      -30,    0;
    21,     5,      -70,    0;
    22,     1.5,    0,      0;
    22.5,   2,      15,     0;
    24,     5,      70,     0;
    27,     2,      0,      0;
    28,     5,      -90,    0;
    29,     1,      -180,   0;
    30,     1,      90,     0;
    31,     3,      0,      0;
    32,     3,      -90,    0;
    33,     3,      -90,    -30;
    34,     3,      -150,   0;
    35,     3,      -90,    30;
    36,     3,      -30,    0;
    37,     1,      0,      0;
    38,     1,      60,     0;
    39,     5,      150,    0;
    40,     3,      90,     -30;
    41,     3,      30,     0;
    42,     3,      90,     30;
    43,     3,      150,    0;
    43.5,   1.5,    -150,   0;
    44,     1.5,    150,    0;
    44.5,   1.5,    -120,   0;
    45,     1.5,    -60,    0;
    45.5,   1.5,    -120,   0;
    46,     1,      60,     0;
    46.5,   0.5,    -30,    0; % walk away
    48,     10,     30,     0;
    48.5,   1.5,    45,     0; % even though
    48.75,  1.5,    -45,    0;
    49,     1.5,    45,     0;
    49.25,  1.5,    -45,    0;
    49.5,   1.5,    0,      0;
    50,     5,      70,     0;
    50.5,   1,      0,      0;
    51,     1,      -30,    0;
    51.5,   1.5,    0,      0;
    51.75,  5,      -70,    0;
    52,     3,      -30,    0;
    53,     2,      0,      0;
    54,     2,      30,     0;
    56,     2,      90,     0;
    58,     5,      150,    0;
    60,     5,      -120,   0;
    62,     2,      -30,    0;
    64,     1,      30,     0;
    64.5,   5,      0,      0;
    66,     5,      -90,    0;
    67,     8,      -120,   0;
    68,     3,      -150,   0;
    69,     0.5,    -180,   0;
    70,     3,      150,    0;
    71,     8,      120,    0;
    72,     3,      150,    0;
    73,     0.5,    180,    0;
    74,     3,      -150,   0;
    75,     8,      -120,   0;
    76,     3,      -150,   0;
    77,     0.5,    180,    0;
    78,     0.5,    160,    20;
    79,     0.5,    120,    45;
    80,     0.5,    60,     60;
    81,     1,      30,     20;
    82,     1,      -30,    0;
    83,     1.5,    -60,    -30;
    84,     1.5,    -30,    -60;
    85,     1.5,    0,      -45;
    86,     1.5,    30,     -20;
    87,     4,      60,     0; % walk away
    88.4,   10,     0,      0;
    88.5,   1.5,    45,     0; % even though
    88.75,  1.5,    -45,    0;
    89,     1.5,    45,     0;
    89.25,  1.5,    -45,    0;
    89.5,   1.5,    0,      0;
    90,     5,      70,     0;
    90.5,   1,      0,      0;
    91,     1,      -30,    0;
    91.5,   1.5,    0,      0;
    91.75,  5,      -70,    0;
    92,     3,      -30,    0;
    93,     2,      0,      0;
    94,     2,      30,     0;
    96,     2,      90,     0;
    98,     5,      150,    0;
    100,    5,      -120,   0;
    102,    2,      -30,    0;
    103.99, 1,      30,     0;
    104,    8,      60,     0;
    106,    8,      0,      0;
    108,    8,      -60,    0;
    110,    8,      -120,   0;
    112,    0.5,    -180,   0;
    114,    8,      120,    0;
    116,    8,      60,     0;
    118,    8,      0,      0;
    120,    8,      -60,    0;
    120.5,  1.5,    45,     0; % even though
    120.75, 1.5,    -45,    0;
    121,    1.5,    45,     0;
    121.25, 1.5,    -45,    0;
    121.5,  1.5,    0,      0;
    122,    5,      70,     0;
    122.5,  1,      0,      0;
    123,    1,      -30,    0;
    123.5,  1.5,    0,      0;
    123.75, 5,      -70,    0;
    124,    3,      -30,    0;
    125,    2,      0,      0;
    126,    2,      30,     0;
    128,    2,      90,     0;
    130,    5,      150,    0;
    132,    5,      -120,   0;
    134,    2,      -30,    0;
    136,    1,      30,     0;
    138,    10,     -60,    0;
    146,    10,     60,     0;
    ];

timeTag = [0; (mtag(:,1)-M0-1)*tPerMeasure+T0; 1e4];
r = mtag(:,2);
az = mtag(:,3)*pi/180;
el = mtag(:,4)*pi/180;
pos = [r.*cos(el).*cos(az), r.*cos(el).*sin(az), r.*sin(el)];
pos = [1, 0, 0; pos; 1, 0, 0];
fname = './pos/pos_die_for_you.json';
keys = {'pos', 'timeTag'};
values = {pos', timeTag};
types = {'f', 'f'};
writeArr2json(fname, keys, values, types);
if(nargout <1)
    figure(1);
    clf;
    axis([-10, 10, -10, 10]);
    cnt = 1;
    for t = 0:0.01:250
        [r, az, el] = insertPos(pos, timeTag, t);
        x(cnt) = r*cos(el/180*pi)*sin(az/180*pi);
        y(cnt) = r*cos(el/180*pi)*cos(az/180*pi);
        cnt = cnt + 1;
    end
    comet(x, y, 0.01);
end