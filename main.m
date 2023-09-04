% global HRTF_L HRTF_R azimuth elevation fs Nf Nw Nfft;
% load('../../../library/HRTF/FABIAN_clockwise.mat');
% Nf = 2^10;
% Nw = 512;
% len = size(HRTF_L, 1);
% Nfft = len+Nf+Nw;
% HRTF_L = fft(HRIR_L, Nfft);
% HRTF_R = fft(HRIR_R, Nfft);
% wavIn = audioread('Die For You.mp3');
% wavIn = mean(wavIn(24*fs:fs*36, :), 2);
% audiowrite('ori-10s.wav', wavIn, fs);
wavIn = audioread('ori-12s.wav');
% wav = BinauralRenderer_h('ori-12s.wav', 0, 2*pi);
% audiowrite('Circ_ori-12s.wav', wav{1}/max(abs(wav{1}(:)))/1.25, fs);
wlen = length(wavIn);
hlen = 16384;
fftLen = wlen + hlen - 1;
dist = [0.2 0.5 2.5 5 10 20];
DRR = [50 10 1 0.3 0.1 0.05];
fnames = {};
recalc = 1;
rirType = 'Sim';
for i = 1:length(dist)
    if(strcmp(rirType, 'Art'))
        frir = sprintf('rir_dist_%g_DRR_%g.mat', dist(i), DRR(i));
    else
        frir = sprintf('rirSim_dist_%g.mat', dist(i));
    end
    if(~exist(frir, 'file')||recalc)
        if(strcmp(rirType, 'Art'))
            [rir, delays, amps, reverbs] = generateRIR(dist(i), DRR(i));
        else
            [rir, delays, amps, reverbs] = simulateRIR(dist(i));
        end
        save(frir, 'rir', 'delays', 'amps', 'reverbs');
    else
        rirdata = load(frir);
        rir = rirdata.rir;
        delays = rirdata.delays;
    end
%     plot(rir);
%     pause;
    continue;
    parts = {'F', 'E', 'L'};
    for j = 1:3
        rirTemp = rir;
        if(j == 2)
            rirTemp(delays(end):end) = 0;
        elseif(j == 3)
            rirTemp(delays(1)+1:delays(end)) = 0;
        end
        wav = real(ifft(fft(wavIn, fftLen).*fft(rirTemp, fftLen)));
        fname = sprintf('%s_%s_dist_%g_DRR_%g.wav',rirType, parts{j}, dist(i), DRR(i));
        audiowrite(fname, wav/max(abs(wav(:)))/1.25, fs);
        fnames = [fnames fname];
    end
end

% rir2 = audioread('rir_real2.wav');
% fftLen = wlen + length(rir2) - 1;
% wav = real(ifft(fft(wavIn, fftLen).*fft(rir2, fftLen)));
% wav = wav(1:wlen+hlen);
% audiowrite('Real_2.wav', wav/max(abs(wav(:)))/1.25, fs);
% wav = BinauralRenderer_h('Real_2.wav', 0, 2*pi);
% audiowrite('Circ_Real_2.wav', wav{1}/max(abs(wav{1}(:)))/1.25, fs);

wav = BinauralRenderer_h(fnames, 0, 2*pi);
Outnames = strcat('Circ_', fnames);
for i = 1:length(Outnames)
    audiowrite(Outnames{i}, wav{i}/max(abs(wav{i}(:)))/1.25, fs);
end
%%
% wavPart = BiPartsRenderer(wavIn, 0, 2*pi);
% for i = 1:length(dist)
%     if(strcmp(rirType, 'Art'))
%         frir = sprintf('rir_dist_%g_DRR_%g.mat', dist(i), DRR(i));
%     else
%         frir = sprintf('rirSim_dist_%g.mat', dist(i));
%     end
%     if(~exist(frir, 'file'))
%         if(strcmp(rirType, 'Art'))
%             [rir, delays, amps, reverbs] = generateRIR(dist(i), DRR(i));
%         else
%             [rir, delays, amps, reverbs] = simulateRIR(dist(i));
%         end
%         save(frir, 'rir', 'delays', 'amps', 'reverbs');
%     else
%         rirdata = load(frir);
%         rir = rirdata.rir;
%         delays = rirdata.delays;
%         reverbs = rirdata.reverbs;
%         amps = rirdata.amps;
%     end
%     
% 
%     len = size(wavPart, 1)-1;
%     direct = zeros(fftLen, 2);
%     early = direct;
%     direct(delays(1):delays(1)+len, :) = wavPart(:, :, 1)*amps(1);
%     for ch = 2:5
%         early(delays(ch):delays(ch)+len, :) = early(delays(ch):delays(ch)+len, :) ...
%             + wavPart(:, :, ch)*amps(ch);
%     end
%     reverbs = [zeros(delays(end)-delays(1), 2); reverbs];
%     fftIn = fft(direct, fftLen);
%     late = real(ifft(fftIn.*fft(reverbs, fftLen)));
%     
%     parts = {'F', 'E'};
%     for j = 1:2
%         rirTemp = rir;
%         if(j == 1)
%             wav = direct + early + late;
%         elseif(j == 2)
%             wav = direct + early;
%         end
%         fname = sprintf('Circ_%sMult_%s_dist_%g_DRR_%g.wav', rirType, parts{j}, dist(i), DRR(i));
%         audiowrite(fname, wav/max(abs(wav(:)))/1.25, fs);
%     end
% end