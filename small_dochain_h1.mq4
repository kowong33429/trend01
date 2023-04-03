//+------------------------------------------------------------------+
//|                                             small_dochain_h1.mq4 |
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
    int risk = 2;
     
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
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - open_time > 3600);
}

void OnTick()
  {
//---
   double buy_turtle_channel = iCustom(NULL,0,"turtle_channel_h1",0,1);
   double sell_turtle_channel = iCustom(NULL,0,"turtle_channel_h1",1,1);
   //iCustom(NULL,0,"TDI Red Green",5,2)
   double lots;
   double atr = iATR(NULL,0,14,1);
   double sl = (int)(atr*2/Point);
   double tp = sl*1.25;
   int buy_sto_cross=0;
   int sell_sto_cross=0;
   for(int i=1;i<3;i++)
   {
      //iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)>=20 && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1)<=20
      if(iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)>=iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1) 
      && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1)<=iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+2))
      {
         if(iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)>=20)
         {
            buy_sto_cross++;
         }
      }
   }
   
   for(int i=1;i<3;i++)
   {
      //iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)<=80 && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1)>=80
      if(iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)<=iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1) 
      && iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+1)>=iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i+2))
      {
         if(iStochastic(NULL,0,8,3,3,MODE_SMA,0,MODE_MAIN,i)<=80)
         {
            sell_sto_cross++;
         }
      }
   }
   
   if(iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1)<=iCustom(NULL,0,"Heiken Ashi",3,1)
   && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green"
   && buy_sto_cross>0
   )
   {
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"tmt01",1111,0,clrGreen);
      }
   }
   else if(iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1)>=iCustom(NULL,0,"Heiken Ashi",3,1)
   && check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red"
   && sell_sto_cross>0
   )
   {
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"tmt01",1111,0,clrRed);
      }
   }
   
   /*for(int i=OrdersTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
      {
         //Print(OrderTicket()," BUY"," , ",iCustom(NULL,0,"Heiken Ashi",2,1)," , ",iMA(NULL,PERIOD_M15,10,0,MODE_EMA,PRICE_CLOSE,1));
         if(iCustom(NULL,0,"Heiken Ashi",3,1) < iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1))
         {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
         }
      }
      else if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
      {
         //Print(OrderTicket()," SELL"," , ",iCustom(NULL,0,"Heiken Ashi",2,1)," , ",iMA(NULL,PERIOD_M15,10,0,MODE_EMA,PRICE_CLOSE,1));
         if(iCustom(NULL,0,"Heiken Ashi",3,1) > iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1))
         {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
         }
      }
      else if(false)
      {
      
      }
   }*/
   
   //reset value
   buy_sto_cross=0;
   sell_sto_cross=0;
  }
//+------------------------------------------------------------------+
