#property strict

//+------------------------INCLUDE---------------------- -------------+
#include <stdlib.mqh>

//+--------------- CLUSTERDELTA VOLUMEN DATA --------------------+
#import "premium_mt4_v4x1.dll"
int InitDLL(int&);
string Receive_Information(int &, string);
int Send_Query(int &, string, string, int, string, string, string, string, string, string, int, string, string, string, int);
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
datetime last_loaded=0;
string indicator_client;
bool ReverseChart_SET=false; // not used in expert
int Seconds_Interval_To_Update_Volumes=10;

bool VOLUMES_INIT=false;

//+----------------------------------------------- --------------------+
//| expert initialization function |
//+----------------------------------------------- --------------------+
int OnInit()
  {
//---
   int INIT_DLL_result;
   InitDLL(INIT_DLL_result); // in the next version you don't have to use this function
   if(INIT_DLL_result==-1) { Print("Error during load Volumes DLL") ; return INIT_FAILED; }

   // DO NOT CHANGE THIS CODE & DATA
   do
   {
     indicator_client = "CDPA" + StringSubstr(DoubleToString(TimeLocal(),0),7,3)+""+DoubleToStr(MathAbs((MathRand()+3)%10),0);     
   } while (GlobalVariableCheck(indicator_client));
   GlobalVariableTemp(indicator_client);
   // ======================
   
   EventSetTimer(1);
   return(INIT_SUCCEEDED);
  }
//+----------------------------------------------- --------------------+
//| Expert deinitialization function |
//+----------------------------------------------- --------------------+
void OnDeinit(const int reason)
  {
//---
   GlobalVariableDel(indicator_client);
  }
//+----------------------------------------------- --------------------+
//| Expert tick function |
//+----------------------------------------------- --------------------+
void OnTick()
{
   //Print("aaaaaaaaaaaaaaaaaaaaaaaaaaaa");
   //DELTA_by_index(0);
   //Print("delta0:  ",DELTA_by_index(0));
   //Print("delta0:  ",DELTA_by_index(0));
   
   // DO NOT FORGET TO USE EventSetTimer(1); in Init
   // IF YOU DO NOT LIKE USE onTimer() YUO SHOULD MOVE THIS CODE TO onTick()
   static int Load_Frequency=0;
   // do not update faster than one time per 5 seconds
   if(Seconds_Interval_To_Update_Volumes<5) { Seconds_Interval_To_Update_Volumes=5; }
  
   VOLUMES_GetData();
   
   if (Load_Frequency % Seconds_Interval_To_Update_Volumes == 0)
   {
      Load_Frequency=0;
      VOLUMES_SetData();
   }
   Load_Frequency++;
   if (VOLUMES_INIT) { Print (Time[0]," ",VOLUME_by_index(0)); } // <-- for testing purposes
  // VOLUMES_INIT is a signal that we have first package of volumes

}
//+----------------------------------------------- --------------------+

//+----------------------------------------------- --------------------+
//| Expert time function |
//+----------------------------------------------- --------------------+
void OnTimer()
{
   
   
}

    
int ArrayBsearchCorrect(datetime &array[], double value,
                        int count = WHOLE_ARRAY, int start = 0,
                        int direction = MODE_ASCEND)
{
   if(ArraySize(array)==0) return(-1);   
   int i = ArrayBsearch(array, (datetime)value, count, start, direction);
   if (value != array[i])
   {
      i = -1;
   }
   return(i);
}

