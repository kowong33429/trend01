//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2018, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property strict

//################################################ ## ###################
//+----------------- CLUSTERDELTA VOLUME DATA --------------------------+

#import "premium_mt4_v4x1.dll"
int InitDLL(int&);
string Receive_Information(int &, string);
int Send_Query(int &, string, string, int, string, string, string,
               string, string, string, int, string, string, string, int);
#import


#import "online_mt4_v4x1.dll"
int Online_Init(int&, string, int);
string Online_Data(int&,string);
int Online_Subscribe(int &, string, string, int, string, string, string,
                     string, string, string, int, string, string, string, int);
#import


datetime TIME_Array[]; // Array for TIME
double VOLUME_Array[]; // Array of Volumes, indexes of array are corelated to TIME_ARRAY
double DELTA_Array[]; // Array of Deltas, indexes of array are corelated to TIME_ARRAY
datetime last_loaded = 0;
string indicator_client;
bool VOLUMES_INIT, ReverseChart_SET = false; // not used in expert


int Days_in_History;
datetime Custom_Start_time, Custom_End_time;

int INIT_DLL_result;



int GMT_SET=1;
int GMT=3;
string MetaTrader_GMT = "+2"; // Change if GMT is different for both

input string Ticker = "AUTO";


//+----------------------------------------------- --------------------+
//| expert initialization function |
//+----------------------------------------------- --------------------+
int OnInit()
  {
// --- Volume & Delta ---
   GlobalVariableDel(indicator_client);

   InitDLL(INIT_DLL_result); // in the next version you don't have to use this function
   if(INIT_DLL_result==-1)
     {
      Print("Error during DLL init. ") ;
      ExpertRemove();
     }

   do // DO NOT CHANGE THIS CODE & DATA --- Volume & Delta
     {
      indicator_client =
         "CDPA" + StringSubstr(DoubleToString(TimeLocal(),0),7,3)+"" +DoubleToStr(MathAbs((MathRand()+3)%10),0);
     }
   while(GlobalVariableCheck(indicator_client));
   GlobalVariableTemp(indicator_client);

   if(!IsTesting())
     {
      Custom_Start_time = D'2017.01.01 00:00'; // Indicator parameters to load 14 last days
      Custom_End_time = D'2017.01.01 00:00';
      Days_in_History = 14;
      Online_Init(INIT_DLL_result, AccountCompany(), AccountNumber());
     }
   Vol_Delta_Cycle_Load();
   //double dellll = iCustom(NULL,0,"my_delta",0,1);
   //double vollll = iCustom(NULL,0,"my_volume",0,1);


//--- create timer
   if(!IsTesting())
      EventSetMillisecondTimer(100);

//---
   return(INIT_SUCCEEDED);
  }
//+----------------------------------------------- --------------------+
//| Expert deinitialization function |
//+----------------------------------------------- --------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   GlobalVariableDel(indicator_client);

   /*for(int it = 1; it < 20; it ++)
      Print(Time[it]," / Vol ",VOLUME_by_index(it)," / Del ",DELTA_by_index(it)); // just yo check vol & delta is working

   Print(findAvgDelta(20));
   Print(findAvgVolume(20));*/
  }
