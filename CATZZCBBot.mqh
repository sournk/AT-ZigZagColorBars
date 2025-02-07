//+------------------------------------------------------------------+
//|                                                   CATZZCBBot.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+
//#include <Generic\HashMap.mqh>
//#include <Arrays\ArrayString.mqh>
//#include <Arrays\ArrayObj.mqh>
//#include <Arrays\ArrayDouble.mqh>
//#include <Arrays\ArrayLong.mqh>
//#include <Trade\TerminalInfo.mqh>
//#include <Trade\DealInfo.mqh>
//#include <Charts\Chart.mqh>
//#include <Math\Stat\Math.mqh>
//#include <Trade\OrderInfo.mqh>

//#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
//#include <ChartObjects\ChartObjectsArrows.mqh> 

//#include "Include\DKStdLib\Analysis\DKChartAnalysis.mqh"
#include "Include\DKStdLib\Common\DKNumPy.mqh"
#include "Include\DKStdLib\Common\CDKBarTag.mqh"

//#include "Include\DKStdLib\Common\CDKString.mqh"
//#include "Include\DKStdLib\Logger\CDKLogger.mqh"
//#include "Include\DKStdLib\TradingManager\CDKPositionInfo.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTrade.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStep.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLStepSpread.mqh"
//#include "Include\DKStdLib\TradingManager\CDKTSLFibo.mqh"
#include "Include\DKStdLib\TradingManager\CDKTSLPriceChannel.mqh"
//#include "Include\DKStdLib\Drawing\DKChartDraw.mqh"
//#include "Include\DKStdLib\History\DKHistory.mqh"

#include "Include\DKStdLib\Common\CDKString.mqh"
#include "Include\DKStdLib\Common\DKDatetime.mqh"
#include "Include\DKStdLib\Arrays\CDKArrayString.mqh"
#include "Include\DKStdLib\Bot\CDKBaseBot.mqh"

#include "CATZZCBInputs.mqh"

enum ENUM_SIG_MODE {
  NONE = -1,
  BAR  = 0,
  DUA  = 1,
  REV  = 2,
};

class CATZZCBBot : public CDKBaseBot<CATZZCBBotInputs> {
public: // SETTINGS

protected:
  CDKBarTag                  ZZTopBT;
  CDKBarTag                  ZZBotBT;
  CDKBarTag                  SigBT;
  ENUM_SIG_MODE              SigBarType;
  int                        SigDir;
  CDKBarTag                  EPBySigBT;
  int                        EPDir;
  
  datetime                   CloseTime;
  
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

  
  int                        CATZZCBBot::GetZZDir();
  int                        CATZZCBBot::GetSignal();
  
  bool                       CATZZCBBot::IsBSFilterPass_NoPosInMarket();
  bool                       CATZZCBBot::IsBSFilterPass_AllowedTime();
  bool                       CATZZCBBot::IsASFilterPass_FirstEntryOnZZRib();
  bool                       CATZZCBBot::IsASFilterPass_WPR();
  
  ulong                      CATZZCBBot::OpenPosOnSignal();
  
  bool                       CATZZCBBot::CloseOnReversal();
  bool                       CATZZCBBot::CloseOnTime();
  
  bool                       CATZZCBBot::UpdateTSL();
  
  void                       CATZZCBBot::DrawZZ();
  void                       CATZZCBBot::DrawTSL(const ulong _ticket, const double _sl);
};

//+------------------------------------------------------------------+
//| Destructor
//+------------------------------------------------------------------+
void CATZZCBBot::~CATZZCBBot(void){
}

string MyStr() {
  Print("123123");
  return "123123";
}

