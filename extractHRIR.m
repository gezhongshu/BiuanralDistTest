function [hrir_l, hrir_r, fs, RR, azs, els] = extractHRIR(rr, azims, elevs, dbname, path)
%EXTRACTHRIR Extracts HRIRs from the PKU-IOA HRTF database or the KU-100 
%   or the FABIAN database.
%   [HRIR_L, HRIR_R, FS, RR, AZS, ELS] = EXTRACTHRIR(R, AZIMS, ELEVS, DBNAME, PATH)
%   extracts HRIRs from the three databases mentioned above. The HRIRs are
%   extracted for the given radius R, the given azimuths AZIMS and the
%   given elevations ELEVS. The database is specified by the string DBNAME.
%   The path to the database is specified by the string PATH. The function
%   returns the HRIRs HRIR_L and HRIR_R and the sampling frequency FS.
%   If no exact match is found, the function returns the HRIRs for the
%   closest match. Input angles are in radians.

%   Zhongshu Ge 2023-09-10

% check input arguments
if nargin < 5
    path = '../../../library/HRTF/';
end
if nargin < 4
    dbname = 'PKU-IOA';
end

% define global variables to store the HRIRs to avoid loading them again
global HRIR_L HRIR_R loaded dbname_old azimuths elevations distances hlen fs_db

% check if the database is changed
if isempty(loaded) || ~strcmp(dbname, dbname_old)
    loaded = false;
    dbname_old = dbname;
end

% load HRIRs if not loaded
if ~loaded
    switch upper(dbname(1))
        case 'P' % 'PKU-IOA'
            try 
                hrir_obj = load([path, '/PKU/hrir_small_44100.mat']);
            catch
                try 
                    hrir_obj = load([path, 'hrir_small_44100.mat']);
                catch
                    error('Cannot find the HRIR database!');
                end
            end
            hrir_obj = hrir_obj.hriDb;
            HRIR_L = squeeze(hrir_obj.hrir(:, 1, :));
            HRIR_R = squeeze(hrir_obj.hrir(:, 2, :));
            hlen = size(HRIR_L, 1);
            fs_db = hrir_obj.fs;
            elev = hrir_obj.elevation * pi / 180;
            azim = hrir_obj.azimuth * pi / 180;
            dist = hrir_obj.dist / 100;
            [E, A, D] = meshgrid(elev, azim, dist);
            elevations = L_(permute(E, [2, 1, 3]))';
            azimuths = L_(permute(A, [2, 1, 3]))';
            distances = L_(permute(D, [2, 1, 3]))';
        case 'K' % 'KU-100'
            try 
                hrir_obj = load([path, '/Neumann KU100/HRIR_FULL2DEG.mat']);
                addpath([path, '/Neumann KU100/']);
            catch
                error('Cannot find the HRIR database!');
            end
            hrir_obj = hrir_obj.HRIR_FULL2DEG;
            HRIR_L = hrir_obj.irChOne;
            HRIR_R = hrir_obj.irChTwo;
            hlen = size(HRIR_L, 1);
            fs_db = hrir_obj.fs;
            azimuths = hrir_obj.azimuths;
            elevations = pi/2 - hrir_obj.elevation;
            distances = hrir_obj.sourceDistance*ones(size(azimuths));
        case 'F' % 'FABIAN'
            try
                hrir_obj = load([path, 'FABIAN.mat']);
            catch
                error('Cannot find the HRIR database!');
            end
            HRIR_L = hrir_obj.HRIR_L;
            HRIR_R = hrir_obj.HRIR_R;
            hlen = size(HRIR_L, 1);
            fs_db = 44100;
            azimuths = hrir_obj.azimuth;
            elevations = hrir_obj.elevation;
            distances = 1*ones(size(azimuths));
        otherwise
            error('Unknown database!');
    end
    loaded = true;
end

% find the closest match
AED = repmat(azimuths*1e6 + elevations*1e3 + distances, length(rr), 1);
aed = repmat(azims*1e6 + elevs*1e3 + rr, 1, size(AED, 2));
[~, idx] = min(abs(AED - aed), [], 2);
hrir_l = permute(HRIR_L(:, idx), [1, 3, 2]);
hrir_r = permute(HRIR_R(:, idx), [1, 3, 2]);
fs = fs_db;
RR = distances(idx);
azs = azimuths(idx);
els = elevations(idx);

function x = L_(x)
%L_ Converts a matrix to a column vector.
%   X = L_(X) converts the matrix X to a column vector.
x = x(:);