function [yaw, pitch] = dir2yawpitch(az, el)
az = az/180*pi;
el = el/180*pi;
x = cos(el)*cos(az);
y = cos(el)*sin(az);
z = sin(el);
yaw = -atan2(y, sign(x)*sqrt(z^2+x^2))*180/pi;
pitch = atan2(-sign(x)*z, abs(x))*180/pi;