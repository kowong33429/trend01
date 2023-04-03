//+------------------------------------------------------------------+
//|                                            Basket_Manager_03.mq4 |
//|                               Copyright © 2015, Khalil Abokwaik. |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Khalil Abokwaik"
#property link "http://www.forexfactory.com/abokwaik"
#property description "BASKET MANAGER - MANUAL TRADING - EA on a Basket Offline Chart"
#property description "Basket Chart must be created by Create_Basket_Script_03"
//-----------------------------
#include <stdlib.mqh>
#include <WinUser32.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
//#property strict
//--- input parameters

input int      Magic_Number             = 555;
input double   fixed_lot_size           = 0.01;
input double   Money_TP                 = 1000;
input double   Money_SL                 = 1000;
input bool     Money_Activated          = false;
input string   color_setup              = "Control Panel Colors Setup";
input color    Ask_Line_Color           = clrRed;
input color    Market_Order_Color       = clrGreen;
input color    Stop_Order_Color         = clrRoyalBlue;
input color    Limit_Order_Color        = clrPink;
input color    TP_Color                 = clrLimeGreen;
input color    SL_Color                 = clrOrangeRed;

//-----------
int oper_max_tries=10;
double basket_PL=0;
string basket_pairs="Pairs:",ma_text,mg_text,ls_text;
//--- buttons ---------------------------------------------------
string __btn_Market_Orders = "__btn_Market_Orders";
string __btn_Pending_Orders = "__btn_Pending_Orders";
string __btn_close_basket = "__btn_close_basket";

string __btn_buy_close_1 = "__btn_buy_close_1";
string __btn_buy_close_2 = "__btn_buy_close_2";
string __btn_buy_close_3 = "__btn_buy_close_3";
string __btn_sell_close_1 = "__btn_sell_close_1";
string __btn_sell_close_2 = "__btn_sell_close_2";
string __btn_sell_close_3 = "__btn_sell_close_3";



string __btn_buy_basket_1 = "__btn_buy_basket_1";
string __btn_basket_Buy_TP_1 = "__btn_basket_Buy_TP_1";
string __btn_basket_Buy_SL_1 = "__btn_basket_Buy_SL_1";
string __btn_sell_basket_1 = "__btn_sell_basket_1";
string __btn_basket_Sell_TP_1 = "__btn_basket_Sell_TP_1";
string __btn_basket_Sell_SL_1 = "__btn_basket_Sell_SL_1";
//---
string __btn_buy_basket_2 = "__btn_buy_basket_2";
string __btn_basket_Buy_TP_2 = "__btn_basket_Buy_TP_2";
string __btn_basket_Buy_SL_2 = "__btn_basket_Buy_SL_2";
string __btn_sell_basket_2 = "__btn_sell_basket_2";
string __btn_basket_Sell_TP_2 = "__btn_basket_Sell_TP_2";
string __btn_basket_Sell_SL_2 = "__btn_basket_Sell_SL_2";

//---
string __btn_buy_basket_3 = "__btn_buy_basket_3";
string __btn_basket_Buy_TP_3 = "__btn_basket_Buy_TP_3";
string __btn_basket_Buy_SL_3 = "__btn_basket_Buy_SL_3";
string __btn_sell_basket_3 = "__btn_sell_basket_3";
string __btn_basket_Sell_TP_3 = "__btn_basket_Sell_TP_3";
string __btn_basket_Sell_SL_3 = "__btn_basket_Sell_SL_3";

//---
string __btn_Act_Lines = "__btn_Act_Lines";

string __btn_buy_stop_1 = "__btn_buy_stop_1";
string __btn_buy_stop_TP_1 = "__btn_buy_stop_TP_1";
string __btn_buy_stop_SL_1 = "__btn_buy_stop_SL_1";

string __btn_sell_stop_1 = "__btn_sell_stop_1";
string __btn_sell_stop_TP_1 = "__btn_sell_stop_TP_1";
string __btn_sell_stop_SL_1 = "__btn_sell_stop_SL_1";

string __btn_buy_stop_2 = "__btn_buy_stop_2";
string __btn_buy_stop_TP_2 = "__btn_buy_stop_TP_2";
string __btn_buy_stop_SL_2 = "__btn_buy_stop_SL_2";

string __btn_sell_stop_2 = "__btn_sell_stop_2";
string __btn_sell_stop_TP_2 = "__btn_sell_stop_TP_2";
string __btn_sell_stop_SL_2 = "__btn_sell_stop_SL_2";

string __btn_buy_limit_1 = "__btn_buy_limit_1";
string __btn_buy_limit_TP_1 = "__btn_buy_limit_TP_1";
string __btn_buy_limit_SL_1 = "__btn_buy_limit_SL_1";
string __btn_sell_limit_1 = "__btn_sell_limit_1";
string __btn_sell_limit_TP_1 = "__btn_sell_limit_TP_1";
string __btn_sell_limit_SL_1 = "__btn_sell_limit_SL_1";

string __btn_buy_limit_2 = "__btn_buy_limit_2";
string __btn_buy_limit_TP_2 = "__btn_buy_limit_TP_2";
string __btn_buy_limit_SL_2 = "__btn_buy_limit_SL_2";
string __btn_sell_limit_2 = "__btn_sell_limit_2";
string __btn_sell_limit_TP_2 = "__btn_sell_limit_TP_2";
string __btn_sell_limit_SL_2 = "__btn_sell_limit_SL_2";

//----- lines ----------------------------------------------------
string __lin_basket_Ask = "__lin_basket_Ask";

string __lin_basket_Buy_1 = "__lin_basket_Buy_1";
string __lin_basket_Buy_TP_1 = "__lin_basket_Buy_TP_1";
string __lin_basket_Buy_SL_1 = "__lin_basket_Buy_SL_1";

string __lin_basket_Sell_1 = "__lin_basket_Sell_1";
string __lin_basket_Sell_TP_1 = "__lin_basket_Sell_TP_1";
string __lin_basket_Sell_SL_1 = "__lin_basket_Sell_SL_1";

string __lin_basket_Buy_2 = "__lin_basket_Buy_2";
string __lin_basket_Buy_TP_2 = "__lin_basket_Buy_TP_2";
string __lin_basket_Buy_SL_2 = "__lin_basket_Buy_SL_2";

string __lin_basket_Sell_2 = "__lin_basket_Sell_2";
string __lin_basket_Sell_TP_2 = "__lin_basket_Sell_TP_2";
string __lin_basket_Sell_SL_2 = "__lin_basket_Sell_SL_2";

string __lin_basket_Buy_3 = "__lin_basket_Buy_3";
string __lin_basket_Buy_TP_3 = "__lin_basket_Buy_TP_3";
string __lin_basket_Buy_SL_3 = "__lin_basket_Buy_SL_3";

string __lin_basket_Sell_3 = "__lin_basket_Sell_3";
string __lin_basket_Sell_TP_3 = "__lin_basket_Sell_TP_3";
string __lin_basket_Sell_SL_3 = "__lin_basket_Sell_SL_3";

//--------------
string __lin_buy_stop_1    = "__lin_buy_stop_1";
string __lin_buy_stop_TP_1 = "__lin_buy_stop_TP_1";
string __lin_buy_stop_SL_1 = "__lin_buy_stop_SL_1";
string __lin_buy_stop_2    = "__lin_buy_stop_2";
string __lin_buy_stop_TP_2 = "__lin_buy_stop_TP_2";
string __lin_buy_stop_SL_2 = "__lin_buy_stop_SL_2";

string __lin_sell_stop_1   = "__lin_sell_stop_1";
string __lin_sell_stop_TP_1= "__lin_sell_stop_TP_1";
string __lin_sell_stop_SL_1= "__lin_sell_stop_SL_1";
string __lin_sell_stop_2   = "__lin_sell_stop_2";
string __lin_sell_stop_TP_2= "__lin_sell_stop_TP_2";
string __lin_sell_stop_SL_2= "__lin_sell_stop_SL_2";

string __lin_buy_limit_1   = "__lin_buy_limit_1";
string __lin_buy_limit_TP_1= "__lin_buy_limit_TP_1";
string __lin_buy_limit_SL_1= "__lin_buy_limit_SL_1";
string __lin_buy_limit_2   = "__lin_buy_limit_2";
string __lin_buy_limit_TP_2= "__lin_buy_limit_TP_2";
string __lin_buy_limit_SL_2= "__lin_buy_limit_SL_2";

string __lin_sell_limit_1   = "__lin_sell_limit_1";
string __lin_sell_limit_TP_1= "__lin_sell_limit_TP_1";
string __lin_sell_limit_SL_1= "__lin_sell_limit_SL_1";
string __lin_sell_limit_2   = "__lin_sell_limit_2";
string __lin_sell_limit_TP_2= "__lin_sell_limit_TP_2";
string __lin_sell_limit_SL_2= "__lin_sell_limit_SL_2";


//---- text and labels ---------------------------------------------
string __Status_Line   = "__Status_Line";


//------------------------------------------------------------------
string pairs[];
double dw[];
double ls[];
string sep=",";                // A separator as a character
bool  stop_robot=false,action=false;
datetime last_time=0;
//ushort u_sep;                  // The code of the separator character
   //--- Get the separator code