//+------------------------------------------------------------------+
//| Inits bot
//+------------------------------------------------------------------+
void CATZZCBBot::InitChild() {
  // Put code here
  ZZBotBT.Init(Sym.Name(), TF);
  ZZTopBT.Init(Sym.Name(), TF);
  SigBT.Init(Sym.Name(), TF);
  EPBySigBT.Init(Sym.Name(), TF);
  EPDir = 0;
  SigBarType = -1;
  
  CloseTime = StringToTime(Inputs.EXT_TIM);
  
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
  if(!(Inputs.SIG_MOD_BAR_ENB || Inputs.SIG_MOD_DUA_ENB || Inputs.SIG_MOD_REV_ENB)) {
    Logger.Critical("Включите как минимум один режим сигналов: 'SIG_MOD_BAR_ENB' или 'SIG_MOD_DUA_ENB' или 'SIG_MOD_REV_ENB'", true);
    return false;    
  }
  
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
  UpdateTSL();
  OpenPosOnSignal();
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
  CloseOnTime();
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
//| Get ZigZag current dir
//+------------------------------------------------------------------+
int CATZZCBBot::GetZZDir() {
  int dir = 0;
  string msg = "";
  
  // Load ZZ
  double buf_zz_top[]; ArraySetAsSeries(buf_zz_top, true);
  double buf_zz_bot[]; ArraySetAsSeries(buf_zz_bot, true);
  if(CopyBuffer(Inputs.IndZZHndl, 0, 0, Inputs.SIG_DPT, buf_zz_top) >= (int)Inputs.SIG_DPT &&
     CopyBuffer(Inputs.IndZZHndl, 1, 0, Inputs.SIG_DPT, buf_zz_bot) >= (int)Inputs.SIG_DPT) {
    // Find ZZ picks
    int zz_top_idx = ArrayFindFirstConditional(buf_zz_top, true, 0.0);
    int zz_bot_idx = ArrayFindFirstConditional(buf_zz_bot, true, 0.0);
    ZZTopBT.Init(Sym.Name(), TF, zz_top_idx, 
                 zz_top_idx >= 0 ? buf_zz_top[zz_top_idx] : 0.0);
    ZZBotBT.Init(Sym.Name(), TF, zz_bot_idx, 
                 zz_bot_idx >= 0 ? buf_zz_bot[zz_bot_idx] : 0.0);
    
    // Get Dir using ZZ  
    if(zz_bot_idx >= (int)Inputs.SIG_ZZ_STR && zz_top_idx >= (int)Inputs.SIG_ZZ_STR) {
      if(zz_bot_idx > zz_top_idx) dir = -1;
      if(zz_bot_idx < zz_top_idx) dir = +1;
    }  
    else
      msg = "Нет двух вершин";
  }
  else {
    msg = "CopyBuffer(ZigZag) failed";
    LSF_ERROR(msg);
  }

  LSF_DEBUG(StringFormat("ZZ_DIR=%d; ZZ_TOP=%s; ZZ_BOT=%s; MSG='%s'",
                         dir,
                         ZZTopBT.__repr__(true),
                         ZZBotBT.__repr__(true),
                         msg));
  
  return dir;
}

//+------------------------------------------------------------------+
//| Get Signal
//+------------------------------------------------------------------+
int CATZZCBBot::GetSignal() {
  int dir = 0;
  
  // Get ZZ dir
  int dir_zz = GetZZDir();
  if(dir_zz == 0) {
    LSF_INFO("RES=0; ZZ_DIR=0");
    return 0;  
  }

  // Load rates
  MqlRates buf_rates[]; ArraySetAsSeries(buf_rates, true);
  if(CopyRates(Sym.Name(), TF, 0, Inputs.SIG_DPT, buf_rates) < (int)Inputs.SIG_DPT){
    LSF_ERROR(StringFormat("RES=0; ZZ_DIR=%d; MSG='CopyRates() failed'", dir_zz));
    return 0;
  }    
    
  // Load Heiken
  double buf_heiken_o[]; ArraySetAsSeries(buf_heiken_o, true);
  double buf_heiken_c[]; ArraySetAsSeries(buf_heiken_c, true);
  if(CopyBuffer(Inputs.IndHeikenHndl, 0, 0, Inputs.SIG_DPT, buf_heiken_o) < (int)Inputs.SIG_DPT ||
     CopyBuffer(Inputs.IndHeikenHndl, 3, 0, Inputs.SIG_DPT, buf_heiken_c) < (int)Inputs.SIG_DPT) {
    LSF_ERROR(StringFormat("RES=0; ZZ_DIR=%d; MSG='CopyBuffer(Heiken) failed'", dir_zz));
    return 0;
  }
  
  string msg = "NONE";
  int zz_last_idx = MathMin(ZZBotBT.GetIndex(), ZZTopBT.GetIndex());
  int i = 0;
  int heiken_dir = 0;
  int bar_dir = 0;
  SigBarType = NONE;
  //for(i=zz_last_idx-1; i>=1; i--) {
  for(i=1; i>=1; i--) {
    heiken_dir = 0;
    if(buf_heiken_o[i] < buf_heiken_c[i]) heiken_dir = +1;
    if(buf_heiken_o[i] > buf_heiken_c[i]) heiken_dir = -1;
    
    bar_dir = 0;
    if(buf_rates[i].open < buf_rates[i].close) bar_dir = +1;
    if(buf_rates[i].open > buf_rates[i].close) bar_dir = -1;
    
    if(Inputs.SIG_MOD_BAR_ENB){
      if(dir_zz > 0 && bar_dir > 0) dir = +1;
      if(dir_zz < 0 && bar_dir < 0) dir = -1;
      if(dir != 0) {
        SigBarType = BAR;
        msg = StringFormat("MOD_BAR; BAR_DT=%s; BAR_DIR=%d", 
                           TimeToString(buf_rates[i].time), bar_dir);
        break;
      }
    }

    if(Inputs.SIG_MOD_DUA_ENB){
      if(dir_zz > 0 && heiken_dir > 0 && bar_dir > 0) dir = +1;
      if(dir_zz < 0 && heiken_dir < 0 && bar_dir < 0) dir = -1;
      if(dir != 0) {
        SigBarType = DUA;
        msg = StringFormat("MOD_DUA; BAR_DT=%s; BAR_DIR=%d; HEIKEN_DIR=%d", 
                           TimeToString(buf_rates[i].time), bar_dir, heiken_dir);
        break;
      }      
    }
    
    if(Inputs.SIG_MOD_REV_ENB){
      if(dir_zz > 0 && heiken_dir < 0 && bar_dir > 0) dir = +1;
      if(dir_zz < 0 && heiken_dir > 0 && bar_dir < 0) dir = -1;
      if(dir != 0) {
        SigBarType = REV;
        msg = StringFormat("MOD_REV; BAR_DT=%s; BAR_DIR=%d; HEIKEN_DIR=%d", 
                           TimeToString(buf_rates[i].time), bar_dir, heiken_dir);
        break;
      }      
    }
  }
  
  SigBT.Init(Sym.Name(), TF);
  if(dir != 0) 
    SigBT.Init(Sym.Name(), TF, buf_rates[i].time, buf_rates[i].close);
    
  LSF_ASSERT(dir != 0,
             StringFormat("RES=%d; ZZ_DIR=%d; MODE=%s",
                          dir, dir_zz, msg),
             INFO, DEBUG);
                               
  return dir;
}

//+------------------------------------------------------------------+
//| Filter passes if there's no pos in market
//+------------------------------------------------------------------+
bool CATZZCBBot::IsBSFilterPass_NoPosInMarket() {
  bool res = Poses.Total() <= 0;
  LSF_DEBUG(StringFormat("RES=%d; POS_CNT=%d", res, Poses.Total()));
  return res; 
}

//+------------------------------------------------------------------+
//| Filter passes if curr time is allowed
//+------------------------------------------------------------------+
bool CATZZCBBot::IsBSFilterPass_AllowedTime() {
  if(Inputs.EXT_TIM == "") {
    LSF_DEBUG("RES=0; EXT_TIM=''");
    return true;
  }
  
  datetime dt_curr = TimeCurrent();
  bool res = !IsTimeCurrentAfterUpdatedTimeToToday(CloseTime);
  
  LSF_DEBUG(StringFormat("RES=%d; CLOSE_DT=%s; CURR_DT=%s", 
                         res, 
                         TimeToString(CloseTime, TIME_MINUTES | TIME_SECONDS), 
                         TimeToString(dt_curr, TIME_DATE | TIME_MINUTES | TIME_SECONDS)));

  return res;
}

//+------------------------------------------------------------------+
//| Filter passes if there's 1st pos on current ZZ rib
//+------------------------------------------------------------------+
bool CATZZCBBot::IsASFilterPass_FirstEntryOnZZRib() {
  CDKBarTag zz_bt;
  //zz_bt = SigDir > 0 ? ZZBotBT : ZZTopBT; <-- ver 1.01
  zz_bt = (ZZTopBT.GetTime() >= ZZBotBT.GetTime()) ? ZZBotBT : ZZTopBT; // ver 1.02
  bool res = (SigDir != EPDir) || (zz_bt.GetTime() != EPBySigBT.GetTime());
  LSF_DEBUG(StringFormat("RES=%d; SIG_DIR=%d; LAST_EP_DIR=%d; ZZ_DT=%s; LAST_EP_BY_SIG_DT=%s", 
                         res, 
                         SigDir, EPDir,
                         TimeToString(zz_bt.GetTime()), TimeToString(EPBySigBT.GetTime())));
  return res; 
}

//+------------------------------------------------------------------+
//| Filter passed if last WPR segment dir is the same with signal
//+------------------------------------------------------------------+
bool CATZZCBBot::IsASFilterPass_WPR() {
  if(!Inputs.FIL_WPR_ENB) {
    LSF_DEBUG("RES=1; FIL_WPR_ENB=0"); 
    return true;
  }
  
  double buf_wpr[]; ArraySetAsSeries(buf_wpr, true);
  if(CopyBuffer(Inputs.IndWPRHndl, 0, 1, 2, buf_wpr) < 2) {
    LSF_ERROR("RES=0; MSG='CopyBuffer(WPR) failed'"); 
    return false;
  }
  
  int wpr_dir = 0;
  if(buf_wpr[1]<buf_wpr[0]) wpr_dir = +1;
  if(buf_wpr[1]>buf_wpr[0]) wpr_dir = -1;
  
  bool res = (SigDir*wpr_dir) > 0;
  LSF_DEBUG(StringFormat("RES=%d; SIG_DIR=%d; WPR_DIR=%d; WPR[2]=%f; WPR[1]=%f", 
                         res, SigDir, wpr_dir, buf_wpr[1], buf_wpr[0]));
  return res; 
}

//+------------------------------------------------------------------+
//| Close pos on ZZ reversal
//+------------------------------------------------------------------+
bool CATZZCBBot::CloseOnReversal() {
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_OFF) return false;
  
  bool pos_close_cnt = 0;
  
  int sig_dir = 0;
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_NEW_ZZ_TOP)
    if(ZZBotBT.GetIndex() >= (int)Inputs.SIG_ZZ_STR && ZZTopBT.GetIndex() >= (int)Inputs.SIG_ZZ_STR)
      sig_dir = ZZBotBT.GetIndex() > ZZTopBT.GetIndex() ? -1 : +1;
  if(Inputs.EXT_REV_MOD == REVERSAL_EXIT_MODE_NEW_SIGNAL)
    sig_dir = SigDir;

  CDKPositionInfo pos;
  for(int i=0;i<PositionsTotal();i++) {
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    if((pos.PositionType() == POSITION_TYPE_BUY  && sig_dir < 0) || 
       (pos.PositionType() == POSITION_TYPE_SELL && sig_dir > 0)) {
      bool res = Trade.PositionClose(Poses.At(i));
      
      if(res) pos_close_cnt++;      
      LSF_ASSERT(res,
                 StringFormat("TICKET=%I64u; MODE=%s; DIR=%s; SIG_DIR=%d; RET_CODE=%d",
                              Poses.At(i),
                              EnumToString(Inputs.EXT_REV_MOD),
                              PositionTypeToString(pos.PositionType()),
                              sig_dir,
                              Trade.ResultRetcode()),
                    WARN, ERROR);
    }
  }
  
  // Refresh Poses.Total()
  if(pos_close_cnt > 0)
    LoadMarket();
  
  return pos_close_cnt > 0; 
}

