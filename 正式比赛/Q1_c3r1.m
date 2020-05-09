clc;clear all;
% �����CNC֮����ƶ�����
temp1=ones(4); % �������
for i=1:4
    for j=1:4
        if i==j
            temp1(i,j)=0;
        elseif i<j
            k=j-i;
            temp1(i,j)=7+13*k; % ��һ��
            temp1(j,i)=temp1(i,j);
        end
    end
end
for i=1:8
    temp2(:,i)=temp1(:,ceil(i/2));
end
for j=1:8
    d(j,:)=temp2(ceil(j/2),:);
end
% ��ʼ�������
time1=31; % RGVΪż�����CNCһ������������ʱ��
time2=28; % RGVΪ������ŵ�CNCһ������������ʱ��
time3=25; % RGV���һ�����ϵ���ϴ��ҵ����ʱ��
time4=560; % CNC�ӹ����һ��һ���������������ʱ��
for i=1:8
    for j=1:8
        if rem(j,2)==0 % ż����ŵ�CNC
            V0(i,j)= d(i,j)+time1;
        else % ������ŵ�CNC
            V0(i,j)= d(i,j)+time2;
        end
    end
end
% �м�������
for i=1:8
    for j=1:8
        if rem(j,2)==0 % ż����ŵ�CNC
            V(i,j)= d(i,j)+time1+time3;
        else % ������ŵ�CNC
            V(i,j)= d(i,j)+time2+time3;
        end
    end
