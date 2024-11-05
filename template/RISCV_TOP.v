module RISCV_TOP (
	//General Signals
	input wire CLK,
	input wire RSTn,

	//I-Memory Signals
	output wire I_MEM_CSN,
	input wire [31:0] I_MEM_DI,//input from IM
	output reg [11:0] I_MEM_ADDR,//in byte address

	//D-Memory Signals
	output wire D_MEM_CSN,
	input wire [31:0] D_MEM_DI,
	output wire [31:0] D_MEM_DOUT,
	output wire [11:0] D_MEM_ADDR,//in word address
	output wire D_MEM_WEN,
	output wire [3:0] D_MEM_BE,

	//RegFile Signals
	output wire RF_WE,
	output wire [4:0] RF_RA1,
	output wire [4:0] RF_RA2,
	output wire [4:0] RF_WA1,
	input wire [31:0] RF_RD1,
	input wire [31:0] RF_RD2,
	output wire [31:0] RF_WD,
	output wire HALT,                   // if set, terminate program
	output reg [31:0] NUM_INST,         // number of instruction completed
	output wire [31:0] OUTPUT_PORT      // equal RF_WD this port is used for test
	);

	
	reg [4:0] state; 
	parameter STATE_0=0;
	parameter STATE_1=1;
	parameter STATE_2=2; 
	parameter STATE_3=3;
	parameter STATE_4=4;

	//new variables for LEVEL_1_CACHE
	
	reg[2:0] index_LEVEL_1_CACHE; 
	reg[135:0] current_line; 
	reg [31:0] OUTPUT1; 
	reg [3:0] ENABLE;
	integer j; 
	reg[1:0] offset; 
	reg[135:0] LEVEL_1_CACHE [7:0]; 

	initial begin 
	NUM_INST = 0;
	state= STATE_0;
	LEVEL_1_CACHE[0][135]=1'b0; 
	LEVEL_1_CACHE[1][135]=1'b0; 
	LEVEL_1_CACHE[2][135]=1'b0; 
	LEVEL_1_CACHE[3][135]=1'b0; 
	LEVEL_1_CACHE[4][135]=1'b0; 
	LEVEL_1_CACHE[5][135]=1'b0; 
	LEVEL_1_CACHE[6][135]=1'b0; 
	LEVEL_1_CACHE[7][135]=1'b0; 
	end

	reg[6:0] OPCODE; 
	reg[31:0] MEM1;
	reg[31:0] MEM2; 
	reg[5:0] index1; 
	reg[5:0] index2;
	reg[3:0] index3; 
	reg[31:0] MEM3; 
	reg[6:0] tag;
	 
	reg hit;  
	reg [31:0] IMMIDIATE7;
	reg [31:0] IMMIDIATE8; 
	wire [4:0] SHIFT;
	
	reg [11:0] TEMP_ADDR; 
	
	reg [31:0] IMMIDIATE_;
	reg [4:0] SHIFT_;
	reg [1:0] LOCAL_HISTORY;
	wire [3:0] ALUop;
	reg [4:0] READ_ADDRESS_2;
	wire [31:0] IMMIDIATE;
	reg WRITE_ENABLE_N; 
	reg [2:0] funct3_0; 

	reg BRANCH_RESULT;
	reg [11:0] I_MEM_ADD_0;
	reg [31:0] RESULT;
	
	reg [31:0] OPERAND_1, OPERAND_2;
	
	
	reg [11:0] I_MEM_ADD_1;
	wire LOAD_STALLING;
	reg HALT_0;
	reg HALT_1;
	reg [31:0] WRITE_DATA;
	
	wire [4:0]WRITE_ADDRESS_TEMP;
	reg [4:0] WRITE_ADDRESS; 
	reg [4:0] READ_ADDRESS_1_1;
	reg [31:0] I_MEM_DI_1;
	reg [6:0] funct7_0; 
	reg [4:0] READ_ADDRESS_2_1;
	reg [4:0] WRITE_ADDRESS_1;
	reg [31:0] RD1_1;
	reg [31:0] RD2_1;
	reg [31:0] IMMIDIATE_1;
	reg [4:0] SHIFT_1;
	reg [6:0] OPCODE_1;
	reg [6:0] funct7_1; 
	reg [2:0] funct3_1;
	reg WRITE_ENABLE;
	reg [31:0] I_MEM_DI_0;

	reg [6:0] OPCODE_0;
	
	reg [4:0] READ_ADDRESS_2_2;
	
	reg [31:0] IMMIDIATE6;
	reg [6:0] OPCODE_3;
	reg [11:0] I_MEM_ADD_2;
	reg [31:0] ALU_3;
	
	reg [6:0] funct7_3;
	reg BRANCH_RESULT_2;
	reg [4:0] READ_ADDRESS_1_2; 
	reg MEM_Write_2; 
	reg [6:0] OPCODE_2;
	reg [31:0] IMMIDIATE1;
	reg [6:0] funct7_2; 
	reg [31:0] I_MEM_DI_3;
	reg [31:0] I_MEM_DI_2;
	reg [31:0] IMMIDIATE3;
	reg [31:0] IMMIDIATE4;	
	reg [31:0] IMMIDIATE5;
	reg [31:0] RD2_2;
	reg [31:0] I_MEM_DI_4;
	reg [4:0] READ_ADDRESS_1;
	
	reg [31:0] IMMIDIATE2;
	reg [4:0] WRITE_ADDRESS_4;
	reg [31:0] ALU_4;
	reg [31:0] D_MEM_DI_4;
	reg [4:0] READ_ADDRESS_1_3;
	reg [31:0] RD1_3;
	reg [4:0] WRITE_ADDRESS_3;
	reg [31:0] RD1_2;
	reg [6:0] OPCODE_4;
	reg [6:0] funct7_4; 
	reg [2:0] funct3_4; 
	reg [31:0] RD2_3;
	reg [31:0] D_MEM_DI_3;
	reg [2:0] funct3_2;
	reg [4:0] READ_ADDRESS_2_3;
	reg BRANCH_RESULT_3;
	reg [2:0] funct3_3;
	reg [4:0] WRITE_ADDRESS_2;
	reg [31:0] ALU_2;
	reg [17:0] BRANCH_PREDICTOR [0:63];

	integer index;
	always @ (negedge CLK) begin
		if (I_MEM_DI_3) begin
			NUM_INST <= NUM_INST + 1;
		end
	end
 
	integer i; 
	initial begin 
		I_MEM_ADDR = 'h0x000;
		BRANCH_PREDICTOR[0][17:0]=  18'b0; 
		BRANCH_PREDICTOR[1][17:0]=  18'b0;
		BRANCH_PREDICTOR[2][17:0]=  18'b0;
		BRANCH_PREDICTOR[3][17:0]=  18'b0;
		BRANCH_PREDICTOR[4][17:0]=  18'b0;
		BRANCH_PREDICTOR[5][17:0]=  18'b0;
		BRANCH_PREDICTOR[6][17:0]=  18'b0;
		BRANCH_PREDICTOR[7][17:0]=  18'b0;
		LOCAL_HISTORY[1:0] = 2'b10;
	end

	assign D_MEM_WEN = WRITE_ENABLE_N;
	assign I_MEM_CSN = ~RSTn;
	assign D_MEM_BE[3:0]= ENABLE; 
	assign D_MEM_CSN = ~RSTn;
	assign D_MEM_DOUT= OUTPUT1; 
	
	assign HALT = HALT_1;
	
	assign D_MEM_ADDR = TEMP_ADDR ; 
	
	reg MemtoReg_; 
	assign MemtoReg= MemtoReg_; 
	
	always @(*) begin
		if(OPCODE==7'b0100011)
			MemtoReg_= 1'b1; 
		else
			MemtoReg_= 1'b0; 
	end

	
	assign RF_WD = WRITE_DATA;
	assign OUTPUT_PORT = WRITE_DATA;
	assign RF_WE = WRITE_ENABLE;
	assign RF_WA1 = WRITE_ADDRESS_3;
	
		
	reg LOAD_STALLING_; 
	assign SHIFT= SHIFT_; 
	assign LOAD_STALLING= LOAD_STALLING_; 

	assign IMMIDIATE= IMMIDIATE_;
	assign RF_RA1= READ_ADDRESS_1; 
	
	always@ (*) begin 
	if (OPCODE_1== 7'b0000011) begin 
		if(WRITE_ADDRESS_1 == RF_RA1)
			LOAD_STALLING_= 1'b1; 
		else if (WRITE_ADDRESS_1 == RF_RA2)
			LOAD_STALLING_= 1'b1; 
		else 
			LOAD_STALLING_= 1'b0;
	end
	else
		LOAD_STALLING_= 1'b0;
	end 

	
	assign RF_RA2= READ_ADDRESS_2; 
	assign WRITE_ADDRESS_TEMP= WRITE_ADDRESS; 
	
////////////////////////////////////////////////////////////////
	
	always @(I_MEM_DI_0) begin
		
		
		SHIFT_[4:0] = 5'b0;
		IMMIDIATE1= {19'b1, I_MEM_DI_0[31], I_MEM_DI_0[7], I_MEM_DI_0[30:25], I_MEM_DI_0[11:8], 1'b0};
		READ_ADDRESS_1[4:0] = 5'b0;
		READ_ADDRESS_2[4:0] = 5'b0;
		IMMIDIATE2={19'b0, I_MEM_DI_0[31], I_MEM_DI_0[7], I_MEM_DI_0[30:25], I_MEM_DI_0[11:8], 1'b0}; 
		IMMIDIATE3= {20'b11111111111111111111, I_MEM_DI_0[31:20]};
		IMMIDIATE4= {20'b0, I_MEM_DI_0[31:20]};
		IMMIDIATE5= {20'b11111111111111111111, I_MEM_DI_0[31:25],I_MEM_DI_0[11:7]};
		IMMIDIATE6= {20'b0, I_MEM_DI_0[31:25],I_MEM_DI_0[11:7]};
		IMMIDIATE7= {11'b11111111111, I_MEM_DI_0[31], I_MEM_DI_0[19:12], I_MEM_DI_0[20], I_MEM_DI_0[30:21], 1'b0};
		IMMIDIATE8= {11'b0, I_MEM_DI_0[31], I_MEM_DI_0[19:12], I_MEM_DI_0[20], I_MEM_DI_0[30:21], 1'b0};
		
				

		if (I_MEM_DI_0[6:0]==7'b1100011) begin 
			
			READ_ADDRESS_2[4:0] = I_MEM_DI_0[24:20];
			if(I_MEM_DI_0[31] == 1'b1) begin
				IMMIDIATE_ = IMMIDIATE1; 
			end
			else begin
				IMMIDIATE_ = IMMIDIATE2; 
			end
			READ_ADDRESS_1[4:0] = I_MEM_DI_0[19:15];
			WRITE_ADDRESS[4:0]=I_MEM_DI_0[11:7];
			
		end

		else if (I_MEM_DI_0[6:0]==7'b1100111) begin 
			READ_ADDRESS_1[4:0]=I_MEM_DI_0[19:15];
			WRITE_ADDRESS[4:0]=I_MEM_DI_0[11:7];
			if(I_MEM_DI_0[31] == 1'b1) begin
				IMMIDIATE_ = IMMIDIATE3; 
			end
			else begin
				IMMIDIATE_ = IMMIDIATE4;  
			end
			
		end


		else if (I_MEM_DI_0[6:0]==7'b0100011) begin 
			READ_ADDRESS_2[4:0]=I_MEM_DI_0[24:20];
			WRITE_ADDRESS[4:0]=5'b0;
			if(I_MEM_DI_0[31] == 1'b1) begin
				IMMIDIATE_[31:0] = IMMIDIATE5;
			end
			else begin
				IMMIDIATE_[31:0] = IMMIDIATE6; 
			end
			READ_ADDRESS_1[4:0]=I_MEM_DI_0[19:15];
			
		end

		else if (I_MEM_DI_0[6:0]==7'b0000011) begin 

			READ_ADDRESS_1[4:0]=I_MEM_DI_0[19:15];
			if(I_MEM_DI_0[31] == 1'b1) begin
				IMMIDIATE_ = IMMIDIATE3;
			end
			else begin
				IMMIDIATE_ = IMMIDIATE4;
			end
			WRITE_ADDRESS[4:0]=I_MEM_DI_0[11:7];
		end
	

		else if (I_MEM_DI_0[6:0]==7'b0110011) begin 
			IMMIDIATE_=32'b0;
			WRITE_ADDRESS=I_MEM_DI_0[11:7];
			READ_ADDRESS_2=I_MEM_DI_0[24:20];
			READ_ADDRESS_1=I_MEM_DI_0[19:15];
			
		end

		else if (I_MEM_DI_0[6:0]==7'b0010011) begin
			 
			if(I_MEM_DI_0[14:12]==3'b001)begin
				
				IMMIDIATE_=32'b0;
				SHIFT_= I_MEM_DI_0[24:20];
			end
			else if(I_MEM_DI_0[14:12]==3'b101)begin
				
				IMMIDIATE_=32'b0;
				SHIFT_= I_MEM_DI_0[24:20];
				
			end
			else begin
				if(I_MEM_DI_0[31] == 1'b1) begin
					IMMIDIATE_= IMMIDIATE3;
				end
				else begin
					IMMIDIATE_= IMMIDIATE4; 
				end
			end
			READ_ADDRESS_1=I_MEM_DI_0[19:15];
			WRITE_ADDRESS=I_MEM_DI_0[11:7];
			
		end

		else if (I_MEM_DI_0[6:0]==7'b1101111) begin 
			if(I_MEM_DI_0[20] == 1'b1) begin
				IMMIDIATE_ = IMMIDIATE7; 
			end
			else begin
				IMMIDIATE_ = IMMIDIATE8;
			end	
							
			WRITE_ADDRESS[4:0] = I_MEM_DI_0[11:7];	
		end
		
	end


/////////////
	

	
		always @(*) begin
		case (OPCODE_1)
		7'b0010011: begin
			if (funct3_1==3'b000)
				RESULT = OPERAND_1 + OPERAND_2;
			else if (funct3_1==3'b010)
				RESULT = $signed(OPERAND_1)<$signed(OPERAND_2);
			else if (funct3_1[2:0]==3'b011)
				RESULT = OPERAND_1<OPERAND_2; 
			else if (funct3_1==3'b100)
				RESULT = OPERAND_1^OPERAND_2;
			else if (funct3_1==3'b101 && funct7_1==7'b0000000)
				RESULT = OPERAND_1>>OPERAND_2; 
			else if (funct3_1==3'b101 && funct7_1==7'b0100000)
				RESULT = $signed(OPERAND_1)>>>$signed(OPERAND_2);
			else if (funct3_1==3'b110)
				RESULT = OPERAND_1|OPERAND_2;  
			else if (funct3_1==3'b111)
				RESULT = OPERAND_1&OPERAND_2; 
			else if (funct3_1==3'b001)
				RESULT = OPERAND_1<<OPERAND_2;
		end
		7'b0110011: begin
			if (funct3_1==3'b000 && funct7_1==7'b0000000)
				RESULT = OPERAND_1 + OPERAND_2;
			else if (funct3_1==3'b000 && funct7_1==7'b0100000)
				RESULT = OPERAND_1-OPERAND_2;
			else if (funct3_1==3'b010)
				RESULT = $signed(OPERAND_1)<$signed(OPERAND_2);
			else if (funct3_1==3'b011)
				RESULT = OPERAND_1<OPERAND_2;
			else if (funct3_1==3'b100)
				RESULT = OPERAND_1^OPERAND_2;        
			else if (funct3_1==3'b101 && funct7_1==7'b0000000)
				RESULT = OPERAND_1>>OPERAND_2;
			else if (funct3_1==3'b101 && funct7_1==7'b0100000)
				RESULT = $signed(OPERAND_1)>>>$signed(OPERAND_2);
			else if (funct3_1==3'b110)
				RESULT = OPERAND_1|OPERAND_2;
			else if (funct3_1==3'b111)
				RESULT = OPERAND_1&OPERAND_2;
			else if (funct3_1==3'b001)
				RESULT = OPERAND_1<<OPERAND_2;
		end
		7'b1100011: begin
			case (I_MEM_DI_1[14:12])
				3'b000: begin
					if (OPERAND_1 == OPERAND_2) BRANCH_RESULT = 1;
					else BRANCH_RESULT = 0; end
				3'b001: begin
					if(OPERAND_1!=OPERAND_2) BRANCH_RESULT =1;
					else BRANCH_RESULT =0; end
				3'b100: begin
					if ($signed(OPERAND_1)<$signed(OPERAND_2)) BRANCH_RESULT = 1;
					else BRANCH_RESULT = 0; end
				3'b101: begin
					if ($signed(OPERAND_1)>=$signed(OPERAND_2)) BRANCH_RESULT =1;
					else BRANCH_RESULT =0; end
				3'b110: begin
					if (OPERAND_1<OPERAND_2) BRANCH_RESULT = 1;
					else BRANCH_RESULT = 0; end
				3'b111: begin
					if(OPERAND_1>=OPERAND_2)	BRANCH_RESULT =1;
					else BRANCH_RESULT =0; end
			endcase
		end
		default: RESULT = OPERAND_1 + OPERAND_2;
		endcase
	end

	always @(I_MEM_DI_1) begin	
		if (OPCODE_1 == 7'b1101111 || OPCODE_1 == 7'b1100111) begin 
			if(I_MEM_ADD_1[11]) begin
				OPERAND_1[31:0]={20'b11111111111111111111, I_MEM_ADD_1};
			end
			else OPERAND_1[31:0]={20'b0, I_MEM_ADD_1};
			OPERAND_2 = 1<<2;			
		end

		else begin
		
			if (READ_ADDRESS_1_1 ==0)
				OPERAND_1 = RD1_1;

			else if (WRITE_ADDRESS_2 == READ_ADDRESS_1_1) begin
				
				if (OPCODE_2 == 7'b0000011) ;
				else if (OPCODE_2 == 7'b0100011)
					OPERAND_1 = RD1_1;
				else if (OPCODE_2 == 7'b1100011)
					OPERAND_1 = RD1_1;
				else OPERAND_1 = ALU_2;
			end 

			else if (WRITE_ADDRESS_3 == READ_ADDRESS_1_1) begin		
				if (OPCODE_3 == 7'b0000011) OPERAND_1 = D_MEM_DI_3;
				else if (OPCODE_3 == 7'b0100011 )
					OPERAND_1 = RD1_1;
				else if (OPCODE_3 == 7'b1100011) 
					OPERAND_1 = RD1_1;
				else OPERAND_1[31:0] = ALU_3[31:0];

			end

			else if (WRITE_ADDRESS_4 == READ_ADDRESS_1_1) begin
				 
				if (OPCODE_4 == 7'b0000011) OPERAND_1 = D_MEM_DI_4;
				else if (OPCODE_4 == 7'b0100011)
					OPERAND_1 = RD1_1;
				else if (OPCODE_4 == 7'b1100011)
					OPERAND_1 = RD1_1;
				else OPERAND_1 = ALU_4;
			end

			else OPERAND_1 = RD1_1;

		
			if (OPCODE_1 == 7'b0010011) begin
				if (funct3_1==3'b001)
					OPERAND_2 = SHIFT;
				else if( funct3_1==3'b101)
					OPERAND_2 = SHIFT;
				else OPERAND_2 = IMMIDIATE;
			end
			else if (OPCODE_1 == 7'b0100011)
				OPERAND_2 = IMMIDIATE;
			else if (OPCODE_1 ==7'b0000011)
				OPERAND_2 = IMMIDIATE;
			else if (OPCODE_1 ==7'b0010011)
				OPERAND_2 = IMMIDIATE;
			else begin
				if (WRITE_ADDRESS_2 == READ_ADDRESS_2_1) begin
				
					if (OPCODE_2 == 7'b0000011) ;
					else if (OPCODE_2 == 7'b0100011)
						OPERAND_2 = RD2_1;
					else if (OPCODE_2 == 7'b1100011) 
						OPERAND_2 = RD2_1;
					else OPERAND_2 = ALU_2;
				end 

				else if (WRITE_ADDRESS_3 == READ_ADDRESS_2_1) begin
					
					if (OPCODE_3 == 7'b0000011) OPERAND_2 = D_MEM_DI_3;
					else if (OPCODE_3 == 7'b0100011)
						OPERAND_2 = RD2_1;
					else if (OPCODE_3 == 7'b1100011)
						OPERAND_2 = RD2_1;
					else OPERAND_2 = ALU_3;
				end
				else if (WRITE_ADDRESS_4 == READ_ADDRESS_2_1) begin
					
					if (OPCODE_4 == 7'b0000011) OPERAND_2 = D_MEM_DI_4;
					else if (OPCODE_4 == 7'b0100011)
						OPERAND_2 = RD2_1;
					else if (OPCODE_4 == 7'b1100011)
						OPERAND_2 = RD2_1;
					else OPERAND_2= ALU_4;
				end
				else OPERAND_2 = RD2_1;
			end
		end	
		
	end
	
	


//////////////////////////////

	always @(posedge CLK) begin
	if (RSTn) begin
		
		case (state)
		STATE_0: begin
		
		if (HALT_0 && I_MEM_DI==32'h0x00008067)
			HALT_1 <= 1;
		else HALT_1 <= 0;

		if (I_MEM_DI == 32'h0x00c00093)
  			HALT_0 <= 1;
		else HALT_0 <= 0;

	OPCODE= I_MEM_DI[6:0]; 
//fnally 
	I_MEM_DI_4 = I_MEM_DI_3;
	OPCODE_4= OPCODE_3; 
	funct7_4= funct7_3; 
	funct3_4= funct3_3;
	
	ALU_4 = ALU_3;
	WRITE_ADDRESS_4 = WRITE_ADDRESS_3;
	D_MEM_DI_4 = D_MEM_DI_3;

//MEM_WB
	I_MEM_DI_3 = I_MEM_DI_2;
	WRITE_ADDRESS_3 = WRITE_ADDRESS_2;
	funct7_3= funct7_2; 
	funct3_3= funct3_2;
	BRANCH_RESULT_3 = BRANCH_RESULT_2;
	OPCODE_3= OPCODE_2;
	
	ALU_3 = ALU_2;

	if (offset==2'b00)
		D_MEM_DI_3= current_line[31:0];
	else if (offset==2'b01)
		D_MEM_DI_3= current_line[63:32]; 
	else if (offset==2'b10) 
		D_MEM_DI_3= current_line[95:64]; 
	else
		D_MEM_DI_3= current_line[127:96]; 
		

//EX_MEM= 2
	I_MEM_ADD_2 = I_MEM_ADD_1;
	BRANCH_RESULT_2 = BRANCH_RESULT;
	I_MEM_DI_2 = I_MEM_DI_1;
	OPCODE_2= OPCODE_1;
	ALU_2 = RESULT;
	WRITE_ADDRESS_2 = WRITE_ADDRESS_1;
	funct7_2= funct7_1; 
	
	READ_ADDRESS_2_2 = READ_ADDRESS_2_1;
	
	RD1_2 = RD1_1;
	funct3_2= funct3_1;
	RD2_2 = RD2_1;
	
	MEM_Write_2 = D_MEM_WEN;
	
//ID/EX
	I_MEM_ADD_1=I_MEM_ADD_0;
	READ_ADDRESS_2_1 = RF_RA2;
	I_MEM_DI_1 = I_MEM_DI_0;
	IMMIDIATE_1 = IMMIDIATE; 
	OPCODE_1 = OPCODE_0;
	funct7_1= funct7_0;
	RD2_1 = RF_RD2;
	funct3_1= funct3_0; 
	READ_ADDRESS_1_1 = RF_RA1;
	WRITE_ADDRESS_1 = WRITE_ADDRESS_TEMP;
	RD1_1 = RF_RD1;
	SHIFT_1 = SHIFT;
	

	I_MEM_DI_0  = I_MEM_DI;
	I_MEM_ADD_0 = I_MEM_ADDR;
	OPCODE_0 = OPCODE; 
	funct7_0 = I_MEM_DI[31:25]; 
	funct3_0 = I_MEM_DI[14:12]; 

	if (LOAD_STALLING == 1'b1) begin
		
		IMMIDIATE_1		<=	0;
		funct7_0 		<= 	funct7_1;  
		funct3_0 		<= 	funct3_1; 
		I_MEM_ADD_0 	<= 	I_MEM_ADD_1;
		I_MEM_DI_1		<= 	0;
		READ_ADDRESS_2_1<=	0;
		I_MEM_DI_0  	<= 	I_MEM_DI_1;
		OPCODE_1		<= 	0;
		funct7_1 		<= 	0;  
		RD1_1			<=	0; 
		funct3_1 		<= 	0; 
		I_MEM_ADD_1 	<= 	0;
		READ_ADDRESS_1_1<= 	0;
		RD2_1			<= 	0;
		WRITE_ADDRESS_1	<= 	0;
		SHIFT_1			<=	0;
		OPCODE_0 		<= 	OPCODE_1;
		end

	 if (OPCODE_2[6:0] == 7'b1100011 && 
		(BRANCH_RESULT_2==1'b0 && (LOCAL_HISTORY == 2'b11 || LOCAL_HISTORY == 2'b10))) begin
 
		

		OPCODE_0		<= 	0;
		READ_ADDRESS_1_1<= 	0;
		RD1_1			<=	0;
		funct3_0		<=	0; 
		I_MEM_ADD_0 	<= 	0;
		funct7_0		<=	0;
		I_MEM_ADD_1 	<= 	0;
		IMMIDIATE_1		<=	0;
		I_MEM_DI_1 		<= 	0;
		RD2_1			<= 	0;
		WRITE_ADDRESS_1	<= 	0;
		OPCODE_1		<= 	0;
		funct7_1		<= 	0;  
		funct3_1 		<= 	0; 
		READ_ADDRESS_2_1<= 	0;
		SHIFT_1			<=	0;
		I_MEM_DI_0 		<= 	0;
	end
	else if (OPCODE_2[6:0] == 7'b1100011 && (BRANCH_RESULT_2==1'b1 && (LOCAL_HISTORY == 2'b00 || LOCAL_HISTORY == 2'b01))) begin

		BRANCH_PREDICTOR[I_MEM_ADD_2[7:2]][13:2]= ((I_MEM_ADD_2[11:0]+{I_MEM_DI_2[7], I_MEM_DI_2[30:25], I_MEM_DI_2[11:8], 1'b0})) & 'h0xFFC;
 
		

		OPCODE_0		<= 	0;
		READ_ADDRESS_1_1<= 	0;
		RD1_1			<=	0;
		funct3_0		<=	0; 
		I_MEM_ADD_0 	<= 	0;
		funct7_0		<=	0;
		I_MEM_ADD_1 	<= 	0;
		IMMIDIATE_1		<=	0;
		I_MEM_DI_1 		<= 	0;
		RD2_1			<= 	0;
		WRITE_ADDRESS_1	<= 	0;
		OPCODE_1		<= 	0;
		funct7_1		<= 	0;  
		funct3_1 		<= 	0; 
		READ_ADDRESS_2_1<= 	0;
		SHIFT_1			<=	0;
		I_MEM_DI_0 		<= 	0;
	end

	if (OPCODE_2== 7'b1100011) begin
		if (BRANCH_RESULT_2) begin
			if (LOCAL_HISTORY == 2'b11 || LOCAL_HISTORY== 2'b10)
				LOCAL_HISTORY <= 2'b11; 
			else if (LOCAL_HISTORY== 2'b00)
				LOCAL_HISTORY<= 2'b01; 
			else if (LOCAL_HISTORY==2'b01)
				LOCAL_HISTORY<= 2'b10; 
		end
		else begin
			if (LOCAL_HISTORY == 2'b11)
				LOCAL_HISTORY<= 2'b10; 
			else if (LOCAL_HISTORY== 2'b10)
				LOCAL_HISTORY<= 2'b01; 
			else if (LOCAL_HISTORY==2'b01 || LOCAL_HISTORY == 2'b00)
				LOCAL_HISTORY<= 2'b00; 
		end

	end

	if (OPCODE_1==7'b1100111) begin
		I_MEM_DI_0 <= 32'b0;
		OPCODE_0   <= 7'b0;
		I_MEM_ADD_0 <= 12'b0;
		funct3_0 <= 3'b0; 
		funct7_0 <= 7'b0; 
	
	end

	if (OPCODE_2==7'b0000011) begin 
		 
		tag= ALU_2[13:7]; 
		index_LEVEL_1_CACHE= ALU_2[6:4];
		offset= ALU_2[3:2];
		current_line= LEVEL_1_CACHE[index_LEVEL_1_CACHE]; 
		hit= current_line[128]==1'b1 && current_line[135:129]==tag;
		if(hit==1'b0) begin
			state= STATE_1;
			LEVEL_1_CACHE[index_LEVEL_1_CACHE][128]= 1'b0; 
			WRITE_ENABLE_N=1'b1; 
			LEVEL_1_CACHE[index_LEVEL_1_CACHE][135:129]= tag; 
			TEMP_ADDR= {ALU_2[13:4],2'b00}; 
			
			
			
		end
	end
	
	else if (OPCODE_2==7'b0100011) begin
		
		if(I_MEM_DI_2[6:0]!= 7'b0100011) 
			OUTPUT1= 32'b0;
		else if (   (WRITE_ADDRESS_4== READ_ADDRESS_2_2) && (I_MEM_DI_4[6:0]==7'b0000011) )
			OUTPUT1= D_MEM_DI_4;
		else if ((WRITE_ADDRESS_3 != READ_ADDRESS_2_2) || I_MEM_DI_3[6:0]==7'b0100011 || I_MEM_DI_3[6:0]==7'b1100011)
			OUTPUT1= RD2_2; 
		else
			OUTPUT1= ALU_3; 
		offset= ALU_2[3:2];
		index_LEVEL_1_CACHE= ALU_2[6:4];
 		
		current_line= LEVEL_1_CACHE[index_LEVEL_1_CACHE];
		


		tag= ALU_2[13:7]; 
		 
		hit= (current_line[128]==1'b1 && current_line[135:129]==tag);
		if(hit==1'b1) begin
			TEMP_ADDR= ALU_2[13:2];
			WRITE_ENABLE_N= 1'b0; 
			if(offset==2'b00)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][31:0]= OUTPUT1; 
			else if(offset==2'b01)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][63:32]= OUTPUT1;
			else if (offset==2'b10)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][95:64]= OUTPUT1;
			else if (offset==2'b11)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][127:96]= OUTPUT1;
			
			
			ENABLE= 4'b1111;
			
		end
		else begin
			LEVEL_1_CACHE[index_LEVEL_1_CACHE][135:129]= tag; 
			WRITE_ENABLE_N=1'b1;
			state= STATE_1; 
			LEVEL_1_CACHE[index_LEVEL_1_CACHE][128]= 1'b0; 
			TEMP_ADDR= {ALU_2[13:4],2'b00}; 
			
			
			
			
			
			 
		end
	end
	

	if (I_MEM_DI_3) begin
		if (OPCODE_3==7'b0100011)
			WRITE_ENABLE<= 1'b0; 
		else if (OPCODE_3== 7'b1100011) begin
			WRITE_ENABLE<= 1'b0; 
		end 
		else  WRITE_ENABLE<= 1'b1;
	end

	
	 
	if (I_MEM_DI_3) begin
		if (OPCODE_3== 7'b1100011)
			WRITE_DATA<= 1'b1; 
		else if (OPCODE_3==7'b0000011)
			WRITE_DATA<= D_MEM_DI_3; 
		else 
			WRITE_DATA<= ALU_3; 
	end
	
	index2= I_MEM_DI[30:25];
	index3= I_MEM_DI_1[31:20]; 
	MEM1= {I_MEM_DI[20], I_MEM_DI[30:21], 1'b0};
	MEM2= {I_MEM_DI[7], index2, I_MEM_DI[11:8], 1'b0};
	index1= I_MEM_ADDR[7:2]; 
	MEM3= {I_MEM_DI_2[7], I_MEM_DI_2[30:25], I_MEM_DI_2[11:8], 1'b0}; 
	
	if (OPCODE_1 == 7'b1100111) begin // stay
		I_MEM_ADDR<=(RD1_1[11:0] + index3) & 'h0xffe & 'h0xFFC;
		
	end


	else if (OPCODE==7'b1101111) begin
		I_MEM_ADDR<=(I_MEM_ADDR+MEM1) & 'h0xFFC;
		
	end
	
	else if (OPCODE==7'b1100011) begin
		
		if (LOCAL_HISTORY == 2'b10) begin
			
			if (BRANCH_PREDICTOR[index1][17:14] === I_MEM_ADDR[11:8] && BRANCH_PREDICTOR[index1])  begin
				BRANCH_PREDICTOR[index1][1:0] <= 2'b10;
				I_MEM_ADDR <= BRANCH_PREDICTOR[index1][13:2];
				
			end
			else begin
			
				BRANCH_PREDICTOR[index1][13:2] <= ((I_MEM_ADDR+MEM2)) & 'h0xFFC;
				BRANCH_PREDICTOR[index1][1:0] <= 2'b10;
				BRANCH_PREDICTOR[index1][17:14] <= I_MEM_ADDR[11:8];
				I_MEM_ADDR <= ((I_MEM_ADDR+MEM2)) & 'h0xFFC;
				
			end
		end

		else if (LOCAL_HISTORY == 2'b11) begin 
			if (BRANCH_PREDICTOR[index1][17:14] === I_MEM_ADDR[11:8] && BRANCH_PREDICTOR[index1])  begin
				BRANCH_PREDICTOR[index1][1:0] <= 2'b10;
				I_MEM_ADDR <= BRANCH_PREDICTOR[index1][13:2];
				
			end
			else begin
			
				BRANCH_PREDICTOR[index1][13:2] <= ((I_MEM_ADDR+MEM2)) & 'h0xFFC;
				BRANCH_PREDICTOR[index1][1:0] <= 2'b10;
				BRANCH_PREDICTOR[index1][17:14] <= I_MEM_ADDR[11:8];
				I_MEM_ADDR <= ((I_MEM_ADDR+MEM2)) & 'h0xFFC;
				
			end
		end
		else begin
			BRANCH_PREDICTOR[index1][1:0] <= 2'b01;
			I_MEM_ADDR <= (I_MEM_ADDR + 4) & 'h0xFFC;
		end
		
	end
	else begin
		if (LOAD_STALLING)  begin
		end
		else if ((BRANCH_RESULT_2) && (BRANCH_PREDICTOR[I_MEM_ADD_2[7:2]][1:0] == 2'b01) && (OPCODE_2 == 7'b1100011) ) begin
			
			BRANCH_PREDICTOR[I_MEM_ADD_2[7:2]][13:2] <= ((I_MEM_ADD_2+MEM3)) & 'h0xFFC;
			I_MEM_ADDR <= (I_MEM_ADD_2+MEM3) & 'h0xFFC; 
		end
		else if (OPCODE_2 == 7'b1100011) begin
			if (~BRANCH_RESULT_2) begin
				if(BRANCH_PREDICTOR[I_MEM_ADD_2[7:2]][1:0] == 2'b10)
					I_MEM_ADDR <= (I_MEM_ADD_2 + 4) & 'h0xFFC;
				else
					I_MEM_ADDR <= (I_MEM_ADDR + 4) & 'h0xFFC; 
			end
			else
				I_MEM_ADDR <= (I_MEM_ADDR + 4) & 'h0xFFC; 
		end
	
		else begin
			I_MEM_ADDR <= (I_MEM_ADDR + 4) & 'h0xFFC; 
			
		end
		
	end 
	end

	STATE_1: begin
		
		LEVEL_1_CACHE[index_LEVEL_1_CACHE][31:0]= D_MEM_DI; 
		TEMP_ADDR= {ALU_2[13:4], 2'b01};
		WRITE_ENABLE_N= 1'b1; 

		I_MEM_DI_4 = I_MEM_DI_3;
    		WRITE_ADDRESS_4 = WRITE_ADDRESS_3;
   		ALU_4 = ALU_3;
    		D_MEM_DI_4 = D_MEM_DI_3;

		OPCODE_4= OPCODE_3; 
		funct7_4= funct7_3; 
		funct3_4= funct3_3;

    		I_MEM_DI_3 [31:0] = 32'b0;
    		WRITE_ADDRESS_3 = 5'b0;
  		ALU_3 = 32'b0;
    		BRANCH_RESULT_3 = 1'b0;
   		D_MEM_DI_3= 32'b0;
    		WRITE_ENABLE = 1'b0;
		funct7_3= 7'b0; 
		funct3_3= 3'b0;
		OPCODE_3= 7'b0;

		state= STATE_2;
	end

	STATE_2: begin
		
		
		
		
		LEVEL_1_CACHE[index_LEVEL_1_CACHE][63:32]= D_MEM_DI; 
		I_MEM_DI_4 = 32'b0;
		WRITE_ENABLE_N= 1'b1;
		TEMP_ADDR= {ALU_2[13:4], 2'b10};
    		WRITE_ADDRESS_4 = 32'b0;
   		ALU_4 = 32'b0;
    		D_MEM_DI_4 = 32'b0;
		OPCODE_4= 7'b0; 
		funct7_4= 7'b0; 
		funct3_4= 3'b0;

		state= STATE_3;
	end
	
	STATE_3: begin 
		
		TEMP_ADDR= {ALU_2[13:4], 2'b11};
		LEVEL_1_CACHE[index_LEVEL_1_CACHE][95:64]= D_MEM_DI; 
		state= STATE_4; 
		WRITE_ENABLE_N= 1'b1;
	
		
		
	end
	
	STATE_4: begin 
		
		 
		LEVEL_1_CACHE[index_LEVEL_1_CACHE][127:96]= D_MEM_DI; 
		
		LEVEL_1_CACHE[index_LEVEL_1_CACHE][128]= 1'b1;
		if (I_MEM_DI_2[6:0]==7'b0000011) begin
			current_line= LEVEL_1_CACHE[index_LEVEL_1_CACHE]; 
			state= STATE_0; 
		end 
		else begin 
			ENABLE= 4'b1111; 
			state= STATE_0; 
			if(offset==2'b00)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][31:0]= OUTPUT1; 
			else if(offset==2'b01)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][63:32]= OUTPUT1;
			else if (offset==2'b10)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][95:64]= OUTPUT1;
			else if (offset==2'b11)
				LEVEL_1_CACHE[index_LEVEL_1_CACHE][127:96]= OUTPUT1;
			
			TEMP_ADDR= ALU_2[13:2]; 
			
			WRITE_ENABLE_N= 1'b0; 
			
		end 
	end 
	endcase
	

end
end
endmodule //







