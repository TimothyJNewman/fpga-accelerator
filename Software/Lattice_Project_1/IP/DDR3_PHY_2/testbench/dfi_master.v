`ifndef DFI_MASTER
`define DFI_MASTER

module dfi_master # (
    parameter ADDR_WIDTH   = 15,
    parameter BA_WIDTH     = 3,
    parameter CKE_WIDTH    = 2,
    parameter CS_WIDTH     = 2,
    parameter DATA_WIDTH   = 128,
    parameter DDR_WIDTH    = 32,
    parameter BYTE_LANE    = DATA_WIDTH/8,
    parameter DQS_WIDTH    = DDR_WIDTH/8,
    parameter CLKOP_FREQ   = 400,
    parameter DELAY        = 1,
    parameter CW_GT10      = 0,
    parameter CW_GT11      = 0,
    parameter NO_INFO      = 0,
    parameter TXN_CNT      = 5,
    parameter MRS0_INIT    = 1296,
    parameter MRS1_INIT    = 68,
    parameter MRS2_INIT    = 512,
    parameter MRS3_INIT    = 0,
    parameter GEARING      = 2
)(
    input                       clk_i,
    input                       rst_i,
    input                       eclk_i,
			                    
    output reg                  clk_stable_o,
    output reg                  dqsbuf_pause_o,
    output reg                  update_done_o,
			                    
    input                       sclk_i,
    input                       dll_update_i,
			                    
    input                       phy_init_act_i,
    input                       wl_act_i,
    input                       wl_err_i,
    input                       rt_err_i,

    output reg [ADDR_WIDTH-1:0] dfi_addr_o,
    output reg [2:0]            dfi_bank_o,
    output reg                  dfi_cas_n_o,
    output reg [CKE_WIDTH-1:0]  dfi_cke_o,
    output reg [CS_WIDTH-1:0]   dfi_cs_n_o,
    output reg [CS_WIDTH-1:0]   dfi_odt_o,
    output reg                  dfi_ras_n_o,
    output reg                  dfi_we_n_o,
    output reg [DATA_WIDTH-1:0] dfi_wrdata_o,
    output reg                  dfi_wrdataen_o,
    output reg [BYTE_LANE-1:0]  dfi_wrdata_mask_o,
    output reg                  dfi_init_start_o,
								
    input [DATA_WIDTH-1:0]      dfi_rddata_i,
    input                       dfi_init_complete_i,
    input                       dfi_rddata_valid_i
);

localparam CLKOP_4PERIOD = (8000000/CLKOP_FREQ);
localparam RD_TIMEOUT    = 31;

localparam BL8         = 2'b00;
localparam BL_BC_FLYBY = 2'b01;
localparam BC4         = 2'b10;

localparam LOOP_COUNT  = 100;

reg [ADDR_WIDTH-1:0] mrs0_written;
reg [ADDR_WIDTH-1:0] mrs1_written;
reg [ADDR_WIDTH-1:0] mrs2_written;

reg [ADDR_WIDTH-1:0] mrs0_toWrite;
reg [ADDR_WIDTH-1:0] mrs1_toWrite;
reg [ADDR_WIDTH-1:0] mrs2_toWrite;

reg [3:0] cas;
reg [1:0] adl;
reg [2:0] cwl;

reg [2:0] active_bank;
reg       rd_timeout_r;
reg [4:0] rd_counter_r;
reg       chk_r;
reg       chk_latch_r;
reg       chk_ctr_r;

reg [1023:0] din_r;
reg [1023:0] din_p_r;
reg [DATA_WIDTH-1:0] pdata;
reg [DATA_WIDTH-1:0] pdata2;
reg [31:0] WrDel;
reg [CS_WIDTH-1:0] cs_active;

wire [1:0] bl;
assign bl = mrs0_written[1:0];

integer i0;
genvar im0;
for(im0 = 0; im0 < 32; im0 = im0 + 1) begin
    always @ (posedge sclk_i) begin
        din_r [im0*32 +: 32] <= $urandom_range({32{1'b0}}, {32{1'b1}});
    end
end

always @ (posedge sclk_i) begin
    din_p_r <= din_r;
end

