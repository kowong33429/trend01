//+------------------------------------------------------------------+
//|                                           small_dochain_macd.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
string check_color(double open,double close) {
   string colors = "";
   if(close-open>0)
   {
      colors = "green";
   }
   else if(close-open<0)
   {
      colors = "red";
   }
	return colors;
}

double calculateLotSize(double stopLoss)
{
    // 1% risk per trade
    int risk = 5;
     
    // Fetch some symbol properties
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot  = MarketInfo(Symbol(), MODE_MINLOT); 
    double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
 
    
    // Calculate the actual lot size
    double lotSize = AccountBalance() * risk / 100 / (stopLoss);
    //Print("lot = ",lotSize," Balance = ", AccountBalance(), " SL = ",stopLoss);
    //Print("Step = ",lotStep, " -> " ,NormalizeDouble(lotSize / lotStep, 0) * lotStep);
    
    return MathMin(
        maxLot,
        MathMax(
            minLot,
            NormalizeDouble(lotSize / lotStep, 0) * lotStep // This rounds the lotSize to the nearest lotstep interval
        )
    );
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
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - open_time > 14400);
}

void OnTick()
  {
//---
   
   //double buy_turtle_channel = iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",0,1);
   //double sell_turtle_channel = iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",1,1);
   
   double buy_turtle_channel = iCustom(NULL,0,"the turtle trading channel mtf + alerts histo",0,1);
   double sell_turtle_channel = iCustom(NULL,0,"the turtle trading channel mtf + alerts histo",1,1);
   
   double lots;
   double atr = iATR(NULL,0,10,1);
   double sl = (int)(atr*2/Point);
   double tp = sl*2;
   
   //Print("atr: ",atr);
   //Print("sl: ",sl);
   //lots = calculateLotSize(sl);
   //Print("lots: ",lots);
   //if(Minute()<=0 && Seconds() <= 0)Print(iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",0,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",1,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",2,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",3,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",4,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",5,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",6,1),"  ",iCustom(NULL,0,"TheTurtleTradingChannel v2  BT",7,1));
   //if(Minute()<=0 && Seconds() <= 0)Print(iCustom(NULL,0,"the turtle trading channel mtf + alerts histo",0,1),"  ",iCustom(NULL,0,"the turtle trading channel mtf + alerts histo",1,1));
   if(buy_turtle_channel == 1.0 && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green" &&
   iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,1)>=0 && iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,2)<=0 && iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1)<=iCustom(NULL,0,"Heiken Ashi",3,1) 
   )
   {
      //buy S+ setup
      lots = calculateLotSize(sl);
      //Print(lots);
      Print("buy S+ setup");
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,0,0,"tmt01",1111,0,clrGreen);
      }
   }
   else if(sell_turtle_channel == 1.0 && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red" &&
   iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,1)<=0 && iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,2)>=0 && iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1)>=iCustom(NULL,0,"Heiken Ashi",3,1)
   )
   {
      //sell S+ setup
      lots = calculateLotSize(sl);
      //Print(lots);
      Print("sell S+ setup");
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,0,0,"tmt01",1111,0,clrRed);
      }
   }
   /*else if(buy_turtle_channel == 1.0 && iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,1)>iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,2) 
   && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green" && iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1)<=iCustom(NULL,0,"Heiken Ashi",3,1) 
   && MathAbs(iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_MAIN,1)) >= 0.000400 && MathAbs(iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_MAIN,2)) >= 0.000400
   )
   {
      //buy A setup
      lots = calculateLotSize(sl);
      Print("buy A setup");
      //Print(lots);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,0,0,"tmt01",1111,0,clrGreen);
      }
   
   }
   else if(sell_turtle_channel == 1.0 && iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,1)<iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,2) 
   && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red" && iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1)>=iCustom(NULL,0,"Heiken Ashi",3,1)
   && MathAbs(iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_MAIN,1)) >= 0.000300 && MathAbs(iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_MAIN,2)) >= 0.000300
   )
   {
      //sell A setup
      lots = calculateLotSize(sl);
      Print("sell A setup");
      //Print(lots);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,0,0,"tmt01",1111,0,clrRed);
      }
   }*/
   
   for(int i=OrdersTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 14400)
      {
         //Print(OrderTicket()," BUY"," , ",iCustom(NULL,0,"Heiken Ashi",2,1)," , ",iMA(NULL,PERIOD_M15,10,0,MODE_EMA,PRICE_CLOSE,1));
         if(iCustom(NULL,0,"Heiken Ashi",3,1) < iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1) || sell_turtle_channel == 1)
         {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
         }
      }
      else if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 14400)
      {
         //Print(OrderTicket()," SELL"," , ",iCustom(NULL,0,"Heiken Ashi",2,1)," , ",iMA(NULL,PERIOD_M15,10,0,MODE_EMA,PRICE_CLOSE,1));
         if(iCustom(NULL,0,"Heiken Ashi",3,1) > iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1) || buy_turtle_channel == 1 )
         {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
         }
      }
      else if(false)
      {
      
      }
   }
   
  }
//+------------------------------------------------------------------+


//buy_turtle_channel != 2147483647.0 && check_color(iCustom(NULL,0,"Heiken Ashi",Red,DodgerBlue,Red,DodgerBlue,2,1),iCustom(NULL,0,"Heiken Ashi",Red,DodgerBlue,Red,DodgerBlue,3,1)) == "green" &&
//iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,1)>=0 && iMACD(NULL,0,5,7,4,PRICE_CLOSE,MODE_SIGNAL,2)<=0 && iMA(NULL,0,5,2,MODE_EMA,PRICE_CLOSE,1)<=iCustom(NULL,0,"Synergy_APB",Red,DodgerBlue,Red,DodgerBlue,3,1)