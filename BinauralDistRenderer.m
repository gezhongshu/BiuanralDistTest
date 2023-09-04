function wav = BinauralDistRenderer(filenames, pos, timeTag)
global HRTF fs Nf Nw Nfft distance;

if(~iscell(filenames))
    filenames = {filenames};
end
wav = cell(length(filenames), 1);

for in = 1:length(filenames)
    [wavIn, fs_audio] = audioread(filenames{in});
    wavIn = wavIn(:, 1);
    if(fs_audio~=fs)
        wavIn = resample(wavIn, fs, fs_audio);
    end
    [wavFrame, nframe] = wav2frame(wavIn, Nf, Nw);
    HRTFs = zeros(Nfft, 2, nframe);
    for fi = 1:nframe
        [r, az, el] = insertPos(pos, timeTag, fi*Nf/fs);
        if(r<distance(1))
            r =  distance(1);
        elseif(r>distance(end))
            r = distance(end);
        end
        for ir = 1:length(distance)-1
            if(r<=distance(ir+1))
                break;
            end
        end
        cr1 = (distance(ir+1) - r)/(distance(ir+1) - distance(ir));
        cr2 = 1 - cr1;
        ia = floor(az/5)+1;
        ca2 = az/5 - ia + 1;
        ca1 = 1 - ca2;
        ie = floor(el/10)+10;
        ce2 = el/10 + 10 - ie;
        ce1 = 1 - ce2;
        HRTFs(:, 1, fi) = HRTF(:, 1, ie, ia, ir)*ce1*ca1*cr1 + HRTF(:, 1, ie+1, ia, ir)*ce2*ca1*cr1 ...
            + HRTF(:, 1, ie, ia+1, ir)*ce1*ca2*cr1 + HRTF(:, 1, ie+1, ia+1, ir)*ce2*ca2*cr1 ...
            + HRTF(:, 1, ie, ia, ir+1)*ce1*ca1*cr2 + HRTF(:, 1, ie+1, ia, ir+1)*ce2*ca1*cr2 ...
            + HRTF(:, 1, ie, ia+1, ir+1)*ce1*ca2*cr2 + HRTF(:, 1, ie+1, ia+1, ir+1)*ce2*ca2*cr2;
        HRTFs(:, 2, fi) = HRTF(:, 2, ie, ia, ir)*ce1*ca1*cr1 + HRTF(:, 2, ie+1, ia, ir)*ce2*ca1*cr1 ...
            + HRTF(:, 2, ie, ia+1, ir)*ce1*ca2*cr1 + HRTF(:, 2, ie+1, ia+1, ir)*ce2*ca2*cr1 ...
            + HRTF(:, 2, ie, ia, ir+1)*ce1*ca1*cr2 + HRTF(:, 2, ie+1, ia, ir+1)*ce2*ca1*cr2 ...
            + HRTF(:, 2, ie, ia+1, ir+1)*ce1*ca2*cr2 + HRTF(:, 2, ie+1, ia+1, ir+1)*ce2*ca2*cr2;
    end
    wavFrameLR = real(ifft(repmat(fft(wavFrame, Nfft), 1, 2).*HRTFs));
    wav{in} = frame2wav(wavFrameLR, Nf);
end

%%
function [wavFrame, nframe] = wav2frame(wav, Nf, Nw)
% wav = rand(100, 2);
% Nf = 1024;
% Nw = 128;
head = hann(2*Nw - 1);
head = head(1:Nw);
wnd = [head; ones(Nf-Nw, 1); flipud(head)];
% wvtool(wnd);
sz = size(wav);
wnd = repmat(wnd, [1, sz(2:end)]);
wav = [zeros([Nf, sz(2:end)]); wav; zeros([Nf+Nw, sz(2:end)])];
len = size(wav, 1);
nframe = floor((len - Nw) / Nf);
wavFrame = zeros([Nf+Nw, prod(sz(2:end)), nframe]);
slide = 0;
for i = 1:nframe
    wavFrame(:, :, i) = wav(slide+(1:Nf+Nw), :).*wnd(:, :);
    slide = slide + Nf;
end
wavFrame = reshape(wavFrame, [Nf+Nw, sz(2:end), nframe]);
%%
function wav = frame2wav(frame, Nf)
sz = size(frame);
dim = length(sz);
wav = zeros(Nf*(sz(end)-1)+sz(1), prod(sz(2:end-1)));
frame = permute(frame, [dim, 1:dim-1]);
slide = 0;
for i = 1:sz(end)
    if(length(size(frame))==2)
        wav(slide+(1:sz(1)), :) = wav(slide+(1:sz(1)), :) + frame(i, :)';
    else
        wav(slide+(1:sz(1)), :) = wav(slide+(1:sz(1)), :) + squeeze(frame(i, :, :));
    end
    slide = slide + Nf;
end
wav(1:Nf,:) = [];
wav = reshape(wav, [Nf*(sz(end)-2)+sz(1), sz(2:end-1)]);
%%
