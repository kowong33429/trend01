//+------------------------------------------------------------------+
//|                                   Parabolic SAR and 3 SMA EA.mq4 |
//|                              Copyright © 2008, TradingSytemForex |
//|                                http://www.tradingsystemforex.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2008, TradingSytemForex"
#property link "http://www.tradingsystemforex.com"

#define eaN "Parabolic SAR and 3 SMA EA"

extern string separator1="---------------- Entry Settings";
extern bool EnterOnlyAtSarCross=true;
extern bool EnterOnlyAtSMACross=false;
extern double Step=0.02;
extern double Maximum=0.2;
extern int SMAPeriod1=30;
extern int SMAPeriod2=50;
extern int SMAPeriod3=100;
extern string separator2="---------------- Lot Management";
extern double Lots=0.1;
extern bool RiskManagement=false; //money management
extern double RiskPercent=10; //risk in percentage
extern bool Martingale=false; //martingale
extern double Multiplier=1.5; //multiplier
extern double MinProfit=0; //minimum profit to apply the martingale
extern string separator3="---------------- TP SL TS BE";
bool EnableHiddenSL=false;
int HiddenSL=5; //stop loss under 15 pîps
bool EnableHiddenTP=false;
int HiddenTP=10; //take profit under 10 pîps
extern int StopLoss=0; //stop loss
extern int TakeProfit=0; //take profit
extern int TrailingStop=0; //trailing stop
int TSStep=1; //trailing step
extern int BreakEven=0; //breakeven
extern string separator4="---------------- Extras";
extern bool Reverse=false;
extern bool AddPositions=true; //positions cumulated
extern int MaxOrders=100; //maximum number of orders
extern bool MAFilter=false; //moving average filter
extern int MAPeriod=20;
extern int MAMethod=1;
extern int MAPrice=0;
extern bool TimeFilter=false; //time filter
extern int StartHour=8;
extern int EndHour=21;
extern int Magic=0;

int Slip=3;static int TL=0;double Balance=0.0;int err=0;int TK;

