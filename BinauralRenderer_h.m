function wav = BinauralRenderer_h(filenames, angle_s, angle_e)
% 用法示例
% [wav, fs] = BinauralRenderer_h({'测试音频1.wav', '测试音频2.wav'}, -pi/4, pi/4);
% sound(wav{1}, fs);
global HRTF_L HRTF_R azimuth elevation fs Nf Nw Nfft;

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
        az = (angle_s*(nframe - fi) + angle_e*(fi - 1)) / (nframe - 1);
        az = round(az*180/pi);%/5*5
        az(az<0) = az(az<0) + 360;
        az(az==360) = 0;
        el = 0;
        ind = (azimuth(:) == az) & (elevation(:) == el);
        HRTFs(:, 1, fi) = HRTF_L(:, ind);
        HRTFs(:, 2, fi) = HRTF_R(:, ind);
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