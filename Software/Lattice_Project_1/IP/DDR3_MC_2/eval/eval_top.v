// =============================================================================
// >>>>>>>>>>>>>>>>>>>>>>>>> COPYRIGHT NOTICE <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
// -----------------------------------------------------------------------------
//   Copyright (c) 2020 by Lattice Semiconductor Corporation
//   ALL RIGHTS RESERVED
// -----------------------------------------------------------------------------
//
//   Permission:
//
//      Lattice SG Pte. Ltd. grants permission to use this code
//      pursuant to the terms of the Lattice Reference Design License Agreement.
//
//
//   Disclaimer:
//
//      This VHDL or Verilog source code is intended as a design reference
//      which illustrates how these types of functions can be implemented.
//      It is the user's responsibility to verify their design for
//      consistency and functionality through the use of formal
//      verification methods.  Lattice provides no warranty
//      regarding the use or functionality of this code.
//
// -----------------------------------------------------------------------------
//
//                  Lattice SG Pte. Ltd.
//                  101 Thomson Road, United Square #07-02
//                  Singapore 307591
//
//
//                  TEL: 1-800-Lattice (USA and Canada)
//                       +65-6631-2000 (Singapore)
//                       +1-503-268-8001 (other locations)
//
//                  web: http://www.latticesemi.com/
//                  email: techsupport@latticesemi.com
//
// -----------------------------------------------------------------------------
//
// =============================================================================
//                         FILE DETAILS
// Project               :
// File                  : eval_top.v
// Title                 :
// Description           : This is an RTL wrapper file that greatly reduced the
//                         DDR3_MC pins that goes to the FPGA fabric to allow
//                         running MAP and PaR check on generated DDR3_MC.
//                         This should NOT be used for verifying the IP functionality.
// =============================================================================
//                        REVISION HISTORY
// Version               : 1.0.1
// Author(s)             :
// Mod. Date             :
// Changes Made          : Initial release.
// =============================================================================

`include "lscc_simple_lfsr.v"
`include "lscc_pll.v"
module eval_top (
  clk_i             ,
  rst_n_i           ,
  mem_rst_n         ,

  
  em_ddr_data_io    ,
  em_ddr_dqs_io     ,
  em_ddr_dm_o       ,
  em_ddr_clk_o      ,
  em_ddr_cke_o      ,
  em_ddr_cs_n_o     ,
  em_ddr_ras_n_o    ,
  em_ddr_cas_n_o    ,
  em_ddr_we_n_o     ,
  em_ddr_odt_o      ,
  em_ddr_addr_o     ,
  em_ddr_ba_o       ,
  em_ddr_reset_n_o  ,
  
  lfsr_in_en_i      ,
  lfsr_out_en_i     ,
  lfsr_out_o
);

