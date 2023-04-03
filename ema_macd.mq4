//+------------------------------------------------------------------+
//|                                                     ema_macd.mq4 |
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
void OnTick()
  {
//---
   double ema5 = iMA(NULL,0,5,0,MODE_EMA,PRICE_CLOSE,1);
   double ema8 = iMA(NULL,0,8,0,MODE_EMA,PRICE_CLOSE,1);
   double ema13 = iMA(NULL,0,13,0,MODE_EMA,PRICE_CLOSE,1);

   double macdMain = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_MAIN,0);
   double macdSignal = iMACD(NULL,0,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);

   if(OrdersTotal() == 0)
     {
      if(ema5 > ema8 && ema8 > ema13 && macdMain > macdSignal)
        {
         OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Ask-500*Point,0,"test",1111,0,clrGreen);
        }
      else
         if(ema5 < ema8 && ema8 < ema13 && macdMain < macdSignal)
           {
            OrderSend(_Symbol,OP_SELL,0.1,Bid,3,Bid+500*Point,0,"test",1111,0,clrRed);
           }
     }

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(ema5 < ema8 || ema8 < ema13 || macdMain < macdSignal)
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
           }
        }
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(ema5 > ema8 || ema8 > ema13 || macdMain > macdSignal)
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
           }
        }
     }

  }
//+------------------------------------------------------------------+
