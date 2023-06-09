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
   Print("Last order ticket is : ", ticket,"open time: ",close_time);

// 1800 = half hour , 3600 = full hour
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - close_time > 1800) && OrdersTotal()==0;
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing_SL()
  {
   for(int i = 0; i < OrdersTotal(); i++)  //Iterar con todas las ordenes
     {
      bool res = OrderSelect(i,SELECT_BY_POS,MODE_TRADES); //Seleccionar por index i
      int Local_ticket = OrderTicket(); //Guardar el numero de orden


      if(OrderType() == OP_BUY)
        {
         if(OrderStopLoss() < OrderOpenPrice() && Ask - OrderOpenPrice() >= 1000*Point)
           {
            OrderModify(Local_ticket,OrderOpenPrice(),OrderOpenPrice()+200*Point,OrderTakeProfit(),0);
           }
         else
            if(OrderStopLoss() > OrderOpenPrice() &&
               Ask -OrderStopLoss() > (((OrderStopLoss() - OrderOpenPrice())/(200*Point))+1) * 1000*Point)
              {
               OrderModify(Local_ticket,OrderOpenPrice(),OrderStopLoss()+200*Point,OrderTakeProfit(),0);
              }
        }
      else
         if(OrderType() == OP_SELL) //y si es compra
           {
            if(OrderStopLoss() > OrderOpenPrice() && OrderOpenPrice() - Bid >= 1000*Point)
              {
               OrderModify(Local_ticket,OrderOpenPrice(),OrderOpenPrice() - 200*Point,OrderTakeProfit(),0);
              }
            else
               if(OrderStopLoss() < OrderOpenPrice() &&
                  OrderStopLoss() - Bid > (((OrderOpenPrice() - OrderStopLoss())/(200*Point))+1) * 1000*Point)
                 {
                  OrderModify(Local_ticket,OrderOpenPrice(),OrderStopLoss() - 200*Point,OrderTakeProfit(),0);
                 }
           }
     }

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_color_HA(double open,double close)
  {
   string colors = "";
   if(close-open>0)
     {
      colors = "green";
     }
   else
      if(close-open<0)
        {
         colors = "red";
        }
   return colors;
  }

//check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green"
//check_color(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red"

//iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1)<=iCustom(NULL,0,"Heiken Ashi",3,1)
//iMA(NULL,0,5,2,MODE_SMA,PRICE_TYPICAL,1)>=iCustom(NULL,0,"Heiken Ashi",3,1)


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   double ma = iMA(NULL,0,13,0,MODE_SMA,PRICE_CLOSE,1);
//tf 30
   double bb_fast = iCustom(NULL,0,"bb-stops-v2-indicator",10,3.0,11,1);
   double bb_medium = iCustom(NULL,0,"bb-stops-v2-indicator",11,3.0,11,1);
   double bb_slow = iCustom(NULL,0,"bb-stops-v2-indicator",20,3.0,11,1);

   double bb_fast_prev = iCustom(NULL,0,"bb-stops-v2-indicator",10,3.0,11,2);
   double bb_medium_prev = iCustom(NULL,0,"bb-stops-v2-indicator",11,3.0,11,2);
   double bb_slow_prev = iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,2);

   double sq_uu = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",0,1);
   double sq_ud = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",2,1);

   double sq_dd = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",1,1);
   double sq_du = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",3,1);

   double sq_hv = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",6,1);
   double sq_lv = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",5,1);

//double sq_hv_prev = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",6,2);
//double sq_lv_prev = iCustom(NULL,0,"bbsqueeze alerts (mtf & multi symbol)",5,2);

//double atr = iCustom(NULL,0,"ATR_X_EMA",0,1);
//double atr_ma = iCustom(NULL,0,"ATR_X_EMA",1,1);

//double adx = iCustom(NULL,0,"my_adx",0,1);
//double avg_adx = iCustom(NULL,0,"my_adx",1,1);

//double volume = iCustom(NULL,0,"my_volume",48,0,0);
//double volumeAvg = iCustom(NULL,0,"my_volume",48,1,0);

