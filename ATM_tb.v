// clock cycle is 10

module ATM_MOORE_TB();


	reg  [3:0] CARD_ID;
	reg  [3:0] PIN0;
	reg  [3:0] PIN1;
	reg  [3:0] PIN2;
	reg  [3:0] PIN3;
	reg [1:0] TRANSACTION;
	reg  [31:0] AMOUNT;
	reg OKAY;
	reg CANCEL;
	reg CLK;
	reg RESET;
	wire SUCCESS;
	wire [3:0] STATUS;
        integer i;
	// Instantiate the Unit Under Test (UUT)
	ATM_MOORE uut (
	CARD_ID,  /* 0 to 9*/
	PIN0,	PIN1,PIN2,PIN3, /*0000 to 9999*/
	
	TRANSACTION,
	AMOUNT,
	OKAY,
	CANCEL,
	CLK,
	RESET,
	SUCCESS,
	STATUS
	);
	
	initial CLK=0;
	always #5 CLK= !CLK;
	
	// must wait for 2 clock cycles after each password AND card entry 

	initial begin
		// Initialize Inputs
        
    #14;
		// Senario1: invalid card id
		CARD_ID=4'b1111;
		OKAY=1'b1;
		#10;
   
    #5;
	 OKAY = 0;
	 #5;
    
		// Senario2: valid card id invalid password
	CARD_ID=4'b0111;
    OKAY = 1;
    #10;
   
		PIN0=4'b1111;
		PIN1=4'b0111;
		PIN2=4'b0111;
		PIN3=4'b0111;
    #10;
   
		#10; //Entering trial1
		PIN0=4'b0111;
		PIN1=4'b0111;
		PIN2=4'b0111;
		PIN3=4'b0111;
    #10;
    
		#10; // valid password, entering menu
		CANCEL=1;  //signing out
		#5;
		CANCEL=0;
    OKAY = 0;
      #5;
		
		//-----------------------------------------------------
    //balance on zero

        CANCEL=1;
        #10;
        CANCEL=0;
        CARD_ID=4'b0000;
        OKAY=1;
        #10;
        PIN0=4'b0000;
        PIN1=4'b0000;
        PIN2=4'b0000;
        PIN3=4'b0000;
        #20;
        TRANSACTION=2'b01;
        #10;
        CANCEL=1;  //signing out
        #10;
        CANCEL=0;
		//Senario3 : depositing then withdrawing
		CARD_ID=4'b0000; //signing in as user "0"
    OKAY=1;
		#10;
		PIN0=4'b0000;
		PIN1=4'b0000;
		PIN2=4'b0000;
		PIN3=4'b0000;
		#20;				//deposit 4 for a while
		TRANSACTION=2'b10;
		AMOUNT= 32'b0100;
    #10
  
		#100;
		
		TRANSACTION=2'b00; //withdraw 16 for a while
		AMOUNT= 32'b010000;
		#10

		CANCEL=1;  //signing out
		#5;
		CANCEL=0;  
    OKAY=0;
	 #5;
		//-----------------------------------------------------
		
		//Senario4: withdrawing
		CARD_ID=4'b0001;
    OKAY=1;
		#10;
		PIN0=4'b0001;
		PIN1=4'b0001;
		PIN2=4'b0001;
		PIN3=4'b0001;
		#20;
		TRANSACTION=2'b00;
		AMOUNT= 32'b01000000;
		#10;
   
		CANCEL=1;  //signing out
		#5;
		CANCEL=0;
		#5;
		CANCEL=1;  //signing out
		#5;
		CANCEL=0;
		#5;
		//-----------------------------------------------------
		CARD_ID=4'bz;     // making all imput values = z, to compare between direct and random testing
		PIN0=4'bz;
		PIN1=4'bz;
		PIN2=4'bz;
		PIN3=4'bz;
		TRANSACTION=2'bz;
		AMOUNT= 32'bz;
		OKAY=1;
		#10;
		//-----------------------------------------------------
