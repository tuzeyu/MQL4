//+------------------------------------------------------------------+
//|                                                      PROphet.mq4 |
//|                                                        PraVedNiK |
//|                                                  taa-34@mail.ru  |        
//+------------------------------------------------------------------+
/* EURUSD M5
包含两个相互独立的线性感知器(Perceptron).
它们中的每个都把输入烛形的属性分为两类.

class № 1 : BUY 并且 class № 2: flat(平) 或者 sell SELL

class № 1: SELL 并且 class № 2: flat 或者 BUY
这是 EA 的特点 - 一个感知器中不会只有BUY或者SELL的类别 !
在前12周进行了优化, 在周末分为两个阶段.
阶段 № 1:
设置变量 daBUY=true 而 daSELL=false , 权重
x1,x2,x3,x4 在 1~200 之间做优化, 预先设置的止损在 30~100 之间做优化, 第一阶段结束.
阶段 № 2:
设置变量 daBUY=false 而 daSELL=true, 权重
y1,y2,y3,y4 在 1~200 之间做优化, 可移动止损在 30~100 之间做优化.
在优化完毕之后, 把变量 daBUY 和 daSELL 设为 true.
取得的值可以用于下个 (未来的) 星期.
每个星期过去都要进行参数的调整.
*/
#property link      "taa-34@mail.ru"
extern  double lot=0.1;
//--------------------------------------------------------------------
extern bool  daBUY=true;  extern int       x1=9,x2=29,x3=94,x4=125,slb=68;
//---------------------------------------------------------------------------
extern bool  daSELL=true; extern int    y1=61,y2=100,y3=117,y4=31,sls=72;

extern int StartH=10, EndH=18;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
//-----For M5_EURUSD------
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------
static int  prevtime=0;    int ticket=0; 
//-----------------------------------------------------------------
int start()
  {
   if(Time[0]==prevtime) return(0);    prevtime=Time[0];

   if(!IsTradeAllowed()) { prevtime=Time[1]; MathSrand(TimeCurrent());Sleep(30000+MathRand());}
//-------------------------------------------------------------------------------------------------

   int total=OrdersTotal(); if(daBUY)BBB(total);if(daSELL)SSS(total); return(0); 
  } //--end_start--
//-------------------------------------------------------------------------------------------
void BBB(int tot) 
  {
   int sprb=MarketInfo(Symbol(),MODE_SPREAD)+2*slb;  int h=Hour();

   for(int i=0; i<tot; i++) 
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==74) 
        {//--------------------

         if(OrderType()==OP_BUY && h>EndH)OrderClose(OrderTicket(),OrderLots(),Bid,3);

         //----------------------------------------------------------------------------------

         if(Bid>(OrderStopLoss()+sprb*Point) && OrderType()==OP_BUY)
           {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Bid-slb*Point,0,0,Blue))
              {Sleep(30000);prevtime=Time[1];}
           }
         //----------------------------------------------------------------------------------


         return(0);
        }
     }//-----------------------------------------------------------------------------------------
   ticket=-1;  RefreshRates();
//-----------------------------------------------------------------------------------------
   if(Qu(x1,x2,x3,x4)>0 && h>=StartH && h<=EndH && IsTradeAllowed()) 
     {

      ticket=OrderSend(Symbol(),OP_BUY,lot,Ask,4,Bid-slb*Point,0,"buy",74,0,Blue);

      PlaySound("news.wav");

      if(ticket<0) { Sleep(30000);prevtime=Time[1]; }
     }    //-- Exit -

   return(0); 
  }
//-------------------------------------------------------------------------------------------
void SSS(int tot) 
  {
   int sprs=MarketInfo(Symbol(),MODE_SPREAD)+2*sls;  int h=Hour();

   for(int i=0; i<tot; i++) 
     {
      OrderSelect(i,SELECT_BY_POS,MODE_TRADES);

      if(OrderSymbol()==Symbol() && OrderMagicNumber()==81) 
        {//--------------------

         if(OrderType()==OP_SELL && h>EndH)OrderClose(OrderTicket(),OrderLots(),Ask,3);

         //----------------------------------------------------------------------------------

         if(Ask<(OrderStopLoss()-sprs*Point) && OrderType()==OP_SELL)
           {
            if(!OrderModify(OrderTicket(),OrderOpenPrice(),Ask+sls*Point,0,0,Blue))
              {Sleep(30000); prevtime=Time[1];}
           }

         return(0);
        }
     }//-----------------------------------------------------------------------------------------
   ticket=-1; RefreshRates();
//-----------------------------------------------------------------------------------------
   if(Qu(y1,y2,y3,y4)>0 && h>=StartH && h<=EndH && IsTradeAllowed()) 
     {

      ticket=OrderSend(Symbol(),OP_SELL,lot,Bid,4,Ask+sls*Point,0,"sell",81,0,Red);

      PlaySound("news.wav");

      if(ticket<0) { Sleep(30000); prevtime=Time[1];}
     }   //-- Exit -

   return(0); 
  }
//=====================================================================================================
double Qu(int q1,int q2,int q3,int q4) 
  {
   return((q1-100)*MathAbs(High[1]-Low[2])+
          (q2-100)*MathAbs(High[3]-Low[2])+(q3-100)*MathAbs(High[2]-Low[1])+(q4-100)*MathAbs(High[2]-Low[3]));
  }
//+------------------------------------------------------------------+