ushort   u_sep=StringGetCharacter(sep,0);
int x = 0,sclr=0;
//----------------------------------------------------------
void init()
{
    BasketGetPairs();
    if(ObjectFind(0,__btn_Market_Orders)>=0)
    {
       if(ObjectGetInteger(0,__btn_Market_Orders,OBJPROP_STATE)==0)         draw_interface(); 
    }
    else draw_interface(); 
   //-- clear lines if no orders exist  -----------------------------------------------------------------------------------    
   clear_lines();
   

 if(!EventSetTimer(1)) Alert("Error in Creating Timer");;
 
 //start();
}
//----------------------------------------------------------
void OnTimer()
{  

      RefreshRates();
      //Comment(Magic_Number,",",basket_pairs, " PipValue = ",DoubleToStr(get_basket_pip_value(),2), " Spread=",DoubleToStr(get_spread(),1));
      Comment(Magic_Number," ", basket_pairs);//," DW :", dw, " LSM: ",ls);
      refresh();
      //-- Show Ask Line ---------------------------------------------------------------------------------------------------
      /*if(ObjectFind(0,__lin_basket_Ask)>=0) 
         ObjectSetDouble(0,__lin_basket_Ask,OBJPROP_PRICE,Close[0]+NormalizeDouble(get_spread()*Point,Digits));
      else 
         action=!HLineCreate(0,__lin_basket_Ask,0,Close[0]+NormalizeDouble(get_spread()*Point,Digits),Ask_Line_Color,0,1,false,false,false,0);     
      */
      if(market_orders()==0) 
      {  ObjectSetString(0,__btn_close_basket,OBJPROP_TEXT,"No Market Orders");         
         ObjectSetInteger(0,__btn_close_basket,OBJPROP_STATE,0);
      }
      //-- Update Order P/L Display ------------------------------------------------------------------------------------------
      update_order_PL_Display();
      //----------------------------------- 
      if(Money_Activated) check_money_SL_TP();
      if(ObjectGetInteger(0,__btn_Act_Lines,OBJPROP_COLOR)==clrWhite) 
      {  check_SL_TP();
         check_Pending_Orders();
      }
      //-- update status line
      if(ObjectFind(0,__Status_Line)>=0)
      {
         if(Money_Activated) 
               ma_text=StringConcatenate("Active Money TP= ",Money_TP," SL= ",Money_SL);
         else  ma_text="Money Targets Not Active";
         mg_text=StringConcatenate("Magic = ",Magic_Number);
         ls_text=StringConcatenate("Lot Size = ",fixed_lot_size);
         ObjectSetString(0,__Status_Line,OBJPROP_TEXT,0,StringConcatenate(mg_text," ",ls_text," ",ma_text));
      }

   return;
}
//----------------------------------------------------------
void deinit()
{
   EventKillTimer();
}
//----------------------------------------------------------
void draw_interface()
{
    if(ChartGetInteger(0,CHART_SHIFT)==0)
   {
      ChartSetInteger(0,CHART_SHIFT,1);
      ChartRedraw();
   }

   Create_Button(__btn_Market_Orders ,"Market Orders" ,121,20,1,150,25,clrSienna,clrWhite);

   Create_Button(__btn_buy_basket_1    ,"BUY"            ,60 ,20,1,150,46,clrRoyalBlue,clrWhite);
   Create_Button(__btn_basket_Buy_TP_1 ,"TP"             ,30 ,20,1,150,67,clrRoyalBlue,clrWhite);
   Create_Button(__btn_basket_Buy_SL_1 ,"SL"             ,29 ,20,1,119,67,clrRoyalBlue,clrWhite);   
   Create_Button(__btn_sell_basket_1   ,"SELL"           ,60 ,20,1,89 ,46,clrCrimson,clrWhite);

   Create_Button(__btn_basket_Sell_TP_1,"TP"             ,30 ,20,1,89 ,67,clrCrimson,clrWhite);
   Create_Button(__btn_basket_Sell_SL_1,"SL"             ,29 ,20,1,58 ,67,clrCrimson,clrWhite);   
   Create_Button(__btn_buy_close_1    ,"X"              ,20 ,20,1,170,46,clrWhite,clrBlack);
   Create_Button(__btn_sell_close_1    ,"X"              ,20 ,20,1,29,46,clrWhite,clrBlack);


//__btn_buy_close_1

//--
   Create_Button(__btn_buy_basket_2    ,"BUY"            ,60 ,20,1,150,90,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_close_2    ,"X"               ,20 ,20,1,170,90,clrWhite,clrBlack);
   Create_Button(__btn_basket_Buy_TP_2 ,"TP"             ,30 ,20,1,150,112,clrRoyalBlue,clrWhite);
   Create_Button(__btn_basket_Buy_SL_2 ,"SL"             ,29 ,20,1,119,112,clrRoyalBlue,clrWhite);   
   Create_Button(__btn_sell_basket_2   ,"SELL"           ,60 ,20,1,89 ,90,clrCrimson,clrWhite);
   Create_Button(__btn_sell_close_2    ,"X"              ,20 ,20,1,29,90,clrWhite,clrBlack);


   Create_Button(__btn_basket_Sell_TP_2,"TP"             ,30 ,20,1,89 ,112,clrCrimson,clrWhite);
   Create_Button(__btn_basket_Sell_SL_2,"SL"             ,29 ,20,1,58 ,112,clrCrimson,clrWhite);   

//--
   Create_Button(__btn_buy_basket_3    ,"BUY"            ,60 ,20,1,150,135,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_close_3    ,"X"              ,20 ,20,1,170,135,clrWhite,clrBlack);
   Create_Button(__btn_basket_Buy_TP_3 ,"TP"             ,30 ,20,1,150,156,clrRoyalBlue,clrWhite);
   Create_Button(__btn_basket_Buy_SL_3 ,"SL"             ,29 ,20,1,119,156,clrRoyalBlue,clrWhite);   
   Create_Button(__btn_sell_basket_3   ,"SELL"           ,60 ,20,1,89 ,135,clrCrimson,clrWhite);
   Create_Button(__btn_sell_close_3    ,"X"              ,20 ,20,1,29,135,clrWhite,clrBlack);
   Create_Button(__btn_basket_Sell_TP_3,"TP"             ,30 ,20,1,89 ,156,clrCrimson,clrWhite);
   Create_Button(__btn_basket_Sell_SL_3,"SL"             ,29 ,20,1,58 ,156,clrCrimson,clrWhite);   

   Create_Button(__btn_close_basket  ,"No Market Orders"  ,121,20,1,150,177,clrDarkGreen,clrWhite);   

//--
   Create_Button(__btn_Pending_Orders ,"Pending Orders" ,121,20,1,150,200,clrSienna,clrWhite);
//--

   Create_Button(__btn_buy_stop_1      ,"Buy Stop"       ,60 ,20,1,150,221,clrRoyalBlue,clrWhite);         
   Create_Button(__btn_buy_stop_TP_1   ,"TP"             ,30 ,20,1,150,242,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_stop_SL_1   ,"SL"             ,29 ,20,1,119,242,clrRoyalBlue,clrWhite);   

   Create_Button(__btn_sell_stop_1     ,"Sell Stop"      ,60 ,20,1,89 ,221,clrCrimson,clrWhite);         
   Create_Button(__btn_sell_stop_TP_1,"TP"               ,30 ,20,1,89 ,242,clrCrimson,clrWhite);
   Create_Button(__btn_sell_stop_SL_1,"SL"               ,29 ,20,1,58 ,242,clrCrimson,clrWhite);   

   Create_Button(__btn_buy_stop_2      ,"Buy Stop"       ,60 ,20,1,150,263,clrRoyalBlue,clrWhite);         
   Create_Button(__btn_buy_stop_TP_2   ,"TP"             ,30 ,20,1,150,284,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_stop_SL_2   ,"SL"             ,29 ,20,1,119,284,clrRoyalBlue,clrWhite);   

   Create_Button(__btn_sell_stop_2     ,"Sell Stop"      ,60 ,20,1,89 ,263,clrCrimson,clrWhite);         
   Create_Button(__btn_sell_stop_TP_2,"TP"               ,30 ,20,1,89 ,284,clrCrimson,clrWhite);
   Create_Button(__btn_sell_stop_SL_2,"SL"               ,29 ,20,1,58 ,284,clrCrimson,clrWhite);   

   Create_Button(__btn_buy_limit_1     ,"Buy Limit"      ,60 ,20,1,150,306,clrRoyalBlue,clrWhite);         
   Create_Button(__btn_buy_limit_TP_1   ,"TP"             ,30 ,20,1,150,327,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_limit_SL_1   ,"SL"             ,29 ,20,1,119,327,clrRoyalBlue,clrWhite);   

   Create_Button(__btn_sell_limit_1    ,"Sell Limit"     ,60 ,20,1,89 ,306,clrCrimson,clrWhite);         
   Create_Button(__btn_sell_limit_TP_1,"TP"               ,30 ,20,1,89 ,327,clrCrimson,clrWhite);
   Create_Button(__btn_sell_limit_SL_1,"SL"               ,29 ,20,1,58 ,327,clrCrimson,clrWhite);   

   Create_Button(__btn_buy_limit_2     ,"Buy Limit"      ,60 ,20,1,150,348,clrRoyalBlue,clrWhite);         
   Create_Button(__btn_buy_limit_TP_2   ,"TP"             ,30 ,20,1,150,369,clrRoyalBlue,clrWhite);
   Create_Button(__btn_buy_limit_SL_2   ,"SL"             ,29 ,20,1,119,369,clrRoyalBlue,clrWhite);   

   Create_Button(__btn_sell_limit_2    ,"Sell Limit"     ,60 ,20,1,89 ,348,clrCrimson,clrWhite);         
   Create_Button(__btn_sell_limit_TP_2,"TP"               ,30 ,20,1,89 ,369,clrCrimson,clrWhite);
   Create_Button(__btn_sell_limit_SL_2,"SL"               ,29 ,20,1,58 ,369,clrCrimson,clrWhite);   


   Create_Button(__btn_Act_Lines       ,"Lines De-Activated" ,121,20,1,150,392,clrCadetBlue,clrBlue);      

   
   Create_Label(__Status_Line,"*** Status Line ***",500,20,4,300,0,clrBlack,clrYellow,8);
   //,500,20,5,5,5,clrBlue,clrWhite);         
   
}

