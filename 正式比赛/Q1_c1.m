% % 情形一：一道工序的物料加工过程
% % 每一组数据运行时要修改time1、time2、time3、time4和移动距离的公式
% % 当前数据为第一组数据

clc;clear all;
% 计算各CNC之间的移动距离
temp1=ones(4); % 距离矩阵
for i=1:4
    for j=1:4
        if i==j
            temp1(i,j)=0;
        elseif i<j
            k=j-i;
            temp1(i,j)=7+13*k; % 移动k单位所需时间
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
% 初始距离矩阵
time1=31; % RGV为偶数编号CNC一次上下料所需时间
time2=28; % RGV为奇数编号的CNC一次上下料所需时间
time3=25; % RGV完成一个物料的清洗作业所需时间
time4=560; % CNC加工完成一个一道工序的物料所需时间
for i=1:8
    for j=1:8
        if rem(j,2)==0 % 偶数编号的CNC
            V0(i,j)= d(i,j)+time1;
        else % 奇数编号的CNC
            V0(i,j)= d(i,j)+time2;
        end
    end
end
% 中间距离矩阵
for i=1:8
    for j=1:8
        if rem(j,2)==0 % 偶数编号的CNC
            V(i,j)= d(i,j)+time1+time3;
        else % 奇数编号的CNC
            V(i,j)= d(i,j)+time2+time3;
        end
    end
end
% 实时距离矩阵
tempV0=V0;
tempV=tempV0;
% 动态最小生成树调度法
temp1=zeros([],2);
temp2=zeros();
t=0;% 时间
r=[];% 记录RGV的每一步
rnowt=[];% 时间线
rt=[];% 记录RGV每一步所消耗的时间
flag=0;% 判断第一轮空作业是否完成
while t<8*3600
    if t==0 % 初始状态，RGV处于CNC1#和CNC2#正中间，所有CNC都处于空闲状态
        mind=inf;
        for i=1:2
            % 寻找造成延误效果最小的一步
            for j=1:8
                if V0(i,j)<=mind % 选择造成最小消耗的机器
                    mind=V0(i,j);
                    r(1)=j; % 记录第一步
                    rnowt=mind; % 记录对应消耗时间
                    rt(1)=mind; % 记录时间线
                end
            end
        end
        t=t+mind;
        
        % 新加入工作的机器进入加工状态，更新实时路径
        tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    elseif size(r)<8
        for i=1:8
            temp1(i,1)=i;
            for j=1:8
                if i~=r(end)
                    if i==j
                        if (V0(r(end),i)-max(tempV0(r(end),j)-V0(r(end),j),0))>0 % 判断选择机器i对它本身是否造成延误
                            temp1(i,2)=temp1(i,2)+V0(r(end),i)-max(tempV0(r(end),j)-V0(r(end),j),0); % 计算选择机器i对它本身造成的延误时间
                        end
                    else
                        if (tempV0(r(end),i)-max(tempV0(i,j)-tempV0(r(end),j),V0(i,j)))>0 % 判断选择机器i对其他机器是否造成延误
                            temp1(i,2)=temp1(i,2)+tempV0(r(end),i)-max(tempV0(i,j)-tempV0(r(end),j),V0(i,j)); % 计算选择机器i对其他机器造成的延误时间
                        end
                    end
                end
            end
        end
        % 寻找造成延误效果最小的下一步
        temp1(temp1(:,2)==0,:)=[];
        min=inf;
        for k=1:size(temp1,1)
            if temp1(k,2)<min
                min=temp1(k,2);
                minx=temp1(k,1);
            end
        end
        temp1=zeros([],2); % 清空存放延误时间的临时数组
        
        % % 记录当前结果
        mind=tempV0(r(end),minx);
        t=t+mind; % 时间增加
        rt=[rt t]; % 时间线
        r=[r minx]; % RGV移动到选择的点
        rnowt=[rnowt mind];% 记录每一步的对应时间
        
        % % 更新实时路径
        for i=1:8
            for j=1:8
                if tempV0(i,j)-mind>V0(i,j)
                    tempV0(i,j)=tempV0(i,j)-mind; 
                else
                    tempV0(i,j)=V0(i,j);
                end
            end
        end
        % 新加入工作的机器进入加工状态，更新实时路径
        tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    else
        if flag==0 % 是否已结束第一轮空作业
            tempV=tempV0+time3;
            flag=1;
        end
        for i=1:8
            temp1(i,1)=i;
            % 计算选择机器i对其他机器产生的影响
            for j=1:8
                if i~=r(end)
                   if i==j
                        if (V(r(end),i)-max(tempV(r(end),j)-V(r(end),j),0))>0 % 判断选择机器i对它本身是否造成延误
                            temp1(i,2)=temp1(i,2)+V(r(end),i)-max(tempV(r(end),j)-V(r(end),j),0); % 计算选择机器i对它本身造成的延误时间
                        end
                    else
                        if (tempV(r(end),i)-max(tempV(i,j)-tempV(r(end),j),V(i,j)))>0 % 判断选择机器i对其他机器是否造成延误
                            temp1(i,2)=temp1(i,2)+tempV(r(end),i)-max(tempV(i,j)-tempV(r(end),j),V(i,j)); % 计算选择机器i对其他机器造成的延误时间
                        end
                    end
                end
            end
        end
        % 寻找造成延误效果最小的下一步
        temp1(temp1(:,2)==0,:)=[];
        min=inf;
        for k=1:size(temp1,1)
            if temp1(k,2)<min
                min=temp1(k,2);
                minx=temp1(k,1);
            end
        end
        temp1=zeros([],2); % 清空存放延误时间的临时数组
        
        % % 记录当前结果
        mind=tempV(r(end),minx);
        t=t+mind; % 时间增加
        rt=[rt t]; % 记录每一步的对应时间
        r=[r minx]; % RGV移动到选择的点
        rnowt=[rnowt mind]; % 时间线
        
        % % 更新实时路径
        for i=1:8
            for j=1:8
                if tempV(i,j)-mind>V(i,j) % 对于进入工作状态的机器，更新实时路径
                    tempV(i,j)=tempV(i,j)-mind; 
                else
                    tempV(i,j)=V(i,j);
                end
            end
        end
        % 新加入工作的机器进入加工状态，更新实时路径
        tempV(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    end
end

% % 整理结果
result=[];
for i=1:size(r,2)
    if i<=8
        if rem(i,2)==0
            result(i,1)=r(i);
            result(i,2)=rt(i)-time1;
        else
            result(i,1)=r(i);
            result(i,2)=rt(i)-time2;
        end
    else
        if rem(i,2)==0
            result(i,1)=r(i);
            result(i,2)=rt(i)-time1-time3;
            result(i-8,3)=rt(i)-time1-time3;
        else
            result(i,1)=r(i);
            result(i,2)=rt(i)-time2-time3;
            result(i-8,3)=rt(i)-time2-time3;
        end
    end
end