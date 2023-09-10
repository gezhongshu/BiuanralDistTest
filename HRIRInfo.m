function info = HRIRInfo(dbname, path)
%HRIRInfo  Get information of the HRIR database.
%   INFO = HRIRINFO(DBNAME, PATH) returns the information of the HRIR
%   database. DBNAME is the name of the HRIR database, which can be
%   'PKU-IOA', 'KU-100', or 'FABIAN'. PATH is the path of the HRIR database.
%   If PATH is not specified, the default path is '../../../library/HRTF/'.
%   INFO is a struct with the following fields:
%       'azimuths': the azimuths of the HRIRs in radians
%       'elevations': the elevations of the HRIRs in radians
%       'distances': the distances of the HRIRs in meters
%       'fs': the sampling frequency of the HRIRs
%       'len': the length of the HRIRs
    
    %   Zhongshu Ge 2023-09-10
    
    % check input arguments
    if nargin < 2
        path = '../../../library/HRTF/';
    end
    if nargin < 1
        dbname = 'PKU-IOA';
    end

    info = [];
    
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
            info.len = size(HRIR_L, 1);
            info.fs = hrir_obj.fs;
            elev = hrir_obj.elevation * pi / 180;
            azim = hrir_obj.azimuth * pi / 180;
            dist = hrir_obj.dist / 100;
            [E, A, D] = meshgrid(elev, azim, dist);
            info.elevations = L_(permute(E, [2, 1, 3]))';
            info.azimuths = L_(permute(A, [2, 1, 3]))';
            info.distances = L_(permute(D, [2, 1, 3]))';
        case 'K' % 'KU-100'
            try 
                hrir_obj = load([path, '/Neumann KU100/HRIR_FULL2DEG.mat']);
                addpath([path, '/Neumann KU100/']);
            catch
                error('Cannot find the HRIR database!');
            end
            hrir_obj = hrir_obj.HRIR_FULL2DEG;
            info.len = size(HRIR_L, 1);
            info.fs = hrir_obj.fs;
            info.azimuths = hrir_obj.azimuths;
            info.elevations = pi/2 - hrir_obj.elevation;
            info.distances = hrir_obj.sourceDistance*ones(size(azimuths));
        case 'F' % 'FABIAN'
            try
                hrir_obj = load([path, 'FABIAN.mat']);
            catch
                error('Cannot find the HRIR database!');
            end
            info.len = size(HRIR_L, 1);
            info.fs = 44100;
            info.azimuths = hrir_obj.azimuth;
            info.elevations = hrir_obj.elevation;
            info.distances = 1*ones(size(azimuths));
        otherwise
            error('Unknown database!');
    end