always @ (*) begin
    adl = mrs1_written[4:3];
    case ({mrs0_written[6], mrs0_written[5], mrs0_written[4], mrs0_written[2]})
        4'b0010 : cas = 4'd5;
        4'b0100 : cas = 4'd6;
        4'b0110 : cas = 4'd7;
        4'b1000 : cas = 4'd8;
        4'b1010 : cas = 4'd9;
        4'b1100 : cas = 4'd10;
        default : cas = 4'd5;
    endcase
    case(cas)
            32'h5: begin
                case(adl)
                    2'b00:   WrDel = 2;
                    2'b01:   WrDel = 3;
                    2'b10:   WrDel = 3;
                    default: WrDel = 4;
                endcase
            end
            32'h6: begin
                case(adl)
                    2'b00:   WrDel = 2;
                    2'b01:   WrDel = 4;
                    2'b10:   WrDel = 4;
                    default: WrDel = 4;
                endcase
            end
            32'h7: begin
                case(adl)
                    2'b00:   WrDel = 2;
                    2'b01:   WrDel = 5;
                    2'b10:   WrDel = 5;
                    default: WrDel = 4;
                endcase
            end
            32'h8: begin
                case(adl)
                    2'b00:   WrDel = 2;
                    2'b01:   WrDel = 6;
                    2'b10:   WrDel = 5;
                    default: WrDel = 4;
                endcase
            end
    endcase
end

