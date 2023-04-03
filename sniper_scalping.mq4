//+------------------------------------------------------------------+
//|                                              sniper_scalping.mq4 |
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
    double lotSize = AccountBalance() * risk / 100 / (stopLoss * tickVal);
    //Print("Acccc : ", AccountBalance() * risk / 100, "SL : ",stopLoss * tickVal);
 
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

void OnTick()
  {
//---
   //double buy_channel = iCustom(NULL,0,"VJ Sniper V3_100253280",0,1);
   //double buy_channel_prev = iCustom(NULL,0,"VJ Sniper V3_100253280",0,2);
   double buy_filter = iCustom(NULL,0,"ForexprofitsupremeFilter",0,1);
   double buy_babarian = iCustom(NULL,0,"Barbarian Arrow Indicator",1,1);
   double buy_babarian_prev = iCustom(NULL,0,"Barbarian Arrow Indicator",1,2);
   
   //double sell_channel = iCustom(NULL,0,"VJ Sniper V3_100253280",1,1);
   //double sell_channel_prev = iCustom(NULL,0,"VJ Sniper V3_100253280",1,2);
   double sell_filter = iCustom(NULL,0,"ForexprofitsupremeFilter",1,1);
   double sell_babarian = iCustom(NULL,0,"Barbarian Arrow Indicator",2,1);
   double sell_babarian_prev = iCustom(NULL,0,"Barbarian Arrow Indicator",2,2);
   //Print("babarian",iCustom(NULL,0,"Barbarian Arrow Indicator",0,1),"   ",iCustom(NULL,0,"Barbarian Arrow Indicator",1,1),"  ",iCustom(NULL,0,"Barbarian Arrow Indicator",2,1));
   double lots;
   double atr = iATR(NULL,0,9,1);
   double sl = (int)(atr*2/Point);
   double tp = sl*2;
   
   if(buy_babarian != 2147483647 && buy_filter == 1 )
   {
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,Ask-sl*Point,Ask+tp*Point,"tmt01",1111,0,clrGreen);
         //Print("buy   ",iCustom(NULL,0,"VJ Sniper V3_100253280",0,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",1,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",2,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",3,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",4,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",5,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",7,1));
      }
   }
   else if(sell_babarian != 2147483647 && sell_filter ==1)
   {
      lots = calculateLotSize(sl);
      if(OrdersTotal() == 0)
      {
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,Bid+sl*Point,Bid-tp*Point,"tmt01",1111,0,clrRed);
         //Print("sell   ",iCustom(NULL,0,"VJ Sniper V3_100253280",0,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",1,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",2,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",3,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",4,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",5,1),"  ",iCustom(NULL,0,"VJ Sniper V3_100253280",7,1));
      }
   }
  }
//+------------------------------------------------------------------+


