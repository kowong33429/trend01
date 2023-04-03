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
bool check_order_buy()
  {
   int ticket = -1;
   datetime close_time = 0;
   if(OrdersHistoryTotal()==0 && OrdersTotal()==0)
     {
      return true;
     }
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
         && OrderSymbol()==_Symbol
         && OrderCloseTime() > close_time)
        {
         ticket = OrderTicket();
         close_time = OrderCloseTime();
        }
      //Print(OrderTicket());
     }
//Print("Last order ticket is : ", ticket,"open time: ",close_time);

// 1800 = half hour , 3600 = full hour
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - close_time > 1800) && OrderType() == OP_BUY;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool check_order_sell()
  {
   int ticket = -1;
   datetime close_time = 0;
   if(OrdersHistoryTotal()==0 && OrdersTotal()==0)
     {
      return true;
     }
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
         && OrderSymbol()==_Symbol
         && OrderCloseTime() > close_time)
        {
         ticket = OrderTicket();
         close_time = OrderCloseTime();
        }
      //Print(OrderTicket());
     }
//Print("Last order ticket is : ", ticket,"open time: ",close_time);

// 1800 = half hour , 3600 = full hour
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - close_time > 1800) && OrderType() == OP_SELL;
  }


//+------------------------------------------------------------------+
//|                                                                  |
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
   int flag = 0;
//2147483647.0 == non value

   if((TimeMinute(TimeCurrent()) == 1 || TimeMinute(TimeCurrent()) == 31) && TimeSeconds(TimeCurrent()) == 1)
     {
      Print("curr up: ",iCustom(NULL,0,"SuperTrend",11,2.0,0,0)," prev up: ",iCustom(NULL,0,"SuperTrend",11,2.0,0,1),
            "curr dow: ",iCustom(NULL,0,"SuperTrend",11,2.0,1,0)," prev dow: ",iCustom(NULL,0,"SuperTrend",11,2.0,1,1));
     }

   if(OrdersTotal() == 0)
     {
      if(trend_fast_up != 2147483647.0 && trend_meduim_up != 2147483647.0 && trend_slow_up != 2147483647.0)
        {
         if(sq_du != 2147483647.0 && sq_hv != 2147483647.0)
           {
            if(check_order_sell())
              {
             
               OrderSend(_Symbol,OP_BUY,0.1,Ask,3,iCustom(NULL,0,"SuperTrend",12,3.0,0,0),0,"test",1111,0,clrGreen);
              }
           }
         else
            if(sq_uu != 2147483647.0 && sq_hv != 2147483647.0)
              {
               if(check_order_sell())
                 {
                 
                  OrderSend(_Symbol,OP_BUY,0.1,Ask,3,iCustom(NULL,0,"SuperTrend",12,3.0,0,0),0,"test",1111,0,clrGreen);
                 }

              }
        }
      else
         if(trend_fast_down != 2147483647.0 && trend_meduim_down != 2147483647.0 && trend_slow_down != 2147483647.0)
           {
            if(sq_ud != 2147483647.0 && sq_hv != 2147483647.0)
              {
               if(check_order_buy())
                 {
                
                  OrderSend(_Symbol,OP_SELL,0.1,Bid,3,iCustom(NULL,0,"SuperTrend",12,3.0,1,0),0,"test",1111,0,clrRed);
                 }
              }
            else
               if(sq_dd != 2147483647.0 && sq_hv != 2147483647.0)
                 {
                  if(check_order_buy())
                    {
                    
                     OrderSend(_Symbol,OP_SELL,0.1,Bid,3,iCustom(NULL,0,"SuperTrend",12,3.0,1,0),0,"test",1111,0,clrRed);
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
            if(true)//OrderOpenPrice()+5<iClose(NULL,0,1)
              {
               if(flag == -1)
                 {
                  OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
                 }
              }
           }
         else
           {
            if(flag == -1)
              {
               Print("1111111111111111111");
               Print(flag);
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
              }
            else
               if((iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,0)<iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1) && iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1)<iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,2))
                  || (iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",1,0) != 2147483647.0))
                 {
                  Print("22222222222222222222");
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

            if(true)//OrderOpenPrice()-5>iClose(NULL,0,1)
              {
               if(flag == 1)
                 {
                  Print("333333333333333");
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
              }
           }
         else
           {
            if(flag == 1)
              {
               Print("44444444444444444444444");
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
              }
            else
               if((iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,0)>iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1) && iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1)>iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,2))
                  || (iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",0,0) != 2147483647.0))
                 {
                  OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
                 }
           }

        }
     }

  }
//+------------------------------------------------------------------+