//+------------------------------------------------------------------+
//| Close pos on time
//+------------------------------------------------------------------+
bool CATZZCBBot::CloseOnTime() {
  // 01. Have pos in market
  if(Poses.Total() <= 0) {
    LSF_DEBUG("RES=0; POS_CNT=0");
    return false;  
  }
  
  // 02. Time is ok
  if(IsBSFilterPass_AllowedTime())
    return false;
  
  // 03. Close pos
  int close_cnt = 0;
  CDKPositionInfo pos;
  for(int i=0;i<Poses.Total();i++){
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    
    bool res = Trade.PositionClose(Poses.At(i));
    if(res) close_cnt++;
    
    LSF_ASSERT(res, 
               StringFormat("TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            Poses.At(i), 
                            Trade.ResultRetcode(), Trade.ResultRetcodeDescription()),
               WARN, ERROR);
  }

  return close_cnt > 0;    
}

//+------------------------------------------------------------------+
//| TSL
//+------------------------------------------------------------------+
bool CATZZCBBot::UpdateTSL() {
  // 01. Have pos in market
  if(!Inputs.EXT_TSL_ENB) {
    LSF_DEBUG("RES=0; EXT_TSL_ENB=0");
    return false;  
  }  

  // 02. Have pos in market
  if(Poses.Total() <= 0) {
    LSF_DEBUG("RES=0; POS_CNT=0");
    return false;  
  }
  
  // 03. TSL update
  int tsl_cnt = 0;
  CDKTSLPriceChannel pos;
  for(int i=0;i<Poses.Total();i++){
    if(!pos.SelectByTicket(Poses.At(i))) continue;
    
    pos.Init(0, TF, 1, Inputs.EXT_TSL_BAR, CHANNEL_BORDER_WICK, 0);
    bool res = pos.Update(Trade, false);
    if(res) tsl_cnt++;
    pos.SelectByTicket(Poses.At(i));
    DrawTSL(Poses.At(i), pos.StopLoss());
    
    LSF_ASSERT(res, 
               StringFormat("TICKET=%I64u; RET_CODE=%d; RET_MSG='%s'",
                            Poses.At(i), 
                            pos.ResultRetcode(), pos.ResultRetcodeDescription()),
               WARN, ERROR);
  }

  return tsl_cnt > 0;    
}


