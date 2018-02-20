
-- ----------------------------------------------
-- File Name: hdl_matmul_fil.vhd
-- Created:   08-Feb-2018 10:01:18
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

 LIBRARY altera_mf;
 USE altera_mf.altera_mf_components.all;
 USE altera_mf.all;



LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY hdl_matmul_fil IS 
PORT (
      sysrst                          : IN  std_logic;
      sysclk                          : IN  std_logic
);
END hdl_matmul_fil;

ARCHITECTURE rtl of hdl_matmul_fil IS

COMPONENT MWClkMgr IS 
PORT (
      RESET_IN                        : IN  std_logic;
      CLK_IN                          : IN  std_logic;
      RXCLK_IN                        : IN  std_logic;
      MACTXCLK                        : OUT std_logic;
      RESET_OUT                       : OUT std_logic;
      DUTCLK                          : OUT std_logic;
      MACRXCLK                        : OUT std_logic;
      TXCLK                           : OUT std_logic
);
END COMPONENT;

COMPONENT FILCore IS 
GENERIC (DUT_INPUT_DATAWIDTH: integer := 8;
DUT_OUTPUT_DATAWIDTH: integer := 8;
VERSION: std_logic_vector(15 DOWNTO 0) := X"0100"
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      CLK125                          : IN  std_logic
);
END COMPONENT;

  SIGNAL dutClk                           : std_logic; -- boolean
  SIGNAL rst                              : std_logic; -- boolean
  SIGNAL ClkIn                            : std_logic; -- boolean
  SIGNAL rxclk                            : std_logic; -- boolean
  SIGNAL txclk                            : std_logic; -- boolean
  SIGNAL rxd                              : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL txd                              : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL txclk_en                         : std_logic; -- boolean
  SIGNAL rxclk_en                         : std_logic; -- boolean
  SIGNAL dcm_reset                        : std_logic; -- boolean
  SIGNAL Bit0                             : std_logic; -- boolean
  SIGNAL ref_clk                          : std_logic; -- boolean
  SIGNAL clk5                             : std_logic_vector(4 DOWNTO 0); -- std5
  SIGNAL clk1                             : std_logic; -- boolean
  SIGNAL clk2                             : std_logic; -- boolean
  SIGNAL clk3                             : std_logic; -- boolean
  SIGNAL LOCKED                           : std_logic; -- boolean
  SIGNAL notLocked                        : std_logic; -- boolean
  SIGNAL clkin_vector                     : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL clkin_tmp                        : std_logic; -- boolean
  SIGNAL zero                             : std_logic; -- boolean
  SIGNAL tmp                              : std_logic; -- boolean
  SIGNAL dut_dout                         : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL dut_din                          : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL dut_clkenb                       : std_logic; -- boolean
  SIGNAL dut_softReset                    : std_logic; -- boolean
  SIGNAL reset_int                        : std_logic; -- boolean
  SIGNAL softFPGAReset                    : std_logic; -- boolean
  SIGNAL softDUTReset                     : std_logic; -- boolean
  SIGNAL status                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL statusvld                        : std_logic; -- boolean
  SIGNAL statusEOP                        : std_logic; -- boolean
  SIGNAL cmd                              : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL cmdVld                           : std_logic; -- boolean
  SIGNAL cmdProcRdy                       : std_logic; -- boolean
  SIGNAL NOPcmd                           : std_logic; -- boolean
  SIGNAL txsRdy                           : std_logic; -- boolean
  SIGNAL dutReset                         : std_logic; -- boolean
  SIGNAL a_in_tmp                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL b_in_tmp                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL c_out_tmp                        : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL state_store_tmp                  : std_logic_vector(7 DOWNTO 0); -- std8

BEGIN

u_ClockManager: MWClkMgr 
PORT MAP(
        RESET_IN             => dcm_reset,
        MACTXCLK             => ref_clk,
        RESET_OUT            => rst,
        DUTCLK               => dutClk,
        CLK_IN               => ClkIn,
        MACRXCLK             => OPEN,
        TXCLK                => OPEN,
        RXCLK_IN             => Bit0
);

u_FILCore: FILCore 
GENERIC MAP (DUT_INPUT_DATAWIDTH => 16,
DUT_OUTPUT_DATAWIDTH => 16,
VERSION => X"0200"
)
PORT MAP(
        clk                  => dutClk,
        reset                => rst,
        txclk_en             => txclk_en,
        rxclk_en             => rxclk_en,
        CLK125               => ref_clk
);

ClkIn <= sysclk;

txclk_en <= '1';
rxclk_en <= '1';
dcm_reset <= sysrst;

Bit0 <= '0';

END;
