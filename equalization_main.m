clear;
close all;
clc;

%parameters
channel=[0.5,1,1.2,-1];
SNR=30;
Delta=15;
Equalization_L=35;%均衡器长度
step=0.4;%步长
epsilon=1e-6;%校正项
Train_L=500;%训练序列长度  
Data_L=5000;%数据序列长度

N=round((Equalization_L-1)/2);%均衡器长度的一半
mode=2;%1: LMS 2: NLMS
M=16;%星座图点数

rng(20240512);

%QPSK
Equalization=equalization_train(Train_L,channel,SNR,Delta,N,step,epsilon,mode);
SER=equalization_trans(Data_L,Equalization,channel,SNR,Delta,N,step,epsilon,M,mode);
disp(SER);


%注意！以下代码与equalization_trans中的打印图片不能同时开启，否则会导致电脑卡死
SER=zeros(26,4);
for M=[4,16,64,256]
    for SNR=5:30
        SER(SNR-4,log2(M)/2)=equalization_trans(Data_L,Equalization,channel,SNR,Delta,N,step,epsilon,M,mode);
    end
end
SER(SER==0)=1e-8;
figure;
hold on;
for M=[4,16,64,256]
    plot(5:30,SER(:,log2(M)/2));
end
xlabel('SNR/dB');
ylabel('SER');
legend('4QAM','16QAM','64QAM','256QAM');
set(gca,'yscale','log');