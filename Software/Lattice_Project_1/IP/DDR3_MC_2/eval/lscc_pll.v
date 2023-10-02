`ifndef __RTL_MODULE__LSCC_PLL__
`define __RTL_MODULE__LSCC_PLL__

//==========================================================================
// Module : lscc_pll
//==========================================================================
module lscc_pll #

( //--begin_param--
//----------------------------
// Parameters
//----------------------------
parameter                     CLKI_FREQ                = 100.0,
parameter                     CLKOP_FREQ_ACTUAL        = 100.0,
parameter                     CLKOS_FREQ_ACTUAL        = 100.0,
parameter                     CLKOS2_FREQ_ACTUAL       = 100.0,
parameter                     CLKOS3_FREQ_ACTUAL       = 100.0,
parameter                     CLKOS4_FREQ_ACTUAL       = 100.0,
parameter                     CLKOS5_FREQ_ACTUAL       = 100.0,
parameter                     CLKOP_PHASE_ACTUAL       = 0.0,
parameter                     CLKOS_PHASE_ACTUAL       = 0.0,
parameter                     CLKOS2_PHASE_ACTUAL      = 0.0,
parameter                     CLKOS3_PHASE_ACTUAL      = 0.0,
parameter                     CLKOS4_PHASE_ACTUAL      = 0.0,
parameter                     CLKOS5_PHASE_ACTUAL      = 0.0,
parameter                     CLKOS_EN                 = 0,
parameter                     CLKOS2_EN                = 0,
parameter                     CLKOS3_EN                = 0,
parameter                     CLKOS4_EN                = 0,
parameter                     CLKOS5_EN                = 0,
parameter                     CLKOP_BYPASS             = 0,
parameter                     CLKOS_BYPASS             = 0,
parameter                     CLKOS2_BYPASS            = 0,
parameter                     CLKOS3_BYPASS            = 0,
parameter                     CLKOS4_BYPASS            = 0,
parameter                     CLKOS5_BYPASS            = 0,
parameter                     ENCLKOP_EN               = 0,
parameter                     ENCLKOS_EN               = 0,
parameter                     ENCLKOS2_EN              = 0,
parameter                     ENCLKOS3_EN              = 0,
parameter                     ENCLKOS4_EN              = 0,
parameter                     ENCLKOS5_EN              = 0,

parameter                     FRAC_N_EN                = 0,
parameter                     SS_EN                    = 0,
parameter                     DYN_PORTS_EN             = 0,
parameter                     PLL_RST                  = 0,
parameter                     LOCK_EN                  = 0,
parameter                     PLL_LOCK_STICKY          = 0,
parameter                     LEGACY_EN                = 0,
parameter                     LMMI_EN                  = 0,
parameter                     APB_EN                   = 0,
parameter                     POWERDOWN_EN             = 0,
parameter                     TRIM_EN_P                = 0,
parameter                     TRIM_EN_S                = 0,

parameter                     PLL_REFCLK_FROM_PIN      = 0,
parameter                     IO_TYPE                  = "LVDS",

parameter                     CLKOP_TRIM_MODE          = "Falling",
parameter                     CLKOS_TRIM_MODE          = "Falling",
parameter                     CLKOP_TRIM               = "0b0000",
parameter                     CLKOS_TRIM               = "0b0000",
parameter                     FBK_MODE                 = "CLKOP",
parameter                     CLKI_DIVIDER_ACTUAL_STR  = "1",
parameter                     FBCLK_DIVIDER_ACTUAL_STR = "1",
parameter                     DIVOP_ACTUAL_STR         = "1",
parameter                     DIVOS_ACTUAL_STR         = "1",
parameter                     DIVOS2_ACTUAL_STR        = "1",
parameter                     DIVOS3_ACTUAL_STR        = "1",
parameter                     DIVOS4_ACTUAL_STR        = "1",
parameter                     DIVOS5_ACTUAL_STR        = "1",
parameter                     SSC_N_CODE_STR           = "0b000010100",
parameter                     SSC_F_CODE_STR           = "0b000000000000000",
parameter                     SSC_PROFILE              = "DOWN",
parameter                     SSC_TBASE_STR            = "0b000000000000",
parameter                     SSC_STEP_IN_STR          = "0b0000000",
parameter                     SSC_REG_WEIGHTING_SEL_STR= "0b000",
parameter                     DELA                     = "0",
parameter                     DELB                     = "0",
parameter                     DELC                     = "0",
parameter                     DELD                     = "0",
parameter                     DELE                     = "0",
parameter                     DELF                     = "0",
parameter                     PHIA                     = "0",
parameter                     PHIB                     = "0",
parameter                     PHIC                     = "0",
parameter                     PHID                     = "0",
parameter                     PHIE                     = "0",
parameter                     PHIF                     = "0",

parameter                     EN_REFCLK_MON            = 0,
parameter                     REF_COUNTS               = "0000",
parameter                     INTFBKDEL_SEL            = "DISABLED",
parameter                     PMU_WAITFORLOCK          = "ENABLED",
parameter                     REF_OSC_CTRL             = "3P2",
parameter                     SIM_FLOAT_PRECISION      = "0.1", // For simulation only

parameter                     IPI_CMP                  = "0b1000",
parameter                     CSET                     = "40P",
parameter                     CRIPPLE                  = "5P",
parameter                     IPP_CTRL                 = "0b1000",
parameter                     IPP_SEL                  = "0b1111",
parameter                     BW_CTL_BIAS              = "0b0101",
parameter                     V2I_PP_RES               = "10K",
parameter                     KP_VCO                   = "0b00011",
parameter                     V2I_KVCO_SEL             = "60",
parameter                     V2I_1V_EN                = "ENABLED"

) //--end_param--

( //--begin_ports--
input                         rstn_i,
input                         clki_i,
input                         usr_fbclk_i,

// Dynamic Phase Control
input                         phasedir_i,
input                         phasestep_i,
input                         phaseloadreg_i,
input       [2:0]             phasesel_i,

// Clock output enable
input                         enclkop_i,
input                         enclkos_i,
input                         enclkos2_i,
input                         enclkos3_i,
input                         enclkos4_i,
input                         enclkos5_i,

// Clock output
output wire                   clkop_o,
output wire                   clkos_o,
output wire                   clkos2_o,
output wire                   clkos3_o,
output wire                   clkos4_o,
output wire                   clkos5_o,

output wire                   lock_o,

input                         pllpd_en_n_i,
input                         legacy_i,

// Ref clock monitor
input                         refdetreset, // Enables users to reset the refclk detection logic

output wire                   refdetlos, // Detect reset from the refclk detection logic

// LMMI bus
input  wire                   lmmi_clk_i,
input  wire                   lmmi_resetn_i,
input  wire                   lmmi_request_i,
input  wire                   lmmi_wr_rdn_i,
input  wire [6:0]             lmmi_offset_i,
input  wire [7:0]             lmmi_wdata_i,
output wire                   lmmi_ready_o,
output wire                   lmmi_rdata_valid_o,
output wire [7:0]             lmmi_rdata_o,

// APB bus
input                         apb_pclk_i,
input                         apb_preset_n_i,
input  wire                   apb_penable_i,
input  wire                   apb_psel_i,
input  wire                   apb_pwrite_i,
input  wire [6:0]             apb_paddr_i,
input  wire [7:0]             apb_pwdata_i,
output wire                   apb_pready_o,
output wire                   apb_pslverr_o,
output wire [7:0]             apb_prdata_o

); //--end_ports--


