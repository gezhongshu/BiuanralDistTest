function [rir, delays, amps, reverbs] = simulateRIR(dist, fs, c)
if(nargin<3)
    c = 340;
end
if(nargin<2)
    fs = 44.1e3;
end
roomSz = [2, 2, 1];
p_s = [3 2 2];
p_r = p_s + dist*[0.707 0.707 0];

nref = 4;
len = 16384;

rirFiles = my_ISM_RIR_bank(my_ISM_setup(fs, c, 0.7, roomSz*max(dist/1.5, 3), p_s, p_r));
[TT, ~, amp] = loadRir(rirFiles);
if(amp(1) - round(amp(1)) == 0)
    amp = 0.7.^amp./(TT*c);
end
drop = find(amp/amp(1) < 1e-5|TT*fs>len);
TT(drop) = [];
amp(drop) = [];

amps = amp(1:nref+1);
delays = round(TT(1:nref+2)*fs);

rir = zeros(len, 1);
for i = 1:length(TT)
    ind = round(TT(i)*fs);
    rir(ind) = rir(ind) + amp(i);
end
[b,a] = butter(4, [0.0023, 0.91]);
reverbs = filter(b, a, rir(delays(end)+1:end));
rir(delays(end)+1:end) = reverbs;
reverbs = [reverbs, reverbs];
coef = 1 / min(max(dist^(1/2), 1), 5) / amps(1);
amps = amps*coef;
rir = rir*coef;
reverbs = reverbs*coef;
if(nargout == 0)
    plot(rir);
end