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
ISA_opt = xlsread('D:\shiyan_neilao\laochengqu\result\249\试一下结果.xlsx','sheet','B2:B546');

jingliuxishu_origin = ones(num, 1);
a = cputime;
[jiangyuliang, paishuiliang] = jiangyuliangandpaishuiliang(yushuikoushu_origin);
b = cputime;
b-a
fprintf('降雨量和排水量计算完成\n');
c = cputime;
for i = 1:num
    i
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
    
    %===================多元线性规划========================
    %======目标函数========
    CN_column = CN(:);
    f = double(98 -  CN_column);
    %=========lb ub=========
    ISA_column = ISA(:);
    xishu_isa_xishu_ublb = 0.2; %水文单元不透水密度的变化范围。防止变化过于夸张
    lb = double(ISA_column * (1 - xishu_isa_xishu_ublb)); %下界
    ub = double(ISA_column * (1 + xishu_isa_xishu_ublb)); %上界
    ub(ub > 1) = 1; %上界不能超过1
    %============Aeq * x = beq===============
    sgs = length(ISA); %统计栅格个数
    beq = ISA_opt(i) * sgs;
    Aeq = ones(1, sgs);
    %=============MLP==============
    [x,fval,exitflag,output,lambda]=linprog(f,[],[],Aeq,beq,lb,ub);
    %======结果写进影像===========
    ISA_after = imread(['D:\shiyan_neilao\laochengqu\ISA\',char(name(1,i))]); % 这一步主要还是获取ISA影像中栅格的分布情况
    ISA_after(ISA_after>=0) = x; %优化结果写进ISA_after
    ISA_after(ISA_after<0) = -1;
    [C,R]=geotiffread(['D:\shiyan_neilao\laochengqu\ISA\',char(name(1,i))]);
    info=geotiffinfo(['D:\shiyan_neilao\laochengqu\ISA\',char(name(1,i))]);
    out_path=['D:\shiyan_neilao\laochengqu\MLP结果\',num2str(i-1),'.tif'];
    geotiffwrite(out_path,ISA_after,R, 'GeoKeyDirectoryTag', info.GeoTIFFTags.GeoKeyDirectoryTag);
end
cputime - c
fprintf('程序结束\n');