function f = fitnessfunction(x, num, swdy_CN, swdy_slope, area)
%FITNESSFUNCTOIN �˴���ʾ�йش˺�����ժҪ
%   Ŀ�꺯��
ISA = x(:,1:num);
yushuikoushu = x(:,(num+1): (2*num) );
[jiangyu,paishui] = jiangyuliangandpaishuiliang(yushuikoushu);
paishui = paishui ./ area; %��λ��LתΪmm
xiashen = xiashenliang(ISA, swdy_CN, swdy_slope,jiangyu);
f = ones(2,1);
jishui = jiangyu - paishui - xiashen;
f(1) = sum(jishui(:)); %Ŀ��1���ܻ�ˮ����С
f(2) = std2(jishui); %Ŀ��2��ÿ��ˮ�ĵ�Ԫ���
end