//----------------------------------------------------------

void OnChartEvent(const int id,  const long &lparam, const double &dparam,  const string &sparam)
  {
   double price_shift=0;
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      price_shift=NormalizeDouble((ChartGetDouble(0,CHART_PRICE_MAX)-ChartGetDouble(0,CHART_PRICE_MIN))/10,4);
      if(sparam==__btn_Market_Orders)
        {   if(ObjectFind(0,__btn_buy_basket_1)<0) draw_interface();
            else delete_buttons();
        }
      //-- Market Orders -----------------------------------------------------------------------
      if(sparam==__btn_buy_basket_1)  Change_Button_Status(__btn_buy_basket_1 ,OP_BUY ,Magic_Number*100+01,__lin_basket_Buy_1);      
      if(sparam==__btn_sell_basket_1) Change_Button_Status(__btn_sell_basket_1,OP_SELL,Magic_Number*100+11,__lin_basket_Sell_1);
      if(sparam==__btn_buy_basket_2)  Change_Button_Status(__btn_buy_basket_2 ,OP_BUY ,Magic_Number*100+02,__lin_basket_Buy_2);      
      if(sparam==__btn_sell_basket_2) Change_Button_Status(__btn_sell_basket_2,OP_SELL,Magic_Number*100+12,__lin_basket_Sell_2);
      if(sparam==__btn_buy_basket_3)  Change_Button_Status(__btn_buy_basket_3 ,OP_BUY ,Magic_Number*100+03,__lin_basket_Buy_3);      
      if(sparam==__btn_sell_basket_3) Change_Button_Status(__btn_sell_basket_3,OP_SELL,Magic_Number*100+13,__lin_basket_Sell_3);
      //--- close check box --------------
      if(sparam==__btn_buy_close_1)    close_order(__btn_buy_basket_1 ,OP_BUY ,Magic_Number*100+01,__lin_basket_Buy_1);      
      if(sparam==__btn_buy_close_2)    close_order(__btn_buy_basket_2 ,OP_BUY ,Magic_Number*100+02,__lin_basket_Buy_2);      
      if(sparam==__btn_buy_close_3)    close_order(__btn_buy_basket_3 ,OP_BUY ,Magic_Number*100+03,__lin_basket_Buy_3);      
      if(sparam==__btn_sell_close_1)   close_order(__btn_sell_basket_1,OP_SELL,Magic_Number*100+11,__lin_basket_Sell_1);
      if(sparam==__btn_sell_close_2)   close_order(__btn_sell_basket_2,OP_SELL,Magic_Number*100+12,__lin_basket_Sell_2);
      if(sparam==__btn_sell_close_3)   close_order(__btn_sell_basket_3,OP_SELL,Magic_Number*100+13,__lin_basket_Sell_3);
      
      //-------------------Markert Orders SL/TP _ 1
      if(sparam==__btn_basket_Buy_SL_1 && ObjectGetString(0,__btn_buy_basket_1,OBJPROP_TEXT)!="BUY")
        {  if(ObjectFind(0,__lin_basket_Buy_SL_1)!=0) action=!HLineCreate(0,__lin_basket_Buy_SL_1,0,Close[0]-price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_SL_1);  
            ChartRedraw();      
        }
      if(sparam==__btn_basket_Buy_TP_1 && ObjectGetString(0,__btn_buy_basket_1,OBJPROP_TEXT)!="BUY")
        {   if(ObjectFind(0,__lin_basket_Buy_TP_1)!=0)  action=!HLineCreate(0,__lin_basket_Buy_TP_1,0,Close[0]+price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_TP_1);  
            ChartRedraw();                  
        }

      if(sparam==__btn_basket_Sell_SL_1 && ObjectGetString(0,__btn_sell_basket_1,OBJPROP_TEXT)!="SELL")
        {   if(ObjectFind(0,__lin_basket_Sell_SL_1)!=0) action=!HLineCreate(0,__lin_basket_Sell_SL_1,0,Close[0]+price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_SL_1);  
            ChartRedraw();                  
        }
      if(sparam==__btn_basket_Sell_TP_1 && ObjectGetString(0,__btn_sell_basket_1,OBJPROP_TEXT)!="SELL")
        {  if(ObjectFind(0,__lin_basket_Sell_TP_1)!=0) action=!HLineCreate(0,__lin_basket_Sell_TP_1,0,Close[0]-price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_TP_1);  
            ChartRedraw();                  
        }
      //------------------- Markert Orders SL/TP _ 2
      if(sparam==__btn_basket_Buy_SL_2 && ObjectGetString(0,__btn_buy_basket_2,OBJPROP_TEXT)!="BUY")
        {  if(ObjectFind(0,__lin_basket_Buy_SL_2)!=0) action=!HLineCreate(0,__lin_basket_Buy_SL_2,0,Close[0]-price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_SL_2);  
            ChartRedraw();      
        }
      if(sparam==__btn_basket_Buy_TP_2 && ObjectGetString(0,__btn_buy_basket_2,OBJPROP_TEXT)!="BUY")
        {   if(ObjectFind(0,__lin_basket_Buy_TP_2)!=0)  action=!HLineCreate(0,__lin_basket_Buy_TP_2,0,Close[0]+price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_TP_2);  
            ChartRedraw();                  
        }

      if(sparam==__btn_basket_Sell_SL_2 && ObjectGetString(0,__btn_sell_basket_2,OBJPROP_TEXT)!="SELL")
        {   if(ObjectFind(0,__lin_basket_Sell_SL_2)!=0) action=!HLineCreate(0,__lin_basket_Sell_SL_2,0,Close[0]+price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_SL_2);  
            ChartRedraw();                  
        }
      if(sparam==__btn_basket_Sell_TP_2 && ObjectGetString(0,__btn_sell_basket_2,OBJPROP_TEXT)!="SELL")
        {  if(ObjectFind(0,__lin_basket_Sell_TP_2)!=0) action=!HLineCreate(0,__lin_basket_Sell_TP_2,0,Close[0]-price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_TP_2);  
            ChartRedraw();                  
        }
      //------------------- Markert Orders SL/TP _ 3
      if(sparam==__btn_basket_Buy_SL_3 && ObjectGetString(0,__btn_buy_basket_3,OBJPROP_TEXT)!="BUY")
        {  if(ObjectFind(0,__lin_basket_Buy_SL_3)!=0) action=!HLineCreate(0,__lin_basket_Buy_SL_3,0,Close[0]-price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_SL_3);  
            ChartRedraw();      
        }
      if(sparam==__btn_basket_Buy_TP_3 && ObjectGetString(0,__btn_buy_basket_3,OBJPROP_TEXT)!="BUY")
        {   if(ObjectFind(0,__lin_basket_Buy_TP_3)!=0)  action=!HLineCreate(0,__lin_basket_Buy_TP_3,0,Close[0]+price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Buy_TP_3);  
            ChartRedraw();                  
        }

      if(sparam==__btn_basket_Sell_SL_3 && ObjectGetString(0,__btn_sell_basket_3,OBJPROP_TEXT)!="SELL")
        {   if(ObjectFind(0,__lin_basket_Sell_SL_3)!=0) action=!HLineCreate(0,__lin_basket_Sell_SL_3,0,Close[0]+price_shift,SL_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_SL_3);  
            ChartRedraw();                  
        }
      if(sparam==__btn_basket_Sell_TP_3 && ObjectGetString(0,__btn_sell_basket_3,OBJPROP_TEXT)!="SELL")
        {  if(ObjectFind(0,__lin_basket_Sell_TP_3)!=0) action=!HLineCreate(0,__lin_basket_Sell_TP_3,0,Close[0]-price_shift,TP_Color,1,1,true,true,false,0);
            else   ObjectDelete(__lin_basket_Sell_TP_3);  
            ChartRedraw();                  
        }

      //-- Close Basket -----------------------------------------------------------------------
      if(sparam==__btn_close_basket)
        {   ObjectSetString(0,__btn_close_basket,OBJPROP_TEXT,"Closing...");
            Change_Button_Status_ALL(__btn_buy_basket_1 ,OP_BUY ,Magic_Number*100+01,__lin_basket_Buy_1);      
            Change_Button_Status_ALL(__btn_sell_basket_1,OP_SELL,Magic_Number*100+11,__lin_basket_Sell_1);
            Change_Button_Status_ALL(__btn_buy_basket_2 ,OP_BUY ,Magic_Number*100+02,__lin_basket_Buy_2);      
            Change_Button_Status_ALL(__btn_sell_basket_2,OP_SELL,Magic_Number*100+12,__lin_basket_Sell_2);
            Change_Button_Status_ALL(__btn_buy_basket_3 ,OP_BUY ,Magic_Number*100+03,__lin_basket_Buy_3);      
            Change_Button_Status_ALL(__btn_sell_basket_3,OP_SELL,Magic_Number*100+13,__lin_basket_Sell_3);
            ObjectSetInteger(0,__btn_close_basket,OBJPROP_STATE,0);
            ObjectSetString(0,__btn_close_basket,OBJPROP_TEXT,"No Market Orders");         
        }
      //-- Pending Orders :Stop Orders -----------------------------------------------------------------------
      if(sparam==__btn_buy_stop_1)
        {   if(ObjectFind(0,__lin_buy_stop_1)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_1,0,Close[0]+price_shift,Stop_Order_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_1,OBJPROP_TEXT,StringConcatenate("1st Buy Stop ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_buy_stop_1);  
               ObjectDelete(__lin_buy_stop_TP_1);  
               ObjectDelete(__lin_buy_stop_SL_1);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_buy_stop_TP_1 && ObjectFind(0,__lin_buy_stop_1) >=0)
        {   if(ObjectFind(0,__lin_buy_stop_TP_1)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_TP_1,0,ObjectGetDouble(0,__lin_buy_stop_1,OBJPROP_PRICE)+price_shift,
              TP_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_TP_1,OBJPROP_TEXT,StringConcatenate("1st Buy Stop TP"));
            }
            else   ObjectDelete(__lin_buy_stop_TP_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_stop_SL_1 && ObjectFind(0,__lin_buy_stop_1) >=0)
        {   if(ObjectFind(0,__lin_buy_stop_SL_1)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_SL_1,0,ObjectGetDouble(0,__lin_buy_stop_1,OBJPROP_PRICE)-price_shift,
              SL_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_SL_1,OBJPROP_TEXT,StringConcatenate("1st Buy Stop SL"));
            }
            else   ObjectDelete(__lin_buy_stop_SL_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_stop_2)
        {   if(ObjectFind(0,__lin_buy_stop_2)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_2,0,Close[0]+price_shift,Stop_Order_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_2,OBJPROP_TEXT,StringConcatenate("2nd Buy Stop ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_buy_stop_2);  
               ObjectDelete(__lin_buy_stop_TP_2);  
               ObjectDelete(__lin_buy_stop_SL_2);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_buy_stop_TP_2 && ObjectFind(0,__lin_buy_stop_2) >=0)
        {   if(ObjectFind(0,__lin_buy_stop_TP_2)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_TP_2,0,ObjectGetDouble(0,__lin_buy_stop_2,OBJPROP_PRICE)+price_shift,
              TP_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_TP_2,OBJPROP_TEXT,StringConcatenate("2nd Buy Stop TP"));
            }
            else   ObjectDelete(__lin_buy_stop_TP_2);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_stop_SL_2 && ObjectFind(0,__lin_buy_stop_2) >=0)
        {   if(ObjectFind(0,__lin_buy_stop_SL_2)!=0) 
            { action=HLineCreate(0,__lin_buy_stop_SL_2,0,ObjectGetDouble(0,__lin_buy_stop_2,OBJPROP_PRICE)-price_shift,
              SL_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_stop_SL_2,OBJPROP_TEXT,StringConcatenate("2nd Buy Stop SL"));
            }
            else   ObjectDelete(__lin_buy_stop_SL_2);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_stop_1)
        {   if(ObjectFind(0,__lin_sell_stop_1)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_1,0,Close[0]-price_shift,Stop_Order_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_1,OBJPROP_TEXT,StringConcatenate("1st Sell Stop ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_sell_stop_1);  
               ObjectDelete(__lin_sell_stop_TP_1);  
               ObjectDelete(__lin_sell_stop_SL_1);  
            }
            ChartRedraw();    
        }
      if(sparam==__btn_sell_stop_TP_1 && ObjectFind(0,__lin_sell_stop_1) >=0)
        {   if(ObjectFind(0,__lin_sell_stop_TP_1)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_TP_1,0,ObjectGetDouble(0,__lin_sell_stop_1,OBJPROP_PRICE)-price_shift,
              TP_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_TP_1,OBJPROP_TEXT,StringConcatenate("1st Sell Buy Stop TP"));
            }
            else   ObjectDelete(__lin_sell_stop_TP_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_stop_SL_1 && ObjectFind(0,__lin_sell_stop_1) >=0)
        {   if(ObjectFind(0,__lin_sell_stop_SL_1)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_SL_1,0,ObjectGetDouble(0,__lin_sell_stop_1,OBJPROP_PRICE)+price_shift,
              SL_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_SL_1,OBJPROP_TEXT,StringConcatenate("1st Sell Stop SL"));
            }
            else   ObjectDelete(__lin_sell_stop_SL_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_stop_2)
        {   if(ObjectFind(0,__lin_sell_stop_2)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_2,0,Close[0]-price_shift,Stop_Order_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Stop ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_sell_stop_2);  
               ObjectDelete(__lin_sell_stop_TP_2);  
               ObjectDelete(__lin_sell_stop_SL_2);  
            }
            ChartRedraw();    
        }
      if(sparam==__btn_sell_stop_TP_2 && ObjectFind(0,__lin_sell_stop_2) >=0)
        {   if(ObjectFind(0,__lin_sell_stop_TP_2)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_TP_2,0,ObjectGetDouble(0,__lin_sell_stop_2,OBJPROP_PRICE)-price_shift,
              TP_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_TP_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Stop TP"));
            }
            else   ObjectDelete(__lin_sell_stop_TP_2);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_stop_SL_2 && ObjectFind(0,__lin_sell_stop_2) >=0)
        {   if(ObjectFind(0,__lin_sell_stop_SL_2)!=0) 
            { action=HLineCreate(0,__lin_sell_stop_SL_2,0,ObjectGetDouble(0,__lin_sell_stop_2,OBJPROP_PRICE)+price_shift,
              SL_Color,1,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_stop_SL_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Stop SL"));
            }
            else   ObjectDelete(__lin_sell_stop_SL_2);  
            ChartRedraw();      
        }
      //-- Pending Orders :Limit Orders -----------------------------------------------------------------------
      if(sparam==__btn_buy_limit_1)
        {   if(ObjectFind(0,__lin_buy_limit_1)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_1,0,Close[0]-price_shift,Limit_Order_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_1,OBJPROP_TEXT,StringConcatenate("1st Buy Limit ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_buy_limit_1);  
               ObjectDelete(__lin_buy_limit_TP_1);  
               ObjectDelete(__lin_buy_limit_SL_1);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_buy_limit_TP_1 && ObjectFind(0,__lin_buy_limit_1) >=0)
        {   if(ObjectFind(0,__lin_buy_limit_TP_1)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_TP_1,0,ObjectGetDouble(0,__lin_buy_limit_1,OBJPROP_PRICE)+price_shift,
              TP_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_TP_1,OBJPROP_TEXT,StringConcatenate("1st Buy Limit TP"));
            }
            else   ObjectDelete(__lin_buy_limit_TP_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_limit_SL_1 && ObjectFind(0,__lin_buy_limit_1) >=0)
        {   if(ObjectFind(0,__lin_buy_limit_SL_1)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_SL_1,0,ObjectGetDouble(0,__lin_buy_limit_1,OBJPROP_PRICE)-price_shift,
              SL_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_SL_1,OBJPROP_TEXT,StringConcatenate("1st Buy Limit SL"));
            }
            else   ObjectDelete(__lin_buy_limit_SL_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_limit_2)
        {   if(ObjectFind(0,__lin_buy_limit_2)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_2,0,Close[0]-price_shift,Limit_Order_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_2,OBJPROP_TEXT,StringConcatenate("2ndt Buy Limit ",fixed_lot_size));
            }
            else   
            {
               ObjectDelete(__lin_buy_limit_2);  
               ObjectDelete(__lin_buy_limit_TP_2);  
               ObjectDelete(__lin_buy_limit_SL_2);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_buy_limit_TP_2 && ObjectFind(0,__lin_buy_limit_2) >=0)
        {   if(ObjectFind(0,__lin_buy_limit_TP_2)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_TP_2,0,ObjectGetDouble(0,__lin_buy_limit_2,OBJPROP_PRICE)+price_shift,
              TP_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_TP_2,OBJPROP_TEXT,StringConcatenate("1st Buy Limit TP"));
            }
            else   ObjectDelete(__lin_buy_limit_TP_2);  
            ChartRedraw();      
        }

      if(sparam==__btn_buy_limit_SL_2 && ObjectFind(0,__lin_buy_limit_2) >=0)
        {   if(ObjectFind(0,__lin_buy_limit_SL_2)!=0) 
            { action=HLineCreate(0,__lin_buy_limit_SL_2,0,ObjectGetDouble(0,__lin_buy_limit_2,OBJPROP_PRICE)-price_shift,
              SL_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_buy_limit_SL_2,OBJPROP_TEXT,StringConcatenate("1st Buy Limit SL"));
            }
            else   ObjectDelete(__lin_buy_limit_SL_2);  
            ChartRedraw();      
        }
      
      if(sparam==__btn_sell_limit_1)
        {   if(ObjectFind(0,__lin_sell_limit_1)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_1,0,Close[0]+price_shift,Limit_Order_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_1,OBJPROP_TEXT,StringConcatenate("1st Sell Limit ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_sell_limit_1);  
               ObjectDelete(__lin_sell_limit_TP_1);  
               ObjectDelete(__lin_sell_limit_SL_1);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_sell_limit_TP_1 && ObjectFind(0,__lin_sell_limit_1) >=0)
        {   if(ObjectFind(0,__lin_sell_limit_TP_1)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_TP_1,0,ObjectGetDouble(0,__lin_sell_limit_1,OBJPROP_PRICE)-price_shift,
              TP_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_TP_1,OBJPROP_TEXT,StringConcatenate("1st Sell Limit TP"));
            }
            else   ObjectDelete(__lin_sell_limit_TP_1);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_limit_SL_1 && ObjectFind(0,__lin_sell_limit_1) >=0)
        {   if(ObjectFind(0,__lin_sell_limit_SL_1)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_SL_1,0,ObjectGetDouble(0,__lin_sell_limit_1,OBJPROP_PRICE)+price_shift,
              SL_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_SL_1,OBJPROP_TEXT,StringConcatenate("1st Sell Limit SL"));
            }
            else   ObjectDelete(__lin_sell_limit_SL_1);  
            ChartRedraw();      
        }
      if(sparam==__btn_sell_limit_2)
        {   if(ObjectFind(0,__lin_sell_limit_2)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_2,0,Close[0]+price_shift,Limit_Order_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Limit ",fixed_lot_size));
            }
            else   
            {  ObjectDelete(__lin_sell_limit_2);  
               ObjectDelete(__lin_sell_limit_TP_2);  
               ObjectDelete(__lin_sell_limit_SL_2);  
            }
            ChartRedraw();      
        }
      if(sparam==__btn_sell_limit_TP_2 && ObjectFind(0,__lin_sell_limit_2) >=0)
        {   if(ObjectFind(0,__lin_sell_limit_TP_2)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_TP_2,0,ObjectGetDouble(0,__lin_sell_limit_2,OBJPROP_PRICE)-price_shift,
              TP_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_TP_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Limit TP"));
            }
            else   ObjectDelete(__lin_sell_limit_TP_2);  
            ChartRedraw();      
        }

      if(sparam==__btn_sell_limit_SL_2 && ObjectFind(0,__lin_sell_limit_2) >=0)
        {   if(ObjectFind(0,__lin_sell_limit_SL_2)!=0) 
            { action=HLineCreate(0,__lin_sell_limit_SL_2,0,ObjectGetDouble(0,__lin_sell_limit_2,OBJPROP_PRICE)+price_shift,
              SL_Color,4,1,true,true,false,0);
              if(action)ObjectSetString(0,__lin_sell_limit_SL_2,OBJPROP_TEXT,StringConcatenate("2nd Sell Limit SL"));
            }
            else   ObjectDelete(__lin_sell_limit_SL_2);  
            ChartRedraw();      
        }


//-----------------------
      if(sparam==__btn_Act_Lines)
        {
               if (ObjectGetInteger(0,__btn_Act_Lines,OBJPROP_COLOR)==clrWhite) 
               {
                  ObjectSetString(0,__btn_Act_Lines,OBJPROP_TEXT,"Lines De-Activated");
                  ObjectSetInteger(0,__btn_Act_Lines,OBJPROP_BGCOLOR,CadetBlue);
                  ObjectSetInteger(0,__btn_Act_Lines,OBJPROP_COLOR,clrBlue);
               }
               else 
               {
                  ObjectSetString(0,__btn_Act_Lines,OBJPROP_TEXT,"Lines Activated");
                  ObjectSetInteger(0,__btn_Act_Lines,OBJPROP_BGCOLOR,Purple);
                  ObjectSetInteger(0,__btn_Act_Lines,OBJPROP_COLOR,clrWhite);                  
               }        
        }
//-----------------------


     }
//--- re-draw property values
   ChartRedraw();
  }
void sell_basket(int magic_number,string line_name)
{  int tries=0,ord_sent=-1;
   if(ObjectFind(line_name)>=0) return;
   for(int j=0;j<ArraySize(pairs);j++)
   {
      tries=0;ord_sent=-1;
      while(ord_sent<0 && tries<oper_max_tries)
      {
         if(dw[j]<0)
            ord_sent=OrderSend(pairs[j],OP_BUY,lot_size(j),MarketInfo(pairs[j],MODE_ASK),100,0,0,"BM03",magic_number,0,clrBlue);
         else
            ord_sent=OrderSend(pairs[j],OP_SELL,lot_size(j),MarketInfo(pairs[j],MODE_BID),100,0,0,"BM03",magic_number,0,clrRed);
         tries=tries+1;
      }
   }
   if(ord_sent>=0) 
   {
      if(ObjectFind(line_name)<0)
   {  if(!HLineCreate(0,line_name,0,Close[0],Market_Order_Color,3,1,true,false,false,0))
        { Print(__FUNCTION__, ": failed. Error code = ",GetLastError());           return; }  
      ChartRedraw();      
   }

   }
}
double lot_size(int pair)
{
   double lot_sz=0;
   lot_sz=fixed_lot_size*ls[pair];
   return(lot_sz);
}
void buy_basket(int magic_number,string line_name)
{  int tries=0,ord_sent=-1;
   if(ObjectFind(line_name)>=0) return;
   for(int j=0;j<ArraySize(pairs);j++)
   {
      tries=0;ord_sent=-1;
      while(ord_sent<0 && tries<oper_max_tries)
      {
         if(dw[j]<0)   
            ord_sent=OrderSend(pairs[j],OP_SELL,lot_size(j),MarketInfo(pairs[j],MODE_BID),100,0,0,"BM03",magic_number,0,clrRed);
         else
            ord_sent=OrderSend(pairs[j],OP_BUY,lot_size(j),MarketInfo(pairs[j],MODE_ASK),100,0,0,"BM03",magic_number,0,clrBlue);
         tries=tries+1;
         
      }
   }
   if(ord_sent>=0)
   {
      if(ObjectFind(line_name)<0)
      {  if(!HLineCreate(0,line_name,0,Close[0],Market_Order_Color,3,1,true,false,false,0))
           { Print(__FUNCTION__, ": failed. Error code = ",GetLastError());           return; }  }
      ChartRedraw();      
   
   }
}

void BasketGetPairs()
{
   basket_pairs = "";
   string chart_comment="";  
   int as=0,p=0,w=0;   
   int k=0;
   string comm[];
   long currChart,prevChart=ChartFirst();
   int i=1,limit=100;
   while(i<limit)// We have certainly not more than 100 open charts
     {
      if(currChart<0) break;          // Have reached the end of the chart list
      chart_comment = ChartGetString(currChart,CHART_COMMENT);
      StringSplit(chart_comment,u_sep,comm);
      if(comm[0]==Symbol())
      {
         as=ArraySize(comm);
         p=(as-1)/3;
         ArrayResize(pairs,p);
         ArrayResize(dw,p);
         ArrayResize(ls,p);
         for(k=0;k<p;k++)
         {
            pairs[k]=comm[k+1];
            basket_pairs=StringConcatenate(basket_pairs," ",pairs[k]);
         }
         Comment(basket_pairs);
         w=0;
         for(k=p+1;k<as;k++)
         {
            dw[w]=StrToDouble(comm[k]);
            w=w+1;
         }
         w=0;
         for(k=2*p+1;k<as;k++)
         {
            ls[w]=StrToDouble(comm[k]);
            w=w+1;
         }

         break;
      }
      prevChart=currChart;// let's save the current chart ID for the ChartNext()
      currChart=ChartNext(prevChart); // Get the new chart ID by using the previous chart ID
      i++;// Do not forget to increase the counter
     }
}
void close_basket(int magic_number,string line_name)
{ int k=-1,j=0,tries=0,error_code=0,ord_arr[100];
   bool order_found= false,OrderClosed=false;
   for(j=0;j<500;j++) ord_arr[j]=0;
   
   int ot = OrdersTotal();
   for(j=0;j<ot;j++)
   {
      if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)==false) break;
      {   
         if( (OrderType()==OP_SELL || OrderType()==OP_BUY)   && OrderMagicNumber()==magic_number)
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
               order_found=OrderSelect(ord_arr[j],SELECT_BY_TICKET,MODE_TRADES);
               if(OrderType()==OP_SELL && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),MarketInfo(OrderSymbol(),MODE_ASK),100,Pink);
               if(OrderType()==OP_BUY && order_found) OrderClosed=OrderClose(ord_arr[j],OrderLots(),MarketInfo(OrderSymbol(),MODE_BID),100,Pink);
               if(order_found && !OrderClosed)
               {
                  error_code=GetLastError();
                  if(error_code!=ERR_NO_ERROR) 
                  {  //Alert("Order Close Error: ",ErrorDescription(error_code));
                     Print("Order Close Error: ",ErrorDescription(error_code));
                  }
               }               
               tries=tries+1;
            }
    }
    if(OrderClosed) ObjectDelete(0,line_name);
}

//--------------------
bool HLineCreate(const long chart_ID=0, const string name="HLine", const int sub_window=0,double price=0,
                 const color clr=clrRed, const ENUM_LINE_STYLE style=STYLE_SOLID,const int       width=1,
                 const bool back=false, const bool selection=true, const bool hidden=true,const long z_order=0)
  {
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   //ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }

void Create_Button(string but_name,string label,int xsize,int ysize,int corner,int xdist,int ydist,int bcolor,int fcolor)
{
   if(ObjectFind(0,but_name)<0)
   {
      if(!ObjectCreate(0,but_name,OBJ_BUTTON,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the button! Error code = ",GetLastError());
         return;
        }
      ObjectSetString(0,but_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,but_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,but_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,but_name,OBJPROP_CORNER,corner);     
      ObjectSetInteger(0,but_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,but_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,but_name,OBJPROP_BGCOLOR,bcolor);
      ObjectSetInteger(0,but_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,but_name,OBJPROP_FONTSIZE,9);
      ObjectSetInteger(0,but_name,OBJPROP_HIDDEN,true);
      //ObjectSetInteger(0,but_name,OBJPROP_BORDER_COLOR,ChartGetInteger(0,CHART_COLOR_FOREGROUND));
      ObjectSetInteger(0,but_name,OBJPROP_BORDER_TYPE,BORDER_RAISED);
      
      ChartRedraw();      
   }

}

void Create_Label(string lbl_name,string label,int xsize,int ysize,int corner,int xdist,int ydist,int bcolor,int fcolor,int font_size)
{
   if(ObjectFind(0,lbl_name)<0)
   {
      if(!ObjectCreate(0,lbl_name,OBJ_LABEL,0,0,0))
        {
         Print(__FUNCTION__,
               ": failed to create the LABEL! Error code = ",GetLastError());
         return;
        }

      ObjectSetString(0,lbl_name,OBJPROP_TEXT,label);
      ObjectSetInteger(0,lbl_name,OBJPROP_XSIZE,xsize);
      ObjectSetInteger(0,lbl_name,OBJPROP_YSIZE,ysize);
      ObjectSetInteger(0,lbl_name,OBJPROP_CORNER,corner);     
      ObjectSetInteger(0,lbl_name,OBJPROP_XDISTANCE,xdist);      
      ObjectSetInteger(0,lbl_name,OBJPROP_YDISTANCE,ydist);         
      ObjectSetInteger(0,lbl_name,OBJPROP_COLOR,fcolor);
      ObjectSetInteger(0,lbl_name,OBJPROP_FONTSIZE,font_size);
      ChartRedraw();      
   }

}
void close_order(string button_name,int button_type,int magic_num,string line_name)
{
   if(button_type==OP_BUY)
   {
      ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
      close_basket(magic_num,line_name);
      ObjectSetString(0,button_name,OBJPROP_TEXT,"BUY");
   }
   if(button_type==OP_SELL)
   {
         ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
         close_basket(magic_num,line_name);
         ObjectSetString(0,button_name,OBJPROP_TEXT,"SELL");
   }
}
void Change_Button_Status(string button_name,int button_type,int magic_num,string line_name)
{
   if(button_type==OP_BUY)
   {
      { if (ObjectGetString(0,button_name,OBJPROP_TEXT)=="BUY")
        {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Buy...");
               buy_basket(magic_num,line_name);
        }
/*        else
        {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
               close_basket(magic_num,line_name);
               ObjectSetString(0,button_name,OBJPROP_TEXT,"BUY");
               
        }*/
      }
   }
   if(button_type==OP_SELL)
   {
      { if (ObjectGetString(0,button_name,OBJPROP_TEXT)=="SELL")
        {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Sell...");
               sell_basket(magic_num,line_name);
               
               
        }
/*        else
        {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
               close_basket(magic_num,line_name);
               ObjectSetString(0,button_name,OBJPROP_TEXT,"SELL");
               
        }*/
      }
   
   }
}      
//---------
void Change_Button_Status_ALL(string button_name,int button_type,int magic_num,string line_name)
{
   if(button_type==OP_BUY)
   {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
               close_basket(magic_num,line_name);
               ObjectSetInteger(0,button_name,OBJPROP_STATE,0);
               ObjectSetString(0,button_name,OBJPROP_TEXT,"BUY");         
   }
   if(button_type==OP_SELL)
   {
               ObjectSetString(0,button_name,OBJPROP_TEXT,"Closing");
               close_basket(magic_num,line_name);
               ObjectSetInteger(0,button_name,OBJPROP_STATE,0);
               ObjectSetString(0,button_name,OBJPROP_TEXT,"SELL");         
               
   
   }
}      
//---------

void delete_interface()
{
   int obj_total=ObjectsTotal();
   for(int i=obj_total-1;i>=0;i--)
     {
      string name=ObjectName(i);
      if (name!="__btn_Market_Orders" )
      if(StringSubstr(name,0,2) == "__") ObjectDelete(name);
     }
   return;
}

void delete_buttons()
{
   int obj_total=ObjectsTotal();
   for(int i=obj_total-1;i>=0;i--)
     {
      string name=ObjectName(i);
      if (name!="__btn_Market_Orders" )
      if(StringSubstr(name,0,5) == "__btn") ObjectDelete(name);
     }
   return;
}

void refresh()
{ int hwnd;
         if(hwnd==0)
           { 
            hwnd=WindowHandle(Symbol(),Period());
            //if(hwnd!=0)
               //Print("Chart window detected");
           }
         //--- refresh window not frequently than 1 time in 2 seconds
         if(hwnd!=0)
           {
            PostMessageA(hwnd,WM_COMMAND,33324,0);
            
           }
           last_time=TimeCurrent();
}
double get_basket_lots()
{ int i=0;
  double lot_tot=0;
  for(i=0;i<OrdersTotal();i++)
  {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderType()==OP_BUY || OrderType()==OP_SELL)
         lot_tot = lot_tot + OrderLots();
  } 
  return(lot_tot);
}
double get_new_orders_lots()
{
   return(ArraySize(pairs) * fixed_lot_size);
}
double get_basket_pip_value()
{  int i=0;
   double basket_pip_value=0.0;
   
   for(i=0;i<ArraySize(pairs);i++)
   {
      basket_pip_value = basket_pip_value+MarketInfo(pairs[i],MODE_TICKVALUE);
/*      if(dw[i]>0)
         basket_pip_value = basket_pip_value+MarketInfo(pairs[i],MODE_TICKVALUE);
      else
         basket_pip_value = basket_pip_value+(1.0/MarketInfo(pairs[i],MODE_TICKVALUE));*/
   }
   return(basket_pip_value);
}

/*double get_spread()
{
   double spread=0,ask=0,bid=0;
   for(int i=0;i<ArraySize(pairs);i++)
   {
         if(dw[i]>0)
         {
            bid+=MarketInfo(pairs[i],MODE_BID)*dw[i];
            ask+=MarketInfo(pairs[i],MODE_ASK)*dw[i];
         }
         else
         {
            ask+=MathAbs(dw[i])/MarketInfo(pairs[i],MODE_BID);
            bid+=MathAbs(dw[i])/MarketInfo(pairs[i],MODE_ASK);
         }
         
   }
   spread=(ask-bid)/Point;
   return(spread);
   
}
*/
double get_order_PL(int mag_number)
{
   double pl=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      if(OrderMagicNumber()==mag_number) pl=pl+OrderProfit()+OrderSwap()+OrderCommission();
   }
   return(pl);
}
int market_orders()
{
   int mo=0,mn=0;
   basket_PL=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      mn=MathFloor(OrderMagicNumber()/100);
      if(mn==Magic_Number && (OrderType()==OP_BUY ||OrderType()==OP_SELL)) 
      {  mo=mo+1;
         basket_PL=basket_PL+OrderProfit()+OrderSwap()+OrderCommission();
      }
      
   }
   return(mo);

}
/*double get_basket_PL()
{  int mn=0;
   double pl=0;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break;
      mn=MathFloor(OrderMagicNumber()/100);
      if(mn==Magic_Number && (OrderType()==OP_BUY ||OrderType()==OP_SELL)) pl=pl+OrderProfit()+OrderSwap()+OrderCommission();
      
   }
   return(pl);
}
*/
void Change_PL_Color(string btn_name)
{
   if( StrToInteger(ObjectGetString(0,btn_name,OBJPROP_TEXT)) <0) ObjectSetInteger(0,btn_name,OBJPROP_COLOR,clrYellow);
   else ObjectSetInteger(0,btn_name,OBJPROP_COLOR,clrWhite);
}      
bool order_found(int mag_num)
{
   bool o_f=false;
   for(int i=0;i<OrdersTotal();i++)
   {
      if(!OrderSelect(i,SELECT_BY_POS,MODE_TRADES)) break;
      if(OrderMagicNumber()==mag_num) { o_f=true;break;}
   }
   return(o_f);
}
void      update_order_PL_Display()
{
      
      if(order_found(Magic_Number*100+01)) 
         {  ObjectSetText(__btn_buy_basket_1,DoubleToString(get_order_PL(Magic_Number*100+01),0));
            Change_PL_Color(__btn_buy_basket_1);  }
      if(order_found(Magic_Number*100+11)) 
         {  ObjectSetText(__btn_sell_basket_1,DoubleToString(get_order_PL(Magic_Number*100+11),0));
            Change_PL_Color(__btn_sell_basket_1);  }
      if(order_found(Magic_Number*100+02)) 
         {  ObjectSetText(__btn_buy_basket_2,DoubleToString(get_order_PL(Magic_Number*100+02),0));
            Change_PL_Color(__btn_buy_basket_2);  }
      if(order_found(Magic_Number*100+12)) 
         { ObjectSetText(__btn_sell_basket_2,DoubleToString(get_order_PL(Magic_Number*100+12),0));
           Change_PL_Color(__btn_sell_basket_2);  }
      if(order_found(Magic_Number*100+03)) 
         { ObjectSetText(__btn_buy_basket_3,DoubleToString(get_order_PL(Magic_Number*100+03),0));
           Change_PL_Color(__btn_buy_basket_3);  }
      if(order_found(Magic_Number*100+13)) 
         { ObjectSetText(__btn_sell_basket_3,DoubleToString(get_order_PL(Magic_Number*100+13),0));
           Change_PL_Color(__btn_sell_basket_3);  }
      //-- Update Basket P/L Display -------------------------------------------------------------------------------------------
      if(market_orders()>0)
      {  
         {  
            ObjectSetText(__btn_close_basket,DoubleToString(basket_PL,0));
            Change_PL_Color(__btn_close_basket);
         }
      }
}
void check_money_SL_TP()
{
      if(market_orders()==0) return;
      if(basket_PL>Money_TP || basket_PL<-1*Money_SL)
      {
         ObjectSetString(0,__btn_close_basket,OBJPROP_TEXT,"Closing...");
         Change_Button_Status_ALL(__btn_buy_basket_1 ,OP_BUY ,Magic_Number*100+01,__lin_basket_Buy_1);      
         Change_Button_Status_ALL(__btn_sell_basket_1,OP_SELL,Magic_Number*100+11,__lin_basket_Sell_1);
         Change_Button_Status_ALL(__btn_buy_basket_2 ,OP_BUY ,Magic_Number*100+02,__lin_basket_Buy_2);      
         Change_Button_Status_ALL(__btn_sell_basket_2,OP_SELL,Magic_Number*100+12,__lin_basket_Sell_2);
         Change_Button_Status_ALL(__btn_buy_basket_3 ,OP_BUY ,Magic_Number*100+03,__lin_basket_Buy_3);      
         Change_Button_Status_ALL(__btn_sell_basket_3,OP_SELL,Magic_Number*100+13,__lin_basket_Sell_3);
         ObjectSetInteger(0,__btn_close_basket,OBJPROP_STATE,0);
         ObjectSetString(0,__btn_close_basket,OBJPROP_TEXT,"No Working Orders");         
      }
     
}
void  check_SL_TP()
{
      if(ObjectFind(0,__lin_basket_Buy_SL_1)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Buy_SL_1,OBJPROP_PRICE))
         close_basket(Magic_Number*100+01,__lin_basket_Buy_1);
      if(ObjectFind(0,__lin_basket_Buy_TP_1)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Buy_TP_1,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+01,__lin_basket_Buy_1);
      if(ObjectFind(0,__lin_basket_Buy_SL_2)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Buy_SL_2,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+02,__lin_basket_Buy_2);
      if(ObjectFind(0,__lin_basket_Buy_TP_2)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Buy_TP_2,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+02,__lin_basket_Buy_2);
      if(ObjectFind(0,__lin_basket_Buy_SL_3)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Buy_SL_3,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+03,__lin_basket_Buy_3); 
      if(ObjectFind(0,__lin_basket_Buy_TP_3)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Buy_TP_3,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+03,__lin_basket_Buy_3); 

      if(ObjectFind(0,__lin_basket_Sell_SL_1)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Sell_SL_1,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+11,__lin_basket_Sell_1);
      if(ObjectFind(0,__lin_basket_Sell_TP_1)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Sell_TP_1,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+11,__lin_basket_Sell_1);
      if(ObjectFind(0,__lin_basket_Sell_SL_2)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Sell_SL_2,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+12,__lin_basket_Sell_2); 
      if(ObjectFind(0,__lin_basket_Sell_TP_2)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Sell_TP_2,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+12,__lin_basket_Sell_2);
      if(ObjectFind(0,__lin_basket_Sell_SL_3)==0 && Close[0]>ObjectGetDouble(0,__lin_basket_Sell_SL_3,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+13,__lin_basket_Sell_3); 
      if(ObjectFind(0,__lin_basket_Sell_TP_3)==0 && Close[0]<ObjectGetDouble(0,__lin_basket_Sell_TP_3,OBJPROP_PRICE)) 
         close_basket(Magic_Number*100+13,__lin_basket_Sell_3); 

}
void   clear_lines()
{
   if (!order_found(Magic_Number*100+01) && ObjectFind(0,__lin_basket_Buy_1 )>=0) 
      { ObjectDelete(0,__lin_basket_Buy_1); ObjectDelete(0,__lin_basket_Buy_SL_1);ObjectDelete(0,__lin_basket_Buy_TP_1); }
   if (!order_found(Magic_Number*100+02) && ObjectFind(0,__lin_basket_Buy_2 )>=0)
      { ObjectDelete(0,__lin_basket_Buy_2); ObjectDelete(0,__lin_basket_Buy_SL_2);ObjectDelete(0,__lin_basket_Buy_TP_2); }
   if (!order_found(Magic_Number*100+03) && ObjectFind(0,__lin_basket_Buy_3 )>=0) 
      { ObjectDelete(0,__lin_basket_Buy_3); ObjectDelete(0,__lin_basket_Buy_SL_3);ObjectDelete(0,__lin_basket_Buy_TP_3); }
   if (!order_found(Magic_Number*100+11) && ObjectFind(0,__lin_basket_Sell_1)>=0)
      { ObjectDelete(0,__lin_basket_Sell_1); ObjectDelete(0,__lin_basket_Sell_SL_1);ObjectDelete(0,__lin_basket_Sell_TP_1); }
   if (!order_found(Magic_Number*100+12) && ObjectFind(0,__lin_basket_Sell_2)>=0) 
      { ObjectDelete(0,__lin_basket_Sell_2); ObjectDelete(0,__lin_basket_Sell_SL_2);ObjectDelete(0,__lin_basket_Sell_TP_2); }
   if (!order_found(Magic_Number*100+13) && ObjectFind(0,__lin_basket_Sell_3)>=0) 
      { ObjectDelete(0,__lin_basket_Sell_3); ObjectDelete(0,__lin_basket_Sell_SL_3);ObjectDelete(0,__lin_basket_Sell_TP_3); }
   if (!order_found(Magic_Number*100+21) && ObjectFind(0,__lin_buy_limit_1  )>=0) 
      { ObjectDelete(0,__lin_buy_limit_1); ObjectDelete(0,__lin_buy_limit_SL_1);ObjectDelete(0,__lin_buy_limit_TP_1); }
   if (!order_found(Magic_Number*100+22) && ObjectFind(0,__lin_buy_limit_2  )>=0)
      { ObjectDelete(0,__lin_buy_limit_2); ObjectDelete(0,__lin_buy_limit_SL_2);ObjectDelete(0,__lin_buy_limit_TP_2); }       
   if (!order_found(Magic_Number*100+41) && ObjectFind(0,__lin_buy_stop_1   )>=0) 
      { ObjectDelete(0,__lin_buy_stop_1); ObjectDelete(0,__lin_buy_stop_SL_1);ObjectDelete(0,__lin_buy_stop_SL_1); }
   if (!order_found(Magic_Number*100+42) && ObjectFind(0,__lin_buy_stop_2   )>=0)   
      { ObjectDelete(0,__lin_buy_stop_2); ObjectDelete(0,__lin_buy_stop_SL_2);ObjectDelete(0,__lin_buy_stop_SL_2); }      
   if (!order_found(Magic_Number*100+31) && ObjectFind(0,__lin_sell_limit_1 )>=0)
      { ObjectDelete(0,__lin_sell_limit_1); ObjectDelete(0,__lin_sell_limit_SL_1);ObjectDelete(0,__lin_sell_limit_TP_1); }      
   if (!order_found(Magic_Number*100+32) && ObjectFind(0,__lin_sell_limit_2 )>=0) 
      { ObjectDelete(0,__lin_sell_limit_2); ObjectDelete(0,__lin_sell_limit_SL_2);ObjectDelete(0,__lin_sell_limit_TP_2); }      
   if (!order_found(Magic_Number*100+51) && ObjectFind(0,__lin_sell_stop_1  )>=0)
      { ObjectDelete(0,__lin_sell_stop_1); ObjectDelete(0,__lin_sell_stop_SL_1);ObjectDelete(0,__lin_sell_stop_TP_1); }           
   if (!order_found(Magic_Number*100+52) && ObjectFind(0,__lin_sell_stop_2  )>=0)         
      { ObjectDelete(0,__lin_sell_stop_2); ObjectDelete(0,__lin_sell_stop_SL_2);ObjectDelete(0,__lin_sell_stop_TP_2); }      
}

