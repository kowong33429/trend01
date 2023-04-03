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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShouldOpen()
  {
   int ticket = -1;
   datetime open_time = 0;
   if(OrdersHistoryTotal()==0 && OrdersTotal()==0)
     {
      return true;
     }
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
         && OrderSymbol()==_Symbol
         && OrderOpenTime() > open_time)
        {
         ticket = OrderTicket();
         open_time = OrderOpenTime();
        }
      //Print(OrderTicket());
     }
   Print("Last order ticket is : ", ticket,"open time: ",open_time);

// 1800 = half hour , 3600 = full hour
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - open_time > 3600) && OrdersTotal()==0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ma10 = iMA(NULL,0,10,0,MODE_SMA,PRICE_CLOSE,1);
//double atr10 = iATR(NULL,0,10,1);
   double bb_stop_trend_cur = iCustom(NULL,0,"bb-stops-v2-indicator",11,1);
   
   bool normalized_price_more_than_avg = iCustom(NULL,0,"normalize_price",0,1)>iCustom(NULL,0,"normalize_price",1,1);
   bool std_more_than_avg = iCustom(NULL,0,"my_std",0,0)>iCustom(NULL,0,"my_std",1,0);
   bool mfi_more_than_avg = iCustom(NULL,0,"my_mfi",0,1)>iCustom(NULL,0,"my_mfi",1,1);
   bool mfi_less_than_avg = iCustom(NULL,0,"my_mfi",0,1)<iCustom(NULL,0,"my_mfi",1,1);
   bool normalized_price_less_than_avg = iCustom(NULL,0,"normalize_price",0,1)<iCustom(NULL,0,"normalize_price",1,1);

  // double atr = iCustom(NULL,0,"ATR_X_EMA",0,1);
   //double atr_ma = iCustom(NULL,0,"ATR_X_EMA",1,1);

   //double atr_in_points    =  atr / Point;

   double lowest = (iClose(NULL,0,1)-Low[iLowest(NULL,0,MODE_LOW,10,1)]<10)?Low[iLowest(NULL,0,MODE_LOW,10,1)]:iClose(NULL,0,1)-10;
   double highest = (High[iHighest(NULL,0,MODE_HIGH,10,1)]-iClose(NULL,0,1)<10)?High[iHighest(NULL,0,MODE_HIGH,10,1)]:iClose(NULL,0,1)+10;

   if(ShouldOpen())
     {
      if(bb_stop_trend_cur == 1.0)
        {
         if(mfi_more_than_avg)
           {
            if(normalized_price_more_than_avg)
              {
               if(true)//std_more_than_avg
                 {
                  if(iClose(NULL,0,1)>ma10 && iClose(NULL,0,1)>iOpen(NULL,0,1))
                    {
                     if(iClose(NULL,0,1)-iCustom(NULL,0,"bb-stops-v2-indicator",3,1)<(2*iATR(NULL,0,14,1)))//iClose(NULL,0,1)-iOpen(NULL,0,1
                       {
                        if(true)
                          {
                           OrderSend(_Symbol,OP_BUY,0.1,Ask,3,lowest,0,"test",1111,0,clrGreen);
                          }
                       }
                    }
                 }
              }
           }
        }
      else
         if(bb_stop_trend_cur == -1.0)
           {
            if(mfi_less_than_avg)
              {
               if(normalized_price_less_than_avg)
                 {
                  if(true)//std_more_than_avg
                    {
                     if(iClose(NULL,0,1)<ma10 && iClose(NULL,0,1)<iOpen(NULL,0,1))
                       {
                        if(iCustom(NULL,0,"bb-stops-v2-indicator",4,1)-iClose(NULL,0,1)<(2*iATR(NULL,0,14,1)))//iOpen(NULL,0,1)-iClose(NULL,0,1)
                          {
                           if(true)
                             {
                              OrderSend(_Symbol,OP_SELL,0.1,Bid,3,highest,0,"test",1111,0,clrRed);
                             }
                          }
                       }
                    }
                 }
              }
           }
     }

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(false)//iClose(NULL,0,1)-iOpen(NULL,0,1)>2.5*iATR(NULL,0,14,1)
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
           }
         else
            if(Bid<iMA(NULL,0,10,0,MODE_SMA,PRICE_LOW,0))
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
              }

        }
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(false)//iOpen(NULL,0,1)-iClose(NULL,0,1)>2.5*iATR(NULL,0,14,1)
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
           }
         else
            if(Ask>iMA(NULL,0,10,0,MODE_SMA,PRICE_HIGH,0))
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
              }
        }
     }

  }
//+------------------------------------------------------------------+
