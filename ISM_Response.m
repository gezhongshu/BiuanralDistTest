function ISM_Response(r, r0, rl, beta, npts)
%pgm: sroom
% subroutine to calculate a room impulse response
% r = vector radius to receiver in sample periods = length/(c*t)
% r0 = vector radius to source in sample periods
% rl = vector of box dimensions in sample periods
% beta = vector of six wall reflection coefs (0 < beta < = 1)
% ht = impulse resp array
% npts = number of points of ht to be computed
% zero delay is in ht(1)
ht = zeros(npts,1);
% dimension r(3), r0(3), nr(3), rl(3), delp(8), beta(2,3)
% equivalence(nr(1), nx),(nr(2), ny),(nr(3), nz)
% for i = 1:npts
% 	ht(i) = 0;
% end
% ck for mic and source at same location
% dis = 0;
% for i = 1:3
% 	dis = (r(i)-r0(i))^2 +dis;
% end
% dis = sqrt(dis);
dis = sqrt((r-r0)*(r-r0)');% distences between source and receiver in sample periods
if(dis<0.5)% about 17 cm, to avoid id = 0
    ht(1) = 1;
    return;
end
% find range of sum
n1 = floor(npts/(rl(1)*2) + 1);
n2 = floor(npts/(rl(2)*2) + 1);
n3 = floor(npts/(rl(3)*2) + 1);
for nx = -n1:n1
    for ny = -n2:n2
        for nz = -n3:n3
            % get eight image locations for mode number nr
            nr = [nx,ny,nz];
            delp = lthimage(r, r0, rl, nr);
            i0 = 0;
            for l = 0:1
                for j = 0:1
                    for k = 0:1
                        i0 = i0 + 1;
                        % make delay an integer
                        id = floor(delp(i0) + 0.5);
                        fdm1 = 4*pi*id*340/8e3;
                        % id = id +1;
                        if(id>npts)
                            continue;
                        end
                        % put in loss factor once for each wall reflection
                        gid = beta(1,1)^abs(nx-l)...
                        *beta(2,1)^abs(nx)...
                        *beta(1,2)^ abs(ny-j)...
                        *beta(2,2)^abs(ny)...
                        *beta(1,3)^abs(nz-k)...
                        *beta(2,3)^abs(nz)...
                        /fdm1;
                        % check for floating point underflow here;
                        % if under flow, skip next line
                        ht(id) = ht(id) +gid;
                    end
                end
            end
        end
    end
end
% impulse resp has been computed
% filter with hi pass filt of 1% of sampling freq(i.e. 100 hz)
% if this step is not desired, return here
% w = 2*pi*100;
% t = 1e-4;
% r1 = exp(-w*t);
% r2 = r1;
% b1 = 2*r1*cos(w*t);
% b2 = -r1*r1;
% a1 = -(1+r2);
% a2 = r2;
% y1 = 0;
% y2 = 0;
% y0 = 0;
% % filter ht
% for i = 1:npts
%     x0 = ht(i);
%     ht(i) = y0 + a1*y1 + a2*y2;
%     y2 = y1;
%     y1 = y0;
%     y0 = b1*y1 + b2*y2 + x0;
% end
end


function delp = lthimage(dr, dr0, rl, nr)
% pgm: lthimage
% pgm to compute eight images of a point in box
% dr is vector radius to receiver in sample periods
% dr0 is vector radius to source in sample periods
% rl is vector of box dimensions in sample periods
% nr is vector of mean image number
% delp is vector of eight source to image
% distances in sample periods
rp = zeros(3,8);
delp = zeros(1,8);
% dimension r2l(3), rl(3), nr(3),delp(8)
% dimension dr0(3), dr(3), rp(3,8)
% loop over all sign permutations and compute r +/-r0
i0 = 1;
for l = -1:2:1
    for j = -1:2:1
        for k = -1:2:1
            % nearest image is l = j = k = -1
            rp(1,i0) = dr(1) + l*dr0(1);
            rp(2,i0) = dr(2) + j*dr0(2);
            rp(3,i0) = dr(3) + k*dr0(3);
            i0 = i0 + 1;
        end
    end
end
% add in mean radius to eight vectors to get total delay
r2l(1) = 2*rl(1)*nr(1);
r2l(2) = 2*rl(2)*nr(2);
r2l(3) = 2*rl(3)*nr(3);
for i = 1:8
    delsq = 0;
    for j = 1:3
        rl = r2l(j)-rp(j,i);
        delsq = delsq +rl^2;
    end
    delp(i) = sqrt(delsq);
end
end