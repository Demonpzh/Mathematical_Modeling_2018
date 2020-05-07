#include <iostream>
#include <vector>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
using namespace std;

int D[8][8];
int T[8][8];


//int Loadtime[2]={27,32};//奇数偶数相反；//第三组
//int Cleartime=25;
//int busytime=545;
//int busytime2[2]={455,182};
//int position[8]={2,1,1,1,2,1,2,1};


//int Loadtime[2]={30,35};//奇数偶数相反；
//int Cleartime=30;
//int busytime=580;
//int busytime2[2]={280,500};
//int position[8]={1,2,1,2,1,2,2,1};//第二组



int Loadtime[2]={28,31};//奇数偶数相反；第一组
int Cleartime=25;
int busytime=560;
int busytime2[2]={400,378};
int position[8]={2,1,1,2,1,2,2,1};


int t=0;
int flag=2;
vector<int>v;
bool start=true;
class Point
{
public:
    int ID;
    bool isFirst;
    int timeToColl;
    int loadtime;
    int cleartime;
    int pathTime;
    int starttime;
    int overtime;
    bool istrouble;
    bool hadtrouble;
    int troubletime;
    Point()
    {
        loadtime=Loadtime[0];
        cleartime=Cleartime;
        hadtrouble=false;
        troubletime=0;
        istrouble=false;
    }
    setPoint(int i)
    {
        ID=i;
        loadtime=Loadtime[i%2];
        cleartime=Cleartime;
        timeToColl=0;
        isFirst=true;
        hadtrouble=false;
        troubletime=0;
        istrouble=false;
    }
    changetime(int time)
    {
        if(timeToColl-time<=0)
            {
                timeToColl=0;
                hadtrouble=false;
            }
        else
            timeToColl-=time;
    }
    getNoColltime()
    {
        if (flag==1)
        {
            if(isFirst)
            {
                isFirst=false;
                return 0;
            }
            else
                return cleartime;
        }
        else
        {
            if(position[ID]==2)
                if(isFirst)
                {
                    isFirst=false;
                    return 0;
                }
                else
                    return cleartime;
        }
    }
    changeErrortime(int time)
    {
        if(istrouble==true)
        {
            if(troubletime>time)
                troubletime=troubletime-time;
            else
            {
                troubletime=0;
                istrouble=false;
            }
        }
    }
    gettocoll()
    {
        if(flag==1)
            timeToColl=busytime;
        else
            timeToColl=busytime2[position[this->ID]-1];
    }

};
Point point[8];
initPoint()
{
    for(int i=0;i<8;i++)
    point[i].setPoint(i);
}
initDT()
{
    for(int i=0;i<8;i++)
        for(int j=0;j<8;j++)
        {
            if(i/2==j/2)
            {
                D[i][j]=0;
                T[i][j]=0;
            }
            else
            {
                D[i][j]=13*abs((j/2)-(i/2)) + 7;
              // D[i][j]=18*abs((j/2)-(i/2)) + 5;
                //D[i][j]=14*abs((j/2)-(i/2)) + 4;
                T[i][j]=D[i][j];
            }
        }
}
displayD()
{
     for(int i=0;i<8;i++)
     {
        for(int j=0;j<8;j++)
            cout<<T[i][j]<<"\t";
        cout<<endl;
     }
}

void changeT(int time)
{
    for(int i=0;i<8;i++)
    {
        point[i].changetime(time);
        point[i].changeErrortime(time);
    }
}
int Max(int a,int b)
{
    if(a>b)
        return a;
    else
        return b;
}
int searchPath(int last)
{
    int temp=999999999;
    int order=0;
    if (start==true)
    {
        for(int i=0;i<8;i++)
        {
            if(point[i].istrouble)
                continue;
            if(position[i]!=1)
                continue;
                int time=0;
            for(int j=0;j<8;j++)
            {
                if(point[j].istrouble)
                    continue;
                if(i==j)
                    time+=D[last][i] + point[i].loadtime;
                else if (position[i]!=position[j])
                {
                    time+= D[last][i] + point[i].loadtime+D[i][j]+point[j].loadtime;
                }
                else
                {

                }
            }
            if(temp>time)
            {
                temp=time;
                order=i;
      //          cout<<"size "<<i<<endl;;
            }
        }
    }
    else if (v.size()<=6)
    {
        for(int i=0;i<8;i++)
        {
            if(point[i].istrouble)
                continue;
            if(position[i]!=1||i==last)
                continue;
            int time=0;
            for(int j=0;j<8;j++)
            {
                if(point[j].istrouble)
                continue;
                if(i==j)
                   // time+=Max( D[last][i],point[i].timeToColl)+point[i].loadtime-point[i].timeToColl;
                   continue;
                else
                {
                    int x=Max( D[last][i],point[i].timeToColl)+point[i].loadtime+ D[i][j];
                    time+= Max( x,point[j].timeToColl) - point[j].timeToColl+point[j].loadtime;
                }
            }
            if(temp>time)
            {
                temp=time;
                order=i;
           //     cout<<last<<"size <4 :"<<i<<"\t"<<v.size()<<endl;;
            }
        }
    }
    else
    {
         for(int i=0;i<8;i++)
         {
            if(point[i].istrouble)
                continue;
            if(position[last]==position[i])
                continue;
            int time=0;
            for(int j=0;j<8;j++)
            {
                if(point[j].istrouble)
                    continue;
                if(i==j)
                    time+=Max( D[last][i] ,point[i].timeToColl)+ point[i].loadtime - point[i].timeToColl;
                else if(position[i]==position[j])
                {

                }
                else
                {
                    int x=Max( D[last][i] ,point[i].timeToColl)+point[i].loadtime+ D[i][j];
                    time+= Max( x , point[j].timeToColl) - point[j].timeToColl+point[j].loadtime;
                }
            }
            if(temp>time)
            {
                temp=time;
                order=i;
            }
        }
    }
    return order;
}
//
//int searchPath(int last)
//{
//    int temp=999999999;
//    int order=0;
//    if (start==true)
//    {
//        for(int i=0;i<8;i++)
//        {
//            if(point[i].istrouble)
//                continue;
//            if(position[i]!=1)
//                continue;
//            int path=0;
//            path=Max(D[last][i],point[i].timeToColl)+point[i].loadtime;
//            if(temp>path)
//            {
//                temp=path;
//                order =i;
//            }
//        }
//    }
//    else if (v.size()<=6)
//    {
//        for(int i=0;i<8;i++)
//        {
//            if(point[i].istrouble)
//                continue;
//            if(position[i]!=1||i==last)
//                continue;
//            int path=0;
//            path=Max(D[last][i],point[i].timeToColl)+point[i].loadtime;
//            if(temp>path)
//            {
//                temp=path;
//                order =i;
//            }
//        }
//    }
//    else
//    {
//         for(int i=0;i<8;i++)
//         {
//            if(point[i].istrouble)
//                continue;
//            if(position[last]==position[i])
//                continue;
//            int path=0;
//            path=Max(D[last][i],point[i].timeToColl)+point[i].loadtime;
//            if(temp>path)
//            {
//                temp=path;
//                order =i;
//            }
//        }
//    }
//    return order;
//}
void producederror()
{
    for(int i=0;i<8;i++)
    {
        if(point[i].timeToColl>0) //在工作中
            if(point[i].hadtrouble==false)  //没发生过 可以发生
                if(rand()%100<1)
                {
                    point[i].istrouble=true;
                    point[i].troubletime=rand()%600+600;//600 1200
                    cout<<i<<"\t"<<t<<"\t"<<point[i].troubletime<<endl;
                }
        point[i].hadtrouble=true;
    }

}

