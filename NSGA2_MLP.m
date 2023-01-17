clc
clear
num=545;  % 优化单元的数量
name=cell(3,num);  % 创建一个3行num列的单元数组
% 以字符串的形式将数据名称存储到name中
% 第1行表示ISA，第2行表示CN，第3行表示slope
for i =0:num-1   
    for j=1:3
       switch j
           case 1
               name{j,i+1}=strcat('ISA',num2str(i),'.tif');
           case 2
               name{j,i+1}=strcat('CN',num2str(i),'.tif');
           case 3
               name{j,i+1}=strcat('slope',num2str(i),'.tif');
       end
    end
end
swdy_ISA = ones(num, 1);
swdy_CN = ones(num, 1);
swdy_slope = ones(num, 1);
yushuikoushu_origin = xlsread('D:\shiyan_neilao\laochengqu\雨水篦子545.xls','yushuikoushu','B2:B546');
area = xlsread('D:\shiyan_neilao\laochengqu\雨水篦子545.xls','yushuikoushu','D2:D546');%水文单元的面积
jingliuxishu_origin = ones(num, 1);
a = cputime;
[jiangyuliang, paishuiliang] = jiangyuliangandpaishuiliang(yushuikoushu_origin);
b = cputime;
b-a
fprintf('降雨量和排水量计算完成\n');
for i = 1:num
    ISA = imread(['D:\shiyan_neilao\laochengqu\ISA\',char(name(1,i))]); % 读取数据
    CN = imread(['D:\shiyan_neilao\laochengqu\CN\',char(name(2,i))]);
    slope = imread(['D:\shiyan_neilao\laochengqu\slope\',char(name(3,i))]);
    ISA = ISA(ISA>=0); %剔除掉背景值
    swdy_ISA(i) = mean(ISA(:));%计算水文单元中的平均ISA
    CN = CN(CN>=0);
    swdy_CN(i) = mean(CN(:));%计算水文单元中的平均CN
    slope = slope(slope>=0);
    swdy_slope(i) = mean(slope(:));%计算水文单元中的平均坡度
    
    %=================计算优化前的径流系数===================
    jiangyu = jiangyuliang(i);%单位为mm
    xiashen = xiashenliang(swdy_ISA(i), swdy_CN(i), swdy_slope(i),jiangyuliang(i));%单位为mm
    paishui = paishuiliang(i)/area(i);%将单位从L转为mm
    jingliuxishu_origin(i) = (jiangyu - xiashen - paishui)/jiangyu;
end
fprintf('优化前的径流系数计算完成\n');
%===================开始准备遗传算法==============
xishu_isa_sum = 0.05; %限制不透水面总量的变化，n是限制当个栅格单元内不透水密度的变化范围
xishu_isa_xishu_ublb = 0.20; %水文单元不透水密度的变化范围
xishu_yushuikoushu = 0.20; %水文单元雨水口数量的变化范围
%计算上下界
lb1 = swdy_ISA * (1 - xishu_isa_xishu_ublb); %水文单元不透水密度的下界
lb2 = yushuikoushu_origin * 1; %雨水口数只增不减，因此下界就是本身
lb = [lb1', lb2']'; %将两个下界合并成一个列向量，便于后面输入函数中
ub1 = swdy_ISA * (1 + xishu_isa_xishu_ublb); %水文单元不透水密度的上界
ub2 = yushuikoushu_origin * (1 + xishu_yushuikoushu); %水文单元雨水口数上界
ub = [ub1', ub2']'; %上界
%限制总不透水面减少0.05以内，构造等式 A * x <= b，这里是 -1 * x <= -b
b = -1 * double(sum(ISA(ISA>0))*xishu_isa_sum);
A1 = -1 * ones(1, num);
A2 = zeros(1,num);
A = [A1, A2];
%设置变量个数
nvars = 2 * num; 
% 其他参数
% 求解器设置
% 最优个体系数paretoFraction
% 种群大小populationsize
% 最大进化代数generations
% 停止代数stallGenLimit
% 函数gaplotpareto：绘制Pareto前沿 
options = optimoptions('gamultiobj','paretoFraction',0.2,'populationsize',10,'generations',300,'stallGenLimit',200,'PlotFcns',@gaplotpareto);
%目标函数见fitnessfunction.m
c = cputime;
%开始遗传算法
[x,fval,exitflag,output,population,scores] = gamultiobj(@(x)fitnessfunction(x, num, swdy_CN, swdy_slope, area),nvars,A,b,[],[],lb,ub,options);
d = cputime;
d - c
fprintf('NSGA2完成\n');






