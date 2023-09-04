function [rir, delays, amps, reverbs] = generateRIR(dist, DRR, fs, c)
if(nargin<4)
    c = 340;
end
if(nargin<3)
    fs = 44.1e3;
end
if(DRR<0.001)
    DRR = 0.001;
end
nref = 4;
delays = zeros(nref+2, 1);
amps = ones(nref+1, 1);
t5080 = [0.05, 0.08];
len = 16384;
delays(1) = round(dist / c * fs);
amps(1) = 1 / min(max(dist^(1/2), 1), 5);
ED = amps(1)^2;
dists = dist + (1+log(dist+1))*(5 + 4*(rand(nref*4, 1)-0.5));
dists = sort(dists);
dists = dists(1:4:end);
delays(2:end-1) = round(dists / c * fs);
amps(2:end) = amps(1)*dist ./ dists;
DER = 1 / min(0.5/DRR, 2);
cref = sqrt(ED / sum(amps(2:end).^2) / DER);
amps(2:end) = cref*amps(2:end);
delays(end) = delays(1) + round((t5080(1) + ...
    atan((max(dist, 0.5) - 0.5)/5)*2/pi*(t5080(2)-t5080(1)))*fs);
tr = (delays(end)+1:len)';
reverbs = amps(1)*exp(-3e-4*tr*[1 1]).*randn(len - delays(end), 2);
DLR = 1 / ( 1/DRR - 1/DER);
aL = 0;
aH = 10;
err = 1;
while(err > 1e-5)
    am = (aL + aH)/2;
    EL = sum((am*reverbs(:, 1)).^2);
    tempR = ED/EL;
    if(tempR > DLR)
        aL = am;
    else
        aH = am;
    end
    err = abs(tempR - DLR) / DLR;
end
reverbs = am*reverbs;
rir = zeros(len, 1);
for i = 1:nref+1
    rir(delays(i)) = amps(i);
end
rir(delays(end)+1:end) = reverbs(:, 1);
if(nargout == 0)
    plot(rir);
end