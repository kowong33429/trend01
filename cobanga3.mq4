//+------------------------------------------------------------------+
//|                                                    Trend 4Hr.mq4 |
//|                      Copyright © 2006, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net
//|
//| Code amended by Pipalot on 14th October 2007 - iMACD function has
//| been replaced with iOsMA fucntion in order to use MACD Histogram
//| figures as needed by Cowabunga trading system.
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

input double TakeProfit    =2000;
input double Lots          =0.1;

extern int IndicatorDisplacement = 15;
extern bool Show_Trend = true;
extern bool Only_Show_Valid_Triggers= true;
extern bool Send_Mail;
//---- buffers
double UPTrend[];
double DNTrend[];
double UPTrigger[];
double DNTrigger[];

datetime lastTime;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- additional buffers are used for counting
   IndicatorBuffers(4);
//---- indicators

   SetIndexLabel(0,"UP TREND");
   SetIndexLabel(1,"DOWN TREND");
   SetIndexLabel(2,"UP ARROW");
   SetIndexLabel(3,"DOWN ARROW");
   
   if((Symbol()=="XAUUSDgmp")&&(Period()==PERIOD_M5))
      {
      SetIndexStyle(0,DRAW_LINE,STYLE_DOT,1,Blue);
      SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,Red);
      }
   else
      {
      SetIndexStyle(0,DRAW_LINE,0,3,Blue);
      SetIndexStyle(1,DRAW_LINE,0,3,Red);
      }
   SetIndexStyle(2,DRAW_ARROW,EMPTY,3,Blue);
   SetIndexStyle(3,DRAW_ARROW,EMPTY,3,Red);
   SetIndexArrow(2,SYMBOL_ARROWUP);
   SetIndexArrow(3,SYMBOL_ARROWDOWN);
   SetIndexBuffer(0,UPTrend);
   SetIndexBuffer(1,DNTrend);
   SetIndexBuffer(2,UPTrigger);
   SetIndexBuffer(3,DNTrigger);
   
   lastTime = iTime(NULL,0,1);

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
  
bool SelectMostRecentClosed()
{
   int ticket = -1;
   datetime close_time = 0;
   for(int i=OrdersHistoryTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
      && OrderSymbol()==_Symbol  
      && OrderCloseTime() > close_time)
      {
         ticket = OrderTicket();
         close_time = OrderCloseTime();
      }
      //Print(OrderTicket());
   }
   //Print("Last order ticket is : " , ticket);
   return OrderSelect(ticket,SELECT_BY_TICKET) && OrderProfit()<0;
}

bool ShouldOpen()
{
   int ticket = -1;
   datetime open_time = 0;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)
      && OrderSymbol()==_Symbol  
      && OrderOpenTime() > open_time)
      {
         ticket = OrderTicket();
         open_time = OrderOpenTime();
      }
      //Print(OrderTicket());
   }
   //Print("Last order ticket is : " , ticket);
   
   // 1800 = half hour , 3600 = full hour
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - OrderOpenTime() > 1800);
}



