//+------------------------------------------------------------------+
//|                                                        tmt01.mq4 |
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
int check_color_candle()
{
   if(iOpen(NULL,PERIOD_D1,0)-iClose(NULL,PERIOD_D1,0)>0)
   {
      //"day is red"
      return -1;
   }
   else if(iOpen(NULL,PERIOD_D1,0)-iClose(NULL,PERIOD_D1,0)<0)
   {
      //"day is green"
      return 1;
   }
   else
   {
      //"neutral"
      return 0;
   }
}

double calculateLotSize(double stopLoss)
{
    // 1% risk per trade
    int risk = 2;
     
    // Fetch some symbol properties
    double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
    double minLot  = MarketInfo(Symbol(), MODE_MINLOT); 
    double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
    double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
 
    
    // Calculate the actual lot size
    double lotSize = AccountBalance() * risk / 100 / (stopLoss);
    
    return MathMin(
        maxLot,
        MathMax(
            minLot,
            NormalizeDouble(lotSize / lotStep, 0) * lotStep // This rounds the lotSize to the nearest lotstep interval
        )
    ); 
}

// Trailing Stop
void TrailingStop(int TrailingOffsetPoints) {

	// Iterate over all the trades beginning from the last one to prevent reindexing
	//Print("ATR = ",TrailingOffsetPoints);
	for (int i = OrdersTotal() - 1; i >= 0; i--) {

		// Select trade by its position and check Magic Number
		if (OrderSelect(i, SELECT_BY_POS, MODE_TRADES)) {

			// Adjust the stoploss if the offset is exceeded
			if ((OrderType() == OP_BUY) && (NormPrice(Bid - OrderOpenPrice()) > NormPrice(TrailingOffsetPoints)))
			{
				OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 50*Point, OrderTakeProfit(), OrderExpiration(), clrNONE);

			} else if ((OrderType() == OP_SELL) && (NormPrice(OrderOpenPrice() - Ask) > NormPrice(TrailingOffsetPoints))) {
				OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 50*Point, OrderTakeProfit(), OrderExpiration(), clrNONE);
			}
		}
	}
}

// Normalize the Price value
double NormPrice(double Price) {
	return NormalizeDouble(Price, Digits);
}

string check_color(double open,double close) {
   string colors = "";
   if(close-open>0)
   {
      colors = "green";
   }
   else if(close-open<0)
   {
      colors = "red";
   }
	return colors;
}

void OnTick()
  {
//---
   double mfi = iCustom(NULL,0,"TMT - FxGlow MFI Meter",3,1);
   double rsi = iCustom(NULL,0,"TMT - FxGlow RSI Meter",3,1);
   //double ema7 = iMA(NULL,PERIOD_H1,7,0,MODE_EMA,PRICE_CLOSE,1);
   //double ema20 = iMA(NULL,PERIOD_H1,20,0,MODE_EMA,PRICE_CLOSE,1);
   double ema7 = iCustom(NULL,0,"TMT - EMA 7",0,1);
   double ema20 = iCustom(NULL,0,"TMT - EMA 20",0,1);
   
   double ema7_h4 = iCustom(NULL,PERIOD_H1,"TMT - EMA 7",0,1);
   double ema20_h4 = iCustom(NULL,PERIOD_H1,"TMT - EMA 20",0,1);
   
   int daily_candle = check_color_candle();
   double lots;
   //double atr = iCustom(NULL,0,"ATR_Stop",0,1);
   double atr = iATR(_Symbol,0,14,1);
   double sl = (int)(atr*2/Point);
   double tp = sl*2;
   
   //TrailingStop(250*Point);
   //Ask>iMA(NULL,PERIOD_M15,200,0,MODE_EMA,PRICE_CLOSE,1)
   if(daily_candle == 1 && iCustom(NULL,0,"TMT - FxGlow RSI Meter",2,1) == 1 && 
   iCustom(NULL,0,"TMT - FxGlow MFI Meter",2,1) == 1 && ema7>ema20 && iClose(_Symbol,PERIOD_M15,1)-ema7<=20
   && iOpen(_Symbol,0,1)>ema20 && iOpen(_Symbol,0,1)<ema7 && iClose(_Symbol,0,1)>ema7 && Ask>ema20)
   {
      //buy
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"tmt01",1111,0,clrGreen);
      }
      /*else
      {
         if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
            }
      }*/
      
   }
   else if(daily_candle == -1 && iCustom(NULL,0,"TMT - FxGlow RSI Meter",3,1) == 1 && 
   iCustom(NULL,0,"TMT - FxGlow MFI Meter",3,1) == 1 && ema7<ema20 && ema7-iClose(_Symbol,PERIOD_M15,1)<=20
   && iOpen(_Symbol,0,1)< ema20 && iOpen(_Symbol,0,1)>ema7 && iClose(_Symbol,0,1)<ema7 && Bid<ema20)
   {
      //sell
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"tmt01",1111,0,clrRed);
      }
      /*else
      {
         if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
            }
      }*/
      
   }
   
   /*if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY && iCustom(NULL,0,"TMT - EMA 7",0,0)<=iCustom(NULL,0,"TMT - EMA 20",0,0))
   {
      OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
   }
   else if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL && iCustom(NULL,0,"TMT - EMA 7",0,0)>=iCustom(NULL,0,"TMT - EMA 20",0,0))
   {
      OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
   }*/
   
   //close order when price touch eam400
   /*if(Ask < iMA(NULL,PERIOD_M15,400,0,MODE_EMA,PRICE_CLOSE,1))
   {
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_BUY)
      {
         OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
      }
   }
   else if(Bid > iMA(NULL,PERIOD_M15,400,0,MODE_EMA,PRICE_CLOSE,1))
   {
      if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType() == OP_SELL)
      {
         OrderClose(OrderTicket(),OrderLots(),Bid,3,clrRed);
      }
   }*/
   
   
  }
//+------------------------------------------------------------------+