always @ (posedge sclk_i) begin
    if(rd_timeout_r == 1'b0) begin
        if(rd_counter_r == 5'h1) begin
            rd_timeout_r <= 1'b1;
        end
        rd_counter_r <= rd_counter_r - 1'b1;
    end
    else begin
        rd_counter_r <= RD_TIMEOUT;
    end
end

always @ (posedge dfi_rddata_valid_i) begin
    rd_timeout_r <= 1'b1;
end

always @ (posedge sclk_i) begin
    if(dfi_rddata_valid_i) begin
        if(chk_ctr_r == 1'b0) begin
            chk_r <= (dfi_rddata_i === pdata);
            chk_ctr_r <= 1'b1;
            if(chk_latch_r == 1'b1) begin
                chk_latch_r <= (dfi_rddata_i === pdata);
            end
        end
        else begin
            chk_r <= (dfi_rddata_i === pdata2);
            chk_ctr_r <= 1'b0;
            if(chk_latch_r == 1'b1) begin
                chk_latch_r <= (dfi_rddata_i === pdata2);
            end
        end
    end
    else begin
        chk_ctr_r <= 1'b0;
        chk_r     <= 1'b1;
    end
end

integer ix0;
initial begin
    init();
    cs_active <= (CS_WIDTH == 2) ? 2'b00 : 1'b0;
    @(posedge sclk_i);
    ActivateBank(3'h5);
    cs_active <= (CS_WIDTH == 2) ? 2'b01 : 1'b0;
    for(ix0 = 0; ix0 < LOOP_COUNT; ix0 = ix0 + 1) begin
        Write(32'h0000, din_r[DATA_WIDTH-1:0], {BYTE_LANE{1'b0}}, din_p_r[DATA_WIDTH-1:0], {BYTE_LANE{1'b0}}, cs_active);
        @(posedge sclk_i);
        Read(32'h0000, cs_active);
    end
    @(posedge sclk_i);
    if(CS_WIDTH == 2) begin
        cs_active <= (CS_WIDTH == 2) ? 2'b10 : 1'b0;
        @(posedge sclk_i);
        for(ix0 = 0; ix0 < LOOP_COUNT; ix0 = ix0 + 1) begin
            Write(32'h0000, din_r[DATA_WIDTH-1:0], {BYTE_LANE{1'b0}}, din_p_r[DATA_WIDTH-1:0], {BYTE_LANE{1'b0}}, cs_active);
            @(posedge sclk_i);
            Read(32'h0000, cs_active);
        end
    end    
// phase 2
    cs_active <= (CS_WIDTH == 2) ? 2'b01 : 1'b0;
    @(posedge sclk_i);
    for(ix0 = 0; ix0 < LOOP_COUNT; ix0 = ix0 + 1) begin
        Write(32'h0000, din_r[DATA_WIDTH-1:0], {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}, 
                        din_p_r[DATA_WIDTH-1:0], {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}, cs_active);
        @(posedge sclk_i);
        Read(32'h0000, cs_active);
    end
    @(posedge sclk_i);
    if(CS_WIDTH == 2) begin
        cs_active <= (CS_WIDTH == 2) ? 2'b10 : 1'b0;
        @(posedge sclk_i);
        for(ix0 = 0; ix0 < LOOP_COUNT; ix0 = ix0 + 1) begin
            Write(32'h0000, din_r[DATA_WIDTH-1:0], {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}, 
                            din_p_r[DATA_WIDTH-1:0], {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}, cs_active);
            @(posedge sclk_i);
            Read(32'h0000, cs_active);
        end
    end 
    @(posedge sclk_i);
    @(posedge sclk_i);
    if(chk_latch_r == 1'b1) begin
        $display("-----------------------------------------------------");
        $display("----------------- SIMULATION PASSED -----------------");
        $display("-----------------------------------------------------");
    end
    else begin
        $display("-----------------------------------------------------");
        $display("!!!!!!!!!!!!!!!!! SIMULATION FAILED !!!!!!!!!!!!!!!!!");
        $display("-----------------------------------------------------");
    end
    $finish;
end

task ActivateBank;
    input [2:0] bank_i;
    begin
        @(posedge sclk_i);
        dfi_addr_o  <= 'h400;
        dfi_bank_o  <= bank_i;
        dfi_ras_n_o <= 1'b0;
        active_bank <= bank_i;
        dfi_cs_n_o <= {CS_WIDTH{1'b0}};
        @(posedge sclk_i);
        dfi_ras_n_o <= 1'b1;
        dfi_cs_n_o <= {CS_WIDTH{1'b1}};
        #100;
        @(posedge sclk_i);
    end
endtask

task Read;
    input [ADDR_WIDTH-1:0] rd_addr_i;
    input [CS_WIDTH-1:0]   cs_r;
    begin
        @(posedge sclk_i);
        dfi_cas_n_o  <= 1'b0;
        dfi_addr_o   <= rd_addr_i;
        dfi_bank_o   <= active_bank;
        dfi_cs_n_o   <= cs_r;
        @(posedge sclk_i);
        dfi_cas_n_o  <= 1'b1;
        dfi_addr_o   <= {ADDR_WIDTH{1'b0}};
        dfi_bank_o   <= 2'b00;
        rd_timeout_r <= 1'b0;
        dfi_cs_n_o   <= {CS_WIDTH{1'b1}};
        @(posedge sclk_i);
        while(rd_timeout_r == 1'b0) @(posedge sclk_i);
    end
endtask

task Write;
    input [ADDR_WIDTH-1:0] wr_addr_i;
    input [DATA_WIDTH-1:0] wr_data_i;
    input [BYTE_LANE-1:0]  byte_en_i;
    input [DATA_WIDTH-1:0] wr_data2_i;
    input [BYTE_LANE-1:0]  byte_en2_i;
    input [CS_WIDTH-1:0]   cs_r;
    integer Wr0;
    begin
        @(posedge sclk_i);
        dfi_addr_o        <= wr_addr_i;
        dfi_bank_o        <= active_bank;
        dfi_cas_n_o       <= 1'b0;
        dfi_we_n_o        <= 1'b0;
        dfi_odt_o         <= ~cs_r;
        dfi_cs_n_o        <= cs_r;
        @(posedge sclk_i);
        dfi_cas_n_o       <= 1'b1;
        dfi_we_n_o        <= 1'b1;
        dfi_bank_o        <= 2'b00;
        dfi_odt_o         <= {CS_WIDTH{1'b0}};
        dfi_cs_n_o        <= {CS_WIDTH{1'b1}};
        for(Wr0 = 0; Wr0 < WrDel; Wr0 = Wr0 + 1) @(posedge sclk_i);
        dfi_wrdataen_o    <= 1'b1;
        dfi_wrdata_mask_o <= byte_en_i;
        dfi_wrdata_o      <= wr_data_i;
        if(byte_en_i == {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}) begin
            pdata[DATA_WIDTH-1:(DATA_WIDTH/2)] <= wr_data_i[DATA_WIDTH-1:(DATA_WIDTH/2)];
        end
        else begin
            pdata         <= wr_data_i;
        end
        @(posedge sclk_i);
        if(GEARING == 2 && (bl == BL8 || (bl == BL_BC_FLYBY && wr_addr_i[12]))) begin
            dfi_wrdata_mask_o <= byte_en2_i;
            dfi_wrdata_o      <= wr_data2_i;
            if(byte_en2_i == {{(BYTE_LANE/2){1'b0}}, {(BYTE_LANE/2){1'b1}}}) begin
                pdata2[DATA_WIDTH-1:(DATA_WIDTH/2)] <= wr_data2_i[DATA_WIDTH-1:(DATA_WIDTH/2)];
            end
            else begin
                pdata2         <= wr_data2_i;
            end
            @(posedge sclk_i);
        end
        dfi_wrdataen_o    <= 1'b0;
        dfi_wrdata_mask_o <= {BYTE_LANE{1'b1}};
        dfi_wrdata_o      <= {DATA_WIDTH{1'b0}};
        @(posedge sclk_i);
        @(posedge sclk_i);
    end
endtask
//---------------------------------------------------------------------------------- 
// Task       :  init
// Description:  Initializes the IP
// Parameters : 
//              
//----------------------------------------------------------------------------------
task init;
    begin
        rd_counter_r       <= RD_TIMEOUT;
        rd_timeout_r       <= 1'b1;
        mrs0_written       <= MRS0_INIT;
        mrs1_written       <= MRS1_INIT;
        mrs2_written       <= MRS2_INIT;
        active_bank        <= 2'b00;
        clk_stable_o       <= 1'b0;
        dqsbuf_pause_o     <= 1'b0;
        update_done_o      <= 1'b0;
        dfi_addr_o         <= {ADDR_WIDTH{1'b0}};
        dfi_bank_o         <= {BA_WIDTH{1'b0}};
        dfi_cke_o          <= {CKE_WIDTH{1'b1}};
        dfi_cs_n_o         <= {CS_WIDTH{1'b1}};
        dfi_odt_o          <= {CS_WIDTH{1'b0}};
        dfi_cas_n_o        <= 1'b1;
        dfi_ras_n_o        <= 1'b1;
        dfi_we_n_o         <= 1'b1;
        dfi_wrdata_o       <= {DATA_WIDTH{1'b0}};
        dfi_wrdataen_o     <= 1'b0;
        dfi_wrdata_mask_o  <= {DATA_WIDTH{1'b1}};
        dfi_init_start_o   <= 1'b0;
        chk_r              <= 1'b1;
        chk_latch_r        <= 1'b1;
        chk_ctr_r          <= 1'b0;
        @(negedge rst_i);  
        @(posedge clk_i);  
        dfi_init_start_o   <= 1'b1;
        clk_stable_o       <= 1'b1;
        @(posedge sclk_i);
        @(posedge dfi_init_complete_i);
        dfi_init_start_o   <= 1'b0;
        @(posedge sclk_i);
        if(rt_err_i) $finish;
    end
endtask

task SetNewMrs;
    input [31:0] mrs_val;
    input [31:0] mrs_targ;
    begin
        @(posedge sclk_i);
        dfi_cas_n_o <= 1'b0;
        dfi_we_n_o  <= 1'b0;
        dfi_ras_n_o <= 1'b0;
        dfi_addr_o  <= mrs_val[ADDR_WIDTH-1:0];
        dfi_bank_o  <= mrs_targ[2:0];
        dfi_cs_n_o  <= {CS_WIDTH{1'b0}};
        if(mrs_targ == 2'b00) mrs0_written <= mrs_val[ADDR_WIDTH-1:0];
        if(mrs_targ == 2'b01) mrs1_written <= mrs_val[ADDR_WIDTH-1:0];
        if(mrs_targ == 2'b10) mrs2_written <= mrs_val[ADDR_WIDTH-1:0];
        @(posedge sclk_i);
        dfi_cas_n_o <= 1'b1;
        dfi_we_n_o  <= 1'b1;
        dfi_ras_n_o <= 1'b1;
        dfi_addr_o  <= {ADDR_WIDTH{1'b0}};
        dfi_bank_o  <= 3'b000;
        dfi_cs_n_o  <= {CS_WIDTH{1'b1}};
        @(posedge sclk_i);
        @(posedge sclk_i);
        @(posedge sclk_i);
    end
endtask

task SetFastCASWRBL;
    input [31:0] cas_r;
    input [31:0] wr;
    input [1:0] bl_r;
    reg [31:0] cas_eq_mrs;
    reg [31:0] wr_eq_mrs;
    reg [31:0] mr0_towrite;
    begin
        mr0_towrite = mrs0_written;
        mr0_towrite[8] = 1'b0;
        mr0_towrite[1:0] = bl_r;
        case(cas_r)
            32'h5: begin
                mr0_towrite[6:4] = 3'b001;
                mr0_towrite[2]   = 1'b0;
            end
            32'h6: begin
                mr0_towrite[6:4] = 3'b010;
                mr0_towrite[2]   = 1'b0;
            end
            32'h7: begin
                mr0_towrite[6:4] = 3'b011;
                mr0_towrite[2]   = 1'b0;
            end
            32'h8: begin
                mr0_towrite[6:4] = 3'b100;
                mr0_towrite[2]   = 1'b0;
            end
        endcase
        case(wr)
            32'h 5: mr0_towrite[11:9] = 3'b001;
            32'h 6: mr0_towrite[11:9] = 3'b010;
            32'h 7: mr0_towrite[11:9] = 3'b011;
            32'h 8: mr0_towrite[11:9] = 3'b100;
            32'h10: mr0_towrite[11:9] = 3'b101;
            32'h12: mr0_towrite[11:9] = 3'b110;
            32'h14: mr0_towrite[11:9] = 3'b111;
            32'h16: mr0_towrite[11:9] = 3'b000;
        endcase
        SetNewMrs(mr0_towrite, 0);
    end
endtask

task SetFastCASWR;
    input [31:0] cas_r;
    input [31:0] wr;
    reg [31:0] cas_eq_mrs;
    reg [31:0] wr_eq_mrs;
    reg [31:0] mr0_towrite;
    begin
        mr0_towrite = mrs0_written;
        mr0_towrite[8] = 1'b0;
        case(cas_r)
            32'h5: begin
                mr0_towrite[6:4] = 3'b001;
                mr0_towrite[2]   = 1'b0;
            end
            32'h6: begin
                mr0_towrite[6:4] = 3'b010;
                mr0_towrite[2]   = 1'b0;
            end
            32'h7: begin
                mr0_towrite[6:4] = 3'b011;
                mr0_towrite[2]   = 1'b0;
            end
            32'h8: begin
                mr0_towrite[6:4] = 3'b100;
                mr0_towrite[2]   = 1'b0;
            end
        endcase
        case(wr)
            32'h 5: mr0_towrite[11:9] = 3'b001;
            32'h 6: mr0_towrite[11:9] = 3'b010;
            32'h 7: mr0_towrite[11:9] = 3'b011;
            32'h 8: mr0_towrite[11:9] = 3'b100;
            32'h10: mr0_towrite[11:9] = 3'b101;
            32'h12: mr0_towrite[11:9] = 3'b110;
            32'h14: mr0_towrite[11:9] = 3'b111;
            32'h16: mr0_towrite[11:9] = 3'b000;
        endcase
        SetNewMrs(mr0_towrite, 0);
    end
endtask

task SetFastAL;
    input [31:0] al_r;
    begin
        case(al_r) // AL-2 = 16, AL-1 = E, AL-0 = 6
            2'b00: SetNewMrs(32'h0006, 1);
            2'b01: SetNewMrs(32'h000E, 1);
            2'b10: SetNewMrs(32'h0016, 1);
        endcase        
    end
endtask

task SetFastCWL;
    input [31:0] cwl_r;
    begin
        case(cwl_r)
            5: SetNewMrs(0, 2);
            6: SetNewMrs(8, 2);
            default: SetNewMrs (0, 2);
        endcase
    end
endtask

endmodule
`endif