void check_Pending_Orders()
{
   string line_name="x",button_name="x",line_TP,line_SL;
   int mag_num=0;
//--- 1st buy stop ---
   if(ObjectFind(0,__lin_buy_stop_1)>=0) 
   { if(Close[0]>ObjectGetDouble(0,__lin_buy_stop_1,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Buy_1)<0) 
         {  line_name = __lin_basket_Buy_1;
            button_name=__btn_buy_basket_1;
            mag_num=Magic_Number*100+01;
            line_TP=__lin_basket_Buy_TP_1;
            line_SL=__lin_basket_Buy_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Buy_2)<0) 
            {  line_name = __lin_basket_Buy_2;
               button_name=__btn_buy_basket_2;
               mag_num=Magic_Number*100+02;
               line_TP=__lin_basket_Buy_TP_2;
               line_SL=__lin_basket_Buy_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Buy_3)<0) 
               {  line_name = __lin_basket_Buy_3;
                  button_name=__btn_buy_basket_3;
                  mag_num=Magic_Number*100+03;
                  line_TP=__lin_basket_Buy_TP_3;
                  line_SL=__lin_basket_Buy_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st Buy Stop because of Max buy Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_BUY ,mag_num,line_name);
            if(ObjectFind(0,__lin_buy_stop_TP_1) >=0)
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_buy_stop_TP_1,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_buy_stop_SL_1) >=0)
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_buy_stop_SL_1,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_buy_stop_1);
            ObjectDelete(0,__lin_buy_stop_TP_1);
            ObjectDelete(0,__lin_buy_stop_SL_1);
         }
     }
  }
