//+------------------------------------------------------------------+
//|                                             sclaping_reverse.mq4 |
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
   double atr = iATR(_Symbol,PERIOD_H4,14,0);
   double atrMultiple = 3;
   
   int stopLoss = (int)(atr * atrMultiple / Point);
   
   double lots = calculateLotSize(stopLoss);
   
   double stop_loss_buy = Ask-(stopLoss*Point);
   double stop_loss_sell = Bid+(stopLoss*Point);
   
   double take_profit_buy = Ask+(1.5*stopLoss*Point);
   double take_profit_sell = Bid-(1.5*stopLoss*Point);
   
   double macd_macd_line = iMACD(_Symbol,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_signal_line = iMACD(_Symbol,PERIOD_H4,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   
   double ema_25 = iMA(_Symbol,PERIOD_H4,25,0,MODE_EMA,PRICE_CLOSE,0);
   double ema_50 = iMA(_Symbol,PERIOD_H4,50,0,MODE_EMA,PRICE_CLOSE,0);
   double ema_100 = iMA(_Symbol,PERIOD_H4,100,0,MODE_EMA,PRICE_CLOSE,0);
   
//BUY:We are looking for a buy signal when both signal and main MACD lines are below 0. 
//We enter the trade when the histogram turns to green color.
//Add-on BUY:If after the valid buy (both lines below 0, histogram turns green) the histogram turns 
//to red and then turns to green again, you add another buy position.
   
   int total = OrdersTotal();

   if(total<1)
   {
      if(macd_macd_line<0 && macd_signal_line<0 && macd_macd_line>macd_signal_line && ema_25>ema_50)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,stop_loss_buy,take_profit_buy,"sud lor EA",1111,0,clrGreen);
      }
      if(macd_macd_line>0 && macd_signal_line>0 && macd_macd_line<macd_signal_line && ema_25<ema_50)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,stop_loss_sell,take_profit_sell,"sud lor EA",1111,0,clrRed);
      }
   }
   
  }
//+------------------------------------------------------------------+