`include "dut_params.v"

localparam OUTSIG_WIDTH = 10 + CKE_WIDTH;
localparam DMSIZE       = DSIZE/8;
localparam INSIG_WIDTH  = 14;

input                     clk_i             ;
input                     rst_n_i           ;
input                     mem_rst_n         ;

// External Memory signals
inout  [DATA_WIDTH-1:0]   em_ddr_data_io    ;
inout  [DQS_WIDTH-1:0]    em_ddr_dqs_io     ;
output [DQS_WIDTH-1:0]    em_ddr_dm_o       ;
output [CLKO_WIDTH -1:0]  em_ddr_clk_o      ;
output [CKE_WIDTH -1:0]   em_ddr_cke_o      ;
output [CS_WIDTH -1:0]    em_ddr_cs_n_o     ;
output                    em_ddr_ras_n_o    ; 
output                    em_ddr_cas_n_o    ; 
output                    em_ddr_we_n_o     ;  
output [CS_WIDTH-1:0]     em_ddr_odt_o      ; 
output [ROW_WIDTH-1:0]    em_ddr_addr_o     ; 
output [2:0]              em_ddr_ba_o       ; 
output                    em_ddr_reset_n_o  ;



// LFSR  
input                     lfsr_in_en_i      ;
input                     lfsr_out_en_i     ;
output reg                lfsr_out_o        ;

reg                      lfsr_in_en_r       ;
reg                      lfsr_out_en_r      ;
reg                      mem_rst_n_i        ;

//Native Interface
wire                     init_done_o        ;
wire                     cmd_rdy_o          ;
wire                     datain_rdy_o       ;
wire                     rt_act_o           ;
wire                     rt_done_o          ;
wire                     rt_err_o           ;
wire                     ext_auto_ref_ack_o ;
wire                     sref_ent_cmd_o     ;
wire                     sref_ext_cmd_o     ;
wire  [CKE_WIDTH -1:0]   dfi_cke_o          ;
wire                     read_data_valid_o  ;
wire  [DSIZE -1:0]       read_data_o        ;

wire  [DSIZE -1:0]       write_data_i       ;
wire  [DMSIZE-1:0]       data_mask_i        ;
wire  [ADDR_WIDTH-1:0]   addr_i             ;
wire                     init_start_i       ;
wire                     rt_req_i           ;
wire                     ext_auto_ref_i     ;
wire                     cmd_valid_i        ;
wire  [3:0]              cmd_i              ;
wire  [4:0]              cmd_burst_cnt_i    ;
wire                     eclk_i             ;
wire                     sync_clk_i         ;
wire                     pll_lock_i         ;

wire                     sclk_o             ; // this pin should not be connected outside
wire                     clocking_good_o    ; // this pin should not be connected outside

wire lfsr_out_data_w;
wire lfsr_out_others_w;
wire [OUTSIG_WIDTH-1:0] out_others_w;
wire [3:0]              lfsr_in_top_w;
wire [INSIG_WIDTH-1:0]  in_others_w;

wire rst_w;
reg  rst_d1;
reg  rst_d2;

assign rst_w = rst_d2;

always @(posedge sclk_o or negedge rst_n_i) begin
  if (!rst_n_i) begin
    rst_d1 <= 1'b1;
    rst_d2 <= 1'b1;
  end
  else begin
    rst_d1 <= 1'b0;
    rst_d2 <= rst_d1;
  end
end

always @(posedge sclk_o or posedge rst_w) begin
  if (rst_w) begin
    lfsr_out_o    <= 1'b0;
	lfsr_in_en_r  <= 1'b0;
	lfsr_out_en_r <= 1'b0;
    mem_rst_n_i   <= 1'b0;
  end
  else begin
    lfsr_out_o    <= lfsr_out_data_w ^ lfsr_out_others_w;
	lfsr_in_en_r  <= lfsr_in_en_i ;
	lfsr_out_en_r <= lfsr_out_en_i;
    mem_rst_n_i   <= mem_rst_n    ;  // register this signal since this should come from LUT in actual application
  end
end

// LFSR for read data
lscc_simple_lfsr #(
    .LFSR_WIDTH (DSIZE                    ),
    .POLYNOMIAL ({8'hC6,{(DSIZE-8){1'b0}}}),
    .LFSR_INIT  ({{(DSIZE-1){1'b0}},1'b1} ),
    .O_PARALLEL (0                        ))
  rdata_gen (
    .clk_i      (sclk_o            ), 
    .rst_i      (rst_w             ), 
    .add_i      (read_data_valid_o ),
    .enb_i      (lfsr_out_en_r     ), 
    .din_i      (read_data_o       ),
    .dout_o     (lfsr_out_data_w   ));

assign out_others_w[0] = init_done_o        ;
assign out_others_w[1] = cmd_rdy_o          ;
assign out_others_w[2] = datain_rdy_o       ;
assign out_others_w[3] = rt_act_o           ;
assign out_others_w[4] = rt_done_o          ;
assign out_others_w[5] = rt_err_o           ;
assign out_others_w[6] = ext_auto_ref_ack_o ;
assign out_others_w[7] = sref_ent_cmd_o     ;
assign out_others_w[8] = sref_ext_cmd_o     ;
assign out_others_w[9] = wl_err_o           ;
assign out_others_w[OUTSIG_WIDTH-1:10] = dfi_cke_o;

lscc_simple_lfsr #(
    .LFSR_WIDTH (OUTSIG_WIDTH                    ),
    .POLYNOMIAL ({2'b11,{(OUTSIG_WIDTH-2){1'b0}}}),
    .LFSR_INIT  ({{(OUTSIG_WIDTH-1){1'b0}},1'b1} ),
    .O_PARALLEL (0                               ))
  out_others_gen (
    .clk_i      (sclk_o        ), 
    .rst_i      (rst_w         ), 
    .add_i      (lfsr_out_en_r ),
    .enb_i      (1'b0          ), 
    .din_i      (out_others_w  ),
    .dout_o     (lfsr_out_others_w));

lscc_simple_lfsr #(
    .LFSR_WIDTH (DSIZE                    ),
    .POLYNOMIAL ({8'hC6,{(DSIZE-8){1'b0}}}),
    .LFSR_INIT  ({{(DSIZE-1){1'b0}},1'b1} ),
    .O_PARALLEL (1                        ))
  wdata_gen (
    .clk_i      (sclk_o          ), 
    .rst_i      (rst_w           ),
    .enb_i      (lfsr_in_top_w[0]),	
    .add_i      (1'b0            ), // unused 
    .din_i      ({DSIZE{1'b0}}   ), // unused      
    .dout_o     (write_data_i    ));
   
lscc_simple_lfsr #(
    .LFSR_WIDTH (DMSIZE                    ),
    .POLYNOMIAL ({2'b11,{(DMSIZE-2){1'b0}}}),
    .LFSR_INIT  ({{(DMSIZE-1){1'b0}},1'b1} ),
    .O_PARALLEL (1                        ))
  wdata_mask_gen (
    .clk_i      (sclk_o            ), 
    .rst_i      (rst_w             ),
    .enb_i      (lfsr_in_top_w[1]  ),	
    .add_i      (1'b0              ), // unused 
    .din_i      ({DMSIZE{1'b0}}    ), // unused      
    .dout_o     (data_mask_i       ));
	
lscc_simple_lfsr #(
    .LFSR_WIDTH (ADDR_WIDTH                    ),
    .POLYNOMIAL ({8'hC1,{(ADDR_WIDTH-8){1'b0}}}),
    .LFSR_INIT  ({{(ADDR_WIDTH-1){1'b0}},1'b1} ),
    .O_PARALLEL (1                        ))
  addr_gen (
    .clk_i      (sclk_o            ), 
    .rst_i      (rst_w             ),
    .enb_i      (lfsr_in_top_w[2]  ),	
    .add_i      (1'b0              ), // unused 
    .din_i      ({ADDR_WIDTH{1'b0}}), // unused      
    .dout_o     (addr_i            ));

assign init_start_i     = in_others_w[0];
assign rt_req_i         = in_others_w[1];
assign ext_auto_ref_i   = in_others_w[2];
assign cmd_valid_i      = in_others_w[3];
assign cmd_i            = in_others_w[7:4];
assign ofly_burst_len_i = in_others_w[8];
assign cmd_burst_cnt_i  = in_others_w[INSIG_WIDTH-1:9];

  
lscc_simple_lfsr #(
    .LFSR_WIDTH (INSIG_WIDTH                    ),
    .POLYNOMIAL ({4'h9,{(INSIG_WIDTH-4){1'b0}}}),
    .LFSR_INIT  ({{(INSIG_WIDTH-1){1'b0}},1'b1} ),
    .O_PARALLEL (1                        ))
  in_others_gen (
    .clk_i      (sclk_o             ), 
    .rst_i      (rst_w              ),
    .enb_i      (lfsr_in_top_w[3]   ),	
    .add_i      (1'b0               ), // unused 
    .din_i      ({INSIG_WIDTH{1'b0}}), // unused      
    .dout_o     (in_others_w        ));
	
lscc_simple_lfsr #(
    .LFSR_WIDTH (4   ),
    .POLYNOMIAL (4'h8),
    .LFSR_INIT  (4'h1),
    .O_PARALLEL (1   ))
  top_lfsr_gen (
    .clk_i      (sclk_o       ), 
    .rst_i      (rst_w        ),
    .enb_i      (lfsr_in_en_r ),	
    .add_i      (1'b0         ), // unused 
    .din_i      (4'h0         ), // unused      
    .dout_o     (lfsr_in_top_w));
   
`include "dut_inst.v"


