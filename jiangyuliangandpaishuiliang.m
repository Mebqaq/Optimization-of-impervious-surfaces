function [Qjiangyuliang, Qpaishuiliang] = jiangyuliangandpaishuiliang(yushuikoushu)
%PAISHUILIANG �˴���ʾ�йش˺�����ժҪ
%   �˺�������ӿ�ʼ���굽���㴦�ĵ��¹�������ˮ��,
%   yushuikoushu���������һ��������/�����������ص���num*1������������ʽ,��������λmm����ˮ����λL
k = 0.34; %������
num = 545;  %����С����/ˮ�ĵ�Ԫ��
v_paishui  = k * 27.155 .* yushuikoushu;%��ˮ�ڵ���ˮ����
area = xlsread('D:\shiyan_neilao\laochengqu\��ˮ����545.xls','yushuikoushu','D2:D546');%ˮ�ĵ�Ԫ�����
Qpai = ones(num,1);
Qjiangyu = ones(num,1);
syms t;
for i = 1:num % ����ÿһ����Ԫ
    [~,v] = GZrainstorm(t, area(i));
    t1 = inverse_GZrainstorm(v_paishui(i), area(i)); %����õ�Ԫ�Ľ��㣬����ˮ����=v_paishui(i)ʱ�������ʱ��t
    Qjiang_Qpai = (double(int(v,t, 60, t1)) - v_paishui(i)*(t1-60))*60*2; %��Ӱ�����������λL
    Qjiang = (double(int(v,t,60,120))+double(int(v,t,60,t1)))*60; %���㵽�ｻ��ʱ������ˮ���ʱ�Ľ���������λL
    Qjiangyu(i) = Qjiang;
    Qpai(i) = Qjiang - Qjiang_Qpai; %������ˮ������λL
end
Qjiangyuliang = Qjiangyu./area;%��������λת��Ϊmm����L/�O
Qpaishuiliang = Qpai;
end