//+----------------------------------------------- --------------------+
//| Expert tick function |
//+----------------------------------------------- --------------------+
void dot(string dotName,double LinePrice,color LineColor)
  {
   ObjectCreate(dotName, OBJ_TEXT, 0, Time[0], LinePrice); //draw an up arrow
   ObjectSetText(dotName, CharToStr(159), 14, "Wingdings", LineColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calculateLotSize(double stopLoss)
  {
// 1% risk per trade
   int risk = 1;

// Fetch some symbol properties
   double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
   double minLot  = MarketInfo(Symbol(), MODE_MINLOT);
   double maxLot  = MarketInfo(Symbol(), MODE_MAXLOT);
   double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);


// Calculate the actual lot size
   double lotSize = (AccountBalance() * risk / 100) / (stopLoss);
//Print("lot = ",lotSize," Balance = ", AccountBalance(), " SL = ",stopLoss);
//Print("Step = ",lotStep, " -> " ,NormalizeDouble(lotSize / lotStep, 0) * lotStep);

   return MathMin(
             maxLot,
             MathMax(
                minLot,
                NormalizeDouble(lotSize / lotStep, 0) * lotStep // This rounds the lotSize to the nearest lotstep interval
             )
          );
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ShouldOpen()
  {
   int ticket = -1;
   datetime open_time = 0;
   for(int i=OrdersHistoryTotal()-1; i>=0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY)
         && OrderSymbol()==_Symbol
         && OrderOpenTime() > open_time)
        {
         ticket = OrderTicket();
         open_time = OrderOpenTime();
        }
      //Print(OrderTicket());
     }
//Print("Last order ticket is : " , ticket);

// 1800 = half hour , 3600 = full hour
   return (OrderSelect(ticket,SELECT_BY_TICKET) && (TimeCurrent() - open_time > 120)) || OrdersHistoryTotal() == 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   static int mmm, mn, vol, del;
   int vol_t, del_t;

   if(IsTesting() && mmm != Month())
     {
      mmm = Month();
      Print("month=",mmm);
      Testing_Load_ind_Vol_Del();

     }
   /*if(TimeSeconds(TimeCurrent()) == 2)
   {
      Print(Time[1]," / Vol ",VOLUME_by_index(1)," / Del ",DELTA_by_index(1));
   }*/
//findAvgDelta(20);
//findAvgVolume(20);

   if(!IsTesting())
     {
      vol_t = VOLUME_by_index(1);
      del_t = DELTA_by_index(1);
      if(mn != Minute())
        {
         mn = Minute();
         vol = vol_t;
         del = del_t;
         Print("Vol ",vol," // Del ",del);
        }
      if(vol_t != vol || del_t != del)
        {
         vol = vol_t;
         del = del_t;
         Print("Update: Vol ",vol," // Del ",del);
        }
     }

//algo
   double ema_3_5_high_bybit = iMA(NULL,PERIOD_M5,3,2,MODE_EMA,PRICE_HIGH,1);
   double ema_3_5_low_bybit = iMA(NULL,PERIOD_M5,3,2,MODE_EMA,PRICE_LOW,1);

   double ema_60_5_binance = iMA(NULL,PERIOD_M5,60,2,MODE_EMA,PRICE_CLOSE,1);
   double ema_120_5_binance = iMA(NULL,PERIOD_M5,120,2,MODE_EMA,PRICE_CLOSE,1);
   double ema_240_5_binance = iMA(NULL,PERIOD_M5,240,2,MODE_EMA,PRICE_CLOSE,1);

   double ema_3_1_high_bybit = iMA(NULL,PERIOD_M1,3,2,MODE_EMA,PRICE_HIGH,1);
   double ema_3_1_low_bybit = iMA(NULL,PERIOD_M1,3,2,MODE_EMA,PRICE_LOW,1);

   double ema_60_1_binance = iMA(NULL,PERIOD_M1,60,2,MODE_EMA,PRICE_CLOSE,1);
   double ema_120_1_binance = iMA(NULL,PERIOD_M1,120,2,MODE_EMA,PRICE_CLOSE,1);
   double ema_240_1_binance = iMA(NULL,PERIOD_M1,240,2,MODE_EMA,PRICE_CLOSE,1);

   double ema_6_5_high_bybit = iMA(NULL,PERIOD_M5,6,2,MODE_EMA,PRICE_HIGH,1);
   double ema_6_1_high_bybit = iMA(NULL,PERIOD_M1,6,2,MODE_EMA,PRICE_HIGH,1);

   double ema_6_1_low_bybit = iMA(NULL,PERIOD_M1,6,2,MODE_EMA,PRICE_LOW,1);
   double ema_6_5_low_bybit = iMA(NULL,PERIOD_M5,6,2,MODE_EMA,PRICE_LOW,1);

   bool ma_order_long_1m = (ema_60_1_binance < ema_120_1_binance) && (ema_120_1_binance < ema_240_1_binance) && (ema_3_1_high_bybit < ema_60_1_binance);
   bool ma_order_long_5m = (ema_60_5_binance < ema_120_5_binance) && (ema_120_5_binance < ema_240_5_binance) && (ema_3_5_high_bybit < ema_60_5_binance);

   bool ma_order_shrt_1m = (ema_60_1_binance > ema_120_1_binance) && (ema_120_1_binance > ema_240_1_binance) && (ema_3_1_low_bybit > ema_60_1_binance);
   bool ma_order_shrt_5m = (ema_60_5_binance > ema_120_5_binance) && (ema_120_5_binance > ema_240_5_binance) && (ema_3_5_low_bybit > ema_60_5_binance);

   bool good_ma_order_long = (ma_order_long_1m == True) && (ma_order_long_5m == True);
   bool good_ma_order_shrt = (ma_order_shrt_1m == True) && (ma_order_shrt_5m == True);

   bool good_shrt_conditions = (good_ma_order_shrt == True) && (Bid > ema_3_5_high_bybit) && (Bid > ema_3_1_high_bybit);
   bool good_long_conditions = (good_ma_order_long == True) && (Ask < ema_3_5_low_bybit) && (Ask < ema_3_1_low_bybit);

   bool good_trade_conditions = (good_shrt_conditions == True) || (good_long_conditions == True);

   bool good_short_trade_conditions = (Bid > ema_3_1_high_bybit);
   bool good_long_trade_conditions = (Ask < ema_3_1_low_bybit);

   double distance = (ema_6_1_high_bybit * 100 / ema_6_1_low_bybit) - 100;
   double rdistance = distance;
   Print("rdis: ",rdistance);
   double min_distance = 0.05;
   
   double lots;
   
   double avg_delta_1200 = findAvgDelta(720);
   double delta_prev_1 = DELTA_by_index(1);
   double delta_prev_2 = DELTA_by_index(2);
   double delta_prev_3 = DELTA_by_index(3);
   double delta_prev_4 = DELTA_by_index(4);

   double avg_volume_240 = findAvgVolume(240);
   double volue_prev_1 = VOLUME_by_index(1);

   if(iStochastic(NULL,0,120,3,3,MODE_SMA,0,MODE_MAIN,0)>=80 && iStochastic(NULL,0,120,3,3,MODE_SMA,0,MODE_SIGNAL,0)>=80)
     {
      dot("Up"+Bars,High[0]+(100*Point),Red);
     }
   else
      if(iStochastic(NULL,0,120,3,3,MODE_SMA,0,MODE_MAIN,0)<=20 && iStochastic(NULL,0,120,3,3,MODE_SMA,0,MODE_SIGNAL,0)<=20)
        {
         dot("Down"+Bars,Low[0]-(100*Point),Lime);
        }


   if(good_long_trade_conditions == True && rdistance >= min_distance && good_trade_conditions == True)
     {
      //buy
      
      
      if(OrdersTotal() == 0 && ShouldOpen())
        {
         lots = calculateLotSize(500);
         OrderSend(_Symbol,OP_BUY,lots,Ask,3,Ask-(500*Point),Ask+(ema_3_5_high_bybit-ema_3_5_low_bybit),"ryu",1111,0,clrGreen);
         Print("nong gameeeeeeeeeeeeeee");
        }
     }
   else
      if(good_short_trade_conditions == True && rdistance >= min_distance && good_trade_conditions == True)
        {

         if(OrdersTotal() == 0 && ShouldOpen())
           {
            lots = calculateLotSize(500);
            OrderSend(_Symbol,OP_SELL,lots,Bid,3,Bid+(500*Point),Bid-(ema_3_5_high_bybit-ema_3_5_low_bybit),"ryu",1111,0,clrRed);
            Print("nong ton");
           }
        }

  }


