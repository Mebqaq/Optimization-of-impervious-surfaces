function f = fitnessfunction(x, num, swdy_CN, swdy_slope, area)
%FITNESSFUNCTOIN 此处显示有关此函数的摘要
%   目标函数
ISA = x(:,1:num);
yushuikoushu = x(:,(num+1): (2*num) );
[jiangyu,paishui] = jiangyuliangandpaishuiliang(yushuikoushu);
paishui = paishui ./ area; %单位从L转为mm
xiashen = xiashenliang(ISA, swdy_CN, swdy_slope,jiangyu);
f = ones(2,1);
jishui = jiangyu - paishui - xiashen;
f(1) = sum(jishui(:)); %目标1，总积水量最小
f(2) = std2(jishui); %目标2，每个水文单元间的
end

