function [SER]=equalization_trans(Length,Equalization,channel,SNR,Delta,N,step,epsilon,M,mode)
    sequence_constellation=qammod(0:M-1,M); %星座点

    %num_QAM 
    data=randi([0,M-1],[Length+4*N,1]); %生成随机序列
    data_QAM=qammod(data,M,'gray'); %QAM调制
    QAM_channel=filter(channel,1,data_QAM); %信道传输
    %加入高斯白噪声
    power=sum(channel.^2)*mean(abs(sequence_constellation).^2); %信号功率
    y_QAM=awgn(QAM_channel,SNR,10*log10(power)); %加入高斯白噪声
   

    data_hat=zeros(1,Length); %均衡后的数据
    data_judgment=zeros(1,Length); %判决数据
    error_num=0; %错误数据

    for i=1:Length
        sequence=y_QAM(i+2*N:-1:i); 
        data_equalization=Equalization*sequence; %均衡
        %判决
        [~,index]=min(abs(data_equalization-sequence_constellation));
        data_hat(i)=data_equalization;
        data_judgment(i)=sequence_constellation(index);
        error=sequence_constellation(index)-data_equalization;
        if mode == 1 %LMS
            Equalization=Equalization+(step*conj(error).*sequence)';
        elseif mode == 2 %NLMS
            Equalization=Equalization+(step*conj(error).*sequence./(epsilon+sequence'*sequence))';
        end
        if data_QAM(i+2*N-Delta)~=sequence_constellation(index)
            error_num=error_num+1;
        end
        
    end
    SER=error_num/Length;
% figure;
% scatter(real(data_QAM),imag(data_QAM));
% title('s(i)');
% xlabel('Re');
% ylabel('Im');
% 
% figure;
% scatter(real(y_QAM),imag(y_QAM));
% title('u(i)');
% xlabel('Re');
% ylabel('Im');
% 
% figure;
% scatter(real(data_hat),imag(data_hat));
% title('均衡后结果');
% xlabel('Re');
% ylabel('Im');
end

