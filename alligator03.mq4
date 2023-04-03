//+------------------------------------------------------------------+
//|                                                  alligator03.mq4 |
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
string check_alligator(double jaw,double teeth,double lips)
{
   string trend = "nothing";
   //buy
   if(lips>teeth && teeth>jaw && lips>jaw)
   {
      trend = "buy";
   }
   else if(lips<teeth && teeth<jaw && lips<jaw)
   {
      trend = "sell";
   }
   return trend;
}

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

bool check_slope_macd(string trend)
{
   int count = 0;
   int check_candle = 3;
   //buy
   if(trend == "buy")
   {
      for(int i=1; i<=check_candle; i++)
      {
         if(iMACD(_Symbol,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i)>iMACD(_Symbol,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1))
         {
            count++;
         }
      }
      if(count == check_candle)
      {
         count = 0;
         return true;
      }
      else
      {
         count = 0;
         return false;
      }
   }
   //sell
   else if(trend == "sell")
   {
      for(int i=1; i<=3; i++)
      {
         if(iMACD(_Symbol,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i)<iMACD(_Symbol,PERIOD_H1,12,26,9,PRICE_CLOSE,MODE_MAIN,i+1))
         {
            count++;
         }
      }
      if(count == check_candle)
      {
         count = 0;
         return true;
      }
      else
      {
         count = 0;
         return false;
      }
   }
   else
   {
    return NULL;
   }
}

bool IsNewBar() { 
   static   datetime lastBar;
            datetime currBar  =  iTime(_Symbol,PERIOD_H1, 0);
   
   if(lastBar != currBar) {
      lastBar  =  currBar;
      return (true); 
   } else {
      return(false);
   }
}

bool check_slope_alligator(string trend)
{
   int count = 0;
   int check_candle = 1;
   //buy
   if(trend == "buy")
   {
      for(int i=1; i<=check_candle; i++)
      {
         if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)>iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,2))
         {
            if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)>iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,2))
            {
               if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)>iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,2))
               {
                  count++;
               }
            }
         }
      }
      if(count == check_candle)
      {
         count = 0;
         return true;
      }
      else
      {
         count = 0;
         return false;
      }
   }
   //sell
   else if(trend == "sell")
   {
      for(int i=1; i<=3; i++)
      {
         if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1)<iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,2))
         {
            if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1)<iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,2))
            {
               if(iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1)<iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,2))
               {
                  count++;
               }
            }
         }
      }
      if(count == check_candle)
      {
         count = 0;
         return true;
      }
      else
      {
         count = 0;
         return false;
      }
   }
   else
   {
    return NULL;
   }
}

void OnTick()
  {
//---
   if (OrdersTotal() > 0 || !IsNewBar()) {
        return;
    }
   
   double atr = iATR(_Symbol,PERIOD_H1,14,1);
   double atrMultiple = 2;
   int stopLoss = (int)(atr * atrMultiple / Point);
   double lots = calculateLotSize(stopLoss);
   
   double stop_loss_buy = Ask-(stopLoss*Point);
   double stop_loss_sell = Bid+(stopLoss*Point);
   
   double take_profit_buy = Ask+(2*stopLoss*Point);
   double take_profit_sell = Bid-(2*stopLoss*Point);
   
   double jaw_h1 = iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
   double teeth_h1 = iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
   double gatorlips_h1 = iAlligator(_Symbol,PERIOD_H1,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
   
   double jaw_h4 = iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORJAW,1);
   double teeth_h4 = iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORTEETH,1);
   double gatorlips_h4 = iAlligator(_Symbol,PERIOD_H4,13,8,8,5,5,3,MODE_SMMA,PRICE_MEDIAN,MODE_GATORLIPS,1);
   
   double macd_macd_line_15min = iMACD(_Symbol,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_signal_line_15min = iMACD(_Symbol,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   
   double histrogram_15min_1 = iOsMA(_Symbol,PERIOD_M15,12,26,9,PRICE_CLOSE,1);
   double histrogram_15min_2 = iOsMA(_Symbol,PERIOD_M15,12,26,9,PRICE_CLOSE,2);
   
   //Strong trend system
   if(check_alligator(jaw_h1,teeth_h1,gatorlips_h1) == check_alligator(jaw_h4,teeth_h4,gatorlips_h4))
   {
      //buy
      if(check_alligator(jaw_h1,teeth_h1,gatorlips_h1) == "buy")
      {
         //check macd buy
         if(check_slope_alligator("buy"))
         {
            Print("buy555555555");
            //check previous candle is green
            OrderSend(_Symbol,OP_BUY,lots,Ask,3,stop_loss_buy,take_profit_buy,"sud lor EA",1111,0,clrGreen);
            /*if(iClose(_Symbol,PERIOD_H1,1)>iOpen(_Symbol,PERIOD_H1,1) && MathAbs(iClose(_Symbol,PERIOD_H1,1)-iOpen(_Symbol,PERIOD_H1,1))>10*Point)
            {
               if(iClose(_Symbol,PERIOD_H1,1)>teeth_h1 && iClose(_Symbol,PERIOD_H1,1)-teeth_h1<100*Point)
               {
                  OrderSend(_Symbol,OP_BUY,lots,Ask,3,stop_loss_buy,take_profit_buy,"sud lor EA",1111,0,clrGreen);
               }
            }*/
         }
      }
      else
      {
      //sell
         //check macd sell
         if(check_slope_alligator("sell"))
         {
            Print("sell44444444444");
            //check previous candle is green
            OrderSend(_Symbol,OP_SELL,lots,Bid,3,stop_loss_sell,take_profit_sell,"sud lor EA",1111,0,clrRed);
            /*if(iClose(_Symbol,PERIOD_H1,1)<iOpen(_Symbol,PERIOD_H1,1) && MathAbs(iClose(_Symbol,PERIOD_H1,1)-iOpen(_Symbol,PERIOD_H1,1))>10*Point)
            {
               if(iClose(_Symbol,PERIOD_H1,1)<teeth_h1 && teeth_h1-iClose(_Symbol,PERIOD_H1,1)<100*Point)
               {
                  OrderSend(_Symbol,OP_SELL,lots,Bid,3,stop_loss_sell,take_profit_sell,"sud lor EA",1111,0,clrRed);
               }
            }*/
         }
      }
   }
   else if(False)
   {
      
   }
   else
   {
   
   }
  }
  
//+------------------------------------------------------------------+
