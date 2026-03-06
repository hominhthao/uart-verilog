module uart_tx
#(
    parameter CLKS_PER_BIT = 87
)
(
    input        i_Clock,
    input        i_Rst,
    input        i_Tx_DV,
    input  [7:0] i_Tx_Byte,

    output reg o_Tx_Active,
    output reg o_Tx_Serial,
    output reg o_Tx_Done
);

localparam IDLE         = 3'b000;
localparam START_BIT    = 3'b001;
localparam DATA_BITS    = 3'b010;
localparam STOP_BIT     = 3'b011;
localparam CLEANUP      = 3'b100;

reg [2:0] r_SM_Main;
reg [15:0] r_Clock_Count;
reg [2:0] r_Bit_Index;
reg [7:0] r_Tx_Data;


always @(posedge i_Clock or posedge i_Rst)
begin

    if (i_Rst)
    begin
        r_SM_Main <= IDLE;
        o_Tx_Serial <= 1'b1;
        o_Tx_Active <= 1'b0;
        o_Tx_Done <= 1'b0;
        r_Clock_Count <= 0;
        r_Bit_Index <= 0;
    end

    else
    begin

        case (r_SM_Main)

        IDLE :
        begin
            o_Tx_Serial <= 1'b1;
            o_Tx_Done <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index <= 0;

            if (i_Tx_DV == 1'b1)
            begin
                o_Tx_Active <= 1'b1;
                r_Tx_Data <= i_Tx_Byte;
                r_SM_Main <= START_BIT;
            end
            else
            begin
                r_SM_Main <= IDLE;
            end
        end


        START_BIT :
        begin
            o_Tx_Serial <= 1'b0;

            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main <= START_BIT;
            end
            else
            begin
                r_Clock_Count <= 0;
                r_SM_Main <= DATA_BITS;
            end
        end


        DATA_BITS :
        begin
            o_Tx_Serial <= r_Tx_Data[r_Bit_Index];

            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main <= DATA_BITS;
            end
            else
            begin
                r_Clock_Count <= 0;

                if (r_Bit_Index < 7)
                begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main <= DATA_BITS;
                end
                else
                begin
                    r_Bit_Index <= 0;
                    r_SM_Main <= STOP_BIT;
                end
            end
        end


        STOP_BIT :
        begin
            o_Tx_Serial <= 1'b1;

            if (r_Clock_Count < CLKS_PER_BIT-1)
            begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main <= STOP_BIT;
            end
            else
            begin
                o_Tx_Done <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main <= CLEANUP;
                o_Tx_Active <= 1'b0;
            end
        end


        CLEANUP :
        begin
            o_Tx_Done <= 1'b1;
            r_SM_Main <= IDLE;
        end

        default :
            r_SM_Main <= IDLE;

        endcase

    end

end

endmodule
