`timescale 100 ps/100 ps
module DDRDLL (
  CODE,
  FREEZE,
  LOCK,
  CLKIN,
  RST,
  DCNTL,
  UDDCNTL_N
)
;
output [8:0] CODE ;
input FREEZE ;
output LOCK ;
input CLKIN ;
input RST ;
output [8:0] DCNTL ;
input UDDCNTL_N ;
endmodule /* DDRDLL */

module ECLKSYNC (
  ECLKIN,
  ECLKOUT,
  STOP
)
;
input ECLKIN ;
output ECLKOUT ;
input STOP ;
endmodule /* ECLKSYNC */

module ECLKDIV (
  DIVOUT,
  DIVRST,
  ECLKIN,
  SLIP
)
;
output DIVOUT ;
input DIVRST ;
input ECLKIN ;
input SLIP ;
endmodule /* ECLKDIV */

module ODDRX2DQ (
  D0,
  D1,
  D2,
  D3,
  DQSW270,
  ECLK,
  SCLK,
  RST,
  Q
)
;
input D0 ;
input D1 ;
input D2 ;
input D3 ;
input DQSW270 ;
input ECLK ;
input SCLK ;
input RST ;
output Q ;
endmodule /* ODDRX2DQ */

module TSHX2DQS (
  T0,
  T1,
  DQSW,
  ECLK,
  SCLK,
  RST,
  Q
)
;
input T0 ;
input T1 ;
input DQSW ;
input ECLK ;
input SCLK ;
input RST ;
output Q ;
endmodule /* TSHX2DQS */

module TSHX2DQ (
  T0,
  T1,
  DQSW270,
  ECLK,
  SCLK,
  RST,
  Q
)
;
input T0 ;
input T1 ;
input DQSW270 ;
input ECLK ;
input SCLK ;
input RST ;
output Q ;
endmodule /* TSHX2DQ */

module ODDRX2DQS (
  D0,
  D1,
  D2,
  D3,
  DQSW,
  ECLK,
  SCLK,
  RST,
  Q
)
;
input D0 ;
input D1 ;
input D2 ;
input D3 ;
input DQSW ;
input ECLK ;
input SCLK ;
input RST ;
output Q ;
endmodule /* ODDRX2DQS */

module DQSBUF (
  BTDETECT,
  BURSTDETECT,
  DATAVALID,
  DQSI,
  DQSW,
  DQSWRD,
  PAUSE,
  RDCLKSEL,
  RDDIR,
  RDLOADN,
  RDPNTR,
  READ,
  READCOUT,
  READMOVE,
  RST,
  SCLK,
  SELCLK,
  DQSR90,
  DQSW270,
  WRCOUT,
  WRDIR,
  WRLOAD_N,
  WRLVCOUT,
  WRLVDIR,
  WRLVLOAD_N,
  WRLVMOVE,
  WRMOVE,
  WRPNTR,
  ECLKIN,
  RSTSMCNT,
  DLLCODE
)
;
output BTDETECT ;
output BURSTDETECT ;
output DATAVALID ;
input DQSI ;
output DQSW ;
output DQSWRD ;
input PAUSE ;
input [3:0] RDCLKSEL ;
input RDDIR ;
input RDLOADN ;
output [2:0] RDPNTR ;
input [3:0] READ ;
output READCOUT ;
input READMOVE ;
input RST ;
input SCLK ;
input SELCLK ;
output DQSR90 ;
output DQSW270 ;
output WRCOUT ;
input WRDIR ;
input WRLOAD_N ;
output WRLVCOUT ;
input WRLVDIR ;
input WRLVLOAD_N ;
input WRLVMOVE ;
input WRMOVE ;
output [2:0] WRPNTR ;
input ECLKIN ;
input RSTSMCNT ;
input [8:0] DLLCODE ;
endmodule /* DQSBUF */

module OSHX2 (
  D0,
  D1,
  ECLK,
  SCLK,
  RST,
  Q
)
;
input D0 ;
input D1 ;
input ECLK ;
input SCLK ;
input RST ;
output Q ;
endmodule /* OSHX2 */

module DELAYB (
  A,
  Z
)
;
input A ;
output Z ;
endmodule /* DELAYB */

module ODDRX1 (
  D0,
  D1,
  SCLK,
  RST,
  Q
)
;
input D0 ;
input D1 ;
input SCLK ;
input RST ;
output Q ;
endmodule /* ODDRX1 */

module ODDRX2 (
  D0,
  D1,
  D2,
  D3,
  SCLK,
  RST,
  ECLK,
  Q
)
;
input D0 ;
input D1 ;
input D2 ;
input D3 ;
input SCLK ;
input RST ;
input ECLK ;
output Q ;
endmodule /* ODDRX2 */

(* black_box_pad_pin="CKN,CKP,DN0,DN1,DN2,DN3,DP0,DP1,DP2,DP3" *)module DPHY (
  LMMICLK,
  LMMIRESET_N,
  LMMIREQUEST,
  LMMIWRRD_N,
  LMMIOFFSET,
  LMMIWDATA,
  LMMIRDATA,
  LMMIRDATAVALID,
  LMMIREADY,
  BITCKEXT,
  CKN,
  CKP,
  CLKREF,
  D0ACTIVE,
  D0BYTCNT,
  D0ERRCNT,
  D0PASS,
  D0VALID,
  D1ACTIVE,
  D1BYTCNT,
  D1ERRCNT,
  D1PASS,
  D1VALID,
  D2ACTIVE,
  D2BYTCNT,
  D2ERRCNT,
  D2PASS,
  D2VALID,
  D3ACTIVE,
  D3BYTCNT,
  D3ERRCNT,
  D3PASS,
  D3VALID,
  DCTSTOUT,
  DN0,
  DN1,
  DN2,
  DN3,
  DP0,
  DP1,
  DP2,
  DP3,
  LOCK,
  PDDPHY,
  PDPLL,
  SCCLKIN,
  UDIR,
  UED0THEN,
  UERCLP0,
  UERCLP1,
  UERCTRL,
  UERE,
  UERSTHS,
  UERSSHS,
  UERSE,
  UFRXMODE,
  UTXMDTX,
  URXACTHS,
  URXCKE,
  URXCKINE,
  URXDE,
  URXDHS,
  URXLPDTE,
  URXSKCHS,
  URXDRX,
  URXSHS,
  URE0D3DP,
  URE1D3DN,
  URE2CKDP,
  URE3CKDN,
  URXULPSE,
  URXVDE,
  URXVDHS,
  USSTT,
  UTDIS,
  UTXCKE,
  UDE0D0TN,
  UDE1D1TN,
  UDE2D2TN,
  UDE3D3TN,
  UDE4CKTN,
  UDE5D0RN,
  UDE6D1RN,
  UDE7D2RN,
  UTXDHS,
  UTXENER,
  UTXRRS,
  UTXRYP,
  UTXRYSK,
  UTXRD0EN,
  UTRD0SEN,
  UTXSKD0N,
  UTXTGE0,
  UTXTGE1,
  UTXTGE2,
  UTXTGE3,
  UTXULPSE,
  UTXUPSEX,
  UTXVDE,
  UTXWVDHS,
  UUSAN,
  U1DIR,
  U1ENTHEN,
  U1ERCLP0,
  U1ERCLP1,
  U1ERCTRL,
  U1ERE,
  U1ERSTHS,
  U1ERSSHS,
  U1ERSE,
  U1FRXMD,
  U1FTXST,
  U1RXATHS,
  U1RXCKE,
  U1RXDE,
  U1RXDHS,
  U1RXDTE,
  U1RXSKS,
  U1RXSK,
  U1RXSHS,
  U1RE0D,
  U1RE1CN,
  U1RE2D,
  U1RE3N,
  U1RXUPSE,
  U1RXVDE,
  U1RXVDHS,
  U1SSTT,
  U1TDIS,
  U1TREQ,
  U1TDE0D3,
  U1TDE1CK,
  U1TDE2D0,
  U1TDE3D1,
  U1TDE4D2,
  U1TDE5D3,
  U1TDE6,
  U1TDE7,
  U1TXDHS,
  U1TXLPD,
  U1TXRYE,
  U1TXRY,
  U1TXRYSK,
  U1TXREQ,
  U1TXREQH,
  U1TXSK,
  U1TXTGE0,
  U1TXTGE1,
  U1TXTGE2,
  U1TXTGE3,
  U1TXUPSE,
  U1TXUPSX,
  U1TXVDE,
  U1TXWVHS,
  U1USAN,
  U2DIR,
  U2END2,
  U2ERCLP0,
  U2ERCLP1,
  U2ERCTRL,
  U2ERE,
  U2ERSTHS,
  U2ERSSHS,
  U2ERSE,
  U2FRXMD,
  U2FTXST,
  U2RXACHS,
  U2RXCKE,
  U2RXDE,
  U2RXDHS,
  U2RPDTE,
  U2RXSK,
  U2RXSKC,
  U2RXSHS,
  U2RE0D2,
  U2RE1D2,
  U2RE2D3,
  U2RE3D3,
  U2RXUPSE,
  U2RXVDE,
  U2RXVDHS,
  U2SSTT,
  U2TDIS,
  U2TREQ,
  U2TDE0D0,
  U2TDE1D1,
  U2TDE2D2,
  U2TDE3D3,
  U2TDE4CK,
  U2TDE5D0,
  U2TDE6D1,
  U2TDE7D2,
  U2TXDHS,
  U2TPDTE,
  U2TXRYE,
  U2TXRYH,
  U2TXRYSK,
  U2TXREQ,
  U2TXREQH,
  U2TXSKC,
  U2TXTGE0,
  U2TXTGE1,
  U2TXTGE2,
  U2TXTGE3,
  U2TXUPSE,
  U2TXUPSX,
  U2TXVDE,
  U2TXWVHS,
  U2USAN,
  U3DIR,
  U3END3,
  U3ERCLP0,
  U3ERCLP1,
  U3ERCTRL,
  U3ERE,
  U3ERSTHS,
  U3ERSSHS,
  U3ERSE,
  U3FRXMD,
  U3FTXST,
  U3RXATHS,
  U3RXCKE,
  U3RXDE,
  U3RXDHS,
  U3RPDTE,
  U3RXSK,
  U3RXSKC,
  U3RXSHS,
  U3RE0CK,
  U3RE1CK,
  U3RE2,
  U3RE3,
  U3RXUPSE,
  U3RXVDE,
  U3RXVDHS,
  U3SSTT,
  U3TDISD2,
  U3TREQD2,
  U3TDE0D3,
  U3TDE1D0,
  U3TDE2D1,
  U3TDE3D2,
  U3TDE4D3,
  U3TDE5CK,
  U3TDE6,
  U3TDE7,
  U3TXDHS,
  U3TXLPDT,
  U3TXRY,
  U3TXRYHS,
  U3TXRYSK,
  U3TXREQ,
  U3TXREQH,
  U3TXSKC,
  U3TXTGE0,
  U3TXTGE1,
  U3TXTGE2,
  U3TXTGE3,
  U3TXULPS,
  U3TXUPSX,
  U3TXVD3,
  U3TXWVHS,
  U3USAN,
  UCENCK,
  UCRXCKAT,
  UCRXUCKN,
  UCSSTT,
  UCTXREQH,
  UCTXUPSC,
  UCTXUPSX,
  UCUSAN,
  LTSTEN,
  LTSTLANE,
  URWDCKHS,
  UTRNREQ,
  UTWDCKHS,
  UCRXWCHS,
  CLKLBACT
)
;
input LMMICLK ;
input LMMIRESET_N ;
input LMMIREQUEST ;
input LMMIWRRD_N ;
input [4:0] LMMIOFFSET ;
input [3:0] LMMIWDATA ;
output [3:0] LMMIRDATA ;
output LMMIRDATAVALID ;
output LMMIREADY ;
input BITCKEXT ;
inout CKN /* synthesis syn_tristate = 1 */ ;
inout CKP /* synthesis syn_tristate = 1 */ ;
input CLKREF ;
output [1:0] D0ACTIVE ;
output [9:0] D0BYTCNT ;
output [9:0] D0ERRCNT ;
output [1:0] D0PASS ;
output [1:0] D0VALID ;
output [1:0] D1ACTIVE ;
output [9:0] D1BYTCNT ;
output [9:0] D1ERRCNT ;
output [1:0] D1PASS ;
output [1:0] D1VALID ;
output [1:0] D2ACTIVE ;
output [9:0] D2BYTCNT ;
output [9:0] D2ERRCNT ;
output [1:0] D2PASS ;
output [1:0] D2VALID ;
output [1:0] D3ACTIVE ;
output [9:0] D3BYTCNT ;
output [9:0] D3ERRCNT ;
output [1:0] D3PASS ;
output [1:0] D3VALID ;
output [9:0] DCTSTOUT ;
inout DN0 /* synthesis syn_tristate = 1 */ ;
inout DN1 /* synthesis syn_tristate = 1 */ ;
inout DN2 /* synthesis syn_tristate = 1 */ ;
inout DN3 /* synthesis syn_tristate = 1 */ ;
inout DP0 /* synthesis syn_tristate = 1 */ ;
inout DP1 /* synthesis syn_tristate = 1 */ ;
inout DP2 /* synthesis syn_tristate = 1 */ ;
inout DP3 /* synthesis syn_tristate = 1 */ ;
output LOCK ;
input PDDPHY ;
input PDPLL ;
input SCCLKIN ;
output UDIR ;
input UED0THEN ;
output UERCLP0 ;
output UERCLP1 ;
output UERCTRL ;
output UERE ;
output UERSTHS ;
output UERSSHS ;
output UERSE ;
input UFRXMODE ;
input UTXMDTX ;
output URXACTHS ;
output URXCKE ;
input URXCKINE ;
output [7:0] URXDE ;
output [15:0] URXDHS ;
output URXLPDTE ;
output URXSKCHS ;
output URXDRX ;
output [3:0] URXSHS ;
output URE0D3DP ;
output URE1D3DN ;
output URE2CKDP ;
output URE3CKDN ;
output URXULPSE ;
output URXVDE ;
output [3:0] URXVDHS ;
output USSTT ;
input UTDIS ;
input UTXCKE ;
input UDE0D0TN ;
input UDE1D1TN ;
input UDE2D2TN ;
input UDE3D3TN ;
input UDE4CKTN ;
input UDE5D0RN ;
input UDE6D1RN ;
input UDE7D2RN ;
input [31:0] UTXDHS ;
input UTXENER ;
output UTXRRS ;
output UTXRYP ;
output UTXRYSK ;
input UTXRD0EN ;
input UTRD0SEN ;
input UTXSKD0N ;
input UTXTGE0 ;
input UTXTGE1 ;
input UTXTGE2 ;
input UTXTGE3 ;
input UTXULPSE ;
input UTXUPSEX ;
input UTXVDE ;
input [3:0] UTXWVDHS ;
output UUSAN ;
output U1DIR ;
input U1ENTHEN ;
output U1ERCLP0 ;
output U1ERCLP1 ;
output U1ERCTRL ;
output U1ERE ;
output U1ERSTHS ;
output U1ERSSHS ;
output U1ERSE ;
input U1FRXMD ;
input U1FTXST ;
output U1RXATHS ;
output U1RXCKE ;
output [7:0] U1RXDE ;
output [15:0] U1RXDHS ;
output U1RXDTE ;
output U1RXSKS ;
output U1RXSK ;
output [3:0] U1RXSHS ;
output U1RE0D ;
output U1RE1CN ;
output U1RE2D ;
output U1RE3N ;
output U1RXUPSE ;
output U1RXVDE ;
output [3:0] U1RXVDHS ;
output U1SSTT ;
input U1TDIS ;
input U1TREQ ;
input U1TDE0D3 ;
input U1TDE1CK ;
input U1TDE2D0 ;
input U1TDE3D1 ;
input U1TDE4D2 ;
input U1TDE5D3 ;
input U1TDE6 ;
input U1TDE7 ;
input [31:0] U1TXDHS ;
input U1TXLPD ;
output U1TXRYE ;
output U1TXRY ;
output U1TXRYSK ;
input U1TXREQ ;
input U1TXREQH ;
input U1TXSK ;
input U1TXTGE0 ;
input U1TXTGE1 ;
input U1TXTGE2 ;
input U1TXTGE3 ;
input U1TXUPSE ;
input U1TXUPSX ;
input U1TXVDE ;
input [3:0] U1TXWVHS ;
output U1USAN ;
output U2DIR ;
input U2END2 ;
output U2ERCLP0 ;
output U2ERCLP1 ;
output U2ERCTRL ;
output U2ERE ;
output U2ERSTHS ;
output U2ERSSHS ;
output U2ERSE ;
input U2FRXMD ;
input U2FTXST ;
output U2RXACHS ;
output U2RXCKE ;
output [7:0] U2RXDE ;
output [15:0] U2RXDHS ;
output U2RPDTE ;
output U2RXSK ;
output U2RXSKC ;
output [3:0] U2RXSHS ;
output U2RE0D2 ;
output U2RE1D2 ;
output U2RE2D3 ;
output U2RE3D3 ;
output U2RXUPSE ;
output U2RXVDE ;
output [3:0] U2RXVDHS ;
output U2SSTT ;
input U2TDIS ;
input U2TREQ ;
input U2TDE0D0 ;
input U2TDE1D1 ;
input U2TDE2D2 ;
input U2TDE3D3 ;
input U2TDE4CK ;
input U2TDE5D0 ;
input U2TDE6D1 ;
input U2TDE7D2 ;
input [31:0] U2TXDHS ;
input U2TPDTE ;
output U2TXRYE ;
output U2TXRYH ;
output U2TXRYSK ;
input U2TXREQ ;
input U2TXREQH ;
input U2TXSKC ;
input U2TXTGE0 ;
input U2TXTGE1 ;
input U2TXTGE2 ;
input U2TXTGE3 ;
input U2TXUPSE ;
input U2TXUPSX ;
input U2TXVDE ;
input [3:0] U2TXWVHS ;
output U2USAN ;
output U3DIR ;
input U3END3 ;
output U3ERCLP0 ;
output U3ERCLP1 ;
output U3ERCTRL ;
output U3ERE ;
output U3ERSTHS ;
output U3ERSSHS ;
output U3ERSE ;
input U3FRXMD ;
input U3FTXST ;
output U3RXATHS ;
output U3RXCKE ;
output [7:0] U3RXDE ;
output [15:0] U3RXDHS ;
output U3RPDTE ;
output U3RXSK ;
output U3RXSKC ;
output [3:0] U3RXSHS ;
output U3RE0CK ;
output U3RE1CK ;
output U3RE2 ;
output U3RE3 ;
output U3RXUPSE ;
output U3RXVDE ;
output [3:0] U3RXVDHS ;
output U3SSTT ;
input U3TDISD2 ;
input U3TREQD2 ;
input U3TDE0D3 ;
input U3TDE1D0 ;
input U3TDE2D1 ;
input U3TDE3D2 ;
input U3TDE4D3 ;
input U3TDE5CK ;
input U3TDE6 ;
input U3TDE7 ;
input [31:0] U3TXDHS ;
input U3TXLPDT ;
output U3TXRY ;
output U3TXRYHS ;
output U3TXRYSK ;
input U3TXREQ ;
input U3TXREQH ;
input U3TXSKC ;
input U3TXTGE0 ;
input U3TXTGE1 ;
input U3TXTGE2 ;
input U3TXTGE3 ;
input U3TXULPS ;
input U3TXUPSX ;
input U3TXVD3 ;
input [3:0] U3TXWVHS ;
output U3USAN ;
input UCENCK ;
output UCRXCKAT ;
output UCRXUCKN ;
output UCSSTT ;
input UCTXREQH ;
input UCTXUPSC ;
input UCTXUPSX ;
output UCUSAN ;
input LTSTEN ;
input [1:0] LTSTLANE ;
output URWDCKHS ;
input UTRNREQ ;
output UTWDCKHS ;
output UCRXWCHS ;
output CLKLBACT ;
endmodule /* DPHY */

module PLL (
  INTFBKOP,
  INTFBKOS,
  INTFBKOS2,
  INTFBKOS3,
  INTFBKOS4,
  INTFBKOS5,
  DIR,
  DIRSEL,
  LOADREG,
  DYNROTATE,
  LMMICLK,
  LMMIRESET_N,
  LMMIREQUEST,
  LMMIWRRD_N,
  LMMIOFFSET,
  LMMIWDATA,
  LMMIRDATA,
  LMMIRDATAVALID,
  LMMIREADY,
  PLLPOWERDOWN_N,
  REFCK,
  CLKOP,
  CLKOS,
  CLKOS2,
  CLKOS3,
  CLKOS4,
  CLKOS5,
  ENCLKOP,
  ENCLKOS,
  ENCLKOS2,
  ENCLKOS3,
  ENCLKOS4,
  ENCLKOS5,
  FBKCK,
  INTLOCK,
  LEGACY,
  LEGRDYN,
  LOCK,
  PFDDN,
  PFDUP,
  PLLRESET,
  STDBY,
  REFMUXCK,
  REGQA,
  REGQB,
  REGQB1,
  CLKOUTDL,
  ROTDEL,
  DIRDEL,
  ROTDELP1,
  GRAYTEST,
  BINTEST,
  DIRDELP1,
  GRAYACT,
  BINACT
)
;
output INTFBKOP ;
output INTFBKOS ;
output INTFBKOS2 ;
output INTFBKOS3 ;
output INTFBKOS4 ;
output INTFBKOS5 ;
input DIR ;
input [2:0] DIRSEL ;
input LOADREG ;
input DYNROTATE ;
input LMMICLK ;
input LMMIRESET_N ;
input LMMIREQUEST ;
input LMMIWRRD_N ;
input [6:0] LMMIOFFSET ;
input [7:0] LMMIWDATA ;
output [7:0] LMMIRDATA ;
output LMMIRDATAVALID ;
output LMMIREADY ;
input PLLPOWERDOWN_N ;
input REFCK ;
output CLKOP ;
output CLKOS ;
output CLKOS2 ;
output CLKOS3 ;
output CLKOS4 ;
output CLKOS5 ;
input ENCLKOP ;
input ENCLKOS ;
input ENCLKOS2 ;
input ENCLKOS3 ;
input ENCLKOS4 ;
input ENCLKOS5 ;
input FBKCK ;
output INTLOCK ;
input LEGACY ;
output LEGRDYN ;
output LOCK ;
output PFDDN ;
output PFDUP ;
input PLLRESET ;
input STDBY ;
output REFMUXCK ;
output REGQA ;
output REGQB ;
output REGQB1 ;
output CLKOUTDL ;
input ROTDEL ;
input DIRDEL ;
input ROTDELP1 ;
input [4:0] GRAYTEST ;
input [1:0] BINTEST ;
input DIRDELP1 ;
input [4:0] GRAYACT ;
input [1:0] BINACT ;
endmodule /* PLL */

