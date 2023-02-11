module ATM_MOORE (
	input wire unsigned [3:0] CARD_ID,
	input wire unsigned [3:0] PIN0,
	input wire unsigned [3:0] PIN1,
	input wire unsigned [3:0] PIN2,
	input wire unsigned [3:0] PIN3,
	input wire [1:0] TRANSACTION,
	input wire unsigned [31:0] AMOUNT,
	input wire OKAY,
	input wire CANCEL,

	input wire CLK,
	input wire RESET,

	output reg SUCCESS
);


localparam [1:0] 	WITHDRAWOP 	= 2'b00,
                    INQUIREOP 	= 2'b01,
                    DEPOSITOP 	= 2'b10;

localparam [3:0]	IDLE		 	= 4'b0000,
										FAILURE 			= 4'b0001,
                    IDLEPIN				= 4'b0011,
                    PINTRIAL1 		= 4'b0010,
                    PINTRIAL2 		= 4'b0110,
                    IDLEMENU 			= 4'b0111,
                    WITHDRAW 			= 4'b0101,
                    INSUFFICIENT 	= 4'b0100,
                    BALANCE 			= 4'b1100,
                    ANOTHER 			= 4'b1101;
									
reg [3:0] CURRENT, NEXT;

reg unsigned [3:0] 	CARDS [0:9];
reg unsigned [3:0] 	PINS [0:9][3:0];
reg unsigned [31:0]	BALANCES [0:9];
integer	DBSIZE = 10;

integer I;
initial
begin: INIT
	for(I = 0; I < DBSIZE; I = I + 1)
	begin
    CARDS[I] = I;
    PINS[I][0] = I;
    PINS[I][1] = I;
    PINS[I][2] = I;
    PINS[I][3] = I;
    BALANCES[I] = I * I * I * I;
	end
end


always @(posedge CLK or negedge RESET)
begin
	if(RESET == 0) CURRENT <= IDLE;
	else CURRENT <= NEXT;
end

always @(*)
begin
	case(CURRENT)
	//IDLE,WITHDRAW,BALANCE: 			SUCCESS = 1'bz;
	FAILURE,PINTRIAL1,PINTRIAL2,INSUFFICIENT: SUCCESS = 1'b0;
	IDLEPIN,IDLEMENU,IDLEMENU,ANOTHER: SUCCESS = 1'b1;
    BALANCE:
    begin
        if(BALANCES[CARD_ID] > 0) SUCCESS = 1'b1;
        else if(BALANCES[CARD_ID] == 0) SUCCESS = 1'b0;
        else SUCCESS = 1'bz;
    end
	default: SUCCESS = 1'bz;
	endcase
end

always @(*)
begin
	case(CURRENT)
	IDLE:
	begin
		if(CARD_ID >= DBSIZE || CARD_ID < 0) NEXT = FAILURE;
		else if(CARD_ID < DBSIZE && CARD_ID >= 0) NEXT = IDLEPIN;
		else NEXT = CURRENT;
	end
	FAILURE:
	begin
		if(CANCEL || OKAY)
			NEXT = IDLE;
		else
			NEXT = CURRENT;
	end
	IDLEPIN:
	begin
		if(CANCEL)
			NEXT = IDLE;
		else if(OKAY && (PIN0 != PINS[CARD_ID][0] || PIN1 != PINS[CARD_ID][1] || PIN2 != PINS[CARD_ID][2] || PIN3 != PINS[CARD_ID][3]))
			NEXT = PINTRIAL1;
		else if(OKAY && PIN0 == PINS[CARD_ID][0] && PIN1 == PINS[CARD_ID][1] && PIN2 == PINS[CARD_ID][2] && PIN3 == PINS[CARD_ID][3])
			NEXT = IDLEMENU;
		else NEXT = CURRENT;
	end
	PINTRIAL1:
	begin
		if(CANCEL)
			NEXT = IDLE;
		else if(OKAY && (PIN0 != PINS[CARD_ID][0] || PIN1 != PINS[CARD_ID][1] || PIN2 != PINS[CARD_ID][2] || PIN3 != PINS[CARD_ID][3]))
			NEXT = PINTRIAL2;
		else if(OKAY && PIN0 == PINS[CARD_ID][0] && PIN1 == PINS[CARD_ID][1] && PIN2 == PINS[CARD_ID][2] && PIN3 == PINS[CARD_ID][3])
			NEXT = IDLEMENU;
		else NEXT = CURRENT;
	end
	PINTRIAL2:
	begin
		if(CANCEL)
			NEXT = IDLE;
		if(OKAY && (PIN0 != PINS[CARD_ID][0] || PIN1 != PINS[CARD_ID][1] || PIN2 != PINS[CARD_ID][2] || PIN3 != PINS[CARD_ID][3]))
			NEXT = FAILURE;
		else if(OKAY && PIN0 == PINS[CARD_ID][0] && PIN1 == PINS[CARD_ID][1] && PIN2 == PINS[CARD_ID][2] && PIN3 == PINS[CARD_ID][3])
			NEXT = IDLEMENU;
		else NEXT = CURRENT;
	end
	IDLEMENU:
	begin
		if(CANCEL)
			NEXT = IDLE;
		else if(TRANSACTION == WITHDRAWOP)
			NEXT = WITHDRAW;
		else if(TRANSACTION == INQUIREOP)
			NEXT = BALANCE;
		else if(TRANSACTION == DEPOSITOP)
		begin
			BALANCES[CARD_ID] = BALANCES[CARD_ID] + AMOUNT;
			NEXT = ANOTHER;
		end
		else NEXT = CURRENT;
	end
	WITHDRAW:
	begin
		if(CANCEL)
			NEXT = IDLEMENU;
		else if(OKAY && (AMOUNT > BALANCES[CARD_ID]))
			NEXT = INSUFFICIENT;
		else if(OKAY && AMOUNT <= BALANCES[CARD_ID])
		begin
			BALANCES[CARD_ID] = BALANCES[CARD_ID] - AMOUNT;
			NEXT = ANOTHER;
		end
		else NEXT = CURRENT;
	end
	INSUFFICIENT:
	begin
		if(CANCEL)
			NEXT = IDLEMENU;
		else if(OKAY)
			NEXT = WITHDRAW;
		else NEXT = CURRENT;
	end
	BALANCE:
	begin
		if(CANCEL)
			NEXT = IDLEMENU;
		else if(OKAY)
			NEXT = ANOTHER;
		else NEXT = CURRENT;	
	end
	ANOTHER:
	begin
		if(CANCEL)
			NEXT = IDLE;
		else if(OKAY)
			NEXT = IDLEMENU;
		else NEXT = CURRENT;
	end
	default: NEXT = IDLE;
	endcase
end

endmodule 
