--Simple CPU template, This is the top level entity in your project
library ieee;
use ieee.std_logic_1164.all;

entity SimpleCPU_Template is
--These are the Outputs that can be displayed on the FPGA, More port statements may be necessary, 
--Depending on how you want to display each signal to the FPGA
port (
	clk : in std_logic;
	pcOut : out std_logic_vector(7 downto 0);
	marOut : out std_logic_vector (7 downto 0);
	irOutput : out std_logic_vector (7 downto 0);
	mdriOutput : out std_logic_vector (7 downto 0);
	mdroOutput : out std_logic_vector (7 downto 0);
	aOut : out std_logic_vector (7 downto 0);
	incrementOut : out std_logic
);

end;

architecture behavior of SimpleCPU_Template is
--Initialize our memory component
component memory_8_by_32
port(	clk:		in std_logic;	
	Write_Enable: in std_logic;
	Read_Addr:	in std_logic_vector	(4 downto 0);
	Data_in: 	in std_logic_vector	(7 downto 0);
	Data_out: 	out std_logic_vector(7 downto 0)
);
end component;
--initialize the alu
component alu
port (
	A : in std_logic_vector			(7 downto 0);
	B : in std_logic_vector			(7 downto 0);
	AluOp : in std_logic_vector		(2 downto 0);
	output : out std_logic_vector	(7 downto 0)
);
end component;
--initialize the registers
component reg
port (
	input : in std_logic_vector		(7 downto 0);
	output : out std_logic_vector	(7 downto 0);
	clk : in std_logic;
	load : in std_logic
);
end component;
--initialize the program counter
component ProgramCounter
port (
	increment : in std_logic;
	clk : in std_logic;
	output : out std_logic_vector	(7 downto 0)
);
end component;
--initialize the mux
component TwoToOneMux
port (
	A : in std_logic_vector			(7 downto 0);
	B : in std_logic_vector			(7 downto 0);
	address : in std_logic;
	output : out std_logic_vector	(7 downto 0)
);
end component;
--initialize the seven segment decoder
component sevenseg
port(
	i : in std_logic_vector(3 downto 0);
	o : out std_logic_vector(0 to 7)
);
end component;

-- initialize control unit
component ControlUnit
port (
	OpCode : in std_logic_vector(2 downto 0);
	clk : in std_logic;
	ToALoad : out std_logic;
	ToMarLoad : out std_logic;
	ToIrLoad : out std_logic;
	ToMdriLoad : out std_logic;
	ToMdroLoad : out std_logic;
	ToPcIncrement : out std_logic;
	ToMarMux : out std_logic;
	ToRamWriteEnable : out std_logic;
	ToAluOp : out std_logic_vector (2 downto 0)
);
end component;

--The following signals will be used in your port map statements, don't use the port variables in your port maps

-- Connections : Need to be sorted
signal ramDataOutToMdri : std_logic_vector (7 downto 0);

-- MAR Multiplexer connections
signal pcToMarMux : std_logic_vector(7 downto 0);
signal muxToMar : std_logic_vector	(7 downto 0);

-- RAM connections
signal marToRamReadAddr : std_logic_vector	(4 downto 0);
signal mdroToRamDataIn : std_logic_vector (7 downto 0);

-- MDRI connections
signal mdriOut : std_logic_vector 	(7 downto 0);

-- IR connection
signal irOut : std_logic_vector		(7 downto 0);

-- ALU / Accumulator connections
signal aluOut: std_logic_vector	(7 downto 0);
signal aToAluB : std_logic_vector	(7 downto 0);

-- Control Unit connections
signal cuToALoad : std_logic;
signal cuToMarLoad : std_logic;
signal cuToIrLoad : std_logic;
signal cuToMdriLoad : std_logic;
signal cuToMdroLoad : std_logic;
signal cuToPcIncrement : std_logic;
signal cuToMarMux : std_logic;
signal cuToRamWriteEnable : std_logic;
signal cuToAluOp : std_logic_vector (2 downto 0);

begin

--PORT MAP STATEMENTS GO HERE
-- Create port map statements for each component in the CPU and map them to the appropriate signal defined above
-- RAM
--SEE INSERTED CODE BELOW
ramA : memory_8_by_32 port map(
	clk => clk,
	Write_Enable => cuToRamWriteEnable,
	Read_Addr => marToRamReadAddr,
	Data_in => mdroToRamDataIn,
	Data_out => ramDataOutToMdri
);

-- Accumulator
--SEE INSERTED CODE BELOW
accumA : reg port map(
	input => aluOut,
	output => aToAluB,
	clk => clk,
	load => cuToALoad
);

-- ALU
--SEE INSERTED CODE BELOW
aluA : alu port map(
	A => mdriOut,
	B => aToAluB,
	AluOp => cuToAluOp,
	output => aluOut
);

-- Program Counter
--SEE INSERTED CODE BELOW
ProgramCounterA : ProgramCounter port map(
	increment => cuToPcIncrement,
	clk => clk,
	output => pcToMarMux
);

-- Instruction Register
--SEE INSERTED CODE BELOW
InstructionRegisterA : reg port map(
	input => mdriOut,
	output => irOut,
	clk => clk,
	load => cuToIrLoad
);

-- MAR mux
--SEE INSERTED CODE BELOW
MuxA : TwoToOneMux port map(
	A => pcToMarMux,
	B => irOut,
	address => cuToMarMux,
	output => MuxToMar
);

-- Memory Access Register
--SEE INSERTED CODE BELOW
MarA : reg port map(
	input => MuxToMar,
	output(4 downto 0) => MarToRamReadAddr,
	clk => clk,
	load => cuToMarLoad
);

-- Memory Data Register Input
--SEE INSERTED CODE BELOW
MdriA : reg port map(
	input => RamDataOutToMdri,
	output => mdriOut,
	clk => clk,
	load => cuToMdriLoad
);

-- Memory Data Register Output
--SEE INSERTED CODE BELOW
MdroA : reg port map(
	input => aluOut,
	output => mdroToRamDataIn,
	clk => clk,
	load => cuToMdroLoad
);

-- Control Unit
--SEE INSERTED CODE BELOW
ControlUnitA : ControlUnit port map(
	OpCode => irOut(7 downto 5), --May have to change this
	clk => clk,
	ToALoad => cuToALoad,
	ToMarLoad => cuToMarLoad,
	ToIrLoad => cuToIrLoad,
	ToMdriLoad => cuToMdriLoad,
	ToMdroLoad => cuToMdroLoad,
	ToPcIncrement => cuToPcIncrement,
	ToMarMux => cuToMarMux,
	ToRamWriteEnable => cuToRamWriteEnable,
	ToAluOp => cuToAluOp
);

--REMAINING CODE GOES HERE
--Here is where you connect the port statement to the matching signal to display it on the FPGA
--If you want to display the signal on LED's, just set it to the port statement port<=signal;
--If you want to send the signal to the seven segment display, initialize an instance of the sevenseg
--Then map i=>signal, o=>port , keep in mind i needs to be 4 bits and o 8 bits
--pcOut <= pcToMarMux;

pcOut <= pcToMarMux;
marOut <= "000"&MarToRamReadAddr;
irOutput <= irOut;
mdriOutput <= mdriOut;
mdroOutput <= mdroToRamDataIn;
aOut <= aToAluB;
incrementOut <= cuToPcIncrement;


end behavior;
