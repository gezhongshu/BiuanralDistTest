function [direct, delays, reverb] = interpRIR(r, rirType)
dist = [0.2 0.5 2.5 5 10 20];
DRR = [50 10 1 0.3 0.1 0.05];

if(r<dist(1))
    r =  dist(1);
elseif(r>dist(end))
    r = dist(end);
end
for ir = 1:length(dist)-1
    if(r<=dist(ir+1))
        break;
    end
end
cr1 = (dist(ir+1) - r)/(dist(ir+1) - dist(ir));
cr2 = 1 - cr1;

if(strcmp(rirType, 'Art'))
    frir1 = sprintf('rir_dist_%g_DRR_%g.mat', dist(ir), DRR(ir));
    frir2 = sprintf('rir_dist_%g_DRR_%g.mat', dist(ir+1), DRR(ir+1));
else
    frir1 = sprintf('rirSim_dist_%g.mat', dist(ir));
    frir2 = sprintf('rirSim_dist_%g.mat', dist(ir+1));
end

rirdata = load(frir1);
rir1 = rirdata.rir;
delays1 = rirdata.delays;
amps1 = rirdata.amps;

rirdata = load(frir2);
rir2 = rirdata.rir;
delays2 = rirdata.delays;
amps2 = rirdata.amps;

direct = zeros(size(rir1));
id = round(cr1*delays1(1) + cr2*delays2(1));
direct(id) = cr1*amps1(1) + cr2*amps2(1);
rir1(delays1) = 0;
rir2(delays2) = 0;
reverb = cr1*rir1 + cr2*rir2;
delays = round(cr1*delays1(2:end-1) + cr2*delays2(2:end-1));
reverb(delays) = cr1*amps1(2:end) + cr2*amps2(2:end);