void SortDictionary(datetime &keys[], double &values[], double &values2[],
                    int sortDirection = MODE_ASCEND)
{
   datetime keyCopy[];
   double valueCopy[];
   double valueCopy2[];   
   ArrayCopy(keyCopy, keys);
   ArrayCopy(valueCopy, values);
   ArrayCopy(valueCopy2, values2);   
   ArraySort(keys, WHOLE_ARRAY, 0, sortDirection);
   for (int i = 0; i < MathMin(ArraySize(keys), ArraySize(values)); i++)
   {
      values[ArrayBsearch(keys, keyCopy[i])] = valueCopy[i];
      values2[ArrayBsearch(keys, keyCopy[i])] = valueCopy2[i];      
   }
}

    
int VOLUMES_SetData()
{

  int k=0,i;
  
  string ExtraData="AUTO";
  string MetaTrader_GMT="AUTO";
  string ver="4.1";
  int Days_in_History=1;
  datetime Custom_Start_time=D'2017.01.01 00:00';
  datetime Custom_End_time=D'2017.01.01 00:00';
  
  i = Send_Query(k,indicator_client, Symbol(), Period(), TimeToStr(TimeCurrent()), TimeToStr(Time[0]), ExtraData, TimeToStr(last_loaded),MetaTrader_GMT,ver,Days_in_History,TimeToStr(Custom_Start_time),TimeToStr (Custom_End_time),AccountCompany(),AccountNumber());

  if (i < 0) { Alert("Error during query registration"); return -1; }
  return 1;
}  

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
   Print("response 154 ",response);
   if (length==0) { return 0; }

    if(StringLen(response)>1)
    {
      Print("response 157 ",response);
      len=StringSplit(response,StringGetCharacter("\n",0),result);                
      if(!len) { return 0; }
      MessageFromServer=result[0];
      
      for(i=1;i<len;i++)
      {
        if(StringLen(result[i])==0) continue;
        StringSplit(result[i],StringGetCharacter(";",0),bardata);                
        td_index=ArraySize(TIME_Array);
        Print("tdindex 168: ",td_index);
        index = (double)StrToTime(bardata[0]);
        ask_value= StringToDouble(bardata[1]);
        bid_value= StringToDouble(bardata[2])*(ReverseChart_SET?-1:1);        

        
        if(index==0) continue;
        iBase = ArrayBsearchCorrect(TIME_Array, index );
        if (iBase >= 0) { td_index=iBase; }
        if(td_index>=ArraySize(TIME_Array))
        {
           ArrayResize(TIME_Array, td_index+1);
           ArrayResize(VOLUME_Array, td_index+1);
           ArrayResize(DELTA_Array, td_index+1);           
        }
        else { if((VOLUME_Array[td_index])>(ask_value) && td_index>=ArraySize(TIME_Array)-2) { ask_value=VOLUME_Array[td_index]; bid_value=DELTA_Array[td_index];} }
    
        TIME_Array[td_index] = (datetime)index;
        VOLUME_Array[td_index] = ask_value;
        DELTA_Array[td_index] = bid_value;        
      
      }
      valid=ArraySize(TIME_Array);
      
      if (valid>0)
      {
       SortDictionary(TIME_Array,VOLUME_Array,DELTA_Array);
       int lastindex = ArraySize(TIME_Array);
       last_loaded=TIME_Array[lastindex-1];  
       if(last_loaded>Time[0])last_loaded=Time[0];        
       VOLUMES_INIT=true;
      }

    }
    return(1);
}


int VOLUME_by_index(int ix, bool BrokehHour=true)
{
      if(ArraySize(TIME_Array)<2) return 0;
      if(ArraySize(Time) <= ix) return 0;
      
      int iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] );

      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 1*60 ); } // 1 Min Broken Hour
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 2*60 ); } // 1 Min Broken Hour      
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 3*60 ); } // 1 Min Broken Hour            
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 4*60 ); } // 1 Min Broken Hour                  
      if (iBase < 0 && Period() >= PERIOD_M15 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 5*60 ); } // 5 Min Broken Hour      
      if (iBase < 0 && Period() >= PERIOD_H1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 30*60 ); } // 35 Min Broken Hour / ES      
      if (iBase < 0 && Period() >= PERIOD_H1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 35*60 ); } // 35 Min Broken Hour / ES
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 60*60 ); } // 60 Min Broken Hour / ES      
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 60*60 ); } // 60 Min Broken Hour / ES            
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 2*60*60 ); } // 120 Min Broken Hour / ES            
      if (iBase < 0 && Period() >= PERIOD_W1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 24*60*60); } // 35 Min Broken Hour / ES      
      
      
      if (iBase >= 0)
      {
         return (int)VOLUME_Array[iBase];
      }
         
      return 0;
}

