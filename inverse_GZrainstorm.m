function t = inverse_GZrainstorm(v, area)
%INVERSE_GZRAINSTORM �˴���ʾ�йش˺�����ժҪ
%   ������̹�ʽ���溯��������������������ˮ���ʵĽ���
v = v /(area/10000);
t1 = 1/((25000*v)/37019069)^(500/403) + 298/5;
if t1 >= 60 && t1 <=120
    t = t1;
elseif t1 >= 120
    t = 120;
elseif t1 <= 60
    t = 60;
end
end

