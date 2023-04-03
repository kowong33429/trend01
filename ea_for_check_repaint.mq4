//+------------------------------------------------------------------+
//|                                         ea_for_check_repaint.mq4 |
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
  /* double trend_meduim_up_1 = iCustom(NULL,0,"SuperTrend",11,2,0,1);
   double trend_meduim_up_2 = iCustom(NULL,0,"SuperTrend",11,2,0,2);
   double trend_meduim_up_3 = iCustom(NULL,0,"SuperTrend",11,2,0,3);
   
   
   double trend_meduim_down_1 = iCustom(NULL,0,"SuperTrend",11,2,1,1);
   double trend_meduim_down_2 = iCustom(NULL,0,"SuperTrend",11,2,1,2);
   double trend_meduim_down_3 = iCustom(NULL,0,"SuperTrend",11,2,1,3);*/
   
  /* double sq_uu_1 = iCustom(NULL,0,"bbsqueeze_alerts_mtf__multi_symbol",6,1);
   double sq_uu_2 = iCustom(NULL,0,"bbsqueeze_alerts_mtf__multi_symbol",6,2);
   double sq_uu_3 = iCustom(NULL,0,"bbsqueeze_alerts_mtf__multi_symbol",6,3);*/
   
   string indi_name = "TMACG-mladen-NRP-TEAMTRADER2-buy-sell";
   int test_index_buffer = 4;
   
   double indi_1 = iCustom(NULL,0,indi_name,test_index_buffer,1);
   double indi_2 = iCustom(NULL,0,indi_name,test_index_buffer,2);
   double indi_3 = iCustom(NULL,0,indi_name,test_index_buffer,3);

   
   if( (TimeMinute(TimeCurrent())==1 || TimeMinute(TimeCurrent())==31) && TimeSeconds(TimeCurrent())==1 )
   {
      Print("   ", indi_1, "  ", indi_2, "  ", indi_3);
   }

   
  }
//+------------------------------------------------------------------+
