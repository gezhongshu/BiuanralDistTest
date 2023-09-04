% global HRTF fs Nf Nw Nfft distance;
% hrdb = load('../../../library/HRTF/PKU/hrir_small_44100.mat');
% hrdb = hrdb.hrirDb;
% hrir = hrdb.hrir;
% distance = hrdb.dist/100;
% fs = hrdb.fs;
% Nf = 2^9;
% Nw = 2^7;
% len = size(hrir, 1);
% Nfft = len+Nf+Nw;
% HRTF = fft(hrir, Nfft);
% 
% wavIn = audioread('Die For You.mp3');
% wavIn = mean(wavIn, 2);
% audiowrite('distChangeTest.wav', wavIn(1:fs*60), fs);

outpath = './distChangeTest/';
wavIn = audioread('distChangeTest.wav');
twave = length(wavIn)/fs;
rlen = 2^14;
NRf = 2^13;
NRw = 2^13;
fftLen = NRf + NRw + rlen;

[pos, timeTag] = generateTrace1(twave);
rirType = 'Art';
parts = 'F';
fnames = {sprintf('%s0D_%s_%s.wav', outpath, rirType, parts), ...
    sprintf('%s0R_%s_%s.wav', outpath, rirType, parts)};

[wavFrame, nframe] = wav2frame(wavIn, NRf, NRw);
RTFs = zeros(fftLen, 2, nframe);
for i = 1:nframe
    tframe = (i-0.5)*NRf/fs;
    [r, ~, ~] = insertPos(pos, timeTag, tframe);
    [direct, delays, reverb] = interpRIR(r, rirType);
    
    if(strcmp(parts, 'L'))
        reverb(delays) = 0;
    end
    id = find(direct>0, 1);
    direct = circshift(direct, 1-id);
    reverb = circshift(reverb, 1-id);
    RTFs(:, :, i) = fft([direct, reverb], fftLen);
end
wavFrameLR = real(ifft(repmat(fft(wavFrame, fftLen), 1, 2).*RTFs));
wavDR = frame2wav(wavFrameLR, NRf);
wavDR = wavDR / max(abs(wavDR(:))) / 1.25;
audiowrite(fnames{1}, wavDR(:, 1), fs);
audiowrite(fnames{2}, wavDR(:, 2), fs);

%%
wav1 = BinauralDistRenderer(fnames(1), pos, timeTag);
wav2 = BinauralDistRenderer(fnames(2), pos*1e5, timeTag);
Outname = strrep(fnames{1}, '0D', 'DistChange');
wav = wav1{1} + wav2{1};
audiowrite(Outname, wav/max(abs(wav(:)))/1.25, fs);