//+------------------------------------------------------------------+
//|                                               Kijun_Rider_01.mq4 |
//|                               Copyright © 2014, Khalil Abokwaik. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Khalil Abokwaik"
#property link "http://www.forexfactory.com/abokwaik"
#property description "Ichimoku Kijun Sen cross, Idea by MMGood47"
//--- input parameters
 
input int      Magic_Number              = 40030;
input double   Fixed_Lot_Size            = 0.1;    
input int      Min_SL_Pips               = 300;      

//----------------------------------------------------------------------------
double KijunSen=0,ChinkouSpan=0,SekouSpanA=0,SekouSpanB=0;
int ord_arr[100],trail_stop_jump=5;
int Tr_SL_Pips=0;
double sell_price = 0,buy_price  = 0,stop_loss=0,profit_target=0;
bool OrderSelected=false,OrderClosed=false;
int NewOrder=0;
int oper_max_tries = 10,tries=0,curr_ord_type;
double sl_price=0,tp_price=0,Lot_Size=0;
bool Long,Short;
datetime prev_order_time=0,Last_Modified=0;

//-----------

int market_buy_order()
{  double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   if (Min_SL_Pips>0)
      sl_price=MathMin(KijunSen,Bid-Min_SL_Pips*Point);
   else
      sl_price=KijunSen;
      
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_BUY,Fixed_Lot_Size,Ask,5,
                         sl_price,
                         0, // not profit target as order will be closed only by the trailing stop
                         "Kijun_Rider_01",Magic_Number,0,Blue);            
      tries=tries+1;
   }
   if(NewOrder>0) prev_order_time=TimeCurrent();
   return(NewOrder);
}
int market_sell_order()
{
   double rem=0; bool x=false;
   NewOrder=0;
   tries=0;
   if(Min_SL_Pips>0)
      sl_price=MathMax(KijunSen,Ask+Min_SL_Pips*Point);
   else
      sl_price=KijunSen;

   // Trying to open the order
   
   while(NewOrder<=0 && tries< oper_max_tries)
   {
      NewOrder=OrderSend(Symbol(),OP_SELL,Fixed_Lot_Size,Bid,5,
                         sl_price,
                         0,            // not profit target as order will be closed only by the trailing stop
                         "Kijun_Rider_01",Magic_Number,0,Red);            
      tries=tries+1;
   }
   if(NewOrder>0) prev_order_time=TimeCurrent();
   return(NewOrder);
}



int total_orders()
{ int tot_orders=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
        ) tot_orders=tot_orders+1;
   }
   return(tot_orders);
}

int current_order_type()
{ int ord_type=-1;
  int tkt_num=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && OrderTicket()>tkt_num
        ) 
        {
            ord_type = OrderType();
            tkt_num=OrderTicket();
        }
   }
   return(ord_type);
}
///------------
//--------------------
void trail_stop()
{ double new_sl=0; bool OrderMod=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number && OrderSymbol()==Symbol())
      {
         if(OrderType()==OP_BUY)
         {  new_sl=KijunSen;
             OrderMod=false;
             tries=0;
             
             while(!OrderMod && tries<oper_max_tries && new_sl>0)
            {  
               OrderMod=OrderModify(OrderTicket(),OrderOpenPrice(),new_sl,OrderTakeProfit(),0,NULL);
               Last_Modified=TimeCurrent();
               tries=tries+1;
            }
            
         }
         if(OrderType()==OP_SELL)
         {   new_sl=KijunSen;
             OrderMod=false;
             tries=0;
             
             while(!OrderMod && tries<oper_max_tries && new_sl>0)
            {  
               OrderMod=OrderModify(OrderTicket(),OrderOpenPrice(),new_sl,OrderTakeProfit(),0,NULL);
               Last_Modified=TimeCurrent();
               tries=tries+1;
            }
         
         }
         
      }
   }
}


//-----------------------------------------------------
void init()
{
}
int start()
{  
   KijunSen    = iIchimoku(Symbol(),0,9,26,52,MODE_KIJUNSEN,1);
   ChinkouSpan = iIchimoku(Symbol(),0,9,26,52,MODE_CHINKOUSPAN,26+1);
   SekouSpanA  = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANA,1);
   SekouSpanB  = iIchimoku(Symbol(),0,9,26,52,MODE_SENKOUSPANB,1);
   Long=False;
   Short=False;
   if(   Close[1]>KijunSen 
      && Close[1]>SekouSpanA
      && Close[1]>SekouSpanB
      && ChinkouSpan > Close[26]
      && (TimeCurrent()-prev_order_time)/60>ChartPeriod()
      )
      Long=True;
   if(   Close[1]<KijunSen 
      && Close[1]<SekouSpanA
      && Close[1]<SekouSpanB
      && ChinkouSpan < Close[26]
      && (TimeCurrent()-prev_order_time)/60>ChartPeriod()
      )
      Short=True;
      

   if(total_orders()==0
      && Long 
      )
      market_buy_order();
   
   if(total_orders()==0
      && Short 
      )
      market_sell_order();   
   if(total_orders()>0 && (TimeCurrent()-Last_Modified)/60 > ChartPeriod())
      trail_stop();
   return(1);
}