//--- 2nd buy stop ---
   if(ObjectFind(0,__lin_buy_stop_2)>=0) 
   { if(Close[0]>ObjectGetDouble(0,__lin_buy_stop_2,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Buy_1)<0) 
         {  line_name = __lin_basket_Buy_1;
            button_name=__btn_buy_basket_1;
            mag_num=Magic_Number*100+01;
            line_TP=__lin_basket_Buy_TP_1;
            line_SL=__lin_basket_Buy_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Buy_2)<0) 
            {  line_name = __lin_basket_Buy_2;
               button_name=__btn_buy_basket_2;
               mag_num=Magic_Number*100+02;
               line_TP=__lin_basket_Buy_TP_2;
               line_SL=__lin_basket_Buy_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Buy_3)<0) 
               {  line_name = __lin_basket_Buy_3;
                  button_name=__btn_buy_basket_3;
                  mag_num=Magic_Number*100+03;
                  line_TP=__lin_basket_Buy_TP_3;
                  line_SL=__lin_basket_Buy_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st Buy Stop because of Max buy Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_BUY ,mag_num,line_name);
            if(ObjectFind(0,__lin_buy_stop_TP_2) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_buy_stop_TP_2,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_buy_stop_SL_2) >=0)            
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_buy_stop_SL_2,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_buy_stop_2);
            ObjectDelete(0,__lin_buy_stop_TP_2);
            ObjectDelete(0,__lin_buy_stop_SL_2);
         }
     }
  }

