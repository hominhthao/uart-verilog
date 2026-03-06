`timescale 1ns/1ps

module uart_tx_tb;

reg r_Clock = 0;
reg r_Rst = 0;

reg r_Tx_DV = 0;
reg [7:0] r_Tx_Byte = 0;

wire w_Tx_Active;
wire w_Tx_Serial;
wire w_Tx_Done;


uart_tx #(.CLKS_PER_BIT(87)) DUT
(
    .i_Clock(r_Clock),
    .i_Rst(r_Rst),
    .i_Tx_DV(r_Tx_DV),
    .i_Tx_Byte(r_Tx_Byte),

    .o_Tx_Active(w_Tx_Active),
    .o_Tx_Serial(w_Tx_Serial),
    .o_Tx_Done(w_Tx_Done)
);


always #5 r_Clock = ~r_Clock;


initial
begin

    r_Rst = 1;
    #20;
    r_Rst = 0;

    #100;

    r_Tx_DV   = 1'b1;
    r_Tx_Byte = 8'h3F;

    #10;
    r_Tx_DV = 1'b0;

    wait(w_Tx_Done == 1);

    #20000;

    $finish;

end


initial
begin
    $dumpfile("uart_tx.vcd");
    $dumpvars(0, uart_tx_tb);
end


endmodule
