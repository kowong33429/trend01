//+------------------------------------------------------------------+
//|                                                 EA_sudlor_01.mq4 |
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
    Print("Acccc : ", AccountBalance() * risk / 100, "SL : ",stopLoss * tickVal);
 
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
			if ((OrderType() == OP_BUY) && (NormPrice(Bid - OrderOpenPrice()) > NormPrice(TrailingOffsetPoints))) {

				OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() + 1, OrderTakeProfit(), OrderExpiration(), clrNONE);

			} else if ((OrderType() == OP_SELL) && (NormPrice(OrderOpenPrice() - Ask) > NormPrice(TrailingOffsetPoints))) {
				OrderModify(OrderTicket(), OrderOpenPrice(), OrderOpenPrice() - 1, OrderTakeProfit(), OrderExpiration(), clrNONE);
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
      double alligator_buy = iCustom(NULL,0,"Alligator AA TT",3,1);
      double alligator_sell = iCustom(NULL,0,"Alligator AA TT",4,1);
      double atr_buy = iCustom(NULL,0,"ATR_Stop",0,1);
      double atr_sell = iCustom(NULL,0,"ATR_Stop",1,1);
      double lots;
      double stop_loss_buy,stop_loss_sell;
      double take_profit_buy,take_profit_sell;
      
      double atr = iATR(_Symbol,PERIOD_H4,14,1);
      double atrMultiple = 2;
      double sl = (int)(atr * atrMultiple);
      
      TrailingStop(60);
 
      if(alligator_buy != 0 && MathAbs(iClose(_Symbol,PERIOD_H1,1)-Ask)<0.2)
      {     
         if(OrdersTotal() == 0)
         {       
            stop_loss_buy = iClose(_Symbol,PERIOD_H1,1) - atr_buy;
            //take_profit_buy = Ask + (stop_loss_buy * 2);
            take_profit_buy = Ask+(iATR(_Symbol,PERIOD_H4,14,1)*1.5);
            //lots = calculateLotSize(stop_loss_buy);
            lots = calculateLotSize(iClose(_Symbol,PERIOD_H1,1)-sl-1);
            OrderSend(_Symbol,OP_BUY,lots,Ask,3,iClose(_Symbol,PERIOD_H1,1)-sl-1,take_profit_buy,"sud lor EA",1111,0,clrGreen);
            Print("Buy SL : ", Ask-sl, "SL value : ",sl, " TP : ",take_profit_buy, "Lots : ",lots);
         }
         else
         {            
            if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_SELL)
            {
               OrderClose(OrderTicket(),OrderLots(),Ask,3,clrRed);
            }
         }
         
      }
      else if(alligator_sell != 0 && MathAbs(Bid-iClose(_Symbol,PERIOD_H1,1))<0.2) 
      {
         if(OrdersTotal() == 0)
         {            
            stop_loss_sell = atr_sell - iClose(_Symbol,PERIOD_H1,1);
            //take_profit_sell = Bid - (stop_loss_sell * 2);
            take_profit_sell = Bid-(iATR(_Symbol,PERIOD_H4,14,1)*1.5);
            //lots = calculateLotSize(stop_loss_sell);
            lots = calculateLotSize(iClose(_Symbol,PERIOD_H1,1)+sl+1);
            OrderSend(_Symbol,OP_SELL,lots,Bid,3,iClose(_Symbol,PERIOD_H1,1)+sl+1,take_profit_sell,"sud lor EA",1111,0,clrRed);
            Print("Sell SL : ", Bid+sl, "SL value : ",sl, " TP : ",take_profit_sell, "Lots : ",lots);;
         }
         else
         {           
            if(OrderSelect(0,SELECT_BY_POS,MODE_TRADES) && OrderType()==OP_BUY)
            {
               OrderClose(OrderTicket(),OrderLots(),Bid,3,clrGreen);
            }
         }
      }     

  }
//+------------------------------------------------------------------+