//---------------------
//--- 1st buy limit ---
   if(ObjectFind(0,__lin_buy_limit_1)>=0) 
   { if(Close[0]<ObjectGetDouble(0,__lin_buy_limit_1,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Buy_1)<0) 
         {  line_name = __lin_basket_Buy_1;
            button_name=__btn_buy_basket_1;
            mag_num=Magic_Number*100+01;
            line_TP=__lin_basket_Buy_TP_1;
            line_SL=__lin_basket_Buy_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Buy_2)<0) 
            {  line_name = __lin_basket_Buy_2;
               button_name=__btn_buy_basket_2;
               mag_num=Magic_Number*100+02;
               line_TP=__lin_basket_Buy_TP_2;
               line_SL=__lin_basket_Buy_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Buy_3)<0) 
               {  line_name = __lin_basket_Buy_3;
                  button_name=__btn_buy_basket_3;
                  mag_num=Magic_Number*100+03;
                  line_TP=__lin_basket_Buy_TP_3;
                  line_SL=__lin_basket_Buy_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st Buy limit because of Max buy Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_BUY ,mag_num,line_name);
            if(ObjectFind(0,__lin_buy_limit_TP_1) >=0)
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_buy_limit_TP_1,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_buy_limit_SL_1) >=0)
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_buy_limit_SL_1,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_buy_limit_1);
            ObjectDelete(0,__lin_buy_limit_TP_1);
            ObjectDelete(0,__lin_buy_limit_SL_1);
         }
     }
  }
