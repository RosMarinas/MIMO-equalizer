function [Equalization]=equalization_train(Length,channel,SNR,Delta,N,step,epsilon,mode)
    %QPSK simulation
    sequence=randi([0,3],[Length+4*N,1]); %生成随机序列
    sequence_QPSK=qammod(sequence,4,'gray'); %QPSK调制
    QPSK_channel=filter(channel,1,sequence_QPSK); %信道传输
    %加入高斯白噪声
    power=2*(sum(channel.^2)); %信号功率
    y_QPSK=awgn(QPSK_channel,SNR,10*log10(power)); %加入高斯白噪声
    %均衡器训练
    Equalization=complex(zeros(1,2*N+1)); %均衡器初始化
    for i=1:Length
        sequence_train=y_QPSK(i+2*N:-1:i); %训练序列;
        err=sequence_QPSK(i+2*N-Delta)-Equalization*sequence_train; %误差
        %权值更新
        if mode==1 %LMS
            Equalization=Equalization+(step*conj(err).*sequence_train)';
        elseif mode==2 %NLMS
            Equalization=Equalization+(step*conj(err).*sequence_train./(epsilon+sequence_train'*sequence_train))';
        end
          
    end
end