//Trailing_SL();

   if(ShouldOpen())//OrdersTotal() == 0
     {
      if(bb_fast == 1.0 && bb_medium == 1.0 && bb_slow == 1.0)//&& bb_medium_prev == -1.0
        {
         if(sq_du != 2147483647.0 && (sq_hv != 2147483647.0))//|| atr>atr_ma
           {
            if(true)//Close[1]-Open[1]<8 && iClose(NULL,PERIOD_M5,1)>iCustom(NULL,0,"bb-stops-v2-indicator",2,3.0,3,2)
              {
               if(check_color_HA(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green")
                 {
                  if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,11) == -1)
                    {
                     OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Close[1]-2.5*iATR(NULL,0,14,1),Close[1]+5*iATR(NULL,0,14,1),"test",1111,0,clrGreen);
                    }
                 }
              }
           }
         else
            if(sq_uu != 2147483647.0 && (sq_hv != 2147483647.0))//|| atr>atr_ma
              {
               if(check_color_HA(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "green")//Close[1]-Open[1]<8
                 {
                  if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,11) == -1)
                    {
                     OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Close[1]-2.5*iATR(NULL,0,14,1),Close[1]+5*iATR(NULL,0,14,1),"test",1111,0,clrGreen);
                    }
                 }
              }
        }
      else
         if(bb_fast == -1.0 && bb_medium == -1.0 && bb_slow == -1.0)//&& bb_medium_prev == 1.0
           {
            if(sq_ud != 2147483647.0 && (sq_hv != 2147483647.0))// || atr>atr_ma
              {
               if(true)//Open[1]-Close[1]<8 && iClose(NULL,PERIOD_M5,1)<iCustom(NULL,0,"bb-stops-v2-indicator",2,3.0,4,2)
                 {
                  if(check_color_HA(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red")
                    {
                     if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,11) == 1)
                       {
                        OrderSend(_Symbol,OP_SELL,0.1,Bid,3,Close[1]+2.5*iATR(NULL,0,14,1),Close[1]-5*iATR(NULL,0,14,1),"test",1111,0,clrRed);
                       }

                    }
                 }
              }
            else
               if(sq_dd != 2147483647.0 && (sq_hv != 2147483647.0))//|| atr>atr_ma
                 {
                  if(check_color_HA(iCustom(NULL,0,"Heiken Ashi",2,1),iCustom(NULL,0,"Heiken Ashi",3,1)) == "red")//Open[1]-Close[1]<8
                    {
                     if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,11) == 1)
                       {
                        OrderSend(_Symbol,OP_SELL,0.1,Bid,3,Close[1]+2.5*iATR(NULL,0,14,1),Close[1]-5*iATR(NULL,0,14,1),"test",1111,0,clrRed);
                       }

                    }
                 }
           }
     }


   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && TimeCurrent() - OrderOpenTime() > 3600)
        {
         /*if(OrderProfit()>0)
           {
            if((iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1)
               && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2)) || Close[1]<ma)
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
              }
           }
         else
           {
            if(Close[1]<ma)//bb_slow == -1
              {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
              }
           }*/
         if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,1) == -1.0)//OrderProfit()>0 && Close[1]<ma
           {
            OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
           }

        }
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && TimeCurrent() - OrderOpenTime() > 3600)
        {
         /*if(OrderProfit()>0)
           {
            if((iCustom(NULL,0,"ATR_X_EMA",0,1)<iCustom(NULL,0,"ATR_X_EMA",1,1)
               && iCustom(NULL,0,"ATR_X_EMA",0,2)<iCustom(NULL,0,"ATR_X_EMA",1,2)) || Close[1]>ma)
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
              }
           }
         else
           {
            if(Close[1]>ma)//bb_slow == 1
              {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
              }
           }*/
         if(iCustom(NULL,0,"bb-stops-v2-indicator",12,3.0,11,1) == 1.0)//OrderProfit()>0 && Close[1]>ma
           {
            OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
           }

        }
     }

  }
//+------------------------------------------------------------------+
