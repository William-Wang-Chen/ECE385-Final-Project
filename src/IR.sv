//This part based on https://github.com/wenalan123/IR

module  IR(
        input                   CLOCK_50                ,
        input                   s_rst_n                 ,
        //ir
        input                   IRDA_RXD   ,
			output			[31:0]  ir_dout
);

logic                            ir_dout_vld                     ;
logic     [ 1: 0]                 rst_r                           ;
logic                            rst_n                           ; 


always  @(posedge CLOCK_50 or negedge s_rst_n) begin
        if(s_rst_n == 1'b0)
            rst_r       <=      'd0;
        else
            rst_r       <=      {rst_r[0],1'b1};
end

assign      rst_n       =       rst_r[1];




ir_decode   ir_decode_inst(
        .clk                    (CLOCK_50               ),
        .rst_n                  (rst_n                  ),
        //ir
        .ir_din                 (IRDA_RXD               ),
        .ir_dout                (ir_dout                ),
        .ir_dout_vld            (ir_dout_vld            )
);



endmodule