//--- 2nd buy limit ---
   if(ObjectFind(0,__lin_buy_limit_2)>=0) 
   { if(Close[0]<ObjectGetDouble(0,__lin_buy_limit_2,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Buy_1)<0) 
         {  line_name = __lin_basket_Buy_1;
            button_name=__btn_buy_basket_1;
            mag_num=Magic_Number*100+01;
            line_TP=__lin_basket_Buy_TP_1;
            line_SL=__lin_basket_Buy_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Buy_2)<0) 
            {  line_name = __lin_basket_Buy_2;
               button_name=__btn_buy_basket_2;
               mag_num=Magic_Number*100+02;
               line_TP=__lin_basket_Buy_TP_2;
               line_SL=__lin_basket_Buy_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Buy_3)<0) 
               {  line_name = __lin_basket_Buy_3;
                  button_name=__btn_buy_basket_3;
                  mag_num=Magic_Number*100+03;
                  line_TP=__lin_basket_Buy_TP_3;
                  line_SL=__lin_basket_Buy_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st Buy limit because of Max buy Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_BUY ,mag_num,line_name);
            if(ObjectFind(0,__lin_buy_limit_TP_2) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_buy_limit_TP_2,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_buy_limit_SL_2) >=0)           
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_buy_limit_SL_2,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_buy_limit_2);
            ObjectDelete(0,__lin_buy_limit_TP_2);
            ObjectDelete(0,__lin_buy_limit_SL_2);
         }
     }
  }

