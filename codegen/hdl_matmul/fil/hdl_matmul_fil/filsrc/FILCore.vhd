
-- ----------------------------------------------
-- File Name: FILCore.vhd
-- Created:   08-Feb-2018 10:01:18
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY FILCore IS 
GENERIC (
         DUT_INPUT_DATAWIDTH: integer := 8;
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
END FILCore;

ARCHITECTURE rtl of FILCore IS

COMPONENT FILCommLayer IS 
GENERIC (DUT_INPUT_DATAWIDTH: integer := 8;
DUT_OUTPUT_DATAWIDTH: integer := 8;
VERSION: std_logic_vector(15 DOWNTO 0) := X"0100"
);
PORT (
      txdclk                          : IN  std_logic;
      txsclk                          : IN  std_logic;
      rxdclk                          : IN  std_logic;
      rxcclk                          : IN  std_logic;
      reset                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      dut_dout                        : IN  std_logic_vector(15 DOWNTO 0);
      dut_doutvld                     : IN  std_logic;
      busIf_cmdProcRdy                : IN  std_logic;
      busIf_status                    : IN  std_logic_vector(7 DOWNTO 0);
      busIf_statusVld                 : IN  std_logic;
      busIf_statusEOP                 : IN  std_logic;
      NOPcmd                          : IN  std_logic;
      tx_stream_en                    : IN  std_logic;
      CLK125                          : IN  std_logic;
      dut_din                         : OUT std_logic_vector(15 DOWNTO 0);
      dut_dinvld                      : OUT std_logic;
      busIf_cmd                       : OUT std_logic_vector(7 DOWNTO 0);
      busIf_cmdVld                    : OUT std_logic;
      busIf_txsRdy                    : OUT std_logic
);
END COMPONENT;

COMPONENT FILCmdProc IS 
GENERIC (VERSION: std_logic_vector(15 DOWNTO 0) := X"0100"
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      cmd                             : IN  std_logic_vector(7 DOWNTO 0);
      cmdVld                          : IN  std_logic;
      txsRdy                          : IN  std_logic;
      cmdProcRdy                      : OUT std_logic;
      status                          : OUT std_logic_vector(7 DOWNTO 0);
      statusVld                       : OUT std_logic;
      statusEOP                       : OUT std_logic;
      softFPGAReset                   : OUT std_logic;
      softDUTReset                    : OUT std_logic;
      NOPcmd                          : OUT std_logic
);
END COMPONENT;

COMPONENT hdl_matmul_wrapper IS 
PORT (
      clk_enable                      : IN  std_logic;
      a_in                            : IN  std_logic_vector(7 DOWNTO 0);
      reset                           : IN  std_logic;
      clk                             : IN  std_logic;
      b_in                            : IN  std_logic_vector(7 DOWNTO 0);
      state_store                     : OUT std_logic_vector(7 DOWNTO 0);
      c_out                           : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

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
  SIGNAL chif_rxdata                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL chif_rxdvld                      : std_logic; -- boolean
  SIGNAL chif_rxdeop                      : std_logic; -- boolean
  SIGNAL chif_rxdrdy                      : std_logic; -- boolean
  SIGNAL chif_rxcmd                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL chif_rxcvld                      : std_logic; -- boolean
  SIGNAL chif_rxdeop_1                    : std_logic; -- boolean
  SIGNAL chif_rxdrdy_1                    : std_logic; -- boolean
  SIGNAL chif_txdata                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL chif_txdvld                      : std_logic; -- boolean
  SIGNAL chif_txdeop                      : std_logic; -- boolean
  SIGNAL chif_txdrdy                      : std_logic; -- boolean
  SIGNAL mac_rxdata                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL mac_rxvld                        : std_logic; -- boolean
  SIGNAL mac_rxeop                        : std_logic; -- boolean
  SIGNAL mac_rxcrcok                      : std_logic; -- boolean
  SIGNAL mac_rxcrcbad                     : std_logic; -- boolean
  SIGNAL mac_rxdstport                    : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL mac_rxreset                      : std_logic; -- boolean
  SIGNAL mac_txreset                      : std_logic; -- boolean
  SIGNAL pkt_txdata                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL pkt_txvld                        : std_logic; -- boolean
  SIGNAL pkt_txeop                        : std_logic; -- boolean
  SIGNAL pkt_txrdy                        : std_logic; -- boolean
  SIGNAL pkt_txstatus                     : std_logic; -- boolean
  SIGNAL pkt_txdatalength                 : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL mac_txdata                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL mac_txvld                        : std_logic; -- boolean
  SIGNAL mac_txeop                        : std_logic; -- boolean
  SIGNAL mac_txrdy                        : std_logic; -- boolean
  SIGNAL mac_txdatalength                 : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL mac_txsrcport                    : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL bufferStatus                     : std_logic_vector(3 DOWNTO 0); -- std4
  SIGNAL clearStatus                      : std_logic; -- boolean
  SIGNAL a_in_tmp_1                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL b_in_tmp_1                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL c_out_tmp_1                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL state_store_tmp_1                : std_logic_vector(7 DOWNTO 0); -- std8

BEGIN

u_FILCommLayer: FILCommLayer 
GENERIC MAP (DUT_INPUT_DATAWIDTH => 16,
DUT_OUTPUT_DATAWIDTH => 16,
VERSION => X"0200"
)
PORT MAP(
        txdclk               => clk,
        txsclk               => clk,
        rxdclk               => clk,
        rxcclk               => clk,
        reset                => reset_int,
        txclk_en             => txclk_en,
        rxclk_en             => rxclk_en,
        dut_din              => dut_din,
        dut_dinvld           => dut_clkenb,
        dut_dout             => dut_dout,
        dut_doutvld          => dut_clkenb,
        busIf_cmd            => cmd,
        busIf_cmdVld         => cmdVld,
        busIf_cmdProcRdy     => cmdProcRdy,
        busIf_status         => status,
        busIf_statusVld      => statusvld,
        busIf_statusEOP      => statusEOP,
        busIf_txsRdy         => txsRdy,
        NOPcmd               => NOPcmd,
        tx_stream_en         => '1',
        CLK125               => CLK125
);

u_FILCmdProc: FILCmdProc 
GENERIC MAP (VERSION => X"0200"
)
PORT MAP(
        clk                  => clk,
        reset                => reset_int,
        cmd                  => cmd,
        cmdVld               => cmdVld,
        cmdProcRdy           => cmdProcRdy,
        status               => status,
        statusVld            => statusvld,
        statusEOP            => statusEOP,
        txsRdy               => txsRdy,
        softFPGAReset        => softFPGAReset,
        softDUTReset         => softDUTReset,
        NOPcmd               => NOPcmd
);

u_hdl_matmul_wrapper: hdl_matmul_wrapper 
PORT MAP(
        clk_enable           => dut_clkenb,
        a_in                 => a_in_tmp,
        reset                => dutReset,
        state_store          => state_store_tmp,
        clk                  => clk,
        b_in                 => b_in_tmp,
        c_out                => c_out_tmp
);

dut_dout <= state_store_tmp & c_out_tmp;
dut_softReset <= reset_int OR softDUTReset;
reset_int <= reset OR softFPGAReset;
dutReset <= reset OR dut_softReset;
a_in_tmp <= dut_din(7 DOWNTO 0);
b_in_tmp <= dut_din(15 DOWNTO 8);

END;
