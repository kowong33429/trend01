//+------------------------------------------------------------------+
//|                                                         aoac.mq4 |
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


bool ShouldOpen()
{
   int ticket = -1;
   datetime open_time = 0;
   for(int i=OrdersTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
      && OrderSymbol()==_Symbol  
      && OrderOpenTime() > open_time)
      {
         ticket = OrderTicket();
         open_time = OrderOpenTime();
      }
   }
   return OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - OrderOpenTime() > 3600);
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

void OnTick()
  {
//---
/*
***Note***

###Best Trading Pair GBPUSD and EURUSD.###
###Time Frame: Excellent for 1Hr time frame###

->short rules
-Awesome Oscillator Turns Red
-Accelerator Oscillator Turns Red
-The Parabolic SARS is above the current Candle
-All conditions for a short must be met below the 200EMA

->long rules
-Awesome Oscillator Turns Green
-Accelerator Oscillator Turns Green
-The Parabolic SARS is below the current Candle
-All conditions for a Long trade must be met above the 200EMA

STOP LOSS:
 Set Stop Loss at the LOW of the entry candle.
PROFIT TARGET:
 Set Take Profit to the same amount of pips as Stop Loss. For Example, if the
difference between profit and entry is 50 pips, set your profit target to be
50pips or better still, you can go for 2:1 risk reward. If your stop loss is 50 pips,
you can aim for 1oo pips take profit.
 Alternatively, you can ride the trend until both the AO and AC change color
(to RED)
*/
   //order
   //double lots = 0.1;
   
   double atr = iATR(_Symbol,PERIOD_H1,14,0);
   double atrMultiple = 1.5;
   
   int stopLoss = (int)(atr * atrMultiple / Point);
   
   
   double lots = calculateLotSize(stopLoss);
   
   double stop_loss_buy = Ask-(stopLoss*Point);
   double stop_loss_sell = Bid+(stopLoss*Point);
   
   double take_profit_buy = Ask+(1.5*stopLoss*Point);
   double take_profit_sell = Bid-(1.5*stopLoss*Point);
   
   //printf("%f ,%f ,%f  ----yyyyyy",stop_loss_buy,stopLoss,lots);
   //printf("%f ,%f yyyyyy",stop_loss_sell,take_profit_sell);
   
   //double stop_loss_buy = Low[2];
   //double stop_loss_sell = High[2];
   
   //double take_profit_buy = Ask+(Open[0]-Low[2]);
   //double take_profit_sell = Bid-(High[2]-Open[0]);
   
   
   
   //indicator H1
   double ao_prev_1 = iAO(_Symbol,PERIOD_H1,1);
   double ao_prev_2 = iAO(_Symbol,PERIOD_H1,2);

   double ac_prev_1 = iAC(_Symbol,PERIOD_H1,1);
   double ac_prev_2 = iAC(_Symbol,PERIOD_H1,2);
   
   //double sar = iSAR(_Symbol,PERIOD_H1,0.02,0.2,1);
   double ema = iMA(_Symbol,PERIOD_H1,200,0,MODE_EMA,PRICE_CLOSE,0);
   
   double rsi_1 = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,1);
   double rsi_2 = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,2);
   double rsi_3 = iRSI(_Symbol,PERIOD_H1,14,PRICE_CLOSE,3);
   
   //double sto_main_prev_1 = iStochastic(_Symbol,PERIOD_H1,5,3,3,MODE_SMA,0,MODE_MAIN,1);
   //double sto_signal_prev_1 = iStochastic(_Symbol,PERIOD_H1,5,3,3,MODE_SMA,0,MODE_SIGNAL,1);
   
   //---double adx = iADX
   
   int total = OrdersTotal();
   
   if(total<1){
      //long condition
      if(ao_prev_1>ao_prev_2 && ac_prev_1>ac_prev_2 && Low[1]>ema && rsi_1 >= 50){
         //printf("%f ,%f 111111111111111111",sar,Close[1]);
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,stop_loss_buy,take_profit_buy,"sud lor EA",1111,0,clrGreen);
      }
   
      //short condition
      if(ao_prev_1<ao_prev_2 && ac_prev_1<ac_prev_2 &&  High[1]<ema && rsi_1<=50){
         //printf("%f ,%f 222222222222222222",sar,Close[1]);
         OrderSend(_Symbol,OP_SELL,lots,Bid,3,stop_loss_sell,take_profit_sell,"sud lor EA",1111,0,clrRed);
      }
   }
   
   /*for(int i=OrdersTotal()-1;i>=0;i--)
   {      
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES) && OrderSymbol()==_Symbol)
      {
         //case close price under ema
         if(OrderType() == OP_BUY && Close[1]<ema){
            //OrderClose(i,0.1,Ask,3,Yellow);
         }
         else if(OrderType() == OP_SELL && Close[1]>ema){
            //OrderClose(i,0.1,Bid,3,Yellow);
         }
         
         //case buy but signal sell happen or sell but signal buy happen
         if(OrderType() == OP_BUY && ao_prev_1<ao_prev_2 && ac_prev_1<ac_prev_2 && sar>Close[1]){
            OrderClose(i,0.1,Ask,3,Yellow);
         }
         else if(OrderType() == OP_SELL && ao_prev_1<ao_prev_2 && ac_prev_1<ac_prev_2 && sar>Close[1]){
            OrderClose(i,0.1,Bid,3,Yellow);
         }
      }
   }*/
  }
//+------------------------------------------------------------------+
