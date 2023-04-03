//+------------------------------------------------------------------+
//|                                                 atr_breakout.mq4 |
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
   double ma10 = iMA(NULL,0,10,0,MODE_EMA,PRICE_CLOSE,1);
//double atr10 = iATR(NULL,0,10,1);
   double bb_stop_trend_cur = iCustom(NULL,0,"bb-stops-v2-indicator",11,1);

   double atr = iCustom(NULL,0,"ATR_X_EMA",0,1);
   double atr_ma = iCustom(NULL,0,"ATR_X_EMA",1,1);
   double volume = iCustom(NULL,0,"my_volume",48,0,1);
   double volumeAvg = iCustom(NULL,0,"my_volume",48,1,1);

   double atr_in_points = 15;
   //double atr_in_points    =  atr / MarketInfo(Symbol(),MODE_POINT);

   int flag = 0;
//fresh signal change trend
   

   if(OrdersTotal() == 0)
     {
      if(atr>atr_ma)
        {
         if(bb_stop_trend_cur == 1.0)
           {
            if(volume>volumeAvg)
              {
               if(iClose(NULL,0,1)>ma10)
                 {
                  OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Ask-atr_in_points,0,"test",1111,0,clrGreen);
                 }
              }
           }
         else
            if(bb_stop_trend_cur == -1.0)
              {
               if(volume>volumeAvg)
                 {
                  if(iClose(NULL,0,1)<ma10)
                    {
                     OrderSend(_Symbol,OP_SELL,0.1,Bid,3,Bid+atr_in_points,0,"test",1111,0,clrRed);
                    }
                 }
              }
        }
     }

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
        
         if(iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1) && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2))
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
           }
        }
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1) && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2))
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
           }
        }
     }

  }
//+------------------------------------------------------------------+
