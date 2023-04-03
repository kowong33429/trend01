//+------------------------------------------------------------------+
//|                                                    halftrend.mq4 |
//|                        Copyright 2022, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
int flag = 0;

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

int speed_ac()
  {
   double ac[5];
   for(int i = 0; i < 5; i++)
     {
      ac[i] = iAC(NULL, PERIOD_M30, i);
     }
   if(ac[0] > ac[1])
     {
      if(ac[1] > ac[2])
        {
         if(ac[2] > ac[3])
           {
            if(ac[3] > ac[4])
              {
               return 4;
              }
            return 3;
           }
         return 2;
        }
      return 1;
     }
   if(ac[0] < ac[1])
     {
      if(ac[1] < ac[2])
        {
         if(ac[2] < ac[3])
           {
            if(ac[3] < ac[4])
              {
               return -4;
              }
            return -3;
           }
         return -2;
        }
      return -1;
     }
   return 0;
  }

int depth_trend()
  {
   double rsi = iRSI(NULL, PERIOD_M30, 8, PRICE_CLOSE, 0);
   if(rsi > 90.0)
      return 4;
   if(rsi > 80.0)
      return 3;
   if(rsi > 70.0)
      return 2;
   if(rsi > 60.0)
      return 1;
   if(rsi < 10.0)
      return -4;
   if(rsi < 20.0)
      return -3;
   if(rsi < 30.0)
      return -2;
   if(rsi < 40.0)
      return -1;
   return 0;
  }

void OnTick()
  {
//---
//0=buy,1=sell
   double ha_candle_buy = iCustom(NULL,0,"Heiken Ashi-Tape",0,1);
   double alligator_green = iCustom(NULL,0,"Alligator_mtf_alert_separate_window",2,1);
   double alligator_red = iCustom(NULL,0,"Alligator_mtf_alert_separate_window",1,1);
   double alligator_blue = iCustom(NULL,0,"Alligator_mtf_alert_separate_window",0,1);
   double volume = iCustom(NULL,0,"my_volume",48,0,0);
   double volumeAvg = iCustom(NULL,0,"my_volume",48,1,0);
   //double adx = iCustom(NULL,0,"ADX Smoothed",2,1);
   double half_trend_buy = iCustom(NULL,0,"HalfTrend-1.02",4,1);
   double half_trend_sell = iCustom(NULL,0,"HalfTrend-1.02",5,1);
   double atr = iCustom(NULL,0,"ATR_X_EMA",0,1);
   double atr_ma = iCustom(NULL,0,"ATR_X_EMA",1,1);

   int index_rsi = depth_trend();
   int index_ac = speed_ac();

//if(TimeMinute(TimeCurrent())==1 && TimeSeconds(TimeCurrent())==1)Print("ha: ",iCustom(NULL,0,"ha_candle",6,4,1));

   if(half_trend_buy != EMPTY_VALUE)
     {
      GlobalVariableSet(flag,1);
      Print("flag_b:  ",GlobalVariableGet(flag));
     }
   else
      if(half_trend_sell != EMPTY_VALUE)
        {
         GlobalVariableSet(flag,-1);
         Print("flag_s:  ",GlobalVariableGet(flag));
        }

   if((index_rsi==2 && index_ac>=1) || (index_rsi==3 && index_ac==1))
     {
      //buy
     }


   if(OrdersTotal() == 0)
     {
      //trend
      if(GlobalVariableGet(flag) == 1 && alligator_green>alligator_blue && ha_candle_buy == 1)
        {
         //volume
         if(volume>volumeAvg && atr>atr_ma)
           {
            OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Low[1]-2*atr,0,"test",1111,0,clrGreen);
            GlobalVariableSet(flag,0);
           }
        }
      else
         if(GlobalVariableGet(flag) == -1 && alligator_green<alligator_blue && ha_candle_buy != 1)
           {
            if(volume>volumeAvg && atr>atr_ma)
              {
               OrderSend(_Symbol,OP_SELL,0.1,Bid,3,High[1]+2*atr,0,"test",1111,0,clrRed);
               GlobalVariableSet(flag,0);
              }

           }

     }

   /*for(int i=OrdersTotal()-1; i>=0; i--)
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
     }*/

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(OrderProfit()>0)
           {
            if(iClose(NULL,PERIOD_M15,1)<iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,1) && ha_candle_buy != 1)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
               GlobalVariableSet(flag,0);
              }

           }
         /*else
           {
            if(GlobalVariableGet(flag) == 1 && alligator_green>alligator_blue && ha_candle_buy == 1)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
               GlobalVariableSet(flag,0);
              }
           }*/
        }
      else
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
           {
            if(OrderProfit()>0)
              {
               if(iClose(NULL,PERIOD_M15,1)>iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,1) && ha_candle_buy == 1)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
              }
            /*else
              {
               if(GlobalVariableGet(flag) == -1 && alligator_green<alligator_blue && ha_candle_buy != 1)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
              }*/
           }
     }

  }
//+------------------------------------------------------------------+
