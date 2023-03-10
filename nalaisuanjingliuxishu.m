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

%优化后的结果试一试
yushuikoushu_opt = xlsread('D:\shiyan_neilao\laochengqu\result\249\试一下结果.xlsx','sheet','C2:C546');
ISA_opt = xlsread('D:\shiyan_neilao\laochengqu\result\249\试一下结果.xlsx','sheet','B2:B546');

jingliuxishu_origin = ones(num, 1);
jingliuxishu_opt = ones(num, 1);
jingliuxishu_idea = ones(num, 1);

a = cputime;
[jiangyuliang, paishuiliang] = jiangyuliangandpaishuiliang(yushuikoushu_origin);
[jiangyuliang_after, paishuiliang_after] = jiangyuliangandpaishuiliang(yushuikoushu_opt);%计算优化之后的最大时刻的降雨量和排水量
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
    %==================计算优化后的径流系数===============
    jiangyu = jiangyuliang_after(i);%单位为mm
    xiashen = xiashenliang(ISA_opt(i), swdy_CN(i), swdy_slope(i),jiangyuliang(i));%单位为mm
    paishui = paishuiliang_after(i)/area(i);%将单位从L转为mm
    jingliuxishu_opt(i) = (jiangyu - xiashen - paishui)/jiangyu;
    %=================计算余华飞版优化率参数================
    jiangyu = jiangyuliang_after(i);%单位为mm
    xiashen = target_noisa(swdy_CN(i), swdy_slope(i),jiangyuliang(i));%单位为mm
    paishui = paishuiliang_after(i)/area(i);%将单位从L转为mm
    jingliuxishu_idea(i) = (jiangyu - xiashen - paishui)/jiangyu;
end
youhualv = (jingliuxishu_origin - jingliuxishu_opt) ./ jingliuxishu_origin;
youhualv_yuhuafei = (jingliuxishu_origin - jingliuxishu_opt) ./ (jingliuxishu_origin - jingliuxishu_idea);
mean_youhualv = mean(youhualv(:));
mean_youhualv_yuhuafei = mean(youhualv_yuhuafei(:));