localparam MAX_STRING_LENGTH = 16;
localparam CONVWIDTH         = 32;
function [CONVWIDTH-1:0] convertDeviceString;
  input [(MAX_STRING_LENGTH)*8-1:0] attributeValue;
  integer i, j;
  integer decVal;
  integer decPlace;
  integer temp, count;
  reg decimalFlag;
  reg [CONVWIDTH-1:0] reverseVal;
  integer concatDec[CONVWIDTH-1:0];
  reg [1:8] character;
  reg [7:0] checkType;
  begin

    decimalFlag = 1'b0;
    decVal = 0;
    decPlace = 1;
    temp = 0;
    count = 0;
    for(i=0; i<=CONVWIDTH-1; i=i+1) begin
      concatDec[i] = -1;
    end
    convertDeviceString = 0;
    checkType = "N";
    for (i=MAX_STRING_LENGTH-1; i>=1 ; i=i-1) begin
      for (j=1; j<=8; j=j+1) begin
        character[j] = attributeValue[i*8-j];
      end

      //Check to see if binary or hex
      if (checkType === "N") begin
        if (character === "b" || character === "x") begin
           checkType = character;
           decimalFlag = 1'b1;
        end
        else begin
          //Convert to string decimal to array of integers for each digit of the number
          case(character)
              "0": concatDec[i-1] = 0;
              "1": concatDec[i-1] = 1;
              "2": concatDec[i-1] = 2;
              "3": concatDec[i-1] = 3;
              "4": concatDec[i-1] = 4;
              "5": concatDec[i-1] = 5;
              "6": concatDec[i-1] = 6;
              "7": concatDec[i-1] = 7;
              "8": concatDec[i-1] = 8;
              "9": concatDec[i-1] = 9;
              default: concatDec[i-1] = -1;
          endcase
        end
      end // (checkType === "N")

      else begin
        //$display("Index %d: %s", i, character);
        //handle binary
        if (checkType === "b") begin
          case(character)
            "0": convertDeviceString[i-1] = 1'b0;
            "1": convertDeviceString[i-1] = 1'b1;
            default: convertDeviceString[i-1] = 1'bx;
          endcase
        end
        //handle hex
        else if (checkType === "x") begin
          case(character)
            "0"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h0;
            "1"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h1;
            "2"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h2;
            "3"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h3;
            "4"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h4;
            "5"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h5;
            "6"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h6;
            "7"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h7;
            "8"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h8;
            "9"      : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'h9;
            "a", "A" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hA;
            "b", "B" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hB;
            "c", "C" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hC;
            "d", "D" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hD;
            "e", "E" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hE;
            "f", "F" : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hF;
            default  : {convertDeviceString[i*4-1], convertDeviceString[i*4-2], convertDeviceString[i*4-3], convertDeviceString[(i-1)*4]} = 4'hX;
          endcase
        end
      end

    end
    //Calculate decmial value from integer array.
    if(decimalFlag === 1'b0) begin
      for (i=0; i<=CONVWIDTH-1 ; i=i+1) begin
        case(concatDec[i])
          0: temp = 0;
          1: temp = 1;
          2: temp = 2;
          3: temp = 3;
          4: temp = 4;
          5: temp = 5;
          6: temp = 6;
          7: temp = 7;
          8: temp = 8;
          9: temp = 9;
          default: temp = -1;
        endcase
        if(temp != -1) begin
          decVal = decVal + (temp * decPlace);
          count = count + 1;
          decPlace = 10 ** count;
        end
      end
      convertDeviceString = decVal;
    end
  end
endfunction // convertDeviceString

function [(2+7)*8-1:0] int_to_7b_str;
  input [6:0]     value;
  reg   [8*7-1:0] binstr;
  integer idx;
  begin
    for(idx=0; idx<7; idx=idx+1) begin
      binstr[idx*8+:8] = (value[idx])? "1" : "0";
    end
    int_to_7b_str = {"0b",binstr};
  end
endfunction // int_to_7b_str

//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam SEL_FBK               = (FBK_MODE == "CLKOP"    )? "FBKCLK0":
                                   (FBK_MODE == "CLKOS"    )? "FBKCLK1":
                                   (FBK_MODE == "CLKOS2"   )? "FBKCLK2":
                                   (FBK_MODE == "CLKOS3"   )? "FBKCLK3":
                                   (FBK_MODE == "CLKOS4"   )? "FBKCLK4":
                                   (FBK_MODE == "CLKOS5"   )? "FBKCLK5":
                                   (FBK_MODE == "INTCLKOP" )? "DIVA":
                                   (FBK_MODE == "INTCLKOS" )? "DIVB":
                                   (FBK_MODE == "INTCLKOS2")? "DIVC":
                                   (FBK_MODE == "INTCLKOS3")? "DIVD":
                                   (FBK_MODE == "INTCLKOS4")? "DIVE":
                                   (FBK_MODE == "INTCLKOS5")? "DIVF":"DIVA";

localparam CLKMUX_FB             = (FBK_MODE == "CLKOP"  || FBK_MODE == "INTCLKOP" )? "CMUX_CLKOP":
                                   (FBK_MODE == "CLKOS"  || FBK_MODE == "INTCLKOS" )? "CMUX_CLKOS":
                                   (FBK_MODE == "CLKOS2" || FBK_MODE == "INTCLKOS2")? "CMUX_CLKOS2":
                                   (FBK_MODE == "CLKOS3" || FBK_MODE == "INTCLKOS3")? "CMUX_CLKOS3":
                                   (FBK_MODE == "CLKOS4" || FBK_MODE == "INTCLKOS4")? "CMUX_CLKOS4":
                                   (FBK_MODE == "CLKOS5" || FBK_MODE == "INTCLKOS5")? "CMUX_CLKOS5":"CMUX_CLKOP";

localparam SEL_OUTA              = (CLKOP_BYPASS  == 1)? "ENABLED": "DISABLED";
localparam SEL_OUTB              = (CLKOS_BYPASS  == 1)? "ENABLED": "DISABLED";
localparam SEL_OUTC              = (CLKOS2_BYPASS == 1)? "ENABLED": "DISABLED";
localparam SEL_OUTD              = (CLKOS3_BYPASS == 1)? "ENABLED": "DISABLED";
localparam SEL_OUTE              = (CLKOS4_BYPASS == 1)? "ENABLED": "DISABLED";
localparam SEL_OUTF              = (CLKOS5_BYPASS == 1)? "ENABLED": "DISABLED";

localparam REF_INTEGER_MODE      = "ENABLED";
localparam FBK_INTEGER_MODE      = (FRAC_N_EN || SS_EN)? "DISABLED" : "ENABLED";

localparam SSC_EN_SSC            = (SS_EN == 1)? "ENABLED": "DISABLED";
localparam SSC_EN_SDM            = (FRAC_N_EN || SS_EN)? "ENABLED": "DISABLED";
localparam SSC_ORDER             = (FRAC_N_EN || SS_EN)? "SDM_ORDER2" : "SDM_ORDER1";
localparam SSC_DITHER            = "DISABLED";
localparam SSC_N_CODE            = (FRAC_N_EN || SS_EN)? SSC_N_CODE_STR : "0b000000000";
localparam SSC_F_CODE            = (FRAC_N_EN || SS_EN)? SSC_F_CODE_STR : "0b000000000000000";
localparam SSC_PI_BYPASS         = "NOT_BYPASSED";
localparam SSC_SQUARE_MODE       = "DISABLED";
localparam SSC_EN_CENTER_IN      = (SSC_PROFILE == "CENTER")? "CENTER_TRIANGLE" : "DOWN_TRIANGLE";
localparam SSC_TBASE             = (SS_EN)? SSC_TBASE_STR : "0b000000000000";
localparam SSC_STEP_IN           = (SS_EN)? SSC_STEP_IN_STR : "0b0000000";
localparam SSC_REG_WEIGHTING_SEL = (SS_EN)? SSC_REG_WEIGHTING_SEL_STR : "0b000";

localparam ENCLK_CLKOP           = (                  ENCLKOP_EN  == 0)? "ENABLED": "DISABLED";
localparam ENCLK_CLKOS           = (CLKOS_EN  == 1 && ENCLKOS_EN  == 0)? "ENABLED": "DISABLED";
localparam ENCLK_CLKOS2          = (CLKOS2_EN == 1 && ENCLKOS2_EN == 0)? "ENABLED": "DISABLED";
localparam ENCLK_CLKOS3          = (CLKOS3_EN == 1 && ENCLKOS3_EN == 0)? "ENABLED": "DISABLED";
localparam ENCLK_CLKOS4          = (CLKOS4_EN == 1 && ENCLKOS4_EN == 0)? "ENABLED": "DISABLED";
localparam ENCLK_CLKOS5          = (CLKOS5_EN == 1 && ENCLKOS5_EN == 0)? "ENABLED": "DISABLED";

localparam DYN_SOURCE            = (DYN_PORTS_EN    == 1)? "DYNAMIC" : "STATIC";
localparam PLLRESET_ENA          = (PLL_RST         == 1)? "ENABLED" : "DISABLED";
localparam PLLPDN_EN             = (POWERDOWN_EN    == 1)? "ENABLED" : "DISABLED";
localparam PLLPD_N               = "USED";
localparam LEGACY_ATT            = (LEGACY_EN       == 1)? "ENABLED" : "DISABLED";
localparam LDT_LOCK_SEL          = (PLL_LOCK_STICKY == 1)? "SFREQ"   : "UFREQ";
localparam TRIMOP_BYPASS_N       = (TRIM_EN_P       == 1)? "USED"    : "BYPASSED";
localparam TRIMOS_BYPASS_N       = (TRIM_EN_S       == 1)? "USED"    : "BYPASSED";

localparam FBK_MMD_DIG           = FBCLK_DIVIDER_ACTUAL_STR;
localparam REF_MMD_DIG           = CLKI_DIVIDER_ACTUAL_STR;
localparam REF_MASK              = "0b00000000";
localparam FBK_MASK              = (FRAC_N_EN || SS_EN)? "0b00010000" : "0b00000000";
localparam FBK_MMD_PULS_CTL      = (FRAC_N_EN)? "0b0110" :
                                   (SS_EN)?     "0b0101" :
                                   (FBCLK_DIVIDER_ACTUAL_STR == "1" ||
                                    FBCLK_DIVIDER_ACTUAL_STR == "2")? "0b0000": "0b0001";
localparam REF_MMD_PULS_CTL      = (CLKI_DIVIDER_ACTUAL_STR == "1" ||
                                    CLKI_DIVIDER_ACTUAL_STR == "2")? "0b0000": "0b0001";
localparam DIVA                  = DIVOP_ACTUAL_STR;
localparam DIVB                  = DIVOS_ACTUAL_STR;
localparam DIVC                  = DIVOS2_ACTUAL_STR;
localparam DIVD                  = DIVOS3_ACTUAL_STR;
localparam DIVE                  = DIVOS4_ACTUAL_STR;
localparam DIVF                  = DIVOS5_ACTUAL_STR;
localparam V2I_PP_ICTRL          = "0b11111";
localparam IPI_CMPN              = "0b0011";

localparam FBK_CLK_DIV_O         = (FBK_MODE == "CLKOP"  || FBK_MODE == "INTCLKOP" )? convertDeviceString(DIVOP_ACTUAL_STR ) :
                                   (FBK_MODE == "CLKOS"  || FBK_MODE == "INTCLKOS" )? convertDeviceString(DIVOS_ACTUAL_STR ) :
                                   (FBK_MODE == "CLKOS2" || FBK_MODE == "INTCLKOS2")? convertDeviceString(DIVOS2_ACTUAL_STR) :
                                   (FBK_MODE == "CLKOS3" || FBK_MODE == "INTCLKOS3")? convertDeviceString(DIVOS3_ACTUAL_STR) :
                                   (FBK_MODE == "CLKOS4" || FBK_MODE == "INTCLKOS4")? convertDeviceString(DIVOS4_ACTUAL_STR) :
                                   (FBK_MODE == "CLKOS5" || FBK_MODE == "INTCLKOS5")? convertDeviceString(DIVOS5_ACTUAL_STR) :
                                                                                      convertDeviceString(DIVOP_ACTUAL_STR );

localparam DIV_DEL               = int_to_7b_str(FBK_CLK_DIV_O);


//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------
wire                          pllreset;
wire                          clki_w;
wire                          fbclk_w;
wire                          intclkop_w;
wire                          intclkos_w;
wire                          intclkos2_w;
wire                          intclkos3_w;
wire                          intclkos4_w;
wire                          intclkos5_w;

wire                          lmmi_clk_w;
wire                          lmmi_resetn_w;
wire        [7:0]             lmmi_wdata_w;
wire                          lmmi_wr_rdn_w;
wire        [6:0]             lmmi_offset_w;
wire                          lmmi_request_w;

wire                          apb_lmmi_request_w;
wire        [6:0]             apb_lmmi_offset_w;
wire        [7:0]             apb_lmmi_wdata_w;
wire        [7:0]             apb_lmmi_rdata_w;
wire                          apb_lmmi_wr_rdn_w;

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------

assign pllreset = ~rstn_i;

assign fbclk_w = (FBK_MODE == "CLKOP"    )? clkop_o:
                 (FBK_MODE == "CLKOS"    )? clkos_o:
                 (FBK_MODE == "CLKOS2"   )? clkos2_o:
                 (FBK_MODE == "CLKOS3"   )? clkos3_o:
                 (FBK_MODE == "CLKOS4"   )? clkos4_o:
                 (FBK_MODE == "CLKOS5"   )? clkos5_o:
                 (FBK_MODE == "INTCLKOP" )? intclkop_w:
                 (FBK_MODE == "INTCLKOS" )? intclkos_w:
                 (FBK_MODE == "INTCLKOS2")? intclkos2_w:
                 (FBK_MODE == "INTCLKOS3")? intclkos3_w:
                 (FBK_MODE == "INTCLKOS4")? intclkos4_w:
                 (FBK_MODE == "INTCLKOS5")? intclkos5_w:
                 (FBK_MODE == "USERFBCLK")? usr_fbclk_i:clkop_o;

generate
   if (PLL_REFCLK_FROM_PIN == 0) begin
      assign clki_w = clki_i;
   end else begin
    BB u0_BB (
      .B                         (clki_i),
      .I                         (1'b0),
      .T                         (1'b1),
      .O                         (clki_w)
    ) ;
   end
endgenerate


generate
  if (APB_EN == 1) begin : APB2LMMI_INST
    // lmmi_error_i is not used by lscc_spi_master_native, thus, this is set to 0
    wire   lmmi_error_w;
    assign lmmi_error_w = 0;
    ///
    lscc_apb2lmmi #(
      .DATA_WIDTH         (8),
      .ADDR_WIDTH         (7),
      .REG_OUTPUT         (0))
    u_lscc_apb2lmmi (
      .clk_i              (apb_pclk_i),
      .rst_n_i            (apb_preset_n_i),
      .apb_penable_i      (apb_penable_i),
      .apb_psel_i         (apb_psel_i),
      .apb_pwrite_i       (apb_pwrite_i),
      .apb_paddr_i        (apb_paddr_i),
      .apb_pwdata_i       (apb_pwdata_i),
      .apb_pready_o       (apb_pready_o),
      .apb_pslverr_o      (apb_pslverr_o),
      .apb_prdata_o       (apb_prdata_o),
      .lmmi_ready_i       (lmmi_ready_o),
      .lmmi_rdata_valid_i (lmmi_rdata_valid_o),
      .lmmi_error_i       (lmmi_error_w),
      .lmmi_rdata_i       (apb_lmmi_rdata_w),
      .lmmi_request_o     (apb_lmmi_request_w),
      .lmmi_wr_rdn_o      (apb_lmmi_wr_rdn_w),
      .lmmi_offset_o      (apb_lmmi_offset_w),
      .lmmi_wdata_o       (apb_lmmi_wdata_w),
      .lmmi_resetn_o      () // unused
    );
  ///
    assign lmmi_clk_w            = apb_pclk_i;
    assign lmmi_resetn_w         = apb_preset_n_i;
    assign lmmi_wdata_w          = apb_lmmi_wdata_w[7:0];
    assign apb_lmmi_rdata_w[7:0] = lmmi_rdata_o;
    assign lmmi_wr_rdn_w         = apb_lmmi_wr_rdn_w;
    assign lmmi_offset_w         = apb_lmmi_offset_w;
    assign lmmi_request_w        = apb_lmmi_request_w;
    ///
  end
endgenerate

// -----------------------------------------------------------------------------
// Generate Assign Statements
// -----------------------------------------------------------------------------
generate
  if (APB_EN == 0) begin : LMMI
    assign lmmi_clk_w     = lmmi_clk_i;
    assign lmmi_resetn_w  = lmmi_resetn_i;
    assign lmmi_wdata_w   = lmmi_wdata_i;
    assign lmmi_wr_rdn_w  = lmmi_wr_rdn_i;
    assign lmmi_offset_w  = lmmi_offset_i;
    assign lmmi_request_w = lmmi_request_i;
  end

  if(EN_REFCLK_MON) begin : gen_en_refclk_mon
    /*PLLA AUTO_TEMPLATE
    (
     .REF_COUNTS                            (REF_COUNTS),
     .CLKOP_TRIM                            (CLKOP_TRIM),
     .CLKOS_TRIM                            (CLKOS_TRIM),
     .TRIMOP_BYPASS_N                       (TRIMOP_BYPASS_N),
     .TRIMOS_BYPASS_N                       (TRIMOS_BYPASS_N),
     .DEL\(.\)                              (DEL\1),
     .PHI\(.\)                              (PHI\1),
     .DIV\(.\)                              (DIV\1),
     .SEL_OUT\(.\)                          (SEL_OUT\1),
     .ENCLK_CLKO\(.*\)                      (ENCLK_CLKO\1),
     .DYN_SOURCE                            (DYN_SOURCE),
     .\(.*\)_INTEGER_MODE                   (\1_INTEGER_MODE),
     .\(.*\)_MASK                           (\1_MASK),
     .\(.*\)_MMD_DIG                        (\1_MMD_DIG),
     .\(.*\)_MMD_PULS_CTL                   (\1_MMD_PULS_CTL),
     .LDT_LOCK_SEL                          (LDT_LOCK_SEL),
     .LEGACY_ATT                            (LEGACY_ATT),
     .PLL\(.*\)                             (PLL\1),
     .SSC_\(.*\)                            (SSC_\1),
     .V2I_\(.*\)                            (V2I_\1),
     .SEL_FBK                               (SEL_FBK),
     .CLKMUX_FB                             (CLKMUX_FB),
     .KP_VCO                                (KP_VCO),
     .CSET                                  (CSET),
     .CRIPPLE                               (CRIPPLE),
     .IPP_CTRL                              (IPP_CTRL),
     .IPP_SEL                               (IPP_SEL),
     .BW_CTL_BIAS                           (BW_CTL_BIAS),
     .IPI_CMPN                              (IPI_CMPN),
     .IPI_CMP                               (IPI_CMP),
     .INTFBKDEL_SEL                         (INTFBKDEL_SEL),
     .PMU_WAITFORLOCK                       (PMU_WAITFORLOCK),
     .REF_OSC_CTRL                          (REF_OSC_CTRL),
     .SIM_FLOAT_PRECISION                   (SIM_FLOAT_PRECISION),
     .DIR                                   (phasedir_i),
     .DIRSEL                                (phasesel_i),
     .LOADREG                               (phaseloadreg_i),
     .DYNROTATE                             (phasestep_i),
     .LMMICLK                               (lmmi_clk_w),
     .LMMIRESET_N                           (lmmi_resetn_w),
     .LMMIREQUEST                           (lmmi_request_w),
     .LMMIWRRD_N                            (lmmi_wr_rdn_w),
     .LMMIOFFSET                            (lmmi_offset_w),
     .LMMIWDATA                             (lmmi_wdata_w),
     .PLLPOWERDOWN_N                        (pllpd_en_n_i),
     .REFCK                                 (clki_w),
     .ENCLKO\(.*\)                          (enclko\l\1_i),
     .FBKCK                                 (fbclk_w),
     .LEGACY                                (legacy_i),
     .PLLRESET                              (pllreset),
     .LOCK                                  (lock_o),
     .CLKO\(.\)                             (clko\l\1_o),
     .CLKOS\(.\)                            (clkos\l\1_o),
     .INTFBKO\(.*\)                         (intclko\l\1_w),
     .LMMIRDATA                             (lmmi_rdata_o),
     .LMMIRDATAVALID                        (lmmi_rdata_valid_o),
     .LMMIREADY                             (lmmi_ready_o),
     .REFDETRESET                           (refdetreset),
     .REFDETLOS                             (refdetlos),
     .STDBY                                 (1'b0),
     .ROTDEL                                (1'b0),
     .DIRDEL                                (1'b0),
     .ROTDELP1                              (1'b0),
     .GRAYTEST                              (5'b0),
     .BINTEST                               (2'b0),
     .DIRDELP1                              (1'b0),
     .GRAYACT                               (5'b0),
     .BINACT                                (2'b0),
     .INTLOCK                               (),
     .LEGRDYN                               (),
     .PFDDN                                 (),
     .PFDUP                                 (),
     .REFMUXCK                              (),
     .REGQA                                 (),
     .REGQB                                 (),
     .REGQB1                                (),
     .CLKOUTDL                              (),
     .\(.*\)                                (),
    );*/

    PLLA #
    (/*AUTOINSTPARAM*/
     // Parameters
     .BW_CTL_BIAS                           (BW_CTL_BIAS),           // Templated
     .CLKOP_TRIM                            (CLKOP_TRIM),            // Templated
     .CLKOS_TRIM                            (CLKOS_TRIM),            // Templated
     .CLKOS2_TRIM                           (),                      // Templated
     .CLKOS3_TRIM                           (),                      // Templated
     .CLKOS4_TRIM                           (),                      // Templated
     .CLKOS5_TRIM                           (),                      // Templated
     .CRIPPLE                               (CRIPPLE),               // Templated
     .CSET                                  (CSET),                  // Templated
     .DELAY_CTRL                            (),                      // Templated
     .DELA                                  (DELA),                  // Templated
     .DELB                                  (DELB),                  // Templated
     .DELC                                  (DELC),                  // Templated
     .DELD                                  (DELD),                  // Templated
     .DELE                                  (DELE),                  // Templated
     .DELF                                  (DELF),                  // Templated
     .DIRECTION                             (),                      // Templated
     .DIVA                                  (DIVA),                  // Templated
     .DIVB                                  (DIVB),                  // Templated
     .DIVC                                  (DIVC),                  // Templated
     .DIVD                                  (DIVD),                  // Templated
     .DIVE                                  (DIVE),                  // Templated
     .DIVF                                  (DIVF),                  // Templated
     .DYN_SEL                               (),                      // Templated
     .DYN_SOURCE                            (DYN_SOURCE),            // Templated
     .ENCLK_CLKOP                           (ENCLK_CLKOP),           // Templated
     .ENCLK_CLKOS                           (ENCLK_CLKOS),           // Templated
     .ENCLK_CLKOS2                          (ENCLK_CLKOS2),          // Templated
     .ENCLK_CLKOS3                          (ENCLK_CLKOS3),          // Templated
     .ENCLK_CLKOS4                          (ENCLK_CLKOS4),          // Templated
     .ENCLK_CLKOS5                          (ENCLK_CLKOS5),          // Templated
     .ENABLE_SYNC                           (),                      // Templated
     .FAST_LOCK_EN                          (),                      // Templated
     .V2I_1V_EN                             (V2I_1V_EN),             // Templated
     .FBK_CUR_BLE                           (),                      // Templated
     .FBK_EDGE_SEL                          (),                      // Templated
     .FBK_IF_TIMING_CTL                     (),                      // Templated
     .FBK_INTEGER_MODE                      (FBK_INTEGER_MODE),      // Templated
     .FBK_MASK                              (FBK_MASK),              // Templated
     .FBK_MMD_DIG                           (FBK_MMD_DIG),           // Templated
     .FBK_MMD_PULS_CTL                      (FBK_MMD_PULS_CTL),      // Templated
     .FBK_MODE                              (),                      // Templated
     .FBK_PI_BYPASS                         (),                      // Templated
     .FBK_PI_RC                             (),                      // Templated
     .FBK_PR_CC                             (),                      // Templated
     .FBK_PR_IC                             (),                      // Templated
     .FLOAT_CP                              (),                      // Templated
     .FLOCK_CTRL                            (),                      // Templated
     .FLOCK_EN                              (),                      // Templated
     .FLOCK_SRC_SEL                         (),                      // Templated
     .FORCE_FILTER                          (),                      // Templated
     .I_CTRL                                (),                      // Templated
     .IPI_CMP                               (IPI_CMP),               // Templated
     .IPI_CMPN                              (IPI_CMPN),              // Templated
     .IPI_COMP_EN                           (),                      // Templated
     .IPP_CTRL                              (IPP_CTRL),              // Templated
     .IPP_SEL                               (IPP_SEL),               // Templated
     .KP_VCO                                (KP_VCO),                // Templated
     .LDT_INT_LOCK_STICKY                   (),                      // Templated
     .LDT_LOCK                              (),                      // Templated
     .LDT_LOCK_SEL                          (LDT_LOCK_SEL),          // Templated
     .LEGACY_ATT                            (LEGACY_ATT),            // Templated
     .LOAD_REG                              (),                      // Templated
     .OPENLOOP_EN                           (),                      // Templated
     .PHIA                                  (PHIA),                  // Templated
     .PHIB                                  (PHIB),                  // Templated
     .PHIC                                  (PHIC),                  // Templated
     .PHID                                  (PHID),                  // Templated
     .PHIE                                  (PHIE),                  // Templated
     .PHIF                                  (PHIF),                  // Templated
     .PLLPDN_EN                             (PLLPDN_EN),             // Templated
     .PLLPD_N                               (PLLPD_N),               // Templated
     .PLLRESET_ENA                          (PLLRESET_ENA),          // Templated
     .REF_INTEGER_MODE                      (REF_INTEGER_MODE),      // Templated
     .REF_MASK                              (REF_MASK),              // Templated
     .REF_MMD_DIG                           (REF_MMD_DIG),           // Templated
     .REF_MMD_IN                            (),                      // Templated
     .REF_MMD_PULS_CTL                      (REF_MMD_PULS_CTL),      // Templated
     .REF_TIMING_CTL                        (),                      // Templated
     .REFIN_RESET                           (),                      // Templated
     .RESET_LF                              (),                      // Templated
     .ROTATE                                (),                      // Templated
     .SEL_OUTA                              (SEL_OUTA),              // Templated
     .SEL_OUTB                              (SEL_OUTB),              // Templated
     .SEL_OUTC                              (SEL_OUTC),              // Templated
     .SEL_OUTD                              (SEL_OUTD),              // Templated
     .SEL_OUTE                              (SEL_OUTE),              // Templated
     .SEL_OUTF                              (SEL_OUTF),              // Templated
     .SLEEP                                 (),                      // Templated
     .SSC_DITHER                            (SSC_DITHER),            // Templated
     .SSC_EN_CENTER_IN                      (SSC_EN_CENTER_IN),      // Templated
     .SSC_EN_SDM                            (SSC_EN_SDM),            // Templated
     .SSC_EN_SSC                            (SSC_EN_SSC),            // Templated
     .SSC_F_CODE                            (SSC_F_CODE),            // Templated
     .SSC_N_CODE                            (SSC_N_CODE),            // Templated
     .SSC_ORDER                             (SSC_ORDER),             // Templated
     .SSC_PI_BYPASS                         (SSC_PI_BYPASS),         // Templated
     .SSC_REG_WEIGHTING_SEL                 (SSC_REG_WEIGHTING_SEL), // Templated
     .SSC_SQUARE_MODE                       (SSC_SQUARE_MODE),       // Templated
     .SSC_STEP_IN                           (SSC_STEP_IN),           // Templated
     .SSC_TBASE                             (SSC_TBASE),             // Templated
     .STDBY_ATT                             (),                      // Templated
     .TRIMOP_BYPASS_N                       (TRIMOP_BYPASS_N),       // Templated
     .TRIMOS_BYPASS_N                       (TRIMOS_BYPASS_N),       // Templated
     .TRIMOS2_BYPASS_N                      (),                      // Templated
     .TRIMOS3_BYPASS_N                      (),                      // Templated
     .TRIMOS4_BYPASS_N                      (),                      // Templated
     .TRIMOS5_BYPASS_N                      (),                      // Templated
     .V2I_KVCO_SEL                          (V2I_KVCO_SEL),          // Templated
     .V2I_PP_ICTRL                          (V2I_PP_ICTRL),          // Templated
     .V2I_PP_RES                            (V2I_PP_RES),            // Templated
     .CLKMUX_FB                             (CLKMUX_FB),             // Templated
     .SEL_FBK                               (SEL_FBK),               // Templated
     .DIV_DEL                               (DIV_DEL),               // Templated
     .PHASE_SEL_DEL                         (),                      // Templated
     .PHASE_SEL_DEL_P1                      (),                      // Templated
     .EXTERNAL_DIVIDE_FACTOR                (),                      // Templated
     .INTFBKDEL_SEL                         (INTFBKDEL_SEL),         // Templated
     .PMU_WAITFORLOCK                       (PMU_WAITFORLOCK),       // Templated
     .REF_OSC_CTRL                          (REF_OSC_CTRL),          // Templated
     .REF_COUNTS                            (REF_COUNTS),            // Templated
     .SIM_FLOAT_PRECISION                   (SIM_FLOAT_PRECISION))   // Templated
    u_PLL
    (/*AUTOINST*/
     // Inputs
     .DIR                                   (phasedir_i),            // Templated
     .DIRSEL                                (phasesel_i),            // Templated
     .LOADREG                               (phaseloadreg_i),        // Templated
     .DYNROTATE                             (phasestep_i),           // Templated
     .LMMICLK                               (lmmi_clk_w),            // Templated
     .LMMIRESET_N                           (lmmi_resetn_w),         // Templated
     .LMMIREQUEST                           (lmmi_request_w),        // Templated
     .LMMIWRRD_N                            (lmmi_wr_rdn_w),         // Templated
     .LMMIOFFSET                            (lmmi_offset_w),         // Templated
     .LMMIWDATA                             (lmmi_wdata_w),          // Templated
     .PLLPOWERDOWN_N                        (pllpd_en_n_i),          // Templated
     .REFCK                                 (clki_w),                // Templated
     .ENCLKOP                               (enclkop_i),             // Templated
     .ENCLKOS                               (enclkos_i),             // Templated
     .ENCLKOS2                              (enclkos2_i),            // Templated
     .ENCLKOS3                              (enclkos3_i),            // Templated
     .ENCLKOS4                              (enclkos4_i),            // Templated
     .ENCLKOS5                              (enclkos5_i),            // Templated
     .FBKCK                                 (fbclk_w),               // Templated
     .LEGACY                                (legacy_i),              // Templated
     .PLLRESET                              (pllreset),              // Templated
     .STDBY                                 (1'b0),                  // Templated
     .ROTDEL                                (1'b0),                  // Templated
     .DIRDEL                                (1'b0),                  // Templated
     .ROTDELP1                              (1'b0),                  // Templated
     .GRAYTEST                              (5'b0),                  // Templated
     .BINTEST                               (2'b0),                  // Templated
     .DIRDELP1                              (1'b0),                  // Templated
     .GRAYACT                               (5'b0),                  // Templated
     .BINACT                                (2'b0),                  // Templated
     .REFDETRESET                           (refdetreset),           // Templated
     // Outputs
     .INTFBKOP                              (intclkop_w),            // Templated
     .INTFBKOS                              (intclkos_w),            // Templated
     .INTFBKOS2                             (intclkos2_w),           // Templated
     .INTFBKOS3                             (intclkos3_w),           // Templated
     .INTFBKOS4                             (intclkos4_w),           // Templated
     .INTFBKOS5                             (intclkos5_w),           // Templated
     .LMMIRDATA                             (lmmi_rdata_o),          // Templated
     .LMMIRDATAVALID                        (lmmi_rdata_valid_o),    // Templated
     .LMMIREADY                             (lmmi_ready_o),          // Templated
     .CLKOP                                 (clkop_o),               // Templated
     .CLKOS                                 (clkos_o),               // Templated
     .CLKOS2                                (clkos2_o),              // Templated
     .CLKOS3                                (clkos3_o),              // Templated
     .CLKOS4                                (clkos4_o),              // Templated
     .CLKOS5                                (clkos5_o),              // Templated
     .INTLOCK                               (),                      // Templated
     .LEGRDYN                               (),                      // Templated
     .LOCK                                  (lock_o),                // Templated
     .PFDDN                                 (),                      // Templated
     .PFDUP                                 (),                      // Templated
     .REFMUXCK                              (),                      // Templated
     .REGQA                                 (),                      // Templated
     .REGQB                                 (),                      // Templated
     .REGQB1                                (),                      // Templated
     .CLKOUTDL                              (),                      // Templated
     .REFDETLOS                             (refdetlos));            // Templated
  end // gen_en_refclk_mon

  else begin : gen_no_refclk_mon
    /*PLL AUTO_TEMPLATE
    (
     .CLKOP_TRIM                            (CLKOP_TRIM),
     .CLKOS_TRIM                            (CLKOS_TRIM),
     .TRIMOP_BYPASS_N                       (TRIMOP_BYPASS_N),
     .TRIMOS_BYPASS_N                       (TRIMOS_BYPASS_N),
     .DEL\(.\)                              (DEL\1),
     .PHI\(.\)                              (PHI\1),
     .DIV\(.\)                              (DIV\1),
     .SEL_OUT\(.\)                          (SEL_OUT\1),
     .ENCLK_CLKO\(.*\)                      (ENCLK_CLKO\1),
     .DYN_SOURCE                            (DYN_SOURCE),
     .\(.*\)_INTEGER_MODE                   (\1_INTEGER_MODE),
     .\(.*\)_MASK                           (\1_MASK),
     .\(.*\)_MMD_DIG                        (\1_MMD_DIG),
     .\(.*\)_MMD_PULS_CTL                   (\1_MMD_PULS_CTL),
     .LDT_LOCK_SEL                          (LDT_LOCK_SEL),
     .LEGACY_ATT                            (LEGACY_ATT),
     .PLL\(.*\)                             (PLL\1),
     .SSC_\(.*\)                            (SSC_\1),
     .V2I_\(.*\)                            (V2I_\1),
     .SEL_FBK                               (SEL_FBK),
     .CLKMUX_FB                             (CLKMUX_FB),
     .KP_VCO                                (KP_VCO),
     .CSET                                  (CSET),
     .CRIPPLE                               (CRIPPLE),
     .IPP_CTRL                              (IPP_CTRL),
     .IPP_SEL                               (IPP_SEL),
     .BW_CTL_BIAS                           (BW_CTL_BIAS),
     .IPI_CMPN                              (IPI_CMPN),
     .IPI_CMP                               (IPI_CMP),
     .INTFBKDEL_SEL                         (INTFBKDEL_SEL),
     .PMU_WAITFORLOCK                       (PMU_WAITFORLOCK),
     .REF_OSC_CTRL                          (REF_OSC_CTRL),
     .SIM_FLOAT_PRECISION                   (SIM_FLOAT_PRECISION),
     .DIR                                   (phasedir_i),
     .DIRSEL                                (phasesel_i),
     .LOADREG                               (phaseloadreg_i),
     .DYNROTATE                             (phasestep_i),
     .LMMICLK                               (lmmi_clk_w),
     .LMMIRESET_N                           (lmmi_resetn_w),
     .LMMIREQUEST                           (lmmi_request_w),
     .LMMIWRRD_N                            (lmmi_wr_rdn_w),
     .LMMIOFFSET                            (lmmi_offset_w),
     .LMMIWDATA                             (lmmi_wdata_w),
     .PLLPOWERDOWN_N                        (pllpd_en_n_i),
     .REFCK                                 (clki_w),
     .ENCLKO\(.*\)                          (enclko\l\1_i),
     .FBKCK                                 (fbclk_w),
     .LEGACY                                (legacy_i),
     .PLLRESET                              (pllreset),
     .LOCK                                  (lock_o),
     .CLKO\(.\)                             (clko\l\1_o),
     .CLKOS\(.\)                            (clkos\l\1_o),
     .INTFBKO\(.*\)                         (intclko\l\1_w),
     .LMMIRDATA                             (lmmi_rdata_o),
     .LMMIRDATAVALID                        (lmmi_rdata_valid_o),
     .LMMIREADY                             (lmmi_ready_o),
     .STDBY                                 (1'b0),
     .ROTDEL                                (1'b0),
     .DIRDEL                                (1'b0),
     .ROTDELP1                              (1'b0),
     .GRAYTEST                              (5'b0),
     .BINTEST                               (2'b0),
     .DIRDELP1                              (1'b0),
     .GRAYACT                               (5'b0),
     .BINACT                                (2'b0),
     .INTLOCK                               (),
     .LEGRDYN                               (),
     .PFDDN                                 (),
     .PFDUP                                 (),
     .REFMUXCK                              (),
     .REGQA                                 (),
     .REGQB                                 (),
     .REGQB1                                (),
     .CLKOUTDL                              (),
     .\(.*\)                                (),
    );*/

    PLL #
    (/*AUTOINSTPARAM*/
     // Parameters
     .BW_CTL_BIAS                           (BW_CTL_BIAS),           // Templated
     .CLKOP_TRIM                            (CLKOP_TRIM),            // Templated
     .CLKOS_TRIM                            (CLKOS_TRIM),            // Templated
     .CLKOS2_TRIM                           (),                      // Templated
     .CLKOS3_TRIM                           (),                      // Templated
     .CLKOS4_TRIM                           (),                      // Templated
     .CLKOS5_TRIM                           (),                      // Templated
     .CRIPPLE                               (CRIPPLE),               // Templated
     .CSET                                  (CSET),                  // Templated
     .DELAY_CTRL                            (),                      // Templated
     .DELA                                  (DELA),                  // Templated
     .DELB                                  (DELB),                  // Templated
     .DELC                                  (DELC),                  // Templated
     .DELD                                  (DELD),                  // Templated
     .DELE                                  (DELE),                  // Templated
     .DELF                                  (DELF),                  // Templated
     .DIRECTION                             (),                      // Templated
     .DIVA                                  (DIVA),                  // Templated
     .DIVB                                  (DIVB),                  // Templated
     .DIVC                                  (DIVC),                  // Templated
     .DIVD                                  (DIVD),                  // Templated
     .DIVE                                  (DIVE),                  // Templated
     .DIVF                                  (DIVF),                  // Templated
     .DYN_SEL                               (),                      // Templated
     .DYN_SOURCE                            (DYN_SOURCE),            // Templated
     .ENCLK_CLKOP                           (ENCLK_CLKOP),           // Templated
     .ENCLK_CLKOS                           (ENCLK_CLKOS),           // Templated
     .ENCLK_CLKOS2                          (ENCLK_CLKOS2),          // Templated
     .ENCLK_CLKOS3                          (ENCLK_CLKOS3),          // Templated
     .ENCLK_CLKOS4                          (ENCLK_CLKOS4),          // Templated
     .ENCLK_CLKOS5                          (ENCLK_CLKOS5),          // Templated
     .ENABLE_SYNC                           (),                      // Templated
     .FAST_LOCK_EN                          (),                      // Templated
     .V2I_1V_EN                             (V2I_1V_EN),             // Templated
     .FBK_CUR_BLE                           (),                      // Templated
     .FBK_EDGE_SEL                          (),                      // Templated
     .FBK_IF_TIMING_CTL                     (),                      // Templated
     .FBK_INTEGER_MODE                      (FBK_INTEGER_MODE),      // Templated
     .FBK_MASK                              (FBK_MASK),              // Templated
     .FBK_MMD_DIG                           (FBK_MMD_DIG),           // Templated
     .FBK_MMD_PULS_CTL                      (FBK_MMD_PULS_CTL),      // Templated
     .FBK_MODE                              (),                      // Templated
     .FBK_PI_BYPASS                         (),                      // Templated
     .FBK_PI_RC                             (),                      // Templated
     .FBK_PR_CC                             (),                      // Templated
     .FBK_PR_IC                             (),                      // Templated
     .FLOAT_CP                              (),                      // Templated
     .FLOCK_CTRL                            (),                      // Templated
     .FLOCK_EN                              (),                      // Templated
     .FLOCK_SRC_SEL                         (),                      // Templated
     .FORCE_FILTER                          (),                      // Templated
     .I_CTRL                                (),                      // Templated
     .IPI_CMP                               (IPI_CMP),               // Templated
     .IPI_CMPN                              (IPI_CMPN),              // Templated
     .IPI_COMP_EN                           (),                      // Templated
     .IPP_CTRL                              (IPP_CTRL),              // Templated
     .IPP_SEL                               (IPP_SEL),               // Templated
     .KP_VCO                                (KP_VCO),                // Templated
     .LDT_INT_LOCK_STICKY                   (),                      // Templated
     .LDT_LOCK                              (),                      // Templated
     .LDT_LOCK_SEL                          (LDT_LOCK_SEL),          // Templated
     .LEGACY_ATT                            (LEGACY_ATT),            // Templated
     .LOAD_REG                              (),                      // Templated
     .OPENLOOP_EN                           (),                      // Templated
     .PHIA                                  (PHIA),                  // Templated
     .PHIB                                  (PHIB),                  // Templated
     .PHIC                                  (PHIC),                  // Templated
     .PHID                                  (PHID),                  // Templated
     .PHIE                                  (PHIE),                  // Templated
     .PHIF                                  (PHIF),                  // Templated
     .PLLPDN_EN                             (PLLPDN_EN),             // Templated
     .PLLPD_N                               (PLLPD_N),               // Templated
     .PLLRESET_ENA                          (PLLRESET_ENA),          // Templated
     .REF_INTEGER_MODE                      (REF_INTEGER_MODE),      // Templated
     .REF_MASK                              (REF_MASK),              // Templated
     .REF_MMD_DIG                           (REF_MMD_DIG),           // Templated
     .REF_MMD_IN                            (),                      // Templated
     .REF_MMD_PULS_CTL                      (REF_MMD_PULS_CTL),      // Templated
     .REF_TIMING_CTL                        (),                      // Templated
     .REFIN_RESET                           (),                      // Templated
     .RESET_LF                              (),                      // Templated
     .ROTATE                                (),                      // Templated
     .SEL_OUTA                              (SEL_OUTA),              // Templated
     .SEL_OUTB                              (SEL_OUTB),              // Templated
     .SEL_OUTC                              (SEL_OUTC),              // Templated
     .SEL_OUTD                              (SEL_OUTD),              // Templated
     .SEL_OUTE                              (SEL_OUTE),              // Templated
     .SEL_OUTF                              (SEL_OUTF),              // Templated
     .SLEEP                                 (),                      // Templated
     .SSC_DITHER                            (SSC_DITHER),            // Templated
     .SSC_EN_CENTER_IN                      (SSC_EN_CENTER_IN),      // Templated
     .SSC_EN_SDM                            (SSC_EN_SDM),            // Templated
     .SSC_EN_SSC                            (SSC_EN_SSC),            // Templated
     .SSC_F_CODE                            (SSC_F_CODE),            // Templated
     .SSC_N_CODE                            (SSC_N_CODE),            // Templated
     .SSC_ORDER                             (SSC_ORDER),             // Templated
     .SSC_PI_BYPASS                         (SSC_PI_BYPASS),         // Templated
     .SSC_REG_WEIGHTING_SEL                 (SSC_REG_WEIGHTING_SEL), // Templated
     .SSC_SQUARE_MODE                       (SSC_SQUARE_MODE),       // Templated
     .SSC_STEP_IN                           (SSC_STEP_IN),           // Templated
     .SSC_TBASE                             (SSC_TBASE),             // Templated
     .STDBY_ATT                             (),                      // Templated
     .TRIMOP_BYPASS_N                       (TRIMOP_BYPASS_N),       // Templated
     .TRIMOS_BYPASS_N                       (TRIMOS_BYPASS_N),       // Templated
     .TRIMOS2_BYPASS_N                      (),                      // Templated
     .TRIMOS3_BYPASS_N                      (),                      // Templated
     .TRIMOS4_BYPASS_N                      (),                      // Templated
     .TRIMOS5_BYPASS_N                      (),                      // Templated
     .V2I_KVCO_SEL                          (V2I_KVCO_SEL),          // Templated
     .V2I_PP_ICTRL                          (V2I_PP_ICTRL),          // Templated
     .V2I_PP_RES                            (V2I_PP_RES),            // Templated
     .CLKMUX_FB                             (CLKMUX_FB),             // Templated
     .SEL_FBK                               (SEL_FBK),               // Templated
     .DIV_DEL                               (DIV_DEL),               // Templated
     .PHASE_SEL_DEL                         (),                      // Templated
     .PHASE_SEL_DEL_P1                      (),                      // Templated
     .EXTERNAL_DIVIDE_FACTOR                (),                      // Templated
     .INTFBKDEL_SEL                         (INTFBKDEL_SEL),         // Templated
     .PMU_WAITFORLOCK                       (PMU_WAITFORLOCK),       // Templated
     .REF_OSC_CTRL                          (REF_OSC_CTRL),          // Templated
     .SIM_FLOAT_PRECISION                   (SIM_FLOAT_PRECISION))   // Templated
    u_PLL
    (/*AUTOINST*/
     // Inputs
     .DIR                                   (phasedir_i),            // Templated
     .DIRSEL                                (phasesel_i),            // Templated
     .LOADREG                               (phaseloadreg_i),        // Templated
     .DYNROTATE                             (phasestep_i),           // Templated
     .LMMICLK                               (lmmi_clk_w),            // Templated
     .LMMIRESET_N                           (lmmi_resetn_w),         // Templated
     .LMMIREQUEST                           (lmmi_request_w),        // Templated
     .LMMIWRRD_N                            (lmmi_wr_rdn_w),         // Templated
     .LMMIOFFSET                            (lmmi_offset_w),         // Templated
     .LMMIWDATA                             (lmmi_wdata_w),          // Templated
     .PLLPOWERDOWN_N                        (pllpd_en_n_i),          // Templated
     .REFCK                                 (clki_w),                // Templated
     .ENCLKOP                               (enclkop_i),             // Templated
     .ENCLKOS                               (enclkos_i),             // Templated
     .ENCLKOS2                              (enclkos2_i),            // Templated
     .ENCLKOS3                              (enclkos3_i),            // Templated
     .ENCLKOS4                              (enclkos4_i),            // Templated
     .ENCLKOS5                              (enclkos5_i),            // Templated
     .FBKCK                                 (fbclk_w),               // Templated
     .LEGACY                                (legacy_i),              // Templated
     .PLLRESET                              (pllreset),              // Templated
     .STDBY                                 (1'b0),                  // Templated
     .ROTDEL                                (1'b0),                  // Templated
     .DIRDEL                                (1'b0),                  // Templated
     .ROTDELP1                              (1'b0),                  // Templated
     .GRAYTEST                              (5'b0),                  // Templated
     .BINTEST                               (2'b0),                  // Templated
     .DIRDELP1                              (1'b0),                  // Templated
     .GRAYACT                               (5'b0),                  // Templated
     .BINACT                                (2'b0),                  // Templated
     // Outputs
     .INTFBKOP                              (intclkop_w),            // Templated
     .INTFBKOS                              (intclkos_w),            // Templated
     .INTFBKOS2                             (intclkos2_w),           // Templated
     .INTFBKOS3                             (intclkos3_w),           // Templated
     .INTFBKOS4                             (intclkos4_w),           // Templated
     .INTFBKOS5                             (intclkos5_w),           // Templated
     .LMMIRDATA                             (lmmi_rdata_o),          // Templated
     .LMMIRDATAVALID                        (lmmi_rdata_valid_o),    // Templated
     .LMMIREADY                             (lmmi_ready_o),          // Templated
     .CLKOP                                 (clkop_o),               // Templated
     .CLKOS                                 (clkos_o),               // Templated
     .CLKOS2                                (clkos2_o),              // Templated
     .CLKOS3                                (clkos3_o),              // Templated
     .CLKOS4                                (clkos4_o),              // Templated
     .CLKOS5                                (clkos5_o),              // Templated
     .INTLOCK                               (),                      // Templated
     .LEGRDYN                               (),                      // Templated
     .LOCK                                  (lock_o),                // Templated
     .PFDDN                                 (),                      // Templated
     .PFDUP                                 (),                      // Templated
     .REFMUXCK                              (),                      // Templated
     .REGQA                                 (),                      // Templated
     .REGQB                                 (),                      // Templated
     .REGQB1                                (),                      // Templated
     .CLKOUTDL                              ());                     // Templated
  end // gen_no_refclk_mon
endgenerate



//defparam u_PLL.SIM_FLOAT_PRECISION = SIM_FLOAT_PRECISION;
///*synthesis translate_off*/
//// For Simulation
//localparam FEEDBACK_FREQ = (FBK_MODE == "CLKOP"    )? CLKOP_FREQ_ACTUAL  :
//                           (FBK_MODE == "CLKOS"    )? CLKOS_FREQ_ACTUAL  :
//                           (FBK_MODE == "CLKOS2"   )? CLKOS2_FREQ_ACTUAL :
//                           (FBK_MODE == "CLKOS3"   )? CLKOS3_FREQ_ACTUAL :
//                           (FBK_MODE == "CLKOS4"   )? CLKOS4_FREQ_ACTUAL :
//                           (FBK_MODE == "CLKOS5"   )? CLKOS5_FREQ_ACTUAL :
//                           (FBK_MODE == "INTCLKOP" )? CLKOP_FREQ_ACTUAL  :
//                           (FBK_MODE == "INTCLKOS" )? CLKOS_FREQ_ACTUAL  :
//                           (FBK_MODE == "INTCLKOS2")? CLKOS2_FREQ_ACTUAL :
//                           (FBK_MODE == "INTCLKOS3")? CLKOS3_FREQ_ACTUAL :
//                           (FBK_MODE == "INTCLKOS4")? CLKOS4_FREQ_ACTUAL :
//                           (FBK_MODE == "INTCLKOS5")? CLKOS5_FREQ_ACTUAL :
//                                                      CLKOP_FREQ_ACTUAL;
//localparam FLOAT_PRECISION_ACTUAL  = (SIM_FLOAT_PRECISION == "0.0001")? (0.2/FEEDBACK_FREQ) : SIM_FLOAT_PRECISION;
//defparam u_PLL.SIM_FLOAT_PRECISION = FLOAT_PRECISION_ACTUAL;
///*synthesis translate_on*/

endmodule //--lscc_pll--
`endif // __RTL_MODULE__LSCC_PLL__


`ifndef LSCC_APB2LMMI
`define LSCC_APB2LMMI
//==========================================================================
// Module : lscc_apb2lmmi
//==========================================================================
module lscc_apb2lmmi

#( //--begin_param--
//----------------------------
// Parameters
//----------------------------
parameter                     DATA_WIDTH = 32,    // Data width
parameter                     ADDR_WIDTH = 16,    // Address width
parameter                     REG_OUTPUT = 1      // enable registered output

) //--end_param--

( //--begin_ports--
//----------------------------
// Global Signals (Clock and Reset)
//----------------------------
input                         clk_i,               // apb clock
input                         rst_n_i,             // active low reset

//----------------------------
// APB Interface
//----------------------------
input                         apb_penable_i,        // apb enable
input                         apb_psel_i,           // apb slave select
input                         apb_pwrite_i,         // apb write 1, read 0
input       [ADDR_WIDTH-1:0]  apb_paddr_i,          // apb address
input       [DATA_WIDTH-1:0]  apb_pwdata_i,         // apb write data

output reg                    apb_pready_o,         // apb ready
output reg                    apb_pslverr_o,        // apb slave error
output reg  [DATA_WIDTH-1:0]  apb_prdata_o,         // apb read data

//----------------------------
// LMMI-Extended Interface
//----------------------------
input                         lmmi_ready_i,         // slave is ready to start new transaction
input                         lmmi_rdata_valid_i,   // read transaction is complete
input                         lmmi_error_i,         // error indicator
input       [DATA_WIDTH-1:0]  lmmi_rdata_i,         // read data

output reg                    lmmi_request_o,       // start transaction
output reg                    lmmi_wr_rdn_o,        // write 1, read 0
output reg  [ADDR_WIDTH-1:0]  lmmi_offset_o,        // address/offset
output reg  [DATA_WIDTH-1:0]  lmmi_wdata_o,         // write data

output wire                   lmmi_resetn_o         // reset to LMMI inteface

); //--end_ports--



//--------------------------------------------------------------------------
//--- Local Parameters/Defines ---
//--------------------------------------------------------------------------
localparam                    ST_BUS_IDLE = 4'b0001;
localparam                    ST_BUS_REQ  = 4'b0010;  // APB_SETUP
localparam                    ST_BUS_DAT  = 4'b0100;  // APB_ACCESS
localparam                    ST_BUS_WAIT = 4'b1000;
localparam                    SM_WIDTH    = 4;

//--------------------------------------------------------------------------
//--- Combinational Wire/Reg ---
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
//--- Registers ---
//--------------------------------------------------------------------------
reg         [SM_WIDTH-1:0]    bus_sm_ns;
reg         [SM_WIDTH-1:0]    bus_sm_cs;

assign lmmi_resetn_o =  rst_n_i;

generate
  if(REG_OUTPUT) begin
    reg                           lmmi_request_nxt;
    reg                           lmmi_wr_rdn_nxt ;
    reg         [ADDR_WIDTH-1:0]  lmmi_offset_nxt ;
    reg         [DATA_WIDTH-1:0]  lmmi_wdata_nxt  ;
    reg                           apb_pready_nxt  ;
    reg                           apb_pslverr_nxt ;
    reg         [DATA_WIDTH-1:0]  apb_prdata_nxt  ;
    //--------------------------------------------
    //-- Bus Statemachine --
    //--------------------------------------------
    always @* begin
      bus_sm_ns = bus_sm_cs;
      case(bus_sm_cs)
        ST_BUS_REQ : begin
          if(lmmi_ready_i) begin
            if(lmmi_wr_rdn_o) begin
              bus_sm_ns   = ST_BUS_WAIT;
            end
            else begin
              if(lmmi_rdata_valid_i)
                bus_sm_ns = ST_BUS_WAIT;
              else
                bus_sm_ns = ST_BUS_DAT;
            end
          end
          else begin
            bus_sm_ns = ST_BUS_REQ;
          end
        end
        ST_BUS_DAT : begin
          if(lmmi_rdata_valid_i)
            bus_sm_ns = ST_BUS_WAIT;
          else
            bus_sm_ns = ST_BUS_DAT;
        end
        ST_BUS_WAIT : begin
          bus_sm_ns   = ST_BUS_IDLE;
        end
        default : begin
          if(apb_psel_i)
            bus_sm_ns = ST_BUS_REQ;
          else
            bus_sm_ns = ST_BUS_IDLE;
        end
      endcase
    end //--always @*--

    //--------------------------------------------
    //-- APB to LMMI conversion --
    //--------------------------------------------
    always @* begin
      lmmi_request_nxt = lmmi_request_o;
      lmmi_wr_rdn_nxt  = lmmi_wr_rdn_o ;
      lmmi_offset_nxt  = lmmi_offset_o ;
      lmmi_wdata_nxt   = lmmi_wdata_o  ;
      apb_pready_nxt   = apb_pready_o  ;
      apb_pslverr_nxt  = 1'b0          ;
      apb_prdata_nxt   = apb_prdata_o  ;
      case(bus_sm_cs)
        ST_BUS_REQ : begin
          if(lmmi_ready_i) begin
            lmmi_request_nxt = 1'b0;
            lmmi_wr_rdn_nxt  = 1'b0;
            if(lmmi_wr_rdn_o) begin
              apb_pready_nxt   = 1'b1;
            end
            else begin
              if(lmmi_rdata_valid_i) begin
                apb_pready_nxt  = 1'b1;
                apb_prdata_nxt  = lmmi_rdata_i;
                apb_pslverr_nxt = lmmi_error_i;
              end
            end
          end
        end
        ST_BUS_DAT : begin
          if(lmmi_rdata_valid_i) begin
            apb_pready_nxt   = 1'b1;
            apb_prdata_nxt   = lmmi_rdata_i;
            apb_pslverr_nxt  = lmmi_error_i;
          end
        end
        ST_BUS_WAIT : begin
          apb_pready_nxt     = 1'b0;
        end
        default : begin
          apb_pready_nxt     = 1'b0;
          if(apb_psel_i) begin
            lmmi_request_nxt = 1'b1;
            lmmi_wr_rdn_nxt  = apb_pwrite_i;
            lmmi_offset_nxt  = apb_paddr_i;
            lmmi_wdata_nxt   = apb_pwdata_i;
          end
          else begin
            lmmi_request_nxt = 1'b0;
            lmmi_wr_rdn_nxt  = 1'b0;
          end
        end
      endcase
    end //--always @*--

    //--------------------------------------------
    //-- Sequential block --
    //--------------------------------------------
    always @(posedge clk_i or negedge rst_n_i) begin
      if(~rst_n_i) begin
        bus_sm_cs <= ST_BUS_IDLE;
        /*AUTORESET*/
        // Beginning of autoreset for uninitialized flops
        apb_prdata_o <= {DATA_WIDTH{1'b0}};
        apb_pready_o <= 1'h0;
        apb_pslverr_o <= 1'h0;
        lmmi_offset_o <= {ADDR_WIDTH{1'b0}};
        lmmi_request_o <= 1'h0;
        lmmi_wdata_o <= {DATA_WIDTH{1'b0}};
        lmmi_wr_rdn_o <= 1'h0;
        // End of automatics
      end
      else begin
        bus_sm_cs    <= bus_sm_ns;
        lmmi_request_o <= lmmi_request_nxt;
        lmmi_wr_rdn_o  <= lmmi_wr_rdn_nxt ;
        lmmi_offset_o  <= lmmi_offset_nxt ;
        lmmi_wdata_o   <= lmmi_wdata_nxt  ;
        apb_pready_o   <= apb_pready_nxt  ;
        apb_pslverr_o  <= apb_pslverr_nxt ;
        apb_prdata_o   <= apb_prdata_nxt  ;
      end
    end //--always @(posedge clk_i or negedge rst_n_i)--
  end // REG_OUTPUT == 1

  else begin // REG_OUTPUT == 0
    //--------------------------------------------
    //-- Bus Statemachine --
    //--------------------------------------------
    always @* begin
      bus_sm_ns = bus_sm_cs;
      case(bus_sm_cs)
        ST_BUS_IDLE : begin
          if(apb_psel_i)
            bus_sm_ns = ST_BUS_REQ;
          else
            bus_sm_ns = ST_BUS_IDLE;
        end
        ST_BUS_REQ : begin
          if(lmmi_ready_i)
            if ((~apb_pwrite_i && ~lmmi_rdata_valid_i))
              bus_sm_ns = ST_BUS_DAT;
            else  // Write access will go to IDLE when ready
              bus_sm_ns = ST_BUS_IDLE;
          else
            bus_sm_ns = ST_BUS_REQ;
        end
        ST_BUS_DAT : begin
          if (apb_penable_i && (~apb_pwrite_i && lmmi_rdata_valid_i))
            bus_sm_ns = ST_BUS_IDLE;
          else
            bus_sm_ns = ST_BUS_DAT;
        end
        default : begin
          bus_sm_ns = ST_BUS_IDLE;
        end
      endcase
    end //--always @*--

    //--------------------------------------------
    //-- LMMI request --
    //--------------------------------------------
    always @* begin
      lmmi_request_o = (bus_sm_ns == ST_BUS_REQ);
      lmmi_wr_rdn_o  = apb_pwrite_i;
      lmmi_offset_o  = apb_paddr_i;
      lmmi_wdata_o   = apb_pwdata_i;
    end //--always @*--

    //--------------------------------------------
    //-- APB outputs --
    //--------------------------------------------
    always @* begin
      apb_prdata_o  = lmmi_rdata_i;
      apb_pslverr_o = lmmi_rdata_valid_i && lmmi_error_i;
      if (apb_pwrite_i) begin
        apb_pready_o  = lmmi_ready_i;
      end
      else begin
        apb_pready_o  = lmmi_ready_i && lmmi_rdata_valid_i;
      end
    end //--always @*--

    //--------------------------------------------
    //-- Sequential block --
    //--------------------------------------------
    always @(posedge clk_i or negedge rst_n_i) begin
      if(~rst_n_i) begin
        bus_sm_cs <= ST_BUS_IDLE;
      end
      else begin
        bus_sm_cs <= bus_sm_ns;
      end
    end //--always @(posedge clk_i or negedge rst_n_i)--
  end // REG_OUTPUT == 0
endgenerate

//--------------------------------------------------------------------------
//--- Module Instantiation ---
//--------------------------------------------------------------------------



endmodule //--lscc_apb2lmmi--
`endif
//--------------------------------------------------------------------------
// Local Variables:
// verilog-library-directories: ("." "C:/lscc/radiant/2.2/cae_library/simulation/verilog/lifcl")
// verilog-library-files: ("C:/lscc/radiant/2.2/cae_library/synthesis/verilog/lifcl.v")
// End:
//--------------------------------------------------------------------------