int DELTA_by_index(int ix,bool BrokehHour=true)
{
      if(ArraySize(TIME_Array)<2) return 0;
      if(ArraySize(Time) <= ix) return 0;
      
      int iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] );
      //Print("kuy: ",TIME_Array[0],TIME_Array[1]);

      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 1*60 ); } // 1 Min Broken Hour
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 2*60 ); } // 1 Min Broken Hour      
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 3*60 ); } // 1 Min Broken Hour            
      if (iBase < 0 && Period() >= PERIOD_M5 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 4*60 ); } // 1 Min Broken Hour                  
      if (iBase < 0 && Period() >= PERIOD_M15 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 5*60 ); } // 5 Min Broken Hour      
      if (iBase < 0 && Period() >= PERIOD_H1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 30*60 ); } // 35 Min Broken Hour / ES      
      if (iBase < 0 && Period() >= PERIOD_H1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 35*60 ); } // 35 Min Broken Hour / ES
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] - 60*60 ); } // 60 Min Broken Hour / ES      
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 60*60 ); } // 60 Min Broken Hour / ES            
      if (iBase < 0 && Period() >= PERIOD_H4 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 2*60*60 ); } // 120 Min Broken Hour / ES            
      if (iBase < 0 && Period() >= PERIOD_W1 && BrokehHour) { iBase = ArrayBsearchCorrect(TIME_Array, Time[ix] + 24*60*60); } // 35 Min Broken Hour / ES      
      
      
      if (iBase >= 0)
      {
         Print("iBAse have valueeeeeeeeeeeeeeeeeeeeeeeeee");
         return (int)DELTA_Array[iBase];
      }
         
      return 0;
}