//start function
int start(){int j=0,limit=1;double BV=0,SV=0;BV=0;SV=0;if(CntO(OP_BUY,Magic)>0)TL=1;if(CntO(OP_SELL,Magic)>0)TL=-1;
for(int i=1;i<=limit;i++){

//time filter
string TIFI="false";string CLTIFI="false";
if(TimeFilter==false||(TimeFilter&&((EndHour>StartHour&&(Hour()>=StartHour&&Hour()<=EndHour))||(StartHour>EndHour&&!(Hour()>=EndHour&&Hour()<=StartHour))))){TIFI="true";}
if(TimeFilter&&((EndHour>StartHour&&!(Hour()>=StartHour&&Hour()<=EndHour))||(StartHour>EndHour&&(Hour()>=EndHour&&Hour()<=StartHour)))){CLTIFI="true";}

//ma filter
double MAF=iMA(Symbol(),0,MAPeriod,0,MAMethod,MAPrice,i);string MAFIB="false";string MAFIS="false";
if((MAFilter==false)||(MAFilter&&Bid>MAF))MAFIB="true";if((MAFilter==false)||(MAFilter&&Ask<MAF))MAFIS="true";

//main signal
double SAR1=iSAR(NULL,0,Step,Maximum,i+1);
double SAR2=iSAR(NULL,0,Step,Maximum,i);
double SMA1a=iMA(Symbol(),0,SMAPeriod1,0,MODE_SMA,PRICE_CLOSE,i+1);
double SMA1b=iMA(Symbol(),0,SMAPeriod1,0,MODE_SMA,PRICE_CLOSE,i);
double SMA2a=iMA(Symbol(),0,SMAPeriod2,0,MODE_SMA,PRICE_CLOSE,i+1);
double SMA2b=iMA(Symbol(),0,SMAPeriod2,0,MODE_SMA,PRICE_CLOSE,i);
double SMA3a=iMA(Symbol(),0,SMAPeriod3,0,MODE_SMA,PRICE_CLOSE,i+1);
double SMA3b=iMA(Symbol(),0,SMAPeriod3,0,MODE_SMA,PRICE_CLOSE,i);
string SBUY="false";string SSEL="false";
if(
(EnterOnlyAtSarCross==false&&EnterOnlyAtSMACross==false&&SMA1b>SMA2b&&SMA2b>SMA3b&&Open[i]>SAR2)||
(EnterOnlyAtSarCross==true&&EnterOnlyAtSMACross==false&&SMA1b>SMA2b&&SMA2b>SMA3b&&Open[i+1]<SAR1&&Open[i]>SAR2)||
(EnterOnlyAtSarCross==false&&EnterOnlyAtSMACross==true&&!(SMA1a>SMA2a&&SMA2a>SMA3a)&&SMA1b>SMA2b&&SMA2b>SMA3b&&Open[i]>SAR2)||
(EnterOnlyAtSarCross==true&&EnterOnlyAtSMACross==true&&!(SMA1a>SMA2a&&SMA2a>SMA3a)&&SMA1b>SMA2b&&SMA2b>SMA3b&&Open[i+1]<SAR1&&Open[i]>SAR2)
)SBUY="true";if(
(EnterOnlyAtSarCross==false&&EnterOnlyAtSMACross==false&&SMA1b<SMA2b&&SMA2b<SMA3b&&Open[i]<SAR2)||
(EnterOnlyAtSarCross==true&&EnterOnlyAtSMACross==false&&SMA1b<SMA2b&&SMA2b<SMA3b&&Open[i+1]>SAR1&&Open[i]<SAR2)||
(EnterOnlyAtSarCross==false&&EnterOnlyAtSMACross==true&&!(SMA1a<SMA2a&&SMA2a<SMA3a)&&SMA1b<SMA2b&&SMA2b<SMA3b&&Open[i]<SAR2)||
(EnterOnlyAtSarCross==true&&EnterOnlyAtSMACross==true&&!(SMA1a<SMA2a&&SMA2a<SMA3a)&&SMA1b<SMA2b&&SMA2b<SMA3b&&Open[i+1]>SAR1&&Open[i]<SAR2)
)SSEL="true";
string stopsell, stopbuy;
//entry conditions
if(!(stopbuy=="true")&&!(Close[i]<SMA1b)&&MAFIB=="true"&&SBUY=="true"&&TIFI=="true"){if(Reverse)SV=1;else {BV=1;stopsell="false";}break;}
if(!(stopsell=="true")&&!(Close[i]>SMA1b)&&MAFIS=="true"&&SSEL=="true"&&TIFI=="true"){if(Reverse)BV=1;else {SV=1;stopbuy="false";}break;}}

//risk management
bool MM=RiskManagement;
if(MM){if(RiskPercent<0.1||RiskPercent>100){Comment("Invalid Risk Value.");return(0);}
else{Lots=MathFloor((AccountFreeMargin()*AccountLeverage()*RiskPercent*Point*100)/(Ask*MarketInfo(Symbol(),MODE_LOTSIZE)*
MarketInfo(Symbol(),MODE_MINLOT)))*MarketInfo(Symbol(),MODE_MINLOT);}}
if(MM==false){Lots=Lots;}

//martingale
if(Balance!=0.0&&Martingale==True){if(Balance>AccountBalance())Lots=Multiplier*Lots;else if((Balance+MinProfit)<AccountBalance())Lots=Lots/Multiplier;
else if((Balance+MinProfit)>=AccountBalance()&&Balance<=AccountBalance())Lots=Lots;}Balance=AccountBalance();if(Lots<0.01)Lots=0.01;if(Lots>100)Lots=100;

//positions initialization
int cnt=0,OP=0,OS=0,OB=0,CS=0,CB=0;OP=0;for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if((OrderType()==OP_SELL||OrderType()==OP_BUY)&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0))OP=OP+1;}
if(OP>=1){OS=0; OB=0;}OB=0;OS=0;CB=0;CS=0;int SL=StopLoss;int TP=TakeProfit;

//entry conditions verification
if(SV>0){OS=1;OB=0;}if(BV>0){OB=1;OS=0;}