void ShowVec(const vector<int>& valList)
{
    int count = valList.size();
    for (int i = 0; i < count;i++)
    {
        cout << valList[i] << "\t";
    }
}
//
//int main()
//{
//    initDT();
//    displayD();
//
//    int Count=0;
//    int xulie[8]={0,0,0,0,0,0,0,0};
//    int a,b,c,d,e,f,g,h;
//    for(a=1;a<=2;a++)
//       for(b=1;b<=2;b++)
//            for(c=1;c<=2;c++)
//                for(d=1;d<=2;d++)
//                    for(e=1;e<=2;e++)
//                        for(f=1;f<=2;f++)
//                            for(g=1;g<=2;g++)
//                                for(h=1;h<=2;h++)
//                                {
//                                    position[0]=a,position[1]=b,position[2]=c,position[3]=d,position[4]=e,position[5]=f,position[6]=g,position[6]=h;
//                                    initPoint();
//                                    int order=0;
//                                    int count=1;
//                                    v.push_back(order);
//                                    while (t<8*3600)
//                                    {
//                                        if(start==true)
//                                        {
//                                            order=searchPath(order);
//                                            start=false;
//                                            continue;
//                                        }
//                                        int mind=0;
//                                        if(D[v.back()][order]>=point[order].timeToColl)
//                                            mind=D[v.back()][order];
//                                        else
//                                            mind=point[order].timeToColl;
//                                        int record=order;
//                                        v.push_back(order);
//                                        mind+=point[order].loadtime;
//                                        t+=mind;
//                                        changeT(mind);
//                                        point[order].gettocoll();
//                                        mind=point[order].getNoColltime();
//                                        t+=mind;
//                                        changeT(mind);
//                                        order=searchPath(order);
//                                        count++;
//
//                                    }
//                                    v.clear();
//                                    t=0;
//                                    cout<<count<<endl;
//                                    if(count>437-10)
//                                    {
//                                        cout<<count<<endl;
//                                        for(int i=0;i<8;i++)
//                                        {
//                                            cout<<position[i]<<"    ";
//                                        }
//                                        cout<<endl;
//                                    }
//                                    if(count>Count)
//                                    {
//                                        Count=count;
//                                        for(int i=0;i<8;i++)
//                                        {
//                                            xulie[i]=position[i];
//                                        }
//                                    }
//                                }
//                                cout<<Count<<endl;
//                                for(int i=0;i<8;i++)
//                                {
//                                    cout<<xulie[i]<<"   ";
//                                }
//
//    return 0;
//}


int main()
{
    srand((unsigned)time(NULL));
    initDT();
    displayD();
    initPoint();

    int order=0;
    int count=1;
    v.push_back(order);
    while (t<8*3600)
    {
        if(start==true)
        {
            order=searchPath(order);
            start=false;
            continue;
        }
        int mind=0;
        if(D[v.back()][order]>=point[order].timeToColl)
            mind=D[v.back()][order];
        else
            mind=point[order].timeToColl;
        int record=order;
        v.push_back(order);
        mind+=point[order].loadtime;
        t+=mind;
        producederror();
       //cout<<"num of order : "<<order<<" before T:"<<t-point[order].loadtime<<"\t"<<endl;
       // cout<<order<<" "<<t-point[order].loadtime<<"\t"<<point[order].loadtime<<"\t"<<mind-point[order].loadtime<<endl;
        cout<<order<<"\t"<<t-point[order].loadtime<<endl;
        changeT(mind);
        point[order].gettocoll();
        mind=point[order].getNoColltime();
        t+=mind;
        changeT(mind);
        order=searchPath(order);
        count++;
    }
    cout<<count<<endl;
    return 0;
}