/*
int SetData()
{
  if(query_in_progress) return -1;
  query_in_progress=true;

  int k=0,i=0;
  if(clusterdelta_client!="")
  {
   i = Send_Query(k,clusterdelta_client, Symbol(), Period(), TimeToStr(TimeCurrent()), TimeToStr(Time[0]), Instrument, TimeToStr(last_loaded),MetaTrader_GMT,ver,Days_in_History,TimeToStr(Custom_Start_time),TimeToStr(Custom_End_time),AccountCompany(),AccountNumber());     
  } 

  if (i < 0) { Alert ("Error during query registration"); return -1; }
  if(Period()<=60) {
    i = Online_Subscribe(k,clusterdelta_client, Symbol(), Period(), TimeToStr(TimeCurrent()), TimeToStr(Time[0]), Instrument, TimeToStr(last_loaded),MetaTrader_GMT,ver,Days_in_History,TimeToStr(Custom_Start_time),TimeToStr(Custom_End_time),AccountCompany(),AccountNumber());     
  }
  
  return 1;
}  


int GetData()
{
 string response="";
   int length=0;
   int valid=0;   
   int len=0,td_index;
   int i=0;
   double index;   
   int iBase=0;
   double volume_value=0, delta_value=0;
   string result[];
   string bardata[];   
   
   response = Receive_Information(length, clusterdelta_client);
   if (length==0) { return 0; }
   query_in_progress=false;                   
    if(StringLen(response)>1) // if we got response (no care how), convert it to mt4 buffers
    {
      
      len=StringSplit(response,StringGetCharacter("\n",0),result);                
      if(!len) { return 0; }
      MessageFromServer=result[0];
      
      for(i=1;i<len;i++)
      {
        if(ArraySize(result)<=i) continue;
        if(StringLen(result[i])==0) continue;
        StringSplit(result[i],StringGetCharacter(";",0),bardata);                
        td_index=ArraySize(TimeData);
        index = StrToTime(bardata[0]);
        volume_value= StringToDouble(bardata[1]);
        delta_value= StringToDouble(bardata[2])*(ReverseChart_SET?-1:1);        
        
        if(index==0) continue;
        iBase = ArrayBsearchCorrect(TimeData, index ); 
        if (iBase >= 0) { td_index=iBase; } 
        if(td_index>=ArraySize(TimeData))
        {
           ArrayResize(TimeData, td_index+1);
           ArrayResize(VolumeData, td_index+1);
           ArrayResize(DeltaData, td_index+1);           
        } else { if((VolumeData[td_index])>(volume_value) && td_index>=ArraySize(TimeData)-2) { volume_value=VolumeData[td_index]; delta_value=DeltaData[td_index];}  }
    
        TimeData[td_index]= index;
        VolumeData[td_index] = volume_value;
        DeltaData[td_index] = delta_value;        
      
      }
      valid=ArraySize(TimeData);
      if (valid>0)
      {
       SortDictionary(TimeData,VolumeData,DeltaData);
       int lastindex = ArraySize(TimeData);
       last_loaded=TimeData[lastindex-1];  
       if(lastindex>5)
       {
         last_loaded=TimeData[lastindex-6];  
       }
       if(last_loaded>Time[0])last_loaded=Time[0]; 
      } 
      if(StringLen(MessageFromServer)>8 && OneTimeAlert==0 )
      { 
          int gmt_shift_left_bracket = StringFind(MessageFromServer,"[");
          int gmt_shift_right_bracket = StringFind(MessageFromServer,"]");
          if (gmt_shift_left_bracket>0 && gmt_shift_right_bracket)
          {
            GMT = StringSubstr(MessageFromServer,gmt_shift_left_bracket+1,gmt_shift_right_bracket-gmt_shift_left_bracket-1);
            GMT_SET=1;
          }
      
          int w=ChartWindowFind();
          if(w<0) w=0;
          ObjectCreate(0,"InfoMessage"+"_"+indicator_id,OBJ_LABEL,w,0,0); 
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_CORNER, 1);    
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);              
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_XDISTANCE, 10);
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_YDISTANCE, 10);
          ObjectSetString (0,"InfoMessage"+"_"+indicator_id, OBJPROP_TEXT,MessageFromServer);
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_COLOR, LightGreen);
          ObjectSetInteger(0,"InfoMessage"+"_"+indicator_id, OBJPROP_FONTSIZE, Font_Size); 
          OneTimeAlert=1; 
      } else { ObjectDelete("InfoMessage"+"_"+indicator_id);  }
      
      if (StringLen(MessageFromServer)>8 && OneTimeAlert==1) { Print("MT4 Time ",TimeToStr(TimeCurrent()),",  data source info:", MessageFromServer ); OneTimeAlert=2; }       
    }
    return (1);
}
int GetOnline()
{
   string response="";
   int length=0;   
   string key="";
   string mydata="";
   int block=0;
   if(Period()>60) return 0;
   response = Online_Data(length, clusterdelta_client);
   if(length  == 0) { return 0; }
   if(ArraySize(TimeData)<4) { return 0; }
   int key_i=StringFind(response, ":");
   key = StringSubstr(response,0,key_i);
   mydata =  StringSubstr(response,key_i+1);
   int compare_minutes ;
   string result[];
   string bardata[];
   if(key == clusterdelta_client)
   {

      StringSplit(mydata,StringGetCharacter("!",0),result);
      
      if(!GMT_SET)
      {
        StringSplit(result[2],StringGetCharacter(";",0),bardata);      
        

        if(VolumeData[ArraySize(VolumeData)-3] == StringToDouble(bardata[1])) // 3-rd bar in stream is 3rd in series
        {
          StringSplit(result[0],StringGetCharacter(";",0),bardata);                      
          compare_minutes = int( (double)(TimeData[ArraySize(TimeData)-1]) - StringToDouble(bardata[0]) );
          GMT = int(compare_minutes / 3600);
          GMT_SET=0;          

        } else
        if(VolumeData[ArraySize(VolumeData)-2] == StringToDouble(bardata[1])) // 3-rd bar in stream is 3rd in series
        {
          compare_minutes = int( (double)(TimeData[ArraySize(TimeData)-2]) - StringToDouble(bardata[0]) );
          GMT = int(compare_minutes / 3600);
          GMT_SET=0;
        } 
      }

          StringSplit(result[0],StringGetCharacter(";",0),bardata);                
          UpdateArray(TimeData, VolumeData,DeltaData, StringToDouble(bardata[0])+3600*GMT, StringToDouble(bardata[1]),StringToDouble(bardata[2])*(ReverseChart_SET?-1:1));
          StringSplit(result[1],StringGetCharacter(";",0),bardata);               
          UpdateArray(TimeData, VolumeData,DeltaData, StringToDouble(bardata[0])+3600*GMT, StringToDouble(bardata[1]),StringToDouble(bardata[2])*(ReverseChart_SET?-1:1));
//          StringSplit(result[2],StringGetCharacter(";",0),bardata);               
//          UpdateArray(TimeData, VolumeData,DeltaData, StringToDouble(bardata[0])+3600*GMT, StringToDouble(bardata[1]),StringToDouble(bardata[2]));


   }
   return 1; 
}

void UpdateArray(datetime& td[],double& ad[], double& bd[], double dtp, double dta, double dtb)
{
    datetime indexx = (datetime)dtp;

    int i=ArraySize(td);    
    int iBase = ArrayBsearchCorrect(td, indexx );

    if (iBase >= 0) { i=iBase;  } 

    if(i>=ArraySize(td))
    {      
      ArrayResize(td, i+1);
      ArrayResize(ad, i+1);
      ArrayResize(bd, i+1);      
    } else { 
      if(ad[i]>dta  && i>=ArraySize(td)-2) { dta=ad[i]; dtb=bd[i]; }       // volume
      //if((ad[i]+bd[i])>(dta+dtb)  && i>=ArraySize(td)-2) { dta=ad[i]; dtb=bd[i]; }             
    }
    
    td[i]= (datetime)dtp;
    ad[i]= dta;
    bd[i]= dtb;
}
*/