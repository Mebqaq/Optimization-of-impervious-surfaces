%�޲�͸ˮ�ر�����µľ�������
function xiashenliang_noisa= target_noisa(CN,slope,p)
%TARGET �˴���ʾ�йش˺�����ժҪ
%impervious���Ż���Ĳ�͸ˮ���ܶ�
%CN��ԭʼCNֵ
%slope���¶�
%P�ǽ�����
%S����ˮ��
%   �˴���ʾ��ϸ˵��
%CNֵ������
% CN2=[];
% CN3=[];
% CN_adjusted=[];
% S=[];
% runoff=[];
%��͸ˮ������CNֵ
%CN2=CN+ISA.*(98-CN);
CN2=CN;
%��͸ˮ����������CN3
CN3=CN2.*exp(0.00673*(100-CN2));
%���¶������������CNֵ
CN_adjusted=((CN3-CN2)/3).*((1-2*exp(-13.86*slope)))+CN2;
%CN_adjusted=((CN3-CN2)/3)-((1-2*exp(-13.86*slope)))+CN2;
% CN_adjusted=cn;
%������ˮ��
S=25400./CN_adjusted-254;
[m,n] = size(S);
if m == 1 && n == 1
    if p>0.2*S %���p>0.2s��ʹ��SCS-CNģ�ͣ���������Ϊ0
        runoff=(p-0.2*S).^2./(p+0.8*S);
    else
        runoff=0;
    end
else
    %����ȫ��p>0.2s��ʹ��SCS-CNģ��
    runoff=(p-0.2*S).^2./(p+0.8*S);
    %�ҵ�����p<0.2s��λ�ò���ֵΪ0
    runoff(logical(p<=0.2*S))=0;
end
xiashenliang_noisa = p - runoff; %��λmm
end

