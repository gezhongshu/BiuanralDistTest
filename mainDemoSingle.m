global fs Nf Nw Nfft;
info = HRIRInfo('PKU', '../../../library/HRTF/');
fs = info.fs;
len = info.len;
Nf = 2^9;
Nw = 2^7;
Nfft = len+Nf+Nw; 
% 
% wavIn = audioread('Die For You.mp3');
% wavIn = mean(wavIn, 2);
% audiowrite('Die For You.wav', wavIn, fs);

outpath = './Demo/';
wavIn = audioread('Die For You.wav');
rlen = 2^14;
NRf = 2^14;
NRw = 2^9;
fftLen = NRf + NRw + rlen - 1;

[pos, timeTag] = pos_die_for_you();
rirType = 'Art';
parts = 'F';
fnames = {sprintf('%sDFY_D_%s_%s.wav', outpath, rirType, parts), ...
    sprintf('%sDFY_R_%s_%s.wav', outpath, rirType, parts)};

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
audiowrite('DieForYou_Move.wav', wavDR, fs);
audiowrite(fnames{1}, wavDR(:, 1), fs);
audiowrite(fnames{2}, wavDR(:, 2), fs);

%%
wav1 = BinauralDistRenderer(fnames(1), pos, timeTag);
wav2 = BinauralDistRenderer(fnames(2), pos*1e5, timeTag);
Outname = strrep(fnames{1}, 'DFY_D', 'Die For You ');
wav = wav1{1} + wav2{1};
audiowrite(Outname, wav/max(abs(wav(:)))/1.25, fs);