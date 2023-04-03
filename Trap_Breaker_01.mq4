//----------------------------------------------------------------------------------------------------------------------------------
//--- Trap_Breaker_01.mq4 
//--- Copyright © 2015, Khalil Abokwaik. 
//----------------------------------------------------------------------------------------------------------------------------------
#property copyright "Copyright 2014, Khalil Abokwaik"
#property link "http://www.forexfactory.com/abokwaik"
#property description "Trap Breaker (Hedging Martingale)"
//----------------------------------------------------------------------------------------------------------------------------------
input int      Magic_Number         = 40040; // Magic Number
input int      Inner_Trap_Pips      = 100;   // Inner Trap in Pips
input int      Outer_Trap_Pips      = 900;   // Outer Trap in Pips
input int      Max_Orders           = 10;    // Max. number of Orders
input double   Profit_Bal_Perc      = 0.1;   // Close after Balance Prof %               
input double   Lot_Bal_Perc         = 0.1;   // First Order Size as Bal %   
input int      BE_After             = 5;     // Break Even after Order Num
input double   Max_DD_Perc          = 50;    // Max Balance Dradown Percentage
input int      FO_From_Hour         = 10;    // First Order Hour From  (0-23)
input int      FO_To_Hour           = 20;    // First Order Hour To (1-24)
input int      MA_Period            = 200;   // Moving Average Period (Filter)
input int      MA_Method            = 0;     // Moving Average Method (0:SMA, 1:EMA)
//----------------------------------------------------------------------------------------------------------------------------------
double   last_vol = 0.1;
int      last_oper = 0,buys,sells=0,buystops=0,sellstops=0;
int      spread;
double   sell_price = 0,buy_price  = 0;
int      min_lot_div = 1,prev_tot_orders=0;
double   tick_value=0;
double  last_order_lots=0,last_order_price=0;
int ord_arr[100];
bool OrderSelected=false,OrderClosed=false;
int oper_max_tries = 10,tries=0,curr_ord_type,r=0;
//----------------------------------------------------------------------------------------------------------------------------------
void delete_pending_orders()
{
   for(int j=0;j<OrdersTotal();j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if(OrderType()==OP_BUYSTOP || OrderType()==OP_SELLSTOP)
         {
            bool Ans=OrderDelete(OrderTicket());
          }
      }
   } // for
}


void open_first()
{     int ma=iMA(Symbol(),0,MA_Period,0,MA_Method,PRICE_CLOSE,1);

      int ticket=0;
      last_vol=AccountBalance()*(Lot_Bal_Perc/100)/MarketInfo(Symbol(),MODE_MARGINREQUIRED);
      last_vol = MathRound(last_vol * min_lot_div)/min_lot_div;
      last_vol = NormalizeDouble(last_vol,2);
      if(Close[1]>ma)
      {
          ticket=OrderSend(Symbol(),OP_BUY,last_vol,Ask,30,  0,  0,  "Trap_Break_01",Magic_Number,0,Blue);
      }
      else
      {
          ticket=OrderSend(Symbol(),OP_SELL,last_vol,Bid,30, 0,  0,  "Trap_Break_01",Magic_Number,0,Blue);
      }

      
}
double sell_vol()
{ double s_v=0;
         for(int i=0;i<OrdersTotal();i++)
         {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number
            && (OrderType()==OP_SELL || OrderType()==OP_SELLSTOP)) 
               s_v=s_v+OrderLots();
            if (OrderType()==OP_SELLSTOP)  
               last_vol=OrderLots();
         }
         return(s_v);
}
double buy_vol()
{ double b_v=0;
         for(int i=0;i<OrdersTotal();i++)
         {
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
            if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number
            && (OrderType()==OP_BUY || OrderType()==OP_BUYSTOP)) 
               b_v=b_v+OrderLots();
            if (OrderType()==OP_BUYSTOP) 
               last_vol=OrderLots();
         }
         return(b_v);
}