generate
  if (PLL_EN == 0) begin : EXT_PLL
    lscc_pll #(
       .CLKI_FREQ                (CLKI_FREQ                ),
       .CLKOP_FREQ_ACTUAL        (CLKOP_FREQ_ACTUAL        ),
       .CLKOS_FREQ_ACTUAL        (CLKOS_FREQ_ACTUAL        ),
       .CLKOS2_FREQ_ACTUAL       (CLKOS2_FREQ_ACTUAL       ),
       .CLKOS3_FREQ_ACTUAL       (CLKOS3_FREQ_ACTUAL       ),
       .CLKOS4_FREQ_ACTUAL       (CLKOS4_FREQ_ACTUAL       ),
       .CLKOS5_FREQ_ACTUAL       (CLKOS5_FREQ_ACTUAL       ),
       .CLKOP_PHASE_ACTUAL       (CLKOP_PHASE_ACTUAL       ),
       .CLKOS_PHASE_ACTUAL       (CLKOS_PHASE_ACTUAL       ),
       .CLKOS2_PHASE_ACTUAL      (CLKOS2_PHASE_ACTUAL      ),
       .CLKOS3_PHASE_ACTUAL      (CLKOS3_PHASE_ACTUAL      ),
       .CLKOS4_PHASE_ACTUAL      (CLKOS4_PHASE_ACTUAL      ),
       .CLKOS5_PHASE_ACTUAL      (CLKOS5_PHASE_ACTUAL      ),
       .CLKOS_EN                 (CLKOS_EN                 ),
       .CLKOS2_EN                (CLKOS2_EN                ),
       .CLKOS3_EN                (CLKOS3_EN                ),
       .CLKOS4_EN                (CLKOS4_EN                ),
       .CLKOS5_EN                (CLKOS5_EN                ),
       .CLKOP_BYPASS             (CLKOP_BYPASS             ),
       .CLKOS_BYPASS             (CLKOS_BYPASS             ),
       .CLKOS2_BYPASS            (CLKOS2_BYPASS            ),
       .CLKOS3_BYPASS            (CLKOS3_BYPASS            ),
       .CLKOS4_BYPASS            (CLKOS4_BYPASS            ),
       .CLKOS5_BYPASS            (CLKOS5_BYPASS            ),
       .ENCLKOP_EN               (ENCLKOP_EN               ),
       .ENCLKOS_EN               (ENCLKOS_EN               ),
       .ENCLKOS2_EN              (ENCLKOS2_EN              ),
       .ENCLKOS3_EN              (ENCLKOS3_EN              ),
       .ENCLKOS4_EN              (ENCLKOS4_EN              ),
       .ENCLKOS5_EN              (ENCLKOS5_EN              ),
       .FRAC_N_EN                (FRAC_N_EN                ),
       .SS_EN                    (SS_EN                    ),
       .DYN_PORTS_EN             (DYN_PORTS_EN             ),
       .PLL_RST                  (PLL_RST                  ),
       .LOCK_EN                  (LOCK_EN                  ),
       .PLL_LOCK_STICKY          (PLL_LOCK_STICKY          ),
       .LEGACY_EN                (LEGACY_EN                ),
       .LMMI_EN                  (LMMI_EN                  ),
       .APB_EN                   (APB_EN                   ),
       .POWERDOWN_EN             (POWERDOWN_EN             ),
       .TRIM_EN_P                (TRIM_EN_P                ),
       .TRIM_EN_S                (TRIM_EN_S                ),
       .PLL_REFCLK_FROM_PIN      (PLL_REFCLK_FROM_PIN      ),
       .IO_TYPE                  (PLL_IO_TYPE              ),
       .CLKOP_TRIM_MODE          (CLKOP_TRIM_MODE          ),
       .CLKOS_TRIM_MODE          (CLKOS_TRIM_MODE          ),
       .CLKOP_TRIM               (CLKOP_TRIM               ),
       .CLKOS_TRIM               (CLKOS_TRIM               ),
       .FBK_MODE                 (FBK_MODE                 ),
       .CLKI_DIVIDER_ACTUAL_STR  (CLKI_DIVIDER_ACTUAL_STR  ),
       .FBCLK_DIVIDER_ACTUAL_STR (FBCLK_DIVIDER_ACTUAL_STR ),
       .DIVOP_ACTUAL_STR         (DIVOP_ACTUAL_STR         ),
       .DIVOS_ACTUAL_STR         (DIVOS_ACTUAL_STR         ),
       .DIVOS2_ACTUAL_STR        (DIVOS2_ACTUAL_STR        ),
       .DIVOS3_ACTUAL_STR        (DIVOS3_ACTUAL_STR        ),
       .DIVOS4_ACTUAL_STR        (DIVOS4_ACTUAL_STR        ),
       .DIVOS5_ACTUAL_STR        (DIVOS5_ACTUAL_STR        ),
       .SSC_N_CODE_STR           (SSC_N_CODE_STR           ),
       .SSC_F_CODE_STR           (SSC_F_CODE_STR           ),
       .SSC_PROFILE              (SSC_PROFILE              ),
       .SSC_TBASE_STR            (SSC_TBASE_STR            ),
       .SSC_STEP_IN_STR          (SSC_STEP_IN_STR          ),
       .SSC_REG_WEIGHTING_SEL_STR(SSC_REG_WEIGHTING_SEL_STR),
       .DELA                     (DELA                     ),
       .DELB                     (DELB                     ),
       .DELC                     (DELC                     ),
       .DELD                     (DELD                     ),
       .DELE                     (DELE                     ),
       .DELF                     (DELF                     ),
       .PHIA                     (PHIA                     ),
       .PHIB                     (PHIB                     ),
       .PHIC                     (PHIC                     ),
       .PHID                     (PHID                     ),
       .PHIE                     (PHIE                     ),
       .PHIF                     (PHIF                     ),
       .EN_REFCLK_MON            (EN_REFCLK_MON            ),
       .REF_COUNTS               (REF_COUNTS               ),
       .INTFBKDEL_SEL            (INTFBKDEL_SEL            ),
       .PMU_WAITFORLOCK          (PMU_WAITFORLOCK          ),
       .REF_OSC_CTRL             (REF_OSC_CTRL             ),
       .SIM_FLOAT_PRECISION      ("0.1"                    ),
       .IPI_CMP                  (IPI_CMP                  ),
       .CSET                     (CSET                     ),
       .CRIPPLE                  (CRIPPLE                  ),
       .IPP_CTRL                 (IPP_CTRL                 ),
       .IPP_SEL                  (IPP_SEL                  ),
       .BW_CTL_BIAS              (BW_CTL_BIAS              ),
       .V2I_PP_RES               (V2I_PP_RES               ),
       .KP_VCO                   (KP_VCO                   ),
       .V2I_KVCO_SEL             (V2I_KVCO_SEL             ),
       .V2I_1V_EN                (V2I_1V_EN                ))
    lscc_pll_inst (
       .clki_i                   (clk_i       ), 
       .usr_fbclk_i              (1'b0        ), 
       .rstn_i                   (rst_n_i     ), 
       .legacy_i                 (1'b1        ), 
       .pllpd_en_n_i             (1'b1        ), 
       .phasedir_i               (1'b0        ), 
       .phasestep_i              (1'b0        ), 
       .phaseloadreg_i           (1'b0        ), 
       .phasesel_i               (3'b000      ), 
       .enclkop_i                (1'b1        ), 
       .enclkos_i                (1'b1        ), 
       .enclkos2_i               (1'b1        ), 
       .enclkos3_i               (1'b1        ), 
       .enclkos4_i               (1'b1        ), 
       .enclkos5_i               (1'b1        ), 
       .clkop_o                  (eclk_i      ), 
       .clkos_o                  (sync_clk_i  ), 
       .clkos2_o                 (            ), 
       .clkos3_o                 (            ), 
       .clkos4_o                 (            ), 
       .clkos5_o                 (            ), 
       .lock_o                   (pll_lock_i  ), 
       .refdetreset              (1'b0        ),
       .refdetlos                (            ),
       .lmmi_clk_i               (1'b0        ), 
       .lmmi_resetn_i            (1'b1        ), 
       .lmmi_request_i           (1'b0        ), 
       .lmmi_wr_rdn_i            (1'b0        ), 
       .lmmi_offset_i            (7'b0000000  ), 
       .lmmi_wdata_i             (8'b00000000 ), 
       .lmmi_rdata_o             (            ), 
       .lmmi_rdata_valid_o       (            ), 
       .lmmi_ready_o             (            ), 
       .apb_pclk_i               (1'b0        ), 
       .apb_preset_n_i           (1'b1        ), 
       .apb_penable_i            (1'b0        ), 
       .apb_psel_i               (1'b0        ), 
       .apb_pwrite_i             (1'b0        ), 
       .apb_paddr_i              (7'b0000000  ), 
       .apb_pwdata_i             (8'b00000000 ), 
       .apb_pready_o             (            ), 
       .apb_pslverr_o            (            ), 
       .apb_prdata_o             (            )); 
  end
endgenerate

endmodule