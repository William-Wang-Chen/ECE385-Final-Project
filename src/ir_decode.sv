//This part based on https://github.com/wenalan123/IR
module  ir_decode(
        input                   clk                     ,
        input                   rst_n                   ,
        //ir
        input                   ir_din                  ,
        output  reg   [31: 0]   ir_dout                 ,
        output  reg             ir_dout_vld 
);

parameter[18:0]   MIN_9MS     =       19'd325_000                     ;//6.5ms
parameter[18:0]   MAX_9MS     =       19'd495_000                     ;//9.9ms
parameter[18:0]   MIN_4_5MS   =       19'd152_500                     ;//3.05ms
parameter[18:0]   MAX_4_5MS   =       19'd277_500                     ;//5.55ms
parameter[18:0]   MIN_560US   =       19'd20_000                      ;//400us
parameter[18:0]   MAX_560US   =       19'd35_000                      ;//700us
parameter[18:0]   MIN_1690US  =       19'd75_000                      ;//1500us
parameter[18:0]   MAX_1690US  =       19'd90_000                      ;//1800us

parameter[3:0]   IDLE        =       4'b0001                         ;
parameter[3:0]   CHECK_T9MS  =       4'b0010                         ;
parameter[3:0]   CHECK_T4_5MS=       4'b0100                         ;
parameter[3:0]   DATA_DECODE =       4'b1000                         ;

logic     [ 3: 0]                 state_c                         ;
logic     [ 3: 0]                 state_n                         ;

logic     [ 3: 0]                 ir_din_r                        ;
logic                            ir_l2h                          ;
logic                            ir_h2l                          ; 

logic     [18: 0]                 cnt_clk                         ; 
logic                            add_cnt_clk                     ;
logic                            end_cnt_clk                     ; 
logic     [31: 0]                 cnt_data                        ;
logic                            add_cnt_data                    ;
logic                            end_cnt_data                    ;

logic                            check_9ms_start                 ;
logic                            check_4_5ms_start               ;
logic                            data_decode_start               ;
logic                           idle_start                      ; 

logic                           check_9ms_ok                    ; 
logic                           check_4_5ms_ok                  ; 
logic                           check_560us_ok                  ; 
logic                           check_1690us_ok                 ; 




always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_din_r    <=      'd0;
        else
            ir_din_r    <=      {ir_din_r[2:0],ir_din};
end

assign  ir_h2l      =       (!ir_din_r[2]) && ir_din_r[3];
assign  ir_l2h      =       ir_din_r[2] && (!ir_din_r[3]);

//cnt_clk
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_clk <= 0;
    end
    else if(add_cnt_clk)begin
        if(end_cnt_clk)
            cnt_clk <= 0;
        else
            cnt_clk <= cnt_clk + 1'b1;
    end
end

assign  add_cnt_clk     =       (state_c != IDLE);    
assign  end_cnt_clk     =       add_cnt_clk && (ir_h2l || ir_l2h);

assign  check_9ms_ok    =       (state_c == CHECK_T9MS) && (cnt_clk >= MIN_9MS) && (cnt_clk <= MAX_9MS);
assign  check_4_5ms_ok  =       (state_c == CHECK_T4_5MS) && (cnt_clk >= MIN_4_5MS) && (cnt_clk <= MAX_4_5MS);
assign  check_560us_ok  =       (state_c == DATA_DECODE) && (cnt_clk >= MIN_560US) && (cnt_clk <= MAX_560US);
assign  check_1690us_ok =       (state_c == DATA_DECODE) && (cnt_clk >= MIN_1690US) && (cnt_clk <= MAX_1690US);



always@(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        state_c <= IDLE;
    end
    else begin
        state_c <= state_n;
    end
end


always@(*)begin
    case(state_c)
        IDLE:begin
            if(check_9ms_start)begin
                state_n = CHECK_T9MS;
            end
            else begin
                state_n = state_c;
            end
        end
        CHECK_T9MS:begin
            if(check_4_5ms_start)begin
                state_n = CHECK_T4_5MS;
            end
            else if(ir_l2h && (!check_9ms_ok))begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        CHECK_T4_5MS:begin
            if(data_decode_start)begin 
                state_n = DATA_DECODE;
            end
            else if(ir_h2l && (!check_4_5ms_ok))begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        DATA_DECODE:begin
            if(idle_start)begin
                state_n = IDLE;
            end
            else begin
                state_n = state_c;
            end
        end
        default:begin
            state_n = IDLE;
        end
    endcase
end

assign  check_9ms_start         =       (state_c == IDLE) && ir_h2l;
assign  check_4_5ms_start       =       (state_c == CHECK_T9MS) && ir_l2h && check_9ms_ok;
assign  data_decode_start       =       (state_c == CHECK_T4_5MS) && ir_h2l && check_4_5ms_ok;
assign  idle_start              =       (state_c == DATA_DECODE) && ((ir_l2h && !check_560us_ok) || (ir_h2l && !check_560us_ok && !check_1690us_ok) || ir_dout_vld);



//cnt_data
always @(posedge clk or negedge rst_n)begin
    if(!rst_n)begin
        cnt_data <= 0;
    end
    else if(add_cnt_data)begin
        if(end_cnt_data)
            cnt_data <= 0;
        else
            cnt_data <= cnt_data + 1;
    end
end

assign add_cnt_data = (state_c == DATA_DECODE) && ir_h2l;
assign end_cnt_data = ((state_c == DATA_DECODE) && ((ir_l2h && !check_560us_ok) || (ir_h2l && !check_560us_ok && !check_1690us_ok))) || (add_cnt_data && (cnt_data == 32-1));   

//ir_dout_vld
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_dout_vld     <=      1'b0;
        else if(add_cnt_data && (cnt_data == 32-1))
            ir_dout_vld     <=      1'b1;
        else
            ir_dout_vld     <=      1'b0;
end

//ir_dout
always  @(posedge clk or negedge rst_n) begin
        if(rst_n == 1'b0)
            ir_dout     <=      1'd0;
        else if(add_cnt_data)
		  begin
            if(check_560us_ok)
                ir_dout[cnt_data]   <=      1'b0;
            else if(check_1690us_ok)
                ir_dout[cnt_data]   <=      1'b1;
		  end
end
endmodule
