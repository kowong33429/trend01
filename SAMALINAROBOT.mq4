//+------------------------------------------------------------------+
//|                                                SAMALINAROBOT.mq4 |
//|                                            www.samalina.com 2017 |
//|                                                 https://''SAMUEL |
//+------------------------------------------------------------------+
#property copyright "www.samalina.com 2017"
#property link      "https://''SAMUEL"
#property version   "1.00"
#property strict
extern int TakeProfit=100;
extern int StopLoss=100;

extern double Lotsize =0.01;
extern bool UseMoveToBreakeven=False;
extern int 	WhenToMoveToBE=50;
extern int  PipsToLockIn=50;
extern bool UseTrailingStop = False;
extern int  WhenToTrail=100;
extern int  TrailAmount=50;
extern bool UseCandleTrail=False;
extern int  PadAmount=10;
extern int  CandlesBack=6;
extern bool UsePercentStop=false;
extern double RiskPercent=1;//in the video these were integers. I changed them to doubles so that you could use 0.5% risk if you wish.
extern bool UsePercentTakeProfit=false;
extern double RewardPercent=2;
//extern double Macd_Threshold=11;
extern int  Slow_Macd_Ema=17;
extern int  Slow_Macd_Ema_Shift=0;
extern int  Slow_Macd_Ema_Method=2;
extern int  Slow_Macd_Ema_AppliedTo=0;
extern int  Fast_Macd_Ema=5;
extern int  Fast_Macd_Ema_Shift=0;
extern int  Fast_Macd_Ema_Method=2;
extern int  Fast_Macd_Ema_AppliedTo=0;
extern int  Signal_Macd=9;
extern int  Signal_Macd_Shift=0;
extern int  Signal_Macd_Method=2;
extern int  Signal_Macd_AppliedTo=0;





extern int  MagicNumber =270515;
extern string Comment ="SAMALINAROBOT";
input int Slippage=30;
 int ticket; 
 
double pips;

//extern int  MagicNumber =270515;


       
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
 
//---
   
   double ticksize = MarketInfo(Symbol(), MODE_TICKSIZE);
   	if (ticksize == 0.00001 || ticksize == 0.001)
	   pips = ticksize*10;
	   else pips =ticksize;
  Comment(AccountLeverage());
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
  if(OpenOrdersThisPair(Symbol())>=0)
   {
      if(UseMoveToBreakeven)MoveToBreakeven();
      if(UseTrailingStop)AdjustTrail();
     // if(IsNewCandle())CheckForMaTrade();
   }
     if(IsNewCandle())CheckForMacdTrade();
//----
   
  }
   
//+------------------------------------------------------------------+

 //+------------------------------------------------------------------+
//Move to breakeven function
//+------------------------------------------------------------------+

void MoveToBreakeven()
{
   for(int b=OrdersTotal()-1; b >= 0; b--)
	{
	if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
      if(OrderMagicNumber()== MagicNumber)
         if(OrderSymbol()==Symbol())
            if(OrderType()==OP_BUY)
               if(Bid-OrderOpenPrice()>WhenToMoveToBE*pips)
                  if(OrderOpenPrice()>OrderStopLoss())
                     if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()+(PipsToLockIn*pips),OrderTakeProfit(),0,CLR_NONE))
                         Print("Order ",ticket," was successfully modified.");
                          else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
   }
   for (int s=OrdersTotal()-1; s >= 0; s--)
	     {
         if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
	        if(OrderMagicNumber()== MagicNumber)
	           if(OrderSymbol()==Symbol())
	              if(OrderType()==OP_SELL)
                  if(OrderOpenPrice()-Ask>WhenToMoveToBE*pips)
                     if(OrderOpenPrice()<OrderStopLoss())    
                        if(OrderModify(OrderTicket(),OrderOpenPrice(),OrderOpenPrice()-(PipsToLockIn*pips),OrderTakeProfit(),0,CLR_NONE))
                        Print("Order ",ticket," was successfully modified.");
                         else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
        }
}
//+------------------------------------------------------------------+
//trailing stop function
//+------------------------------------------------------------------+
void AdjustTrail()
{
int buyStopCandle= iLowest(NULL,0,1,CandlesBack,1); 
int sellStopCandle=iHighest(NULL,0,2,CandlesBack,1); 

//buy order section
      for(int b=OrdersTotal()-1;b>=0;b--)
	      {
         if(OrderSelect(b,SELECT_BY_POS,MODE_TRADES))
           if(OrderMagicNumber()==MagicNumber)
              if(OrderSymbol()==Symbol())
                  if(OrderType()==OP_BUY)
                        if(UseCandleTrail)
                        {  
                              if(OrderStopLoss()<Low[buyStopCandle]-PadAmount*pips)
                                 if(OrderModify(OrderTicket(),OrderOpenPrice(),Low[buyStopCandle]-PadAmount*pips,OrderTakeProfit(),0,CLR_NONE))
                                 Print("Order ",ticket," was successfully modified.");
                            else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
                                       
                        }
                      else if(Bid-OrderOpenPrice()>WhenToTrail*pips) 
                              if(OrderStopLoss()<Bid-TrailAmount*pips)
                                 if(OrderModify(OrderTicket(),OrderOpenPrice(),Bid-(TrailAmount*pips),OrderTakeProfit(),0,CLR_NONE))
                                 Print("Order ",ticket," was successfully modified.");
                            else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
         }
//sell order section
      for(int s=OrdersTotal()-1;s>=0;s--)
	      {
         if(OrderSelect(s,SELECT_BY_POS,MODE_TRADES))
            if(OrderMagicNumber()== MagicNumber)
               if(OrderSymbol()==Symbol())
                  if(OrderType()==OP_SELL)
                      if(UseCandleTrail)
                       {   
                              if(OrderStopLoss()>High[sellStopCandle]+PadAmount*pips|| OrderStopLoss()==0)
                                 if(OrderModify(OrderTicket(),OrderOpenPrice(),High[sellStopCandle]+PadAmount*pips,OrderTakeProfit(),0,CLR_NONE))
                                Print("Order ",ticket," was successfully modified.");
                            else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
                       }
                    else if(OrderOpenPrice()-Ask>WhenToTrail*pips)
                              if(OrderStopLoss()>Ask+TrailAmount*pips|| OrderStopLoss()==0)
                                 if(OrderModify(OrderTicket(),OrderOpenPrice(),Ask+(TrailAmount*pips),OrderTakeProfit(),0,CLR_NONE))
                                 Print("Order ",ticket," was successfully modified.");
                            else Print("Order ",ticket," was NOT successfully modified.",GetLastError());
         }
}


