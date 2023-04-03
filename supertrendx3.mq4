//+------------------------------------------------------------------+
//|                                                 supertrendx3.mq4 |
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
   double atr = iCustom(NULL,0,"ATR_X_EMA",0,1);
   double atr_ma = iCustom(NULL,0,"ATR_X_EMA",1,1);

   double trend_fast_up = iCustom(NULL,0,"SuperTrend",10,1.0,0,1);
   double trend_meduim_up = iCustom(NULL,0,"SuperTrend",11,2.0,0,1);
   double trend_slow_up = iCustom(NULL,0,"SuperTrend",12,3.0,0,1);

   double trend_fast_down = iCustom(NULL,0,"SuperTrend",10,1.0,1,1);
   double trend_meduim_down = iCustom(NULL,0,"SuperTrend",11,2.0,1,1);
   double trend_slow_down = iCustom(NULL,0,"SuperTrend",12,3.0,1,1);

   double sq_uu = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",0,1);
   double sq_ud = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1);

   double sq_dd = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",1,1);
   double sq_du = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1);

   double sq_hv = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",6,1);
   double sq_lv = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",5,1);

//2147483647.0 == non value

   if(OrdersTotal() == 0)
     {
      if(trend_fast_up != 2147483647.0 && trend_meduim_up != 2147483647.0 && trend_slow_up != 2147483647.0)
        {
         if(sq_du != 2147483647.0 && sq_hv != 2147483647.0)
           {
            if(atr>atr_ma)
              {
               OrderSend(_Symbol,OP_BUY,0.1,Ask,3,trend_slow_up,0,"test",1111,0,clrGreen);
              }
           }
         else
            if(sq_uu != 2147483647.0 && sq_hv != 2147483647.0)
              {
               if(atr>atr_ma)
                 {
                  OrderSend(_Symbol,OP_BUY,0.1,Ask,3,trend_slow_up,0,"test",1111,0,clrGreen);
                 }

              }
        }
      else
         if(trend_fast_down != 2147483647.0 && trend_meduim_down != 2147483647.0 && trend_slow_down != 2147483647.0)
           {
            if(sq_ud != 2147483647.0 && sq_hv != 2147483647.0)
              {
               if(atr>atr_ma)
                 {
                  OrderSend(_Symbol,OP_SELL,0.1,Bid,3,trend_slow_down,0,"test",1111,0,clrRed);
                 }
              }
            else
               if(sq_dd != 2147483647.0 && sq_hv != 2147483647.0)
                 {
                  if(atr>atr_ma)
                    {
                     OrderSend(_Symbol,OP_SELL,0.1,Bid,3,trend_slow_down,0,"test",1111,0,clrRed);
                    }
                 }
           }
     }


   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(OrderProfit()>0)
           {
            if(Ask>OrderOpenPrice()+40)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+8,0,0,Blue);
              }
            else
               if(Ask>OrderOpenPrice()+30)
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+6,0,0,Blue);
                 }
               else
                  if(Ask>OrderOpenPrice()+20)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+4,0,0,Blue);
                    }
                  else
                     if(Ask>OrderOpenPrice()+10)
                       {
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+2,0,0,Blue);
                       }
            if(OrderOpenPrice()+5<iClose(NULL,0,1))//<iClose(NULL,0,1)
              {
               if(iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1)
                  && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
                 }
              }
           }
         else
           {
            if(trend_fast_down == -1.0 && trend_meduim_down == -1.0 && trend_slow_down == -1.0)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
              }
            else
               if((iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,0)<iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1) && iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1)<iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,2))
                  || (iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",1,0) != 2147483647.0))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
                 }
           }

        }
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
        {
         if(OrderProfit()>0)
           {
            if(OrderOpenPrice()-40)
              {
               OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-8,0,0,Red);
              }
            else
               if(Ask>OrderOpenPrice()-30)
                 {
                  OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-6,0,0,Red);
                 }
               else
                  if(Ask>OrderOpenPrice()-20)
                    {
                     OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-4,0,0,Red);
                    }
                  else
                     if(Ask>OrderOpenPrice()-10)
                       {
                        OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-2,0,0,Red);
                       }

            if(OrderOpenPrice()-5>iClose(NULL,0,1))//>iClose(NULL,0,1)
              {
               if(iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1)
                  && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
              }
           }
         else
           {
            if(trend_fast_up == 1.0 && trend_meduim_up == 1.0 && trend_slow_up == 1.0)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
              }
            else
               if((iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,0)>iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1) && iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1)>iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,2))
                  || (iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",0,1) != 2147483647.0))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
           }

        }
     }

  }
//+------------------------------------------------------------------+
