function [r, az, el] = insertPos(pos, timeTag, t)
[~, it] = min(abs(timeTag - t));
if(timeTag(it) - t > 0 || t > timeTag(end))
    bg = it-1;
    ed = it;
elseif(timeTag(it) - t == 0)
    bg = it;
    ed = bg;
else
    bg = it;
    ed = it+1;
end
if(bg == ed)
    pos = pos(bg, :);
else
    lambda = (timeTag(ed) - t)/(timeTag(ed) - timeTag(bg));
    pos = pos(bg, :)*lambda + pos(ed, :)*(1-lambda);
end
r = sqrt(sum(pos.^2));
x = pos(1);
y = pos(2);
z = pos(3);
az = atan2(y, x)*180/pi;
el = asin(z/r)*180/pi;
az = mod(az, 360);