//+------------------------------------------------------------------+
//|                     find EMA of Delta                            |
//+------------------------------------------------------------------+
double findAvgDelta(int count)
  {
   double deltaTmp[];
   ArrayResize(deltaTmp,count);
   for(int i=0; i<count; i++)
     {
      ArrayFill(deltaTmp,i,1,MathAbs(DELTA_by_index(i)));
     }
   return iMAOnArray(deltaTmp,0,count,0,MODE_EMA,0);
  }

//+------------------------------------------------------------------+
//|                     find EMA of Volumn                           |
//+------------------------------------------------------------------+
double findAvgVolume(int count)
  {
   double volumeTmp[];
   ArrayResize(volumeTmp,count);
   for(int i=1; i<count; i++)
     {
      ArrayFill(volumeTmp,i,1,MathAbs(VOLUME_by_index(i)));
     }
   return iMAOnArray(volumeTmp,0,count,0,MODE_EMA,0);
  }


//+----------------------------------------------- --------------------+
//| time function |
//+----------------------------------------------- --------------------+
void OnTimer()
  {
   uchar static Timer, Timer_V;
   bool static Get_new_Vol = false;
   Print("Ontimer , ",TimeCurrent());
   if(TimeHour(TimeCurrent()) < 1)
      return; // Do not download DPOC data before 1:00 (if set)
   if(!IsTesting())
     {
      Timer++;
      if(TimeSeconds(TimeCurrent()) == 59)
        {
         VOLUMES_GetOnline();
        }
      else
         Timer_V++;
        {
         Timer_V++;
         if(Timer_V >= 10)
           {
            Timer_V = 0;
            VOLUMES_GetOnline();
            if(Get_new_Vol)
              {
               if(VOLUMES_GetData())
                  Get_new_Vol = false;
              }
           }
        }
      if(Timer >= 50)
        {
         VOLUMES_SetData();
         Timer=0;
         Get_new_Vol = true;
        }
     }

  }
