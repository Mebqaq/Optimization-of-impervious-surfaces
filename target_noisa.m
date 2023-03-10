%无不透水地表情况下的径流计算
function xiashenliang_noisa= target_noisa(CN,slope,p)
%TARGET 此处显示有关此函数的摘要
%impervious是优化后的不透水面密度
%CN是原始CN值
%slope是坡度
%P是降雨量
%S是滞水量
%   此处显示详细说明
%CN值的修正
% CN2=[];
% CN3=[];
% CN_adjusted=[];
% S=[];
% runoff=[];
%不透水面修正CN值
%CN2=CN+ISA.*(98-CN);
CN2=CN;
%不透水面修正后求CN3
CN3=CN2.*exp(0.00673*(100-CN2));
%用坡度修正后的最终CN值
CN_adjusted=((CN3-CN2)/3).*((1-2*exp(-13.86*slope)))+CN2;
%CN_adjusted=((CN3-CN2)/3)-((1-2*exp(-13.86*slope)))+CN2;
% CN_adjusted=cn;
%计算滞水量
S=25400./CN_adjusted-254;
[m,n] = size(S);
if m == 1 && n == 1
    if p>0.2*S %如果p>0.2s，使用SCS-CN模型，否则径流量为0
        runoff=(p-0.2*S).^2./(p+0.8*S);
    else
        runoff=0;
    end
else
    %假设全部p>0.2s，使用SCS-CN模型
    runoff=(p-0.2*S).^2./(p+0.8*S);
    %找到满足p<0.2s的位置并赋值为0
    runoff(logical(p<=0.2*S))=0;
end
xiashenliang_noisa = p - runoff; %单位mm
end