//---------------------
//--- 1st sell stop ---
   if(ObjectFind(0,__lin_sell_stop_1)>=0) 
   { if(Close[0]<ObjectGetDouble(0,__lin_sell_stop_1,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Sell_1)<0) 
         {  line_name = __lin_basket_Sell_1;
            button_name=__btn_sell_basket_1;
            mag_num=Magic_Number*100+11;
            line_TP=__lin_basket_Sell_TP_1;
            line_SL=__lin_basket_Sell_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Sell_2)<0) 
            {  line_name = __lin_basket_Sell_2;
               button_name=__btn_sell_basket_2;
               mag_num=Magic_Number*100+12;
               line_TP=__lin_basket_Sell_TP_2;
               line_SL=__lin_basket_Sell_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Sell_3)<0) 
               {  line_name = __lin_basket_Sell_3;
                  button_name=__btn_sell_basket_3;
                  mag_num=Magic_Number*100+13;
                  line_TP=__lin_basket_Sell_TP_3;
                  line_SL=__lin_basket_Sell_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st sell Stop because of Max sell Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_SELL ,mag_num,line_name);
            if(ObjectFind(0,__lin_sell_stop_TP_1) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_sell_stop_TP_1,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_sell_stop_SL_1) >=0)           
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_sell_stop_SL_1,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_sell_stop_1);
            ObjectDelete(0,__lin_sell_stop_TP_1);
            ObjectDelete(0,__lin_sell_stop_SL_1);
         }
     }
  }
//--- 2nd sell stop ---
   if(ObjectFind(0,__lin_sell_stop_2)>=0) 
   { if(Close[0]<ObjectGetDouble(0,__lin_sell_stop_2,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Sell_1)<0) 
         {  line_name = __lin_basket_Sell_1;
            button_name=__btn_sell_basket_1;
            mag_num=Magic_Number*100+11;
            line_TP=__lin_basket_Sell_TP_1;
            line_SL=__lin_basket_Sell_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Sell_2)<0) 
            {  line_name = __lin_basket_Sell_2;
               button_name=__btn_sell_basket_2;
               mag_num=Magic_Number*100+12;
               line_TP=__lin_basket_Sell_TP_2;
               line_SL=__lin_basket_Sell_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Sell_3)<0) 
               {  line_name = __lin_basket_Sell_3;
                  button_name=__btn_sell_basket_3;
                  mag_num=Magic_Number*100+13;
                  line_TP=__lin_basket_Sell_TP_3;
                  line_SL=__lin_basket_Sell_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st sell Stop because of Max sell Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_SELL ,mag_num,line_name);
            if(ObjectFind(0,__lin_sell_stop_TP_2) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_sell_stop_TP_2,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_sell_stop_SL_2) >=0)           
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_sell_stop_SL_2,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_sell_stop_2);
            ObjectDelete(0,__lin_sell_stop_TP_2);
            ObjectDelete(0,__lin_sell_stop_SL_2);
         }
     }
  }

//---------------------
//--- 1st sell limit ---
   if(ObjectFind(0,__lin_sell_limit_1)>=0) 
   { if(Close[0]>ObjectGetDouble(0,__lin_sell_limit_1,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Sell_1)<0) 
         {  line_name = __lin_basket_Sell_1;
            button_name=__btn_sell_basket_1;
            mag_num=Magic_Number*100+11;
            line_TP=__lin_basket_Sell_TP_1;
            line_SL=__lin_basket_Sell_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Sell_2)<0) 
            {  line_name = __lin_basket_Sell_2;
               button_name=__btn_sell_basket_2;
               mag_num=Magic_Number*100+12;
               line_TP=__lin_basket_Sell_TP_2;
               line_SL=__lin_basket_Sell_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Sell_3)<0) 
               {  line_name = __lin_basket_Sell_3;
                  button_name=__btn_sell_basket_3;
                  mag_num=Magic_Number*100+13;
                  line_TP=__lin_basket_Sell_TP_3;
                  line_SL=__lin_basket_Sell_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st sell limit because of Max sell Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_SELL ,mag_num,line_name);
            if(ObjectFind(0,__lin_sell_limit_TP_1) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_sell_limit_TP_1,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_sell_limit_SL_1) >=0)           
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_sell_limit_SL_1,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_sell_limit_1);
            ObjectDelete(0,__lin_sell_limit_TP_1);
            ObjectDelete(0,__lin_sell_limit_SL_1);
         }
     }
  }
//--- 2nd sell limit ---
   if(ObjectFind(0,__lin_sell_limit_2)>=0) 
   { if(Close[0]>ObjectGetDouble(0,__lin_sell_limit_2,OBJPROP_PRICE)) 
     {
         if(ObjectFind(0,__lin_basket_Sell_1)<0) 
         {  line_name = __lin_basket_Sell_1;
            button_name=__btn_sell_basket_1;
            mag_num=Magic_Number*100+11;
            line_TP=__lin_basket_Sell_TP_1;
            line_SL=__lin_basket_Sell_SL_1;
         }
         else
         {  if(ObjectFind(0,__lin_basket_Sell_2)<0) 
            {  line_name = __lin_basket_Sell_2;
               button_name=__btn_sell_basket_2;
               mag_num=Magic_Number*100+12;
               line_TP=__lin_basket_Sell_TP_2;
               line_SL=__lin_basket_Sell_SL_2;
               
            }
            else
            {
               if(ObjectFind(0,__lin_basket_Sell_3)<0) 
               {  line_name = __lin_basket_Sell_3;
                  button_name=__btn_sell_basket_3;
                  mag_num=Magic_Number*100+13;
                  line_TP=__lin_basket_Sell_TP_3;
                  line_SL=__lin_basket_Sell_SL_3;

               }
            }
         }
         if(line_name=="x") 
         {
            Alert("Can Not Activate 1st sell limit because of Max sell Orders");
         }
         else
         {
            Change_Button_Status(button_name ,OP_SELL ,mag_num,line_name);
            if(ObjectFind(0,__lin_sell_limit_TP_2) >=0)           
            HLineCreate(0,line_TP,0,ObjectGetDouble(0,__lin_sell_limit_TP_2,OBJPROP_PRICE),TP_Color,1,1,true,true,false,0);            
            if(ObjectFind(0,__lin_sell_limit_SL_2) >=0)           
            HLineCreate(0,line_SL,0,ObjectGetDouble(0,__lin_sell_limit_SL_2,OBJPROP_PRICE),SL_Color,1,1,true,true,false,0);            
            ObjectDelete(0,__lin_sell_limit_2);
            ObjectDelete(0,__lin_sell_limit_TP_2);
            ObjectDelete(0,__lin_sell_limit_SL_2);
         }
     }
  }


}
