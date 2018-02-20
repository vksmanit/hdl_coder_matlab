
-- ----------------------------------------------
-- File Name: MWChIfRXUnpack.vhd
-- Created:   08-Feb-2018 10:01:15
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfRXUnpack IS 
GENERIC (
         OUTPUT_DATAWIDTH: integer := 8
);

PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      rxData                          : IN  std_logic_vector(7 DOWNTO 0);
      rxVld                           : IN  std_logic;
      unPackDone                      : OUT std_logic;
      dout                            : OUT std_logic_vector(OUTPUT_DATAWIDTH - 1 DOWNTO 0)
);
END MWChIfRXUnpack;

ARCHITECTURE rtl of MWChIfRXUnpack IS

COMPONENT MWRotateRight IS 
GENERIC (DATA_WIDTH: integer := 8
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      shift                           : IN  std_logic;
      load                            : IN  std_logic;
      input                           : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      output                          : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
);
END COMPONENT;

COMPONENT MWMuxReg IS 
GENERIC (DATA_WIDTH: integer := 8
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      selIn1                          : IN  std_logic;
      in1                             : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      in2                             : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      output                          : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
);
END COMPONENT;

  CONSTANT input_CONST                    : std_logic_vector(1 DOWNTO 0) := (others => '0'); -- ufix
  SIGNAL dout_total                       : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL dout_0                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL dout_1                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL unPktDone                        : std_logic; -- boolean
  SIGNAL enbReg                           : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL mask                             : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL enbReg_0                         : std_logic; -- boolean
  SIGNAL enb                              : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL enbBit_1                         : std_logic; -- boolean
  SIGNAL enbBit_0                         : std_logic; -- boolean

BEGIN

u_MWRotateRight: MWRotateRight 
GENERIC MAP (DATA_WIDTH => 2
)
PORT MAP(
        clk                  => clk,
        reset                => reset,
        shift                => rxVld,
        load                 => '0',
        input                => input_CONST,
        output               => enbReg
);

u_MWMuxReg: MWMuxReg 
GENERIC MAP (DATA_WIDTH => 8
)
PORT MAP(
        clk                  => clk,
        reset                => reset,
        selIn1               => enbBit_1,
        in1                  => rxData,
        in2                  => dout_1,
        output               => dout_1
);

u_MWMuxReg_inst1: MWMuxReg 
GENERIC MAP (DATA_WIDTH => 8
)
PORT MAP(
        clk                  => clk,
        reset                => reset,
        selIn1               => enbBit_0,
        in1                  => rxData,
        in2                  => dout_0,
        output               => dout_0
);

dout <= dout_0 & dout_1;
unPackDone <= enbReg_0 AND rxVld;
mask <= (others => rxVld);
enbReg_0 <= enbReg(0);
enb <= enbReg AND mask;
enbBit_1 <= enb(1);
enbBit_0 <= enb(0);

END;
