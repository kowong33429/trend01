//+------------------------------------------------------------------+
//|                                                  alligator01.mq4 |
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

   double atr = iATR(_Symbol,PERIOD_M5,14,0);
   double atrMultiple = 3;
   
   int stopLoss = (int)(atr * atrMultiple / Point);
   
   double lots = calculateLotSize(stopLoss);
   
   double stop_loss_buy = Ask-(stopLoss*Point);
   double stop_loss_sell = Bid+(stopLoss*Point);
   
   double take_profit_buy = Ask+(1.5*stopLoss*Point);
   double take_profit_sell = Bid-(1.5*stopLoss*Point);
   
   double macd_macd_line = iMACD(_Symbol,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_signal_line = iMACD(_Symbol,PERIOD_M5,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   
   double ema_25 = iMA(_Symbol,PERIOD_M5,25,0,MODE_EMA,PRICE_CLOSE,1);
   double ema_50 = iMA(_Symbol,PERIOD_M5,50,0,MODE_EMA,PRICE_CLOSE,1);
   double ema_100 = iMA(_Symbol,PERIOD_M5,100,0,MODE_EMA,PRICE_CLOSE,1);
   double ema_200 = iMA(_Symbol,PERIOD_M5,100,0,MODE_EMA,PRICE_CLOSE,1);
   
   double jaw = iAlligator(_Symbol,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
   double teeth = iAlligator(_Symbol,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
   double gatorlips = iAlligator(_Symbol,PERIOD_M5,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
   
   int total = OrdersTotal();
   
   //lip going up means uptrend
   //lip goinf down means downtrend
   if(total<1)
   {
   //buy
      if()
      {
      
      }
   //sell
   }
   
  }
//+------------------------------------------------------------------+