double calculteLot()
{
   /*if (AccountBalance() >= 10000) return 1;
   else if (AccountBalance() >= 9000) return 0.9;
   else if (AccountBalance() >= 8000) return 0.8;
   else if (AccountBalance() >= 7000) return 0.7;
   else if (AccountBalance() >= 6000) return 0.6;
   else if (AccountBalance() >= 5000) return 0.5;
   else if (AccountBalance() >= 4000) return 0.4;
   else if (AccountBalance() >= 3000) return 0.3;
   else if (AccountBalance() >= 2000) return 0.2;
   else if (AccountBalance() >= 400) return 0.1;
   else ExpertRemove();*/
   
   if (AccountBalance() >= 10000) return 1;
   else if (AccountBalance() >= 1000) return NormalizeDouble(AccountBalance()/10000,2);
   else if (AccountBalance() >= 400) return 0.1;
   else ExpertRemove();
}


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
void OnTick(void)
   {
   int maCross,StochCHANGE,maCross4H,StochCHANGE4H,MACDChange,i,counted_bars=IndicatorCounted();
   double ma5now,ma10now,ma5prev,ma10prev,ma5now4H,ma10now4H,ma5prev4H,ma10prev4H,ma200now;
   double RSI,Stoch1,Stoch2,Signal1,Signal2,MACDChange1,MACDChange2,RSI4H,Stoch4H1,Stoch4H2,Signal4H1,Signal4H2;
   int Trigger,i4h,ticket;
   static int TrendON;
   bool GBP15,MACDEnable;
   string text,CRLF;   
   double maDiff = 0;
   int bigTimeFrame = PERIOD_M30;
      
   CRLF=CharToStr(13) + CharToStr(10);
   
   GBP15=((Symbol()=="XAUUSDgmp")&&(Period()==PERIOD_M5));
   if(GBP15) MACDEnable=true;          

   //if(Bars<=100) return(0);
  //---- check for possible errors
     //if(counted_bars<0) return(-1);
  //---- the last counted bar will be recounted
   //if(counted_bars>0) counted_bars--;
   
   // Do we have enough bars to work with
   if(Bars(_Symbol,_Period)<60) // if total bars is less than 60 bars
     {
      //Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }
// We will use the static Old_Time variable to serve the bar time.
// At each OnTick execution we will check the current bar time with the saved one.
// If the bar time isn't equal to the saved time, it indicates that we have a new tick.
   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;

// copying the last bar time to the element New_Time[0]
   int copied=CopyTime(_Symbol,_Period,0,1,New_Time);
   if(copied>0) // ok, the data has been copied successfully
     {
      if(Old_Time!=New_Time[0]) // if old time isn't equal to new bar time
        {
         IsNewBar=true;   // if it isn't a first call, the new bar has appeared
         //Print("We have new bar here ",New_Time[0]," old time was ",Old_Time);
         Old_Time=New_Time[0];            // saving bar time
        }
     }
   else
     {
      Alert("Error in copying historical times data, error =",GetLastError());
      ResetLastError();
      return;
     }

//--- EA should only check for new trade if we have a new bar
   if(IsNewBar==false)
     {
      return;
     }
 
//--- Do we have enough bars to work with
   int Mybars=Bars(_Symbol,_Period);
   if(Mybars<60) // if total bars is less than 60 bars
     {
      Alert("We have less than 60 bars, EA will now exit!!");
      return;
     }   
     
     
   double lots = calculteLot();  
    
   if(SelectMostRecentClosed()==true)
   {
      //Print("Looking at order ",OrderTicket(), " Magic No. ",OrderMagicNumber());
      //Print("Current time : ",TimeCurrent()," Order closed at : " ,OrderCloseTime());
      if(OrderMagicNumber()!=12345 && OrdersTotal()==0) {
         int order_type=OrderType();
         if(order_type==OP_BUY)
         {
            ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,3,Bid+5,Bid-10,"hedge",12345,0,Red);
            if(ticket>0)
              {
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                  Print("SELL order opened : ",OrderOpenPrice());
              }
            else
               Print("Error opening SELL order : ",GetLastError());
         }
         else 
         {
            ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,3,Ask-5,Ask+10,"hedge",12345,0,Red);
            if(ticket>0)
              {
               if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                  Print("SELL order opened : ",OrderOpenPrice());
              }
            else
               Print("Error opening SELL order : ",GetLastError());
         }
      }
   } 
   
   i=Bars;
   
   

   while(i>=0)
      {


      

      ma200now=iMA(NULL,bigTimeFrame,200,0,MODE_EMA,PRICE_CLOSE,1);
      
      if(iClose(NULL,bigTimeFrame,1) > ma200now) TrendON=1;
      if(iClose(NULL,bigTimeFrame,1) < ma200now) TrendON=-1;
      
      if(GBP15)
         {
               //---- TRIGGERS
         ma5now=iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,1);
         ma10now=iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,1);  
         ma5prev=iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,2);
         ma10prev=iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,2);
         if(ma5now > ma5prev && ma10now > ma10prev && ma5prev < ma10prev && ma5now > ma10now) maCross=1;
         else if(ma5now < ma5prev && ma10now < ma10prev && ma5prev > ma10prev && ma5now < ma10now) maCross=2;
         else maCross=0;
         RSI= iRSI(NULL,0,9,PRICE_CLOSE,1);
         Stoch1= iStochastic(NULL,0,10,3,3,MODE_SMA,0,MODE_MAIN,1);
         Stoch2= iStochastic(NULL,0,10,3,3,MODE_SMA,0,MODE_MAIN,2);
         Signal1= iStochastic(NULL,0,10,3,3,MODE_SMA,0,MODE_SIGNAL,1);
         Signal2= iStochastic(NULL,0,10,3,3,MODE_SMA,0,MODE_SIGNAL,2);
         if(Stoch1>Stoch2 && Signal1>Signal2) StochCHANGE=1;
         else if(Stoch1<Stoch2 && Signal1<Signal2) StochCHANGE=2;
         else StochCHANGE=0;
         
         //MACDChange1=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i);
         MACDChange1=iOsMA(NULL,PERIOD_M5,5,10,9,PRICE_CLOSE,1);
         //MACDChange2=iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1);
         MACDChange2=iOsMA(NULL,PERIOD_M5,5,10,9,PRICE_CLOSE,2);
         
         if(MACDChange2<0 && MACDChange2<MACDChange1) MACDChange=1;
         else if(MACDChange2>0 && MACDChange2>MACDChange1) MACDChange=2;
         else MACDChange=0;
         
         if((maCross==1) && MathAbs(ma5now - ma10now)>maDiff && (RSI>60) && (RSI<=80) && (StochCHANGE==1) && (MACDChange==1) && ((TrendON==1)||(Only_Show_Valid_Triggers==false))) Trigger=1;
         if((maCross==2) && MathAbs(ma5now - ma10now)>maDiff && (RSI<40) && (RSI>=20) && (StochCHANGE==2) && (MACDChange==2) && ((TrendON==-1)||(Only_Show_Valid_Triggers==false))) Trigger=2;
     
         //if(Trigger==1) UPTrigger[i]= High[i]+10*Point;
         //if(Trigger==2) DNTrigger[i]= Low[i]-10*Point;
         //Print(Trigger);
         if(Trigger>0 && OrdersTotal()==0)
            {         
               if(Trigger==1) 
               {
                  ticket=OrderSend(Symbol(),OP_BUY,lots,Ask,3,Ask-6,Ask+15,"conbanga",16384,0,Green);
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("BUY order opened : ",OrderOpenPrice());
                    }
                  else
                     Print("Error opening BUY order : ",GetLastError());
               }
               else 
               {
                  ticket=OrderSend(Symbol(),OP_SELL,lots,Bid,3,Bid+6,Bid-15,"conbanga",16384,0,Red);
                  if(ticket>0)
                    {
                     if(OrderSelect(ticket,SELECT_BY_TICKET,MODE_TRADES))
                        Print("SELL order opened : ",OrderOpenPrice());
                    }
                  else
                     Print("Error opening SELL order : ",GetLastError());
               };
              /* if(TrendON==1)
               {
                  Print("In timeframe 1H : Trend = BUY ");
               }
               else
               {
                  Print("In timeframe 1H : Trend = SELL ");
               }*/
               //Print("Stoch1 = ",Stoch1," ,Stoch2 = ",Stoch2);
               //Print("Signal1 = ",Signal1," ,Signal2 = ",Signal2);
               //Print("lastTime = ",iTime(NULL,0,0));
            }
         /*if(Trigger>0)
            {
            Print(TimeDay(Time[i])+"/"+TimeMonth(Time[i])+"/"+TimeYear(Time[i])+" at "+TimeHour(Time[i])+":"+TimeMinute(Time[i]));
            Print(Day()+"/"+Month()+"/"+Year()+" at "+Hour()+":"+Minute());
            Print(Send_Mail);
            }*/
            
         }
      Trigger=0;
      i--;
      }
      
   }
//+-----------------------------------------------------------------+