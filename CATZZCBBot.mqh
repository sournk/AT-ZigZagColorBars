//+------------------------------------------------------------------+
//|                                                   CATZZCBBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
#include <Math\Stat\Math.mqh>
#include <Trade\OrderInfo.mqh>

//#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh> 

#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
//#include "Include\DKStdLib\Common\DKStdLib.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CATZZCBInputs.mqh"


class CATZZCBBot : public CDKBaseBot<CATZZCBBotInputs> {
public: // SETTINGS

protected:
  MqlDateTime                SignalTime;
  MqlDateTime                CloseTime;
  
  CArrayString               WeekDayAllowedLong;
  CArrayString               WeekDayAllowedShort;
  
  CArrayString               WeekDayCloseLong;
  CArrayString               WeekDayCloseShort;
  
  datetime                   NextM1Time;
  
  double                     OpenLot;
  datetime                   OpenDT;
  ENUM_POSITION_TYPE         OpenDir;
  
public:
  // Constructor & init
  //void                       CATZZCBBot::CATZZCBBot(void);
  void                       CATZZCBBot::~CATZZCBBot(void);
  void                       CATZZCBBot::InitChild();
  bool                       CATZZCBBot::Check(void);

  // Event Handlers
  void                       CATZZCBBot::OnDeinit(const int reason);
  void                       CATZZCBBot::OnTick(void);
  void                       CATZZCBBot::OnTrade(void);
  void                       CATZZCBBot::OnTimer(void);
  double                     CATZZCBBot::OnTester(void);
  void                       CATZZCBBot::OnBar(void);
  
  // Bot's logic
  void                       CATZZCBBot::UpdateComment(const bool _ignore_interval = false);
  
  ulong                      CATZZCBBot::OpenPosOnSignal();
  
  void                       CATZZCBBot::Draw();
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CATZZCBBot::~CATZZCBBot(void){
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CATZZCBBot::InitChild() {
  NextM1Time = TimeCurrent();

  // Put code here

  UpdateComment(true);
}

//+------------------------------------------------------------------+
//| Check bot's params
//+------------------------------------------------------------------+
bool CATZZCBBot::Check(void) {
  if(!CDKBaseBot<CATZZCBBotInputs>::Check())
    return false;
    
  if(!Inputs.InitAndCheck()) {
    Logger.Critical(Inputs.LastErrorMessage, true);
    return false;
  }
  
  // Put your additional checks here
  
  return true;
}

//+------------------------------------------------------------------+
//| OnDeinit Handler
//+------------------------------------------------------------------+
void CATZZCBBot::OnDeinit(const int reason) {
}

//+------------------------------------------------------------------+
//| OnTick Handler
//+------------------------------------------------------------------+
void CATZZCBBot::OnTick(void) {
  CDKBaseBot<CATZZCBBotInputs>::OnTick(); // Check new bar and show comment
  
  // 03. Channels update
  bool need_update = false;

  // 06. Update comment
  if(need_update)
    UpdateComment(true);
}

//+------------------------------------------------------------------+
//| OnBar Handler
//+------------------------------------------------------------------+
void CATZZCBBot::OnBar(void) {
}

//+------------------------------------------------------------------+
//| OnTrade Handler
//+------------------------------------------------------------------+
void CATZZCBBot::OnTrade(void) {
  CDKBaseBot<CATZZCBBotInputs>::OnTrade();
}

//+------------------------------------------------------------------+
//| OnTimer Handler
//+------------------------------------------------------------------+
void CATZZCBBot::OnTimer(void) {
  UpdateComment();
  CDKBaseBot<CATZZCBBotInputs>::OnTimer();
}

//+------------------------------------------------------------------+
//| OnTester Handler
//+------------------------------------------------------------------+
double CATZZCBBot::OnTester(void) {
  return 0;
}



//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Bot's logic
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Updates comment
//+------------------------------------------------------------------+
void CATZZCBBot::UpdateComment(const bool _ignore_interval = false) {
  ClearComment();

  //datetime dt_curr = TimeCurrent();
  //AddCommentLine(StringFormat("Time:   %s", TimeToString(TimeCurrent())));
  //AddCommentLine(StringFormat("Signal: %s in %s", TimeToString(StructToTime(SignalTime)), TimeDurationToString(StructToTime(SignalTime)-dt_curr)));
  //AddCommentLine(StringFormat("Close:  %s in %s", TimeToString(StructToTime(CloseTime)), TimeDurationToString(StructToTime(CloseTime)-dt_curr)));

  ShowComment(_ignore_interval);     
}

//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CATZZCBBot::OpenPosOnSignal() {
  // 07. Open pos
  ulong ticket = 0;
//  double lot = CalcLot();
//  lot = AdjustLot(lot);
//  
//  string comment = StringFormat("%s: %s", Logger.Name, TimeToString(TimeCurrent()));
//  if(dir > 0) 
//    ticket = Trade.Buy(lot, Sym.Name(), 0, 0, 0, comment);
//  else
//    ticket = Trade.Sell(lot, Sym.Name(), 0, 0, 0, comment);
//  
//  if(ticket > 0) 
//    SaveTradeToTerminal(dir, lot, dt_curr);
//  
//  Logger.Assert(ticket > 0,
//                LSF(StringFormat("RET_CODE=%d; TICKET=%I64u; DIR=%d",
//                                 Trade.ResultRetcode(),
//                                 ticket,
//                                 dir)),
//                WARN, ERROR);
//
  return ticket;
}


void CATZZCBBot::Draw() {

}