//+------------------------------------------------------------------+
//| Open pos on Signal
//+------------------------------------------------------------------+
ulong CATZZCBBot::OpenPosOnSignal() {
  SigDir = GetSignal();
  
  if(!IsASFilterPass_WPR()) {
    LSF_INFO(StringFormat("TICKET=0; SIG_DIR=%d; FILTERED_OUT_BY=IsASFilterPass_WPR", SigDir));
    return 0;  
  }

  CloseOnReversal();
  
  if(SigDir == 0) {
    LSF_INFO("TICKET=0; SIG_DIR=0");
    return 0;
  }
  
  if(!IsBSFilterPass_AllowedTime()) {
    LSF_INFO("TICKET=0; FILTERED_OUT_BY=IsBSFilterPass_AllowedTime");
    return 0;
  }
  
  if(!IsBSFilterPass_NoPosInMarket()) {
    LSF_INFO("TICKET=0; FILTERED_OUT_BY=IsBSFilterPass_NoPosInMarket");
    return 0;
  }  
  
  
  if(!IsASFilterPass_FirstEntryOnZZRib()) {
    LSF_INFO(StringFormat("TICKET=0; SIG_DIR=%d; FILTERED_OUT_BY=IsASFilterPass_FirstEntryOnZZRib", SigDir));
    return 0;
  }
  


  // 07. Open pos
  ulong ticket = 0;
  string comment = StringFormat("%s:%s_%s", Logger.Name, EnumToString(SigBarType), TimeToString(TimeCurrent()));
  
  ENUM_POSITION_TYPE pos_type = SigDir > 0 ? POSITION_TYPE_BUY : POSITION_TYPE_SELL;
  double ep = Sym.GetPriceToOpen(pos_type);
  double sl = SigDir > 0 ? ZZBotBT.GetValue() : ZZTopBT.GetValue();
  //double extra_sl_shift = ep*Inputs.ENT_SL_SHF_PER/100;
  //sl = Sym.AddToPrice(pos_type, sl, -1*extra_sl_shift);
  sl = Sym.AddToPrice(pos_type, sl, -1*Inputs.ENT_SL_SHF_PNT);
  double tp = (Inputs.ENT_TP_PNT > 0) ? Sym.AddToPrice(pos_type, ep, +1*Inputs.ENT_TP_PNT) : 0;
  double lot = CalculateLotSuper(Sym.Name(), Inputs.ENT_LTP, Inputs.ENT_LTV, ep, sl);
  
  if(SigDir > 0) 
    ticket = Trade.Buy(lot, Sym.Name(), 0, sl, tp, comment);
  else
    ticket = Trade.Sell(lot, Sym.Name(), 0, sl, tp, comment);
  
  if(ticket > 0) {
    //EPBySigBT = SigDir > 0 ? ZZBotBT : ZZTopBT; // Save ZZ top of entry to skip 2nd entry from it <-- ver 1.01
    EPBySigBT = (ZZTopBT.GetTime() >= ZZBotBT.GetTime()) ? ZZBotBT : ZZTopBT; // ver 1.02
    EPDir = SigDir;
    DrawZZ();
  }
  
  LSF_ASSERT(ticket > 0,
             StringFormat("TICKET=%I64u; SIG_DIR=%d; RET_CODE=%d",
                          ticket,
                          SigDir,
                          Trade.ResultRetcode()),
             WARN, ERROR);

  return ticket;
}


