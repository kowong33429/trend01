//+------------------------------------------------------------------+
//|                                                  cowbanga_01.mq4 |
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
   //h4
   double ema5_h4 = iMA(NULL,PERIOD_H4,5,0,MODE_EMA,PRICE_CLOSE,1);
   double ema10_h4 = iMA(NULL,PERIOD_H4,10,0,MODE_EMA,PRICE_CLOSE,1);
   double rsi_1_h4 = iRSI(NULL,PERIOD_H4,9,PRICE_CLOSE,1);
   double rsi_2_h4 = iRSI(NULL,PERIOD_H4,9,PRICE_CLOSE,2);
   double rsi_3_h4 = iRSI(NULL,PERIOD_H4,9,PRICE_CLOSE,3);
   double sto_1_h4 = iStochastic(NULL,PERIOD_H4,10,3,3,MODE_SMA,0,MODE_MAIN,1);
   double sto_2_h4 = iStochastic(NULL,PERIOD_H4,10,3,3,MODE_SMA,0,MODE_MAIN,1);
   double sto_3_h4 = iStochastic(NULL,PERIOD_H4,10,3,3,MODE_SMA,0,MODE_MAIN,1);
   //m15
   double ema5_m15 = iMA(NULL,PERIOD_M15,5,0,MODE_EMA,PRICE_CLOSE,1);
   double ema10_m15 = iMA(NULL,PERIOD_M15,10,0,MODE_EMA,PRICE_CLOSE,1);
   double rsi_1_m15 = iRSI(NULL,PERIOD_M15,9,PRICE_CLOSE,1);
   double rsi_2_m15 = iRSI(NULL,PERIOD_M15,9,PRICE_CLOSE,2);
   double rsi_3_m15 = iRSI(NULL,PERIOD_M15,9,PRICE_CLOSE,3);
   double macd_1_m15 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_2_m15 = iMACD(NULL,PERIOD_M15,12,26,9,PRICE_CLOSE,MODE_MAIN,2);
   double sto_1_m15 = iStochastic(NULL,PERIOD_M15,10,3,3,MODE_SMA,0,MODE_MAIN,1);
   double sto_2_m15 = iStochastic(NULL,PERIOD_M15,10,3,3,MODE_SMA,0,MODE_MAIN,1);
   double sto_3_m15 = iStochastic(NULL,PERIOD_M15,10,3,3,MODE_SMA,0,MODE_MAIN,1);

   if(ema5_h4>ema10_h4 && rsi_3_h4<rsi_2_h4 && rsi_2_h4<rsi_1_h4 && rsi_1_h4>50 && rsi_2_h4>50
   && sto_3_h4<sto_2_h4 && sto_2_h4<sto_1_h4 && sto_1_h4>50 && sto_2_h4>50)
   {
      if(ema5_m15>ema10_m15 && rsi_3_m15<rsi_2_m15 && rsi_2_m15<rsi_1_m15 && rsi_1_m15>50 && rsi_2_m15>50
      && sto_3_m15<sto_2_m15 && sto_2_m15<sto_1_m15 && sto_1_m15>50 && sto_2_m15>50 && macd_1_m15>macd_2_m15)
      {
         OrderSend(_Symbol,OP_BUY,0.1,Ask,3,Ask-300*Point,Ask+300*Point,"cowbungwa",1111,0,clrGreen);
      }
   }
  }
//+------------------------------------------------------------------+
