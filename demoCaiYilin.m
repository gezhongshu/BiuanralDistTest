global HRTF fs Nf Nw Nfft distance;
hrdb = load('../../../library/HRTF/PKU/hrir_small_44100.mat');
hrdb = hrdb.hrirDb;
hrir = hrdb.hrir;
distance = hrdb.dist/100;
fs = hrdb.fs;
Nf = 2^9;
Nw = 2^7;
len = size(hrir, 1);
Nfft = len+Nf+Nw; 
HRTF = fft(hrir, Nfft);
% 
% wavIn = audioread('Die For You.mp3');
% wavIn = mean(wavIn, 2);
% audiowrite('Die For You.wav', wavIn, fs);

outpath = './Demo/';
wavIn = audioread('蔡依林.mp3');
rlen = 2^14;
NRf = 2^14;
NRw = 2^10;
fftLen = NRf + NRw + rlen - 1;

[pos, timeTag] = pos_CaiYilin();
rirType = 'Art';
parts = 'F';

fnames = {sprintf('%stmpD.wav', outpath), ...
    sprintf('%stmpR.wav', outpath)};

[wavFrame, nframe] = wav2frame([wavIn(441:end, 2); zeros(440, 1)], NRf, NRw);
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
wavDR = wavDR / 2;
audiowrite(fnames{1}, wavDR(:, 1), fs);
audiowrite(fnames{2}, wavDR(:, 2), fs);

wav1 = BinauralDistRenderer(fnames(1), pos, timeTag);
wav2 = BinauralDistRenderer(fnames(2), pos*1e5, timeTag);
wav = wav1{1} + wav2{1};


pos(:, 1) = 2;
pos(:, 2:3) = 0;
[wavFrame, nframe] = wav2frame(wavIn(:, 1)/2, NRf, NRw);
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
wavDR = wavDR / 2;
audiowrite(fnames{1}, wavDR(:, 1), fs);
audiowrite(fnames{2}, wavDR(:, 2), fs);

wav1 = BinauralDistRenderer(fnames(1), pos, timeTag);
% wav2 = BinauralDistRenderer(fnames(2), pos*1e5, timeTag);
wav = wav + wav1{1};

audiowrite([outpath, '蔡依林人声环绕.wav'], wav/max(abs(wav(:)))/1.25, fs);