void CATZZCBBot::DrawZZ() {
  if(!Inputs._GUI_ZZ_ENB) return;

  CChartObjectTrend line;
  string name = StringFormat("%s_ZZ_RIB_%s", Logger.Name, TimeToString(TimeCurrent()));
  line.Create(0, name, 0, 
              ZZBotBT.GetTime(), ZZBotBT.GetValue(),
              ZZTopBT.GetTime(), ZZTopBT.GetValue());
  line.Color(SigDir < 0 ? clrGreen : clrRed);
  line.Width(3);
  line.Detach();
  
  name = StringFormat("%s_SIG_BAR_%s", Logger.Name, TimeToString(TimeCurrent()));
  line.Create(0, name, 0, 
              SigDir > 0 ? ZZBotBT.GetTime() : ZZTopBT.GetTime(),
              SigDir > 0 ? ZZBotBT.GetValue() : ZZTopBT.GetValue(),
              SigBT.GetTime(), SigBT.GetValue());
  line.Color(SigDir < 0 ? clrRed : clrGreen);
  line.Style(STYLE_DOT);
  line.Detach();
  
  
  CChartObjectVLine vline;
  name = StringFormat("%s_SIG_VDT_%s", Logger.Name, TimeToString(TimeCurrent()));
  vline.Create(0, name, 0, TimeCurrent());
  vline.Color(SigDir > 0 ? clrGreen : clrRed);
  vline.Style(STYLE_DOT);
  vline.Detach();  
}

void CATZZCBBot::DrawTSL(const ulong _ticket, const double _sl) {
  if(!Inputs._GUI_TSL_ENB) return;

  CChartObjectTrend line;
  string name = StringFormat("%s_TSL_%d", Logger.Name, _ticket);
  line.Create(0, name, 0, 
              iTime(Sym.Name(), TF, Inputs.EXT_TSL_BAR), _sl,
              TimeCurrent(), _sl);
  line.Color(Inputs._GUI_TSL_CLR);
  line.Width(Inputs._GUI_TSL_WDT);
  line.Detach();  
}

