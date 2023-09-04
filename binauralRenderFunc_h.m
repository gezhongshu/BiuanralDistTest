pow2Ind = @(x)(ceil(log(x)/log(2)));
[wav, fs_w] = audioread('horse5.1.wav');% 输入音频流应当为44100 Hz采样率
if(fs_w~=44100)
    wav = resample(wav, 44100, fs_w);
    wav = wav / max(abs(wav(:))) / 1.25;
end
wav(:, 1) = wav(:, 1)/2;
%% 以下可以作为初始化函数的设置内容
frameSize = 512; % 帧长，可设定参数
ch = size(wav, 2); % 输入音频的通道数
% 固定参数与全局变量
fid = fopen('hrir_db_h72_44.1k.bin', 'rb');
hrir_db = fread(fid, inf, 'float32');
fclose(fid);
hrir_db = reshape(hrir_db, [256, 2, 72]);
delta = 5;
azims = 0:delta:360;
hLen = 256;
fs = 44100;

overlape = 2^pow2Ind(frameSize/4);
wnd = (1-cos((1:overlape)'/(overlape+1)*pi))/2;
fftLen = 2^pow2Ind(frameSize + overlape + hLen);
hrtfs = fft(hrir_db, fftLen);
hrtfs(end/2+2:end, :, :) = [];
head = zeros(overlape, ch);
tail = zeros(overlape + hLen, 2);

%% 模拟音频流输入输出
Start = 1;
Total = size(wav, 1);
output = zeros(Total + hLen + overlape, 2);
cnt = 0;
while(Start < Total)
    if(mod(cnt, 201)==0)
        tmp = mod(cnt, 20) + 1;
        process = sprintf('Calculating:%s%03d / 100', [repmat('>', [1 tmp]) repmat(' ', [1 20-tmp])], ...
            round(Start/Total*100));
        fprintf('%s', process);
    end
    frameIn = zeros(frameSize, ch);
    End = min(Start + frameSize - 1, Total);
    frameIn(1:End-Start+1, :) = wav(Start:End, :); % 输入音频帧
%     dirs = [0 ,mod(cnt/5, 360)]; % 指定通道对应的水平角
    dirs = [30, -30, 0, 0, 110, -110]; % 指定通道对应的水平角
    %% 以下可以作为音频帧处理函数进行调用
    binaural = zeros(fftLen, 2);
    for ich = 1:ch
        frame = zeros(overlape + frameSize, 1);
        frame(1:overlape) = head(:, ich).*wnd;
        frame(overlape+1:frameSize) = frameIn(1:frameSize-overlape, ich);
        head(:, ich) = frameIn(end - overlape + 1:end, ich).*wnd;
        frame(frameSize+1:end) = frameIn(end - overlape + 1:end, ich) - head(:, ich);
        % 根据方向对传递函数进行插值
        dir = mod(dirs(ich), 360);
        ind1 = floor(dir/delta)+1;
        ind2 = ind1+1;
        c1 = (azims(ind2) - dir)/delta;
        c2 = 1 - c1;
        ind2 = mod(ind2 - 1, 360/delta) + 1;
        hrtf = hrtfs(:, :, ind1)*c1 + hrtfs(:, :, ind2)*c2;
        
        frameFFT = fft(frame, fftLen);
        binauFFT = repmat(frameFFT(1:size(hrtf, 1)), [1 2]).*hrtf;
        binauFFT(end) = real(binauFFT(end));
        binaural = binaural + ifft([binauFFT; conj(binauFFT(end-1:-1:2, :))]);
    end
    indT = size(tail, 1);
    binaural(1:indT, :) = binaural(1:indT, :) + tail;
    output(Start:Start + frameSize - 1, :) = binaural(1:frameSize, :);
    tail = binaural(frameSize+1:end, :);
    Start = Start + frameSize;
    
    cnt = cnt + 1;
    if(mod(cnt, 201)==0)
        fprintf(repmat('\b', [1 length(process)]));
    end
end
fprintf('\nCalculated:%s100 / 100\n', repmat('>', [1 20]));
audiowrite('bi_horse5.1.wav', output, fs);