//conditions to close position
if((SV>0)||(Close[i]<SMA1b)||(CLTIFI=="true")||(EnableHiddenSL&&(OrderOpenPrice()-Bid)/Point>=HiddenSL)||(EnableHiddenTP&&(Ask-OrderOpenPrice())/Point>=HiddenTP)){CB=1;stopbuy="true";}
if((BV>0)||(Close[i]>SMA1b)||(CLTIFI=="true")||(EnableHiddenSL&&(Ask-OrderOpenPrice())/Point>=HiddenSL)||(EnableHiddenTP&&(OrderOpenPrice()-Bid)/Point>=HiddenTP)){CS=1;stopsell="true";}
for(cnt=0;cnt<OrdersTotal();cnt++){OrderSelect(cnt,SELECT_BY_POS,MODE_TRADES);
if(OrderType()==OP_BUY&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){if(CB==1){OrderClose(OrderTicket(),OrderLots(),Bid,Slip,Red);return(0);}}
if(OrderType()==OP_SELL&&OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){if(CS==1){OrderClose(OrderTicket(),OrderLots(),Ask,Slip,Red);return(0);}}}
double SLI=0,TPI=0;int TK=0;

//open position
if((AddP()&&AddPositions&&OP<=MaxOrders)||(OP==0&&!AddPositions)){
if(OS==1){if(TP==0)TPI=0;else TPI=Bid-TP*Point;if(SL==0)SLI=0;else SLI=Bid+SL*Point;
TK=OrderSend(Symbol(),OP_SELL,Lots,Bid,Slip,SLI,TPI,eaN,Magic,0,Red);OS=0;return(0);}	
if(OB==1){if(TP==0)TPI=0;else TPI=Ask+TP*Point;if(SL==0)SLI=0;else SLI=Ask-SL*Point;
TK=OrderSend(Symbol(),OP_BUY,Lots,Ask,Slip,SLI,TPI,eaN,Magic,0,Lime);OB=0;return(0);}}
for(j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS,MODE_TRADES)){if(OrderSymbol()==Symbol()&&((OrderMagicNumber()==Magic)||Magic==0)){TrP();}}}return(0);}

//number of orders
int CntO(int Type,int Magic){int _CntO;_CntO=0;
for(int j=0;j<OrdersTotal();j++){OrderSelect(j,SELECT_BY_POS,MODE_TRADES);if(OrderSymbol()==Symbol()){
if((OrderType()==Type&&(OrderMagicNumber()==Magic)||Magic==0))_CntO++;}}return(_CntO);}

//trailing stop and breakeven
void TrP(){int BE=BreakEven;int TS=TrailingStop;double pb,pa,pp;pp=MarketInfo(OrderSymbol(),MODE_POINT);if(OrderType()==OP_BUY){pb=MarketInfo(OrderSymbol(),MODE_BID);if(BE>0){
if((pb-OrderOpenPrice())>BE*pp){if((OrderStopLoss()-OrderOpenPrice())<0){ModSL(OrderOpenPrice()+0*pp);}}}if(TS>0){if((pb-OrderOpenPrice())>TS*pp){
if(OrderStopLoss()<pb-(TS+TSStep-1)*pp){ModSL(pb-TS*pp);return;}}}}if(OrderType()==OP_SELL){pa=MarketInfo(OrderSymbol(),MODE_ASK);
if(BE>0){if((OrderOpenPrice()-pa)>BE*pp){if((OrderOpenPrice()-OrderStopLoss())<0){ModSL(OrderOpenPrice()-0*pp);}}}if(TS>0){if(OrderOpenPrice()-pa>TS*pp){
if(OrderStopLoss()>pa+(TS+TSStep-1)*pp||OrderStopLoss()==0){ModSL(pa+TS*pp);return;}}}}}

//stop loss modification function
void ModSL(double ldSL){bool fm;fm=OrderModify(OrderTicket(),OrderOpenPrice(),ldSL,OrderTakeProfit(),0,CLR_NONE);}

//add positions function
bool AddP(){int _num=0; int _ot=0;
for (int j=0;j<OrdersTotal();j++){if(OrderSelect(j,SELECT_BY_POS)==true && OrderSymbol()==Symbol()&&OrderType()<3&&((OrderMagicNumber()==Magic)||Magic==0)){	
_num++;if(OrderOpenTime()>_ot) _ot=OrderOpenTime();}}if(_num==0) return(true);if(_num>0 && ((Time[0]-_ot))>0) return(true);else return(false);

//not enough money message to continue the martingale
if(TK<0){if (GetLastError()==134){err=1;Print("NOT ENOGUGHT MONEY!!");}return (-1);}}