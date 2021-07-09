module integrate(
input cphase,
input [1:0]slave,
input [7:0]data_in,
input [7:0]data_ins0,
input [7:0]data_ins1,
input [7:0]data_ins2,
input clk,
input rst,
input start,
input [3:0]size,
output wire[7:0]data_out,
output wire[7:0]data_outs0,
output wire[7:0]data_outs1,
output wire[7:0]data_outs2,
output wire [7:0]mos,
output wire [7:0]mos0,
output wire [7:0]mos1,
output wire [7:0]mos2
);
//wire [7:0]data_outm;
parameter bits = 8;
wire miso;
wire mosi;
wire spi_clk;
wire [2:0]cs;
wire miso1;
wire miso2;
wire miso3;
assign miso=(cs==3'b110)?miso1:
             (cs==3'b101)?miso2:
              (cs==3'b011)?miso3:
                    1'b z;
//SPI_Master s (rst,clk,t_start,data_inm,size,data_outm,miso,spi_clk,cs,mos_m);
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
                .cphase(cphase),
		.size(size),
		.cs(cs),
		.rst(rst),
		.spi_clk(spi_clk),
		.miso(miso),
		.mosi(mosi),
                .mos(mos)
	);
SPI_Slave
#(
		.reg_wid(bits)
	) spi1
	(
.rst(rst),
.cphase(cphase),
.data_ins(data_ins0),
.size(size),
.data_outs(data_outs0),
.miso(miso1),
.mosi(mosi),
.spi_clk(spi_clk),
.cs(cs[0]),
.moss(mos0)
         );
SPI_Slave
#(
		.reg_wid(bits)
	) spi2
	(
.rst(rst),
.cphase(cphase),
.data_ins(data_ins1),
.size(size),
.data_outs(data_outs1),
.miso(miso2),
.mosi(mosi),
.spi_clk(spi_clk),
.cs(cs[1]),
.moss(mos1)
         );
SPI_Slave
#(
		.reg_wid(bits)
	) spi3
	(
.rst(rst),
.cphase(cphase),
.data_ins(data_ins2),
.size(size),
.data_outs(data_outs2),
.miso(miso3),
.mosi(mosi),
.spi_clk(spi_clk),
.cs(cs[2]),
.moss(mos2)
         );
endmodule
module tst5();
parameter bits = 8;
reg [7:0]data_inm;
reg [7:0]data_ins1;
reg [7:0]data_ins2;
reg [7:0]data_ins3;
reg  clk;
reg [1:0]slave;
reg rst;
reg t_start;
reg cpol;
reg [3:0]size;
wire[7:0]data_out;
wire[7:0]data_outs;
wire[7:0]data_outs1;
wire[7:0]data_outs2;
wire[7:0]mos;
wire[7:0]mos0;
wire[7:0]mos1;
wire[7:0]mos2;
reg cphase;
integer i;
integrate i1(cphase,slave,data_inm,data_ins1,data_ins2,data_ins3,clk,rst,t_start,size,data_out,data_outs,data_outs1,data_outs2,mos,mos0,mos1,mos2);

always
		#2 clk = !clk;

	initial
	begin
                data_inm=8'b10101010;
                data_ins1=8'b11111111;
                data_ins2=8'b11011101;
                data_ins3=8'b11001100;
//////////////////////////////////////////////////////////////////////////////////////////////////////// 
                slave=0;
		cphase=0;
		cpol=0;
		clk = cpol;

		$display("MODE= %d ",{cpol,cphase});
		$display("slave selected=  %d",slave);
                $display("S[2](initial & Final)    S[1](initial & Final)   S[0](initial & Final)   Mas(initial & Final)");
                $monitor(" %b    %b    %b    %b    %b    %b    %b    %b",mos2,data_outs2,mos1,data_outs1,mos0,data_outs,mos,data_out);

		t_start = 0;
		rst = 0;
		size = bits;
		#2
		rst=1;
		#4;
		rst = 0;
        #3 t_start = 1;
	#4 t_start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;

//////////////////////////////////////////////////////////////////////////////////////////////////////////

		slave=1;
		cphase=1;
		cpol=0;
		clk = cpol;

		$display("MODE= %d ",{cpol,cphase});
		$display("slave selected=  %d",slave);
                $display("S[2](initial & Final)    S[1](initial & Final)   S[0](initial & Final)   Mas(initial & Final)");
                $monitor(" %b    %b    %b    %b    %b    %b    %b    %b",mos2,data_outs2,mos1,data_outs1,mos0,data_outs,mos,data_out);

		t_start = 0;
		rst = 0;
		size = bits;
		#2
		rst=1;
		#4;
		rst = 0;
        #3 t_start = 1;
	#4 t_start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;
///////////////////////////////////////////////////////////////////////////////////////
		slave=2;
		cphase=0;
		cpol=1;
		clk = cpol;

		$display("MODE= %d ",{cpol,cphase});
		$display("slave selected=  %d",slave);
                $display("S[2](initial & Final)    S[1](initial & Final)   S[0](initial & Final)   Mas(initial & Final)");
                $monitor(" %b    %b    %b    %b    %b    %b    %b    %b",mos2,data_outs2,mos1,data_outs1,mos0,data_outs,mos,data_out);

		t_start = 0;
		rst = 0;
		size = bits;
		#2
		rst=1;
		#4;
		rst = 0;
        #3 t_start = 1;
	#4 t_start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;

//////////////////////////////////////////////////////////////////////////////////////////

		slave=0;
		cphase=1;
		cpol=1;
		clk = cpol;

		$display("MODE= %d ",{cpol,cphase});
		$display("slave selected=  %d",slave);
                $display("S[2](initial & Final)    S[1](initial & Final)   S[0](initial & Final)   Mas(initial & Final)");
                $monitor(" %b    %b    %b    %b    %b    %b    %b    %b",mos2,data_outs2,mos1,data_outs1,mos0,data_outs,mos,data_out);

		t_start = 0;
		rst = 0;
		size = bits;
		#2
		rst=1;
		#4;
		rst = 0;
        #3 t_start = 1;
	#4 t_start = 0;
	for( i=0; i < bits; i=i+1)
	begin
	#4;
	end
	#16;




end
endmodule
