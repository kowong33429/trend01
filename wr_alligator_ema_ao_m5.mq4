//+------------------------------------------------------------------+
//|                                       wr_alligator_ema_ao_m5.mq4 |
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

double calculateLotSize(int stopLoss)
{
    // 1% risk per trade
    int risk = 1;
     
    // Fetch some symbol properties
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot  = MarketInfo(Symbol(), MODE_MINLOT); 
    double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
 
    // Calculate the actual lot size
    double lotSize = AccountBalance() * risk / 100 / (stopLoss * tickVal);
 
    return MathMin(
        maxLot,
        MathMax(
            minLot,
            NormalizeDouble(lotSize / lotStep, 0) * lotStep // This rounds the lotSize to the nearest lotstep interval
        )
    ); 
}

void OnTick()
  {
//---
   double atr = iATR(_Symbol,PERIOD_M30,14,0);
   double atrMultiple = 1;
   int stopLoss = (int)(atr * atrMultiple / Point);
   double lots = calculateLotSize(stopLoss);
   
   double stop_loss_buy = Ask-(stopLoss*Point);
   double stop_loss_sell = Bid+(stopLoss*Point);
   
   double take_profit_buy = Ask+(1.5*stopLoss*Point);
   double take_profit_sell = Bid-(1.5*stopLoss*Point);
   
   //w%r
   double wr_1 = iWPR(_Symbol,PERIOD_M30,14,1);
   double wr_5 = iWPR(_Symbol,PERIOD_M30,14,5);
   //alligator
   double jaw = iAlligator(_Symbol,PERIOD_M30,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
   double teeth = iAlligator(_Symbol,PERIOD_M30,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
   double lips = iAlligator(_Symbol,PERIOD_M30,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
   //sma
   double sma = iMA(_Symbol,PERIOD_M30,20,0,MODE_SMA,PRICE_CLOSE,1);
   //ao
   double ao_1 = iAO(_Symbol,PERIOD_M30,1);
   double ao_2 = iAO(_Symbol,PERIOD_M30,2);
   
   int total = OrdersTotal();
   
   if(total<1)
   {
      if(lips>teeth && teeth>jaw && lips>jaw && Close[1]>sma && Open[1]>sma && Close[1]-lips<100*Point && wr_5<-20 && wr_1>-20 && ao_1>0 && ao_1>ao_2)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,stop_loss_buy,take_profit_buy,"sud lor EA",1111,0,clrGreen);
      }
      
      if(lips<teeth && teeth<jaw && lips<jaw && Close[1]<sma && Open[1]<sma && lips-Close[1]<100*Point && wr_5>-80 && wr_1<-80 && ao_1<0 && ao_1<ao_2)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,stop_loss_sell,take_profit_sell,"sud lor EA",1111,0,clrRed);
      }
   }
   
  }
//+------------------------------------------------------------------+