void init()
{
   spread=MarketInfo(Symbol(),MODE_SPREAD);
   min_lot_div=1/MarketInfo(Symbol(),MODE_MINLOT);
   tick_value=MarketInfo(Symbol(),MODE_TICKVALUE);  
}
void get_order_count_by_type()
{     buys=0;sells=0;buystops=0;sellstops=0;
      for(int i=0;i<OrdersTotal();i++)
      {
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
         if(OrderSymbol()==Symbol()&& OrderMagicNumber()==Magic_Number)
         {
            if(OrderType()==OP_BUY)       buys++;
            if(OrderType()==OP_SELL)      sells++;
            if(OrderType()==OP_BUYSTOP)   buystops++;
            if(OrderType()==OP_SELLSTOP)  sellstops++;
         }
      }
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

int last_order_type()
{ int ord_type=-1,tkt_num=0;
   last_order_lots=0; last_order_price=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==Magic_Number 
         && OrderSymbol()==Symbol()
         && (OrderType()==OP_BUY || OrderType()==OP_SELL)
         && OrderTicket()>tkt_num
        ) 
        {
            tkt_num=OrderTicket();
            ord_type = OrderType();
            last_order_lots=OrderLots();
            last_order_price=OrderOpenPrice();
        }
   }
   return(ord_type);
}
void close_current_orders_BY()
{ int k=-1,l=-1;
   bool x= false;
   double j_lots=0,l_lots=0;
   for(int j=0;j<10;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if( (OrderType()==OP_SELL || OrderType()==OP_BUY)   )
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {
      if(!OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES)) break;
      if(OrderType()==OP_SELL) break;
      j_lots= OrderLots();
      while(j_lots>0 && l<=k)
      { 
         for(l=0;l<=k;l++)
         {  
            if(!OrderSelect(ord_arr[l],SELECT_BY_TICKET,MODE_TRADES)) break;
            if(OrderType()==OP_BUY) continue;
            l_lots=OrderLots();
            j_lots = j_lots - l_lots;
            x=OrderCloseBy(ord_arr[j],ord_arr[l],Gray);
         }
       }
    }
}

void close_current_orders()
{ int k=-1;
   bool x= false;
   for(int j=0;j<10;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderSymbol()==Symbol() && OrderMagicNumber()==Magic_Number)
      {   
         if( (OrderType()==OP_SELL || OrderType()==OP_BUY)   )
         {  k = k + 1; 
            ord_arr[k]=OrderTicket();
         }
      }     
    }
    for(j=0;j<=k;j++)
    {  OrderClosed=false;
       tries=0;
       while(!OrderClosed && tries<oper_max_tries)
            {
               x=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               if(OrderType()==OP_SELL) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Ask,100,NULL);
               if(OrderType()==OP_BUY) OrderClosed=OrderClose(ord_arr[j],OrderLots(),Bid,100,NULL);
               tries=tries+1;
            }
    }
}


void start()
{
      int ticket=0;
      double SL = 0;
      double TP = 0;

      if
      (total_orders()<prev_tot_orders || (AccountEquity()-AccountBalance()) > AccountBalance()*(Profit_Bal_Perc/100)
         || (total_orders()>=BE_After && AccountEquity()-AccountBalance() >0) 
         || (AccountBalance()-AccountEquity())>((Max_DD_Perc/100)*AccountBalance()) 
      )
      { close_current_orders_BY();
        close_current_orders();
        delete_pending_orders();         
      }
      if (total_orders() == 0 && TimeHour(TimeCurrent()) >= FO_From_Hour && TimeHour(TimeCurrent()) <= FO_To_Hour)  open_first();
      else 
      if (total_orders() > 0)
      {
         get_order_count_by_type();
         if (buys+sells==0 && buystops+sellstops > 0   ) delete_pending_orders();         
         else
         if (buystops+sellstops==0 && buys+sells > 0 && total_orders()<Max_Orders)
          {
            if(last_order_type()==0) // last oper buy --> new oper Sell
            { 
                  sell_price = NormalizeDouble(last_order_price-(Inner_Trap_Pips*Point),Digits);
                  last_vol = (buy_vol() * (Outer_Trap_Pips) - sell_vol() * (Outer_Trap_Pips-Inner_Trap_Pips))/ (Outer_Trap_Pips-Inner_Trap_Pips);
                  last_vol = last_vol + (AccountBalance()*(Profit_Bal_Perc/100))/(tick_value*(Outer_Trap_Pips-Inner_Trap_Pips));            
                  last_vol = MathRound(last_vol * min_lot_div)/min_lot_div;
                  last_vol = NormalizeDouble(last_vol,2);
                  ticket=OrderSend(Symbol(),OP_SELLSTOP,last_vol,sell_price,30,0,0, "Trap_Break_01",Magic_Number,0,Red);
                  
            } 
            else 
            {
               if(last_order_type()==1) // last oper sell --> new oper Buy
               {                                   
                     buy_price = NormalizeDouble(last_order_price+(Inner_Trap_Pips*Point),Digits);
                     last_vol =(sell_vol()*(Outer_Trap_Pips) - buy_vol()*(Outer_Trap_Pips-Inner_Trap_Pips)) / (Outer_Trap_Pips-Inner_Trap_Pips);
                     last_vol = last_vol + (AccountBalance()*(Profit_Bal_Perc/100))/(tick_value*(Outer_Trap_Pips-Inner_Trap_Pips));            
                     last_vol = MathRound(last_vol * min_lot_div)/min_lot_div;
                     last_vol = NormalizeDouble(last_vol,2);
                     ticket=OrderSend(Symbol(),OP_BUYSTOP,last_vol,buy_price,30,0,0,"Trap_Break_01",Magic_Number,0,Blue);
                     
               } 
            }
          } 
      }
      prev_tot_orders=total_orders();
}