//Senario5: valid card invalid pass twice then valud
    CANCEL=1;
#10;
CANCEL=0;
    CARD_ID=4'b0011;
    OKAY = 1;
    #10;
    
        PIN0=4'b1111;
        PIN1=4'b0111;
        PIN2=4'b0111;
        PIN3=4'b0111;
    #10;

     //Entering trial1
        PIN0=4'b0111;
        PIN1=4'b0111;
        PIN2=4'b1111;
        PIN3=4'b0111;
    #10;

               CANCEL=1;
     #10; // invalid password, backto idle
    
//cancel on withdraw
    CANCEL=1;
       #10;
    CANCEL=0;
        CARD_ID=4'b0101;
        OKAY=1;
        #10;
        PIN0=4'b0101;
        PIN1=4'b0101;
        PIN2=4'b0101;
        PIN3=4'b0101;
        #20;
        TRANSACTION=2'b00;
        AMOUNT= 32'b0100000;
        OKAY=0;
        #10;
        CANCEL=1;  //signing out
        #10;
        CANCEL=0;

//-----------------------------------
//-----------------------------------
//cancel on idle pin
    CANCEL=1;
       #10;
    CANCEL=0;
    CARD_ID=4'b0101;
    OKAY=1;
    #10;
    PIN0=4'b0101;
    PIN1=4'b0101;
    PIN2=4'b0101;
    PIN3=4'b0101;
    CANCEL=1;
    #10;

//stay on same faiulre state


    CARD_ID=4'b0011;
    OKAY = 1;
    #10;
    PIN0=4'b1111;
    PIN1=4'b0111;
    PIN2=4'b0111;
    PIN3=4'b0111;
    #10;
    PIN0=4'b0111;
    PIN1=4'b0111;
    PIN2=4'b1111;
    PIN3=4'b0111;
    #10;
    PIN0=4'b0111;
    PIN1=4'b0111;
    PIN2=4'b1111;
    PIN3=4'b0111;
    #10;

    CANCEL=0;
    OKAY=0;
       #20;

    CANCEL=1;
    #10
    CANCEL=0;


//--------------------
//-----------------------------------
//cancel on trial 1
    CANCEL=1;
       #10;
    CANCEL=0;
    CARD_ID=4'b0101;
    OKAY=1;
    #10;
    PIN0=4'b0101;
    PIN1=4'b0101;
    PIN2=4'b0111;
    PIN3=4'b1101;
    #10;
    PIN0=4'b0101;
    PIN1=4'b0101;
    PIN2=4'b0101;
    PIN3=4'b0101;
    OKAY=0;
    CANCEL=1;
    #10;
    CANCEL=1;
    #10;
    CANCEL=0;
// BALANCE INQUIRY TESTCASE
    CANCEL=1;
       #10;
    CANCEL=0;

    CARD_ID=4'b0110;
    OKAY = 1;
    #10;
    
        PIN0=4'b0110;
        PIN1=4'b0110;
        PIN2=4'b0110;
        PIN3=4'b0110;
    #10;
    TRANSACTION=2'b01;
    #10;
  


      OKAY = 0;
      #5;

		//senario random
                for(i=1;i<10000;i=i+1)begin
		CARD_ID=$random();
		#10;
		PIN0=$random();   // giving random seeds
		PIN1=$random();
		PIN2=$random();
		PIN3=$random();
              #10;	
       
                PIN0=CARD_ID;  // dassertferent random seeds to generate dassertferent random PIN
		PIN1=CARD_ID;
		PIN2=CARD_ID;
		PIN3=CARD_ID;
      #10;

        
		PIN0=$random();
		PIN1=$random();
		PIN2=$random();
		PIN3=$random();
      #10;	
 
		#1; if(SUCCESS==1)begin
		TRANSACTION=2'b00;
		AMOUNT= 32'b0100;
#9;

	
end
else #9;
		
	
           end
		$finish;
	end
      
endmodule