//+------------------------------------------------------------------+
//insuring its a new candle function
//+------------------------------------------------------------------+
 bool IsNewCandle()
{
   static int BarsOnChart=0;
	if (Bars == BarsOnChart)
	return (false);
	BarsOnChart = Bars;
	return(true);
}

//+------------------------------------------------------------------+
//function that checks or an Ma cross
//+------------------------------------------------------------------+
void CheckForMacdTrade()
{
double Macd_Value=iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,0,1);
double PreviousFast = iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,0,2);
double CurrentFast = iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,0,1); 
//double PreviousSlow = iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,0,2); 
//double CurrentSlow = iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,0,1); 
double Macd_Signal= iMACD(NULL,0,Fast_Macd_Ema,Slow_Macd_Ema,Signal_Macd,0,1,1); 

if(PreviousFast<Macd_Signal && CurrentFast>Macd_Signal)OrderEntry(0);
if(PreviousFast>Macd_Signal && CurrentFast<Macd_Signal)OrderEntry(1);
}



//------------------------------------------------
void OrderEntry(int direction)
{
   double Equity=AccountEquity();
   double RiskedAmount=Equity*RiskPercent*0.01;
   double RewardAmount=Equity*RewardPercent*0.01;
   Comment(RewardPercent);

   if(direction==0)
   {
       
       double btp = 0;
       double bsl = 0;
       int buyticket=0;
      if(StopLoss!=0)bsl=Ask-(StopLoss*pips);
      if(UsePercentStop)bsl=Ask-(RiskedAmount/(0.01*10))*pips;
      if(TakeProfit!=0)btp=Ask+(TakeProfit*pips);
      if(UsePercentTakeProfit)btp=Ask+(RewardAmount/(0.01*10))*pips;
      if(OpenOrdersThisPair(Symbol())==0)
      if(OrdersTotal()==0)
      buyticket= OrderSend(Symbol(),OP_BUY,0.01,Ask,30,0,0,NULL,MagicNumber,0,Green);
      if(buyticket>0)
         if(OrderModify(buyticket,OrderOpenPrice(),bsl,btp,0,CLR_NONE))
           Print("Order ",buyticket," was successfully modified.");
            else Print("Order ",buyticket," was NOT successfully modified.",GetLastError());
      
   }
   
   
   if(direction==1)
   {
      double ssl=0;
      double stp=0;
      int sellticket=0;
      if(StopLoss!=0)ssl=Bid+(StopLoss*pips);
      if(UsePercentStop)ssl=Bid+(RiskedAmount/(0.01*10))*pips;
      if(TakeProfit!=0)stp=Bid-(TakeProfit*pips);
      if(UsePercentTakeProfit)stp=Bid-(RewardAmount/(0.01*10))*pips;
      if(OpenOrdersThisPair(Symbol())==0)
      if(OrdersTotal()==0)
      sellticket= OrderSend(Symbol(),OP_SELL,0.01,Bid,30,0,0,NULL,MagicNumber,0,Red);
      if(sellticket>0)
         if(OrderModify(sellticket,OrderOpenPrice(),ssl,stp,0,CLR_NONE))
           Print("Order ",sellticket," was successfully modified.");
            else Print("Order ",sellticket," was NOT successfully modified.",GetLastError());
   }
}


//+------------------------------------------------------------------+
//checks to see if any orders open on this currency pair.
//+------------------------------------------------------------------+
int OpenOrdersThisPair(string pair)
{
  int total=0;
   for(int i=OrdersTotal()-1; i >= 0; i--)
	  {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderSymbol()== pair) total++;
	  }
	  return (total);
}  
  
//+------------------------------------------------------------------+  
//---


