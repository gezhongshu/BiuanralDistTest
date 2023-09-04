function [pos, timeTag] = generateTrace1(t)
r = 0.4;
dt = 2;
x0 = [r, 2*r, 4*r, 10*r, 4*r, 2*r];
y0 = [0, -0.3, -2.5, -10, -2.5, -0.3];
z0 = zeros(1, 6);
x1 = [x0 x0];
y1 = [y0 -y0];
z1 = [z0 z0];
time = dt*(0:11)';

rep = ceil(t / dt / 11);
Dt = dt*12*ones(12, 1)*((1:rep)-1);
timeTag = repmat(time, 1, rep) + Dt;
timeTag = timeTag(:);
pos = [x1' y1' z1'];
pos = repmat(pos, rep, 1);