//+----------------------------------------------- --------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Testing_Load_ind_Vol_Del()
  {

   ulong Timer_uSEC;
   int it, MM_0, MM_1, YY_0, YY_1, temp, cc;
   string mm_0, mm_1;
   int temp_1_Vol[], temp_2_Vol[], temp_1_Del[], temp_2_Del[];
   datetime temp_1_Time[], temp_2_Time[];

   ArrayFree(temp_1_Time);
   ArrayFree(temp_1_Vol);
   ArrayFree(temp_1_Del);
   ArrayFree(temp_2_Time);
   ArrayFree(temp_2_Vol);
   ArrayFree(temp_2_Del);
   ArrayFree(TIME_Array);
   ArrayFree(VOLUME_Array);
   ArrayFree(DELTA_Array);

   string f_name, f_handle, yyy, mmm;
   yyy = IntegerToString(Year());
   if(Month() < 10)
      mmm = "0"+ IntegerToString(Month());
   else
      mmm = Month();
   f_name = Symbol() +"\\"+ IntegerToString(yyy) +"_"+ mmm +".csv";
   Print("file name ",f_name);
   if(IsTesting() && FileIsExist(f_name))
     {
      Print("Testing_Load_file_Vol_Delta_by_Month");
      Testing_Load_file_Vol_Delta_by_Month();
      return;
     }
   Print("file not exist");
   ArrayFree(TIME_Array);
   ArrayFree(VOLUME_Array);
   ArrayFree(DELTA_Array); // Reset Array for Vol & Delta: load 1st part
   MM_0 = Month() -1;
   YY_0 = Year();
   MM_1 = Month();
   YY_1 = YY_0;
   if(MM_0 == 0)
     {
      MM_0 = 12;
      YY_0 -= 1;
     }
   if(MM_0 < 10)
      mm_0 = "0"+ IntegerToString(MM_0);
   else
      mm_0 = IntegerToString(MM_0);
   if(MM_1 < 10)
      mm_1 = "0"+ IntegerToString(MM_1);
   else
      mm_1 = IntegerToString(MM_1);


   Custom_Start_time = StringToTime(IntegerToString(YY_0) +"."+ mm_0 +".12");
   Custom_End_time = StringToTime(IntegerToString(YY_1) +"."+ mm_1 +".01");
   Days_in_History = 0;
   Print("Load indicator data for period: ",TimeToString(Custom_Start_time)," - ",TimeToString(Custom_End_time));
   Vol_Delta_Cycle_Load();
   if(!VOLUMES_INIT)
     {
      Print("Indicator Volume & Delta Data not loaded, exit");
      ExpertRemove();
     }

   ArrayResize(temp_1_Time, ArraySize(TIME_Array));
   ArrayResize(temp_1_Vol, ArraySize(TIME_Array));
   ArrayResize(temp_1_Del, ArraySize(TIME_Array));
   for(it = 0; it < ArraySize(TIME_Array); it ++)
     {
      if(TimeMonth(TIME_Array[it]) == MM_1)
         continue;
      temp_1_Time[it] = TIME_Array[it];
      if(it < ArraySize(VOLUME_Array))
         temp_1_Vol[it] = VOLUME_Array[it];
      if(it < ArraySize(DELTA_Array))
         temp_1_Del[it] = DELTA_Array[it];
     }

   ArrayFree(TIME_Array);
   ArrayFree(VOLUME_Array);
   ArrayFree(DELTA_Array); // Reset Array for Vol & Delta: Load 2nd part
   MM_0 = Month();
   YY_0 = Year();
   MM_1 = Month() +1;
   YY_1 = YY_0;
   if(MM_1 == 13)
     {
      MM_1 = 1;
      YY_1 += 1;
     }
   if(MM_0 < 10)
      mm_0 = "0"+ IntegerToString(MM_0);
   else
      mm_0 = IntegerToString(MM_0);
   if(MM_1 < 10)
      mm_1 = "0"+ IntegerToString(MM_1);
   else
      mm_1 = IntegerToString(MM_1);
   Custom_Start_time = StringToTime(IntegerToString(YY_0) +"."+ mm_0 +".01");
   Custom_End_time = StringToTime(IntegerToString(YY_1) +"."+ mm_1 +".01");
   Days_in_History = 0;
   Print("Load indicator data for period: ",TimeToString(Custom_Start_time)," - ",TimeToString(Custom_End_time));
   Vol_Delta_Cycle_Load();
   if(!VOLUMES_INIT)
     {
      Print("Indicator Volume & Delta Data not loaded, exit");
      ExpertRemove();
     }

   ArrayResize(temp_2_Time, ArraySize(TIME_Array));
   ArrayResize(temp_2_Vol, ArraySize(TIME_Array));
   ArrayResize(temp_2_Del, ArraySize(TIME_Array));
   for(it = 0; it < ArraySize(TIME_Array); it ++)
     {
      if(TimeMonth(TIME_Array[it]) < MM_0)
         continue;
      temp_2_Time[it] = TIME_Array[it];
      if(it < ArraySize(VOLUME_Array))
         temp_2_Vol[it] = VOLUME_Array[it];
      if(it < ArraySize(DELTA_Array))
         temp_2_Del[it] = DELTA_Array[it];
     }



   ArrayFree(TIME_Array);
   ArrayFree(VOLUME_Array);
   ArrayFree(DELTA_Array); // Reset Array for Vol & Delta: merge 1st & 2nd parts
   for(it = 0; it < ArraySize(temp_1_Time); it++)
     {
      ArrayResize(TIME_Array, ArraySize(TIME_Array) +1);
      TIME_Array[it] = temp_1_Time[it];
      ArrayResize(VOLUME_Array, ArraySize(VOLUME_Array) +1);
      VOLUME_Array[it] = temp_1_Vol[it];
      ArrayResize(DELTA_Array, ArraySize(DELTA_Array) +1);
      DELTA_Array[it] = temp_1_Del[it];
     }

   temp = ArraySize(temp_1_Time);
   for(it = 0; it < ArraySize(temp_2_Time); it++)
     {
      ArrayResize(TIME_Array, ArraySize(TIME_Array) +1);
      TIME_Array[it +temp] = temp_2_Time[it];
      ArrayResize(VOLUME_Array, ArraySize(VOLUME_Array) +1);
      VOLUME_Array[it +temp] = temp_2_Vol[it];
      ArrayResize(DELTA_Array, ArraySize(DELTA_Array) +1);
      DELTA_Array[it +temp] = temp_2_Del[it];
     }

   Testing_Write_file_Vol_Delta_by_Month(); // save merged data to file

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Vol_Delta_Init()
  {

   indicator_client =
      "CDPA" + StringSubstr(DoubleToString(TimeLocal(),0),7,3)+"" +DoubleToStr(MathAbs((MathRand()+3)%10),0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Vol_Delta_Cycle_Load()
  {

   ulong Timer_uSEC;
   int it, itt, c;

   for(itt = 0; itt < 5; itt ++) // 5 attempt with reinitialization
     {
      Vol_Delta_Init();
      Print("initialization Vol & Delta client # ",itt +1);
      for(it = 0; it < 3; it ++) // 3 attempt to load single request
        {
         Timer_uSEC = GetMicrosecondCount(); // ---------- send server request
         for(c = 1; c <= 3; c++)
           {
            last_loaded = 0;
            if(VOLUMES_SetData() < 0) // Server request data
              {
               while(!IsStopped() && GetMicrosecondCount() < (Timer_uSEC + 5000000 *c))
                 {
                  for(int cc = 0; cc < 100; cc ++)
                    }
               Print("Volume - send server request #",c);
              }
            else
               break;
           }

         Timer_uSEC = GetMicrosecondCount(); // ---------- check for loaded data
         for(c = 1; c <= 5; c++)
           {
            ArrayFree(TIME_Array);
            ArrayFree(VOLUME_Array);
            ArrayFree(DELTA_Array);
            if(VOLUMES_GetData() == 0) // Check is data ready ???
              {
               while(!IsStopped() && GetMicrosecondCount() < (Timer_uSEC + 5000000 * c))
                  for(int cc = 0; cc < 100; cc ++);  // pause before next try
              }
            else
              {
               if(!VOLUMES_INIT)
                 { while(!IsStopped() && GetMicrosecondCount() < (Timer_uSEC + 5000000 *c)) for(int cc = 0; cc < 100; cc ++); }
              }
            Print("Volume - check for loaded data #",c);
            if(VOLUMES_INIT)
              {
               Print("Volume Loaded # ",it);
               break;
              }
           }
         if(VOLUMES_INIT)
            break;
        }
      if(VOLUMES_INIT)
         break;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ArrayBsearchCorrect(datetime &array[], double value,
                        int count = WHOLE_ARRAY, int start = 0,
                        int direction = MODE_ASCEND)
  {
   if(ArraySize(array)==0)
      return(-1);
   int i = ArrayBsearch(array, (datetime)value, count, start, direction);
   if(value != array[i])
     {
      i = -1;
     }
   return(i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SortDictionary(datetime &keys[], double &values[], double &values2[], int sortDirection = MODE_ASCEND)
  {
   datetime keyCopy[];
   double valueCopy[];
   double valueCopy2[];
   ArrayCopy(keyCopy, keys);
   ArrayCopy(valueCopy, values);
   ArrayCopy(valueCopy2, values2);
   ArraySort(keys, WHOLE_ARRAY, 0, sortDirection);
   for(int i = 0; i < MathMin(ArraySize(keys), ArraySize(values)); i++)
     {
      values[ArrayBsearch(keys, keyCopy[i])] = valueCopy[i];
      values2[ArrayBsearch(keys, keyCopy[i])] = valueCopy2[i];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void UpdateArray(datetime& td[],double& ad[], double& bd[], double dtp, double dta, double dtb)
  {
   datetime indexx = (datetime)dtp;

   int i=ArraySize(td);
   int iBase = ArrayBsearchCorrect(td, indexx);

   if(iBase >= 0)
     {
      i=iBase;
     }

   if(i>=ArraySize(td))
     {
      ArrayResize(td, i+1);
      ArrayResize(ad, i+1);
      ArrayResize(bd, i+1);
     }
   else
     {
      if(ad[i]>dta && i>=ArraySize(td)-2)
        {
         dta=ad[i];
         dtb=bd[i];
        }
     }

   td[i]= (datetime)dtp;
   ad[i]=dta;
   bd[i]=dtb;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VOLUMES_SetData()
  {

   datetime Time_Current;
   datetime Time_bar_arr;

   if(IsTesting())
     {
      Time_Current = Custom_End_time;
      Time_bar_arr = Custom_End_time;
     }
   else
     {
      Time_Current = TimeCurrent();
      Time_bar_arr = Time[0];
     }


   int k=0,i;

   string Instrument = Ticker;
   string ver="4.3";



   i = Send_Query(k,indicator_client,
                  Symbol(), Period(),
                  TimeToStr(Time_Current), TimeToStr(Time_bar_arr),
                  Instrument,TimeToStr(last_loaded),MetaTrader_GMT,ver,
                  Days_in_History,TimeToStr(Custom_Start_time),TimeToStr(Custom_End_time),
                  AccountCompany(),AccountNumber());

   if(i < 0)
     {
      Alert("Error during query registration");
      return -1;
     }

   if(!IsTesting())
     {
      i = Online_Subscribe(k,indicator_client,
                           Symbol(), Period(),
                           TimeToStr(TimeCurrent()), TimeToStr(Time[0]),
                           Instrument, TimeToStr(last_loaded),MetaTrader_GMT,ver,
                           Days_in_History,TimeToStr(Custom_Start_time),TimeToStr(Custom_End_time),
                           AccountCompany(),AccountNumber()); //
     }

   VOLUMES_INIT=false;
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VOLUMES_GetData()
  {

   string response="";
   int length=0;
   int valid=0;
   int len=0,td_index;
   int i=0;
   double index;
   int iBase=0;
   double ask_value=0, bid_value=0;
   string result[];
   string bardata[];
   string MessageFromServer;

// get query from dll
   response = Receive_Information(length, indicator_client);
   if(length==0)
     {
      return 0;
     }

   if(StringLen(response)>1)
     {
      len=StringSplit(response,StringGetCharacter("\n",0),result);
      if(!len)
        {
         return 0;
        }
      MessageFromServer=result[0];

      for(i=1; i<len; i++)
        {
         if(StringLen(result[i])==0)
            continue;
         StringSplit(result[i],StringGetCharacter(";",0),bardata);
         // --- my check
         if(ArraySize(bardata) < 3)
           {
            Print("Zero Bardata");
            //Vol_Delta_Init(); // reinitialize Indicator
            //VOLUMES_SetData(); // resend server request
            return(0); // exit
           }
         // ---
         td_index = ArraySize(TIME_Array);
         index = (double)StrToTime(bardata[0]);
         ask_value = StringToDouble(bardata[1]);
         bid_value = StringToDouble(bardata[2])*(ReverseChart_SET?-1:1);


         if(index==0)
            continue;
         iBase = ArrayBsearchCorrect(TIME_Array, index);
         if(iBase >= 0)
           {
            td_index=iBase;
           }
         if(td_index >= ArraySize(TIME_Array))
           {
            ArrayResize(TIME_Array, td_index+1);
            ArrayResize(VOLUME_Array, td_index+1);
            ArrayResize(DELTA_Array, td_index+1);
           }
         else
           {
            if((VOLUME_Array[td_index]) > (ask_value) && td_index >= ArraySize(TIME_Array)-2)
              { ask_value = VOLUME_Array[td_index]; bid_value = DELTA_Array[td_index];}
           }

         TIME_Array[td_index] = (datetime)index;
         VOLUME_Array[td_index] = ask_value;
         DELTA_Array[td_index] = bid_value;

        }
      valid=ArraySize(TIME_Array);

      if(valid>0)
        {
         SortDictionary(TIME_Array,VOLUME_Array,DELTA_Array);
         int lastindex = ArraySize(TIME_Array);
         last_loaded=TIME_Array[lastindex-1];
         if(last_loaded>Time[0])
            last_loaded=Time[0];
         VOLUMES_INIT = true;
        }
      else
         return(0);

     }
   return(1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VOLUMES_GetOnline()
  {

   static int prnt_v_0, prnt_d_0, prnt_t_0, prnt_v_1, prnt_d_1, prnt_t_1;

   string response="";
   int length=0;
   string key="";
   string mydata="";
   int block=0;
//if(Period()>60) return 0;
   response = Online_Data(length, indicator_client);
   if(length == 0)
     {
      return 0;
     }
   if(ArraySize(TIME_Array)<4)
     {
      return 0;
     }
   int key_i=StringFind(response, ":");
   key = StringSubstr(response,0,key_i);
   mydata = StringSubstr(response,key_i+1);
   int compare_minutes = 0;



   string result[];
   string bardata[];
   if(key == indicator_client)
     {
      StringSplit(mydata,StringGetCharacter("!",0),result);

      if(!GMT_SET)
        {
         StringSplit(result[2],StringGetCharacter(";",0),bardata);
         if(VOLUME_Array[ArraySize(VOLUME_Array)-3] == StringToDouble(bardata[1])) // 3rd bar in stream is 3rd in series
           {
            StringSplit(result[0],StringGetCharacter(";",0),bardata);
            compare_minutes = int((double)(TIME_Array[ArraySize(TIME_Array)-1]) - StringToDouble(bardata[0]));
            GMT = int(compare_minutes / 3600);
            GMT_SET=0;
           }
         else
            if(VOLUME_Array[ArraySize(VOLUME_Array)-2] == StringToDouble(bardata[1])) // 3rd bar in stream is 3rd in series
              {
               compare_minutes = int((double)(TIME_Array[ArraySize(TIME_Array)-2]) - StringToDouble(bardata[0]));
               GMT = int(compare_minutes / 3600);
               GMT_SET=0;
              }
        }

      StringSplit(result[0],StringGetCharacter(";",0),bardata);
      UpdateArray(TIME_Array, VOLUME_Array,DELTA_Array, StringToDouble(bardata[0])+3600*GMT, StringToDouble(bardata[1]),StringToDouble(bardata[2]));
      //if(prnt_t_0 != StrToInteger(bardata[0])+3600*GMT) {prnt_t_0 = StrToInteger(bardata[0])+3600*GMT; Print("Time_0 ",TimeToString(StrToInteger(bardata[0])+3600*GMT));}
      //if(prnt_v_0 != StrToInteger(bardata[1])) {prnt_v_0 = StrToInteger(bardata[1]); Print(" / Vol_0 ", bardata[1]);}
      //if(prnt_d_0 != StrToInteger(bardata[2])) {prnt_d_0 = StrToInteger(bardata[2]); Print(" / Delta_0 ", bardata[2]);}

      StringSplit(result[1],StringGetCharacter(";",0),bardata);
      UpdateArray(TIME_Array, VOLUME_Array,DELTA_Array, StringToDouble(bardata[0])+3600*GMT, StringToDouble(bardata[1]),StringToDouble(bardata[2]));
      //if(prnt_t_1 != StrToInteger(bardata[0])+3600*GMT) {prnt_t_1 = StrToInteger(bardata[0])+3600*GMT; Print("Time_1 ",TimeToString(StrToInteger(bardata[0])+3600*GMT));}
      //if(prnt_v_1 != StrToInteger(bardata[1])) {prnt_v_1 = StrToInteger(bardata[1]); Print(" / Vol_1 ", bardata[1]);}
      //if(prnt_d_1 != StrToInteger(bardata[2])) {prnt_d_1 = StrToInteger(bardata[2]); Print(" / Delta_1 ", bardata[2]);}
     }
   return 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int VOLUME_by_index(int ix, bool BrokehHour=true)
  {
   if(ArraySize(TIME_Array)<2)
      return 0;
   if(ArraySize(Time)<=ix)
      return 0;

   int iBase = ArrayBsearchCorrect(TIME_Array, Time[ix]);

   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 1*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 2*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 3*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 4*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M15 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 5*60);   // 5 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_H1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 30*60);   // 35 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 35*60);   // 35 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 60*60);   // 60 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 60*60);   // 60 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 2*60*60);   // 120 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_W1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 24*60*60);   // 35 Min Broken Hour / ES
     }


   if(iBase >= 0)
     {
      return (int)VOLUME_Array[iBase];
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DELTA_by_index(int ix, bool BrokehHour=true)
  {
   if(ArraySize(TIME_Array)<2)
      return 0;
   if(ArraySize(Time)<=ix)
      return 0;

   int iBase = ArrayBsearchCorrect(TIME_Array, Time[ix]);

   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 1*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 2*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 3*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M5 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 4*60);   // 1 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_M15 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 5*60);   // 5 Min Broken Hour
     }
   if(iBase < 0 && Period() >= PERIOD_H1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 30*60);   // 35 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 35*60);   // 35 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 60*60);   // 60 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 60*60);   // 60 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_H4 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 2*60*60);   // 120 Min Broken Hour / ES
     }
   if(iBase < 0 && Period() >= PERIOD_W1 && BrokehHour)
     {
      iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 24*60*60);   // 35 Min Broken Hour / ES
     }


   if(iBase >= 0)
     {
      return (int)DELTA_Array[iBase];
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Testing_Write_file_Vol_Delta_by_Month()
  {

   if(!IsTesting())
      return;
   int it, dt, vol, del;
   string f_name, f_handle, yyy, mmm, date;
   yyy = IntegerToString(Year());
   if(Month() < 10)
      mmm = "0"+ IntegerToString(Month());
   else
      mmm = Month();
   f_name = Symbol() +"\\"+ IntegerToString(yyy) +"_"+ mmm +".csv";
   if(FileIsExist(f_name))
      return; // exit if file already exists
   Print(f_name);

   f_handle = FileOpen(f_name, FILE_READ|FILE_WRITE|FILE_CSV);
   for(it = 0; it < ArraySize(TIME_Array); it ++)
     {
      dt = TIME_Array[it];
      date = TimeToString(dt);
      if(it < ArraySize(VOLUME_Array))
         vol = VOLUME_Array[it];
      if(it < ArraySize(DELTA_Array))
         del = DELTA_Array [it];
      if(f_handle > 0)
         FileWrite(f_handle, date, dt, vol, del);
     }
   FileClose(f_handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Testing_Load_file_Vol_Delta_by_Month()
  {

   string f_name, yyy, mmm, date;
   int f_handle;
   yyy = IntegerToString(Year());
   if(Month() < 10)
      mmm = "0"+ IntegerToString(Month());
   else
      mmm = Month();
   f_name = Symbol() +"\\"+ IntegerToString(yyy) +"_"+ mmm +".csv";

   f_handle = FileOpen(f_name, FILE_READ|FILE_WRITE|FILE_CSV);
   while(!FileIsEnding(f_handle))
     {
      ArrayResize(TIME_Array, ArraySize(TIME_Array) +1);
      ArrayResize(VOLUME_Array, ArraySize(VOLUME_Array) +1);
      ArrayResize(DELTA_Array, ArraySize(DELTA_Array) +1);

      date = FileReadString(f_handle);
      TIME_Array [ArraySize(TIME_Array) -1] = FileReadString(f_handle);
      VOLUME_Array[ArraySize(VOLUME_Array) -1] = FileReadString(f_handle);
      DELTA_Array [ArraySize(DELTA_Array) -1] = FileReadString(f_handle);
     }
   FileClose(f_handle);
  }
//+------------------------------------------------------------------+
