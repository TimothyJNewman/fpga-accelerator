
`ifdef DELAY_0  // values 0,1,2,10,50
   `define DELAY 0
`else
   `ifdef DELAY_2
      `define DELAY 2
   `else
      `ifdef DELAY_10
         `define DELAY 10
      `else
         `ifdef DELAY_50
            `define DELAY 50
         `else
            `ifdef X4_GEAR
               `define DELAY 2
            `else
               `define DELAY 1
            `endif
         `endif
      `endif
   `endif
`endif

`ifdef FLY_BY_DEL_2000
  `define FULL_FLY_BY_DEL 2000
`elseif FLY_BY_DEL_1500
  `define FULL_FLY_BY_DEL 1500
`else
`define FULL_FLY_BY_DEL 1000
`endif

`ifdef RDIMM
  `ifdef NO_WRITE_LEVEL
     `define FBY_TRC_DQS8 0 
     `define FBY_TRC_DQS3 0
     `define FBY_TRC_DQS2 0
     `define FBY_TRC_DQS1 0
     `define FBY_TRC_DQS0 0

     `define FBY_TRC_DQS4 0
     `define FBY_TRC_DQS5 0
     `define FBY_TRC_DQS6 0
     `define FBY_TRC_DQS7 0

     `define FBY_TRC_DQS17 0 
     `define FBY_TRC_DQS12 0 
     `define FBY_TRC_DQS11 0 
     `define FBY_TRC_DQS10 0 
     `define FBY_TRC_DQS9 0 

     `define FBY_TRC_DQS13 0 
     `define FBY_TRC_DQS14 0 
     `define FBY_TRC_DQS15 0 
     `define FBY_TRC_DQS16 0 

  `else

     `ifdef x4

       `define FBY_TRC_DQS0 520 
       `define FBY_TRC_DQS1 400 
       `define FBY_TRC_DQS2 270 
       `define FBY_TRC_DQS3 200 

       `define FBY_TRC_DQS4 200 
       `define FBY_TRC_DQS5 270 
       `define FBY_TRC_DQS6 400 
       `define FBY_TRC_DQS7 520 

       `define FBY_TRC_DQS8 520 
       `define FBY_TRC_DQS9 400 
       `define FBY_TRC_DQS10 270 
       `define FBY_TRC_DQS11 200 

       `define FBY_TRC_DQS12 200 
       `define FBY_TRC_DQS13 270 
       `define FBY_TRC_DQS14 400 
       `define FBY_TRC_DQS15 520 
       `define FBY_TRC_DQS16 520 
       `define FBY_TRC_DQS17 520 

     `else
       `define FBY_TRC_DQS0 520 
       `define FBY_TRC_DQS1 400 
       `define FBY_TRC_DQS2 270 
       `define FBY_TRC_DQS3 200 

       `define FBY_TRC_DQS4 200 
       `define FBY_TRC_DQS5 270 
       `define FBY_TRC_DQS6 400 
       `define FBY_TRC_DQS7 520 
       `define FBY_TRC_DQS8 520 
     `endif

  `endif

`else // UDIMM

// x4
`define FBY_TRC_DQS9 0
`define FBY_TRC_DQS10 0
`define FBY_TRC_DQS11 0
`define FBY_TRC_DQS12 0
`define FBY_TRC_DQS13 0
`define FBY_TRC_DQS14 0
`define FBY_TRC_DQS15 0
`define FBY_TRC_DQS16 0
`define FBY_TRC_DQS17 0 

  `ifdef NO_WRITE_LEVEL
     `define FBY_TRC_DQS0 0
     `define FBY_TRC_DQS1 0
     `define FBY_TRC_DQS2 0
     `define FBY_TRC_DQS3 0
     `define FBY_TRC_DQS4 0
     `define FBY_TRC_DQS5 0
     `define FBY_TRC_DQS6 0
     `define FBY_TRC_DQS7 0
     `define FBY_TRC_DQS8 0 
  `else
      `ifdef FBY_TRC_DQS_50
         `define FBY_TRC_DQS0 65
         `define FBY_TRC_DQS1 65
         `define FBY_TRC_DQS2 65 
         `define FBY_TRC_DQS3 65
         `define FBY_TRC_DQS4 65 
         `define FBY_TRC_DQS5 65
         `define FBY_TRC_DQS6 65
         `define FBY_TRC_DQS7 65
         `define FBY_TRC_DQS8 65
     `else
         `define FBY_TRC_DQS0 (`FULL_FLY_BY_DEL * 0.461)   //TL1 
         `define FBY_TRC_DQS1 (`FULL_FLY_BY_DEL * 0.077)   //TL2 
         `define FBY_TRC_DQS2 (`FULL_FLY_BY_DEL * 0.077)   //TL3 
         `define FBY_TRC_DQS3 (`FULL_FLY_BY_DEL * 0.077)   //TL4 
         `define FBY_TRC_DQS4 (`FULL_FLY_BY_DEL * 0.077)   //TL5 
         `define FBY_TRC_DQS5 (`FULL_FLY_BY_DEL * 0.077)   //TL6 
         `define FBY_TRC_DQS6 (`FULL_FLY_BY_DEL * 0.077)   //TL7 
         `define FBY_TRC_DQS7 (`FULL_FLY_BY_DEL * 0.077)   //TL8 
         `define FBY_TRC_DQS8 (`FULL_FLY_BY_DEL * 0.077)   //TL9 
     `endif
  `endif //NO_WRITE_LEVEL
`endif // UDIMM

`define RD_Tstaoff 2640
`define RD_tPDM 780
