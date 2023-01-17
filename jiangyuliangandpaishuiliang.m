function [Qjiangyuliang, Qpaishuiliang] = jiangyuliangandpaishuiliang(yushuikoushu)
%PAISHUILIANG 此处显示有关此函数的摘要
%   此函数求出从开始降雨到交点处的地下管网的排水量,
%   yushuikoushu输入必须是一个行向量/列向量，返回的是num*1的行向量的形式,降雨量单位mm，排水量单位L
k = 0.34; %开孔率
num = 545;  %径流小区数/水文单元数
v_paishui  = k * 27.155 .* yushuikoushu;%排水口的排水速率
area = xlsread('D:\shiyan_neilao\laochengqu\雨水篦子545.xls','yushuikoushu','D2:D546');%水文单元的面积
Qpai = ones(num,1);
Qjiangyu = ones(num,1);
syms t;
for i = 1:num % 遍历每一个单元
    [~,v] = GZrainstorm(t, area(i));
    t1 = inverse_GZrainstorm(v_paishui(i), area(i)); %计算该单元的交点，即排水速率=v_paishui(i)时，降雨的时间t
    Qjiang_Qpai = (double(int(v,t, 60, t1)) - v_paishui(i)*(t1-60))*60*2; %阴影部分面积，单位L
    Qjiang = (double(int(v,t,60,120))+double(int(v,t,60,t1)))*60; %计算到达交点时，即积水最大时的降雨量，单位L
    Qjiangyu(i) = Qjiang;
    Qpai(i) = Qjiang - Qjiang_Qpai; %管网排水量，单位L
end
Qjiangyuliang = Qjiangyu./area;%降雨量单位转换为mm，即L/㎡
Qpaishuiliang = Qpai;
end

