clc;clear all;
% 计算各CNC之间的移动距离
temp1=ones(4); % 距离矩阵
for i=1:4
    for j=1:4
        if i==j
            temp1(i,j)=0;
        elseif i<j
            k=j-i;
            temp1(i,j)=7+13*k; % 第一组
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
flagerror1=zeros(8,500);% 记录错误
flagerror2=zeros(8,500);% 记录错误出现步骤
flag1=0;% 判断该次加工过程中是否判断过故障
errortime=[];% 每次故障的时长
errornum=zeros(1,8);% 每台机器故障次数
errorall=0; % 故障总数
errorstep=[]; % 故障出现时的r
while t<8*3600
    if t==0 % 初始状态，RGV处于CNC1#和CNC2#正中间，所有CNC都处于空闲状态
        mind=inf;
        for i=1:2
            for j=1:8
                if tempV0(j,j)~=V0(j,j) && flag1==0 % 判断该机器是否在加工状态
                    if flag1==0 && flagerror1(j,size(r,2)+1)==0 && unifrnd(0,1)<=0.0025 % 发生1%概率的故障
                        errornum(i)=errornum(i)+1;% 故障次数增加
                        flagerror1(j,size(r,2)+1)=1;% 发生故障后，进入休眠状态，离开作业队列
                        flagerror2(j,size(r,2)+1)=1;
                        errorall=errorall+1;
                        errorstep(errorall)=size(r,2);
                        errortime(errorall)=round(unifrnd(600,1200));
                        tempV0(j,:)=V0(j,:)+errortime(errorall);
                        tempV0(:,j)=V0(:,j)+errortime(errorall);
                    elseif tempV0(j,j)~=V0(j,j) && flag1==1
                        flag1=0;
                    end
                    flag1=1; % 判断过一次后就不再判断
                end
                % 寻找造成延误效果最小的一步
                if V0(i,j)<=mind % 选择最短路径
                    mind=V0(i,j);
                    r(1)=j; % 记录第一步
                    rnowt=mind; % 记录对应消耗时间
                    rt(1)=mind; % 记录时间线
                end
            end
        end
        t=t+mind;
        
        % 新加入工作的机器进入加工状态,更新实时路径
         tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    elseif size(r)<8
        for i=1:8
            temp1(i,1)=i;
            if tempV0(i,i)~=V0(i,i) && flag1==0 % 判断该机器是否在加工状态
                if flagerror1(i,size(r,2))==0 && unifrnd(0,1)<=0.0025 % 发生1%概率的故障
                    flagerror1(i,size(r,2)+1)=1;% 发生故障后，进入休眠状态，离开作业队列
                    flagerror2(i,size(r,2)+1)=1;
                    errornum(i)=errornum(i)+1;% 故障次数增加
                    errorall=errorall+1;
                    errorstep(errorall)=size(r,2);
                    errortime(errorall)=round(unifrnd(600,1200));
                    tempV0(i,:)=V0(i,:)+errortime(errorall);
                    tempV0(:,i)=V0(:,i)+errortime(errorall);
                elseif flag1==1
                    flag1=0;
                end
                flag1=1; % 判断过一次后就不再判断
            else
                flag1=0;
            end
            for j=1:8
                if i~=r(end) && flagerror1(i,size(r,2)+1)==0
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
        rt=[rt t]; % 记录每一步的对应时间
        rnowt=[rnowt mind];
        r=[r minx]; % RGV移动到选择的点
        
        % % 更新实时路径
        for i=1:8
            for j=1:8
                if tempV0(i,j)-mind>V0(i,j) % 对于进入工作状态的机器，更新实时路径
                    tempV0(i,j)=tempV0(i,j)-mind;
                    if flagerror1(i,size(r,2)-1)==1 
                        flagerror1(i,size(r,2))=1; % 若故障未排除，仍标记为故障
                        flagerror2(i,size(r,2))=1;
                    end
                else
                    tempV0(i,j)=V0(i,j); % 若工作已完成，恢复初始路径
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=0; % 若故障已排除，标记为无故障
                        flagerror2(i,size(r,2))=0;
                    end
                end
            end
        end
        % 新加入工作的机器进入加工状态，更新实时路径
        tempV0(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    else
        if flag==0 % 是否已结束第一轮空作业
            tempV=tempV0+time3;% 加入清洗时间
            flag=1;
        end
        for i=1:8
            temp1(i,1)=i;
            if tempV(i,i)~=V(i,i) && flag1==0 % 判断该机器是否在加工状态
                if flagerror1(i,size(r,2))==0 && unifrnd(0,1)<=0.0025 % 发生1%概率的故障
                    flagerror1(i,size(r,2)+1)=1; % 发生故障后，进入休眠状态，离开作业队列
                    flagerror2(i,size(r,2)+1)=1;
                    errornum(i)=errornum(i)+1; % 故障次数增加
                    errorall=errorall+1;
                    errorstep(errorall)=size(r,2);
                    errortime(errorall)=round(unifrnd(600,1200));
                    tempV(i,:)=V(i,:)+errortime(errorall);
                    tempV(:,i)=V(:,i)+errortime(errorall);
                elseif flag1==1
                    flag1=0;
                end
                flag1=1; % 判断过一次后就不再判断
            else
                flag1=0;
            end
            % 计算选择机器i对其他机器产生的影响
            for j=1:8
                if i~=r(end) && flagerror1(i,size(r,2)+1)==0 
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
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=1; % 若故障未排除，仍标记为故障
                        flagerror2(i,size(r,2))=1;
                    end
                else
                    tempV(i,j)=V(i,j); % 若工作已完成，恢复初始路径
                    if flagerror1(i,size(r,2)-1)==1
                        flagerror1(i,size(r,2))=0; % 若故障已排除，标记为无故障
                        flagerror2(i,size(r,2))=0;
                    end
                end
            end
        end
        % 新加入工作的机器进入加工状态，更新实时路径
        tempV(:,r(end))=time4-(rem(r(end),2)-1)*time1+rem(r(end),2)*time2;
    end
end
% % % % 整理结果
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