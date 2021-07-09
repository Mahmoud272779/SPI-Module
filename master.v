module SPI_Master
#(
	parameter reg_wid = 8,
parameter num = $clog2(reg_wid)
)
(
	//////////////////////// controller ///////////////////////////

	input rst,					//reset
        input [1:0]slave,					//slaveaddress
	input clk,					//clock
	input start,					//enable
	input [reg_wid-1:0] data_in,			//input data
	input [num:0] size,				//counter after 8 clock cicles
	input cphase,					
	output reg [reg_wid-1:0] data_out,		//the output data
	
	//////////////////////// SPI side ///////////////////////////////////

	input wire miso,					//master in slave out
	output reg mosi,				//maser out slave in
	output spi_clk,					//output clock to slave
	output reg[2:0]cs,					//slave selector
        output reg[7:0]mos
);
	parameter reset = 0, idle = 1, load = 2, transact = 3, unload = 4,stslave=5;

	reg [reg_wid-1:0] mosi_d;
	reg [reg_wid-1:0] miso_d;
	reg [num:0] count;
	reg [2:0] state;
        wire [2:0]temb;


assign temb=(slave==0)?110:
           (slave==1)?101:
           (slave==2)?011:
            111;
assign spi_clk = clk ;
	// begin state machine
	always @(state)
	begin
		case (state)
			reset:
			begin
				data_out <= 0;
				miso_d <= 0;
				mosi_d <= 0;
				count <= 0;
                                
			end
			idle:
			begin
				data_out <= data_out;
				miso_d <= 0;
				mosi_d <= 0;
				count <= 0;
                           
                                
			end
                        stslave:
                           cs=temb;
			load:
			begin
				data_out <= data_out;
				miso_d <= 0;
				mosi_d <= data_in;
				count <= size;
                                 
		 	end
			transact:
			begin
				
			end
			unload:
			begin
				data_out <= miso_d;
                                cs=3'b111;
				miso_d <= 0;
				mosi_d <= 0;
				count <= count;
                                mosi=1'b x;
                                mos=8'b0000000;
			end

			default:
				state = reset;
		endcase
	end
	
	always @(posedge spi_clk)
	begin
		if (rst)
			state = reset;
		else
			case (state)
				reset:
					if (start)
						state = stslave;
					else
						state = idle;
				idle:
					if (start)
                                            begin
						state = stslave;
                                                 
                                            end
				stslave:
                                        state=load;
                                load:
					if (count != 0)
						state = transact;
					else
						state = reset;
				transact:
					if (count != 0)
						state = transact;
					else
						state = unload;
				unload:
					if (start)
						state = load;
					else
						state = idle;
			endcase
	end
	// end state machine

	// begin SPI logic

	//assign mosi = ( ~cs ) ? mosi_d[0] : 1'bz;
	
	
	// Shift Data
	always @(posedge spi_clk)
	begin
		if ( state == transact )
		begin
			if(~cphase)
                            mosi=mosi_d[0];
			
			if((cphase) &(miso==1'b0|miso==1'b1))
			begin
			mosi_d <= { 1'b0,mosi_d[reg_wid-1:1]};
                        miso_d <= {miso,miso_d[reg_wid-1:1]};
                        data_out <= miso_d;
			mos<=mosi_d;
			count <= count-1;
			end

		end
	end


	always @(negedge spi_clk)
	begin
		if ( state == transact )
		begin
			if((~cphase)&(miso==1'b0|miso==1'b1))
			begin
			mosi_d <= { 1'b0,mosi_d[reg_wid-1:1]};
                        miso_d <= {miso,miso_d[reg_wid-1:1]};
                        data_out <= miso_d;
			mos<=mosi_d;
			count <= count-1;
			end
			
			if(cphase)
                        mosi=mosi_d[0];

		end
	end
	// end SPI logic



endmodule

module spi_test();

	parameter bits = 8;

	reg clk;
	reg start;
	reg [bits-1:0] data_in;
	wire [bits-1:0] data_out;
	reg [$clog2(bits):0] size;
	wire [2:0]cs;
	reg rst;
	wire spi_clk;
	wire miso;
	wire mosi;
	reg cphase;
reg cpol;
        reg [1:0]slave;
wire [7:0]mos;
integer i;
	SPI_Master
	#(
		.reg_wid(bits)
	) spi
	(
		.clk(clk),
                .slave(slave),
		.start(start),
		.data_in(data_in),
		.data_out(data_out),
		.size(size),
                .cs(cs),
		.rst(rst),
		.spi_clk(spi_clk),
		.miso(miso),
		.mosi(mosi),
                .mos(mos),
		.cphase(cphase)
);
assign miso = mosi;
always
		#2 clk = !clk;

	initial
	begin
                data_in=8'b10101010;
///////////////////////////////////////////////////////////////

		cphase=0;
		cpol=0;
		clk = cpol;
                slave=0;

		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MOSI");
                $monitor("%b  %b    %b",mos,data_out,mosi);
		start = 0;
		rst = 1;
		size = bits;
		#4;
		rst = 0;
        #3 start = 1;
	#4 start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;
////////////////////////////////////////////////////////////////

		cphase=1;
		cpol=0;
		clk = cpol;
                slave=1;

		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MOSI");
                $monitor("%b  %b    %b",mos,data_out,mosi);
		start = 0;
		rst = 1;
		size = bits;
		#4;
		rst = 0;
        #3 start = 1;
	#4 start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;
/////////////////////////////////////////////////////////////

		cphase=0;
		cpol=1;
		clk = cpol;
                slave=2;

		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MOSI");
                $monitor("%b  %b    %b",mos,data_out,mosi);
		start = 0;
		rst = 1;
		size = bits;
		#4;
		rst = 0;
        #3 start = 1;
	#4 start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;
//////////////////////////////////////////////////////////////

		cphase=1;
		cpol=1;
		clk = cpol;
                slave=0;

		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MOSI");
                $monitor("%b  %b    %b",mos,data_out,mosi);
		start = 0;
		rst = 1;
		size = bits;
		#4;
		rst = 0;
        #3 start = 1;
	#4 start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;


		end
	

endmodule