end
% ʵʱ�������
tempV0=V0;
tempV=tempV0;
% ��̬��С���������ȷ�
temp1=zeros([],2);
temp2=zeros();
t=0;% ʱ��
r=[];% ��¼RGV��ÿһ��
rnowt=[];% ʱ����
rt=[];% ��¼RGVÿһ�������ĵ�ʱ��
flag=0;% �жϵ�һ�ֿ���ҵ�Ƿ����
flagerror1=zeros(8,500);% ��¼����
flagerror2=zeros(8,500);% ��¼������ֲ���
flag1=0;% �жϸôμӹ��������Ƿ��жϹ�����
errortime=[];% ÿ�ι��ϵ�ʱ��
errornum=zeros(1,8);% ÿ̨�������ϴ���
errorall=0; % ��������
errorstep=[]; % ���ϳ���ʱ��r
while t<8*3600
    if t==0 % ��ʼ״̬��RGV����CNC1#��CNC2#���м䣬����CNC�����ڿ���״̬
        mind=inf;
        for i=1:2
            for j=1:8
                if tempV0(j,j)~=V0(j,j) && flag1==0 % �жϸû����Ƿ��ڼӹ�״̬
                    if flag1==0 && flagerror1(j,size(r,2)+1)==0 && unifrnd(0,1)<=0.0025 % ����1%���ʵĹ���
                        errornum(i)=errornum(i)+1;% ���ϴ�������
                        flagerror1(j,size(r,2)+1)=1;% �������Ϻ󣬽�������״̬���뿪��ҵ����
                        flagerror2(j,size(r,2)+1)=1;
                        errorall=errorall+1;
                        errorstep(errorall)=size(r,2);
                        errortime(errorall)=round(unifrnd(600,1200));
                        tempV0(j,:)=V0(j,:)+errortime(errorall);
                        tempV0(:,j)=V0(:,j)+errortime(errorall);
                    elseif tempV0(j,j)~=V0(j,j) && flag1==1
                        flag1=0;
                    end
                    flag1=1; % �жϹ�һ�κ�Ͳ����ж�
                end
                % Ѱ���������Ч����С��һ��
                if V0(i,j)<=mind % ѡ�����·��
                    mind=V0(i,j);
                    r(1)=j; % ��¼��һ��
                    rnowt=mind; % ��¼��Ӧ����ʱ��
                    rt(1)=mind; % ��¼ʱ����
                end
            end
        end
        t=t+mind;
        
        % �¼��빤���Ļ�������ӹ�״̬,����ʵʱ·��
         tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    elseif size(r)<8
        for i=1:8
            temp1(i,1)=i;
            if tempV0(i,i)~=V0(i,i) && flag1==0 % �жϸû����Ƿ��ڼӹ�״̬
                if flagerror1(i,size(r,2))==0 && unifrnd(0,1)<=0.0025 % ����1%���ʵĹ���
                    flagerror1(i,size(r,2)+1)=1;% �������Ϻ󣬽�������״̬���뿪��ҵ����
                    flagerror2(i,size(r,2)+1)=1;
                    errornum(i)=errornum(i)+1;% ���ϴ�������
                    errorall=errorall+1;
                    errorstep(errorall)=size(r,2);
                    errortime(errorall)=round(unifrnd(600,1200));
                    tempV0(i,:)=V0(i,:)+errortime(errorall);
                    tempV0(:,i)=V0(:,i)+errortime(errorall);
                elseif flag1==1
                    flag1=0;
                end
                flag1=1; % �жϹ�һ�κ�Ͳ����ж�
            else
                flag1=0;
            end
            for j=1:8
                if i~=r(end) && flagerror1(i,size(r,2)+1)==0
                    if i==j
                        if (V0(r(end),i)-max(tempV0(r(end),j)-V0(r(end),j),0))>0 % �ж�ѡ�����i���������Ƿ��������
                            temp1(i,2)=temp1(i,2)+V0(r(end),i)-max(tempV0(r(end),j)-V0(r(end),j),0); % ����ѡ�����i����������ɵ�����ʱ��
                        end
                    else
                        if (tempV0(r(end),i)-max(tempV0(i,j)-tempV0(r(end),j),V0(i,j)))>0 % �ж�ѡ�����i�����������Ƿ��������
                            temp1(i,2)=temp1(i,2)+tempV0(r(end),i)-max(tempV0(i,j)-tempV0(r(end),j),V0(i,j)); % ����ѡ�����i������������ɵ�����ʱ��
                        end
                    end
                end
            end
        end
        % Ѱ���������Ч����С����һ��
        temp1(temp1(:,2)==0,:)=[];
        min=inf;
        for k=1:size(temp1,1)
            if temp1(k,2)<min
                min=temp1(k,2);
                minx=temp1(k,1);
            end
        end
        temp1=zeros([],2); % ��մ������ʱ�����ʱ����
        
        % % ��¼��ǰ���
        mind=tempV0(r(end),minx);
        t=t+mind; % ʱ������
        rt=[rt t]; % ��¼ÿһ���Ķ�Ӧʱ��
        rnowt=[rnowt mind];
        r=[r minx]; % RGV�ƶ���ѡ��ĵ�
        
        % % ����ʵʱ·��
        for i=1:8
            for j=1:8
                if tempV0(i,j)-mind>V0(i,j) % ���ڽ��빤��״̬�Ļ���������ʵʱ·��
                    tempV0(i,j)=tempV0(i,j)-mind;
                    if flagerror1(i,size(r,2)-1)==1 
                        flagerror1(i,size(r,2))=1; % ������δ�ų����Ա��Ϊ����
                        flagerror2(i,size(r,2))=1;
                    end
                else
                    tempV0(i,j)=V0(i,j); % ����������ɣ��ָ���ʼ·��
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=0; % ���������ų������Ϊ�޹���
                        flagerror2(i,size(r,2))=0;
                    end
                end
            end
        end
        % �¼��빤���Ļ�������ӹ�״̬������ʵʱ·��
        tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    else
        if flag==0 % �Ƿ��ѽ�����һ�ֿ���ҵ
            tempV=tempV0+time3;% ������ϴʱ��
            flag=1;
        end
        for i=1:8
            temp1(i,1)=i;
            if tempV(i,i)~=V(i,i) && flag1==0 % �жϸû����Ƿ��ڼӹ�״̬
                if flagerror1(i,size(r,2))==0 && unifrnd(0,1)<=0.0025 % ����1%���ʵĹ���
                    flagerror1(i,size(r,2)+1)=1; % �������Ϻ󣬽�������״̬���뿪��ҵ����
                    flagerror2(i,size(r,2)+1)=1;
                    errornum(i)=errornum(i)+1; % ���ϴ�������
                    errorall=errorall+1;
                    errorstep(errorall)=size(r,2);
                    errortime(errorall)=round(unifrnd(600,1200));
                    tempV(i,:)=V(i,:)+errortime(errorall);
                    tempV(:,i)=V(:,i)+errortime(errorall);
                elseif flag1==1
                    flag1=0;
                end
                flag1=1; % �жϹ�һ�κ�Ͳ����ж�
            else
                flag1=0;
            end
            % ����ѡ�����i����������������Ӱ��
            for j=1:8
                if i~=r(end) && flagerror1(i,size(r,2)+1)==0 
                   if i==j
                        if (V(r(end),i)-max(tempV(r(end),j)-V(r(end),j),0))>0 % �ж�ѡ�����i���������Ƿ��������
                            temp1(i,2)=temp1(i,2)+V(r(end),i)-max(tempV(r(end),j)-V(r(end),j),0); % ����ѡ�����i����������ɵ�����ʱ��
                        end
                    else
                        if (tempV(r(end),i)-max(tempV(i,j)-tempV(r(end),j),V(i,j)))>0 % �ж�ѡ�����i�����������Ƿ��������
                            temp1(i,2)=temp1(i,2)+tempV(r(end),i)-max(tempV(i,j)-tempV(r(end),j),V(i,j)); % ����ѡ�����i������������ɵ�����ʱ��
                        end
                    end
                end
            end
        end
        % Ѱ���������Ч����С����һ��
        temp1(temp1(:,2)==0,:)=[];
        min=inf;
        for k=1:size(temp1,1)
            if temp1(k,2)<min
                min=temp1(k,2);
                minx=temp1(k,1);
            end
        end
        temp1=zeros([],2); % ��մ������ʱ�����ʱ����
        
        % % ��¼��ǰ���
        mind=tempV(r(end),minx);
        t=t+mind; % ʱ������
        rt=[rt t]; % ��¼ÿһ���Ķ�Ӧʱ��
        r=[r minx]; % RGV�ƶ���ѡ��ĵ�
        rnowt=[rnowt mind]; % ʱ����
        
        % % ����ʵʱ·��
        for i=1:8
            for j=1:8
                if tempV(i,j)-mind>V(i,j) % ���ڽ��빤��״̬�Ļ���������ʵʱ·��
                    tempV(i,j)=tempV(i,j)-mind;
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=1; % ������δ�ų����Ա��Ϊ����
                        flagerror2(i,size(r,2))=1;
                    end
                else
                    tempV(i,j)=V(i,j); % ����������ɣ��ָ���ʼ·��
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=0; % ���������ų������Ϊ�޹���
                        flagerror2(i,size(r,2))=0;
                    end
                end
            end
        end
        % �¼��빤���Ļ�������ӹ�״̬������ʵʱ·��
        tempV(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    end
end
% % % % ������
% % errornum(9)=sum(errornum);
% % error=flagerror2(:,1:size(r,2));
% % error=[error;rt];
% % error=[errornum' error];
% result=[];
% 
% for i=1:size(r,2)
%     if i<=8
%         if rem(i,2)==0
%             result(i,1)=r(i);
%             result(i,2)=rt(i)-time1;
%         else
%             result(i,1)=r(i);
%             result(i,2)=rt(i)-time2;
%         end
%     elseif i> 8&& i<errorstep(1)
%         if rem(i,2)==0
%             result(i,1)=r(i);
%             result(i,2)=rt(i)-time1-time3;
%             result(i-8,3)=rt(i)-time1-time3;
%         else
%             result(i,1)=r(i);
%             result(i,2)=rt(i)-time2-time3;
%             result(i-8,3)=rt(i)-time2-time3;
%         end
%     elseif i>errorstep(1) && i<errorstep(2)
%         
%     elseif i>errorstep(2)&&i<errorstep(3)
%         
%     elseif i>errorstep(3)&&i<errorstep(4)
%         
%     elseif i>errorstep(4)
%         
%     end
% end