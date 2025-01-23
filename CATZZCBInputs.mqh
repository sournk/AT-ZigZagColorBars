//+------------------------------------------------------------------+
//|                                                CATZZCBInputs.mqh |
//|                                                  Denis Kislitsyn |
//|                                             https://kislitsyn.me |
//+------------------------------------------------------------------+

#include "Include\DKStdLib\Common\DKStdLib.mqh"


// PARSING AREA OF INPUT STRUCTURE == START == DO NOT REMOVE THIS COMMENT
struct CATZZCBBotInputs {
  // input  group                    "1. ENTRY (ENT)"
  ENUM_MM_TYPE                ENT_LTP;                  // ENT_LTP: Lot Type // ENUM_MM_TYPE_FIXED_LOT
  double                      ENT_LTV;                  // ENT_LTV: Lot Type Value // 1.0(x > 0)
  
  // input  group                    "5. MISCELLANEOUS (MS)"
  ulong                       MS_MGC;                   // MS_MGC: Expert Adviser ID - Magic // 20250122
  string                      MS_EGP;                   // MS_EGP: Expert Adviser Global Prefix // "ATZZCB"
  LogLevel                    MS_LOG_LL;                // MS_LOG_LL: Log Level // INFO
  string                      MS_LOG_FI;                // MS_LOG_FI: Log Filter IN String (use `;` as sep) // ""
  string                      MS_LOG_FO;                // MS_LOG_FO: Log Filter OUT String (use `;` as sep) // ""
  bool                        MS_COM_EN;                // MS_COM_EN: Comment Enable (turn off for fast testing) // true
  uint                        MS_COM_IS;                // MS_COM_IS: Comment Interval, Sec // 30
  bool                        MS_COM_CW;                // MS_COM_EW: Comment Custom Window // true
  
  
// PARSING AREA OF INPUT STRUCTURE == END == DO NOT REMOVE THIS COMMENT

  string LastErrorMessage;
  bool CATZZCBBotInputs::InitAndCheck();
  bool CATZZCBBotInputs::Init();
  bool CATZZCBBotInputs::CheckBeforeInit();
  bool CATZZCBBotInputs::CheckAfterInit();
  void CATZZCBBotInputs::CATZZCBBotInputs();
  
  
  // IND HNDLs
  //int IndMAHndl;
};

//+------------------------------------------------------------------+
//| Init struc and Check values
//+------------------------------------------------------------------+
bool CATZZCBBotInputs::InitAndCheck(){
  LastErrorMessage = "";

  if (!CheckBeforeInit())
    return false;

  if (!Init())
  {
    LastErrorMessage = "Input.Init() failed";
    return false;
  }

  return CheckAfterInit();
}

//+------------------------------------------------------------------+
//| Init struc
//+------------------------------------------------------------------+
bool CATZZCBBotInputs::Init(){
  return true;
}

//+------------------------------------------------------------------+
//| Check struc after Init
//+------------------------------------------------------------------+
bool CATZZCBBotInputs::CheckAfterInit(){
  LastErrorMessage = "";

  // Put you ind checks
  
  return LastErrorMessage == "";
}

// GENERATED CODE == START == DO NOT REMOVE THIS COMMENT

input  group                    "1. ENTRY (ENT)"
input  ENUM_MM_TYPE              Inp_ENT_LTP                        = ENUM_MM_TYPE_BALANCE_PERCENT;               // ENT_LTP: Lot Type
input  double                    Inp_ENT_LTV                        = 1.0;                                  // ENT_LTV: Lot Type Value



input  group                    "5. MISCELLANEOUS (MS)"
input  ulong                    Inp_MS_MGC                          = 20250107;                             // MS_MGC: Expert Adviser ID - Magic
sinput string                   Inp_MS_EGP                          = "DSATZZCB";                           // MS_EGP: Expert Adviser Global Prefix
sinput LogLevel                 Inp_MS_LOG_LL                       = LogLevel(INFO);                       // MS_LOG_LL: Log Level
sinput string                   Inp_MS_LOG_FI                       = "";                                   // MS_LOG_FI: Log Filter IN String (use `;` as sep)
sinput string                   Inp_MS_LOG_FO                       = "";                                   // MS_LOG_FO: Log Filter OUT String (use `;` as sep)
       bool                     Inp_MS_COM_EN                       = true;                                 // MS_COM_EN: Comment Enable (turn off for fast testing)
       uint                     Inp_MS_COM_IS                       = 15;                                   // MS_COM_IS: Comment Interval, Sec
sinput bool                     Inp_MS_COM_CW                       = true;                                 // MS_COM_EW: Comment Custom Window


void FillInputs(CATZZCBBotInputs& _inputs) {
  _inputs.ENT_LTP = Inp_ENT_LTP;
}

//+------------------------------------------------------------------+
//| Constructor
//+------------------------------------------------------------------+
void CATZZCBBotInputs::CATZZCBBotInputs():
       ENT_LTP(ENUM_MM_TYPE_FIXED_LOT),
       ENT_LTV(1.0){
};


//+------------------------------------------------------------------+
//| Check struc before Init
//+------------------------------------------------------------------+
bool CATZZCBBotInputs::CheckBeforeInit() {
  LastErrorMessage = "";
  if(!(ENT_LTV > 0)) LastErrorMessage = "'ENT_LTV' must satisfy condition: ENT_LTV > 0";

  return LastErrorMessage == "";
}
// GENERATED CODE == END == DO NOT REMOVE THIS COMMENT



