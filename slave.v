module SPI_Slave
#(
	parameter reg_wid = 8,
parameter num = $clog2(reg_wid)
)
(
	
	input rst,
	input [reg_wid-1:0] data_ins,
	input [num:0] size,  //same master
	input cphase,
	output reg [reg_wid-1:0] data_outs,

	// SPI side
	output reg miso,
	input wire mosi,
	input spi_clk,
	input cs,
	output reg [7:0]moss
);
	parameter reset = 0, load = 1, transact = 2, unload = 3 ,idle=4;

	reg [reg_wid-1:0] mosi_d;
	reg [reg_wid-1:0] miso_d;
	reg [num:0] count;
	reg [2:0] state;

	// begin state machine
	always @(state)
	begin
		case (state)
			reset:
			begin
				data_outs <= 0;
				miso_d <= 0;
				mosi_d <= 0;
				count <= 0;
			end
                        idle:
                        begin
                                data_outs <=  data_outs;
				miso_d <= 0;
				mosi_d <= 0;
				count <= 0;
                        end
			load:
			begin
				data_outs <= 0;
				miso_d <= data_ins;
				mosi_d <= 0;
				count <= size;
			end
			transact:
			begin
				
			end
			unload:
			begin
				data_outs <=mosi_d;
				miso_d <= 0;
				mosi_d <= 0;
				count <= count;
                                miso=1'b x;
                                   moss=0;
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
					if (~cs)
						state = load;
				idle:
					if (~cs)
                                            begin
						state = load;
                                            end
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
					if (~cs)
						state = load;
					else
						state = idle;
			endcase
	end
	// end state machine

	// begin SPI logic

	// Shift Data

always @(posedge spi_clk)
	begin
		if ( state == transact )
		begin
			if(~cphase)
                        miso=miso_d[0];
			
			if((cphase)&(mosi==1'b0|mosi==1'b1))
			begin
			miso_d <= { 1'b0,miso_d[reg_wid-1:1]};
                        mosi_d <= {mosi,mosi_d[reg_wid-1:1]};
data_outs <=mosi_d;
			moss<=miso_d;
			count <= count-1;
			end

		end
	end


	always @(negedge spi_clk)
	begin
		if ( state == transact )
		begin
			if((~cphase)&(mosi==1'b0|mosi==1'b1) )
			begin
			miso_d <= { 1'b0,miso_d[reg_wid-1:1]};
                        mosi_d <= {mosi,mosi_d[reg_wid-1:1]};
data_outs <=mosi_d;
			moss<=miso_d;
			count <= count-1;
			end
			
			if(cphase)
                         miso=miso_d[0];

		end
	end
	// end SPI logic

endmodule

module SLAVE_test();
parameter bits = 8;
reg rst;
	reg [bits-1:0] data_ins;
	reg [$clog2(bits):0] size;  //same master
	wire [bits-1:0] data_outs;

	// SPI side
        wire miso;
	wire mosi;
	reg spi_clk;
	reg cs;
	reg cphase;
	reg cpol;
	wire [7:0]moss;
	integer i;
SPI_Slave
#(
		.reg_wid(bits)
	) spi
	(
.rst(rst),
.data_ins(data_ins),
.size(size),
.data_outs(data_outs),
.miso(miso),
.mosi(mosi),
.spi_clk(spi_clk),
.cs(cs),
.moss(moss),
.cphase(cphase)
         );
assign mosi = miso;
always
		#2 spi_clk = !spi_clk;

	initial
	begin

                data_ins=8'b10101010;
//////////////////////////////////////////////////////////////////////////
		
		cphase=0;
		cpol=0;
		spi_clk = cpol;
		
		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MISO");
                $monitor("%b  %b    %b",moss,data_outs,miso);
		rst = 1;
                cs=0;
		size = bits;
		#4;
		rst = 0;
 	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	cs=1;
	#16;
//////////////////////////////////////////////////////////////////////////
		
		cphase=1;
		cpol=0;
		spi_clk = cpol;
		
		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MISO");
                $monitor("%b  %b    %b",moss,data_outs,miso);
		rst = 1;
                cs=0;
		size = bits;
		#4;
		rst = 0;
 	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	cs=1;
	#16;
//////////////////////////////////////////////////////////////////////////
		
		cphase=0;
		cpol=1;
		spi_clk = cpol;
		
		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MISO");
                $monitor("%b  %b    %b",moss,data_outs,miso);
		rst = 1;
                cs=0;
		size = bits;
		#4;
		rst = 0;
 	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	cs=1;
	#16;
//////////////////////////////////////////////////////////////////////////
		
		cphase=1;
		cpol=1;
		spi_clk = cpol;
		
		$display("Mode = %d",{cpol,cphase});
		$display("Initial     Final     MISO");
                $monitor("%b  %b    %b",moss,data_outs,miso);
		rst = 1;
                cs=0;
		size = bits;
		#4;
		rst = 0;
 	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	cs=1;
	#16;

		end
endmodule
