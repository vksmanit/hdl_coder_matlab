
-- ----------------------------------------------
-- File Name: MWChIf.vhd
-- Created:   08-Feb-2018 10:01:16
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIf IS 
GENERIC (
         DUT_INPUT_DATAWIDTH: integer := 8;
         DUT_OUTPUT_DATAWIDTH: integer := 8;
         COUPLE_RXTX: std_logic := '1'
);

PORT (
      txdclk                          : IN  std_logic;
      txsclk                          : IN  std_logic;
      rxdclk                          : IN  std_logic;
      rxcclk                          : IN  std_logic;
      txdrst                          : IN  std_logic;
      rxdrst                          : IN  std_logic;
      sys_rst                         : IN  std_logic;
      chif_rxdata                     : IN  std_logic_vector(7 DOWNTO 0);
      chif_rxdvld                     : IN  std_logic;
      chif_rxdeop                     : IN  std_logic;
      chif_rxcmd                      : IN  std_logic_vector(7 DOWNTO 0);
      chif_rxcvld                     : IN  std_logic;
      chif_rxceop                     : IN  std_logic;
      chif_txdrdy                     : IN  std_logic;
      chif_cmdrdy                     : IN  std_logic;
      chif_datafromdut                : IN  std_logic_vector(DUT_OUTPUT_DATAWIDTH - 1 DOWNTO 0);
      chif_datafromdutvld             : IN  std_logic;
      chif_NOPcmd                     : IN  std_logic;
      tx_stream_en                    : IN  std_logic;
      chif_rxdrdy                     : OUT std_logic;
      chif_rxcrdy                     : OUT std_logic;
      chif_txdata                     : OUT std_logic_vector(7 DOWNTO 0);
      chif_txdvld                     : OUT std_logic;
      chif_txdeop                     : OUT std_logic;
      chif_cmd                        : OUT std_logic_vector(7 DOWNTO 0);
      chif_cmdvld                     : OUT std_logic;
      chif_cmdEOP                     : OUT std_logic;
      chif_datatodut                  : OUT std_logic_vector(DUT_INPUT_DATAWIDTH - 1 DOWNTO 0);
      chif_dutenb                     : OUT std_logic
);
END MWChIf;

ARCHITECTURE rtl of MWChIf IS

COMPONENT MWChIfRX IS 
GENERIC (OUTPUT_DATAWIDTH: integer := 8;
COUPLE_RXTX: std_logic := '1'
);
PORT (
      clk                             : IN  std_logic;
      rxdrst                          : IN  std_logic;
      cmdrst                          : IN  std_logic;
      rxData                          : IN  std_logic_vector(7 DOWNTO 0);
      rxVld                           : IN  std_logic;
      rxRdy                           : IN  std_logic;
      rxEOP                           : IN  std_logic;
      updateSimCycle                  : IN  std_logic;
      rxcclk                          : IN  std_logic;
      rxCmd                           : IN  std_logic_vector(7 DOWNTO 0);
      rxCmdVld                        : IN  std_logic;
      rxCmdEOP                        : IN  std_logic;
      cmdRdy                          : IN  std_logic;
      simCycle                        : OUT std_logic_vector(15 DOWNTO 0);
      simMode                         : OUT std_logic;
      rxEOPAck                        : OUT std_logic;
      txDataLength                    : OUT std_logic_vector(15 DOWNTO 0);
      dout                            : OUT std_logic_vector(OUTPUT_DATAWIDTH - 1 DOWNTO 0);
      unPackDone                      : OUT std_logic;
      rxCmdRdy                        : OUT std_logic;
      cmd                             : OUT std_logic_vector(7 DOWNTO 0);
      cmdVld                          : OUT std_logic;
      cmdEOP                          : OUT std_logic
);
END COMPONENT;

COMPONENT MWChIfTX IS 
GENERIC (OUTPUT_DATAWIDTH: integer := 8
);
PORT (
      dclk                            : IN  std_logic;
      reset                           : IN  std_logic;
      dataIn                          : IN  std_logic_vector(OUTPUT_DATAWIDTH - 1 DOWNTO 0);
      dataInVld                       : IN  std_logic;
      txPayLoad                       : IN  std_logic;
      dataOut                         : OUT std_logic_vector(7 DOWNTO 0);
      dataOutVld                      : OUT std_logic
);
END COMPONENT;

COMPONENT MWChIfCtrl IS 
GENERIC (RX_DATAWIDTH: integer := 8;
TX_DATAWIDTH: integer := 8;
COUPLE_RXTX: std_logic := '1'
);
PORT (
      rxdclk                          : IN  std_logic;
      txdclk                          : IN  std_logic;
      rxdrst                          : IN  std_logic;
      txdrst                          : IN  std_logic;
      dinVld                          : IN  std_logic;
      unPackDone                      : IN  std_logic;
      txRdy                           : IN  std_logic;
      rxEOP                           : IN  std_logic;
      simCycle                        : IN  std_logic_vector(15 DOWNTO 0);
      simMode                         : IN  std_logic;
      NOPcmd                          : IN  std_logic;
      tx_stream_en                    : IN  std_logic;
      updateSimCycle                  : OUT std_logic;
      dutEnb                          : OUT std_logic;
      shftOutReg                      : OUT std_logic;
      rxRdy                           : OUT std_logic;
      txEOP                           : OUT std_logic
);
END COMPONENT;

  SIGNAL shftOutReg                       : std_logic; -- boolean
  SIGNAL rxRdy                            : std_logic; -- boolean
  SIGNAL simCycle                         : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL simMode                          : std_logic; -- boolean
  SIGNAL txDataLength                     : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL rxEOPAck                         : std_logic; -- boolean
  SIGNAL updateSimCycle                   : std_logic; -- boolean
  SIGNAL unPackDone                       : std_logic; -- boolean
  SIGNAL payLoad                          : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL payLoadVld                       : std_logic; -- boolean
  SIGNAL unPktDone                        : std_logic; -- boolean
  SIGNAL txDone                           : std_logic; -- boolean
  SIGNAL txCompleted                      : std_logic; -- boolean
  SIGNAL simCycle_temp                    : std_logic_vector(15 DOWNTO 0); -- std16

BEGIN

u_MWChIfRX: MWChIfRX 
GENERIC MAP (OUTPUT_DATAWIDTH => DUT_INPUT_DATAWIDTH,
COUPLE_RXTX => COUPLE_RXTX
)
PORT MAP(
        clk                  => rxdclk,
        rxdrst               => rxdrst,
        cmdrst               => sys_rst,
        rxData               => chif_rxdata,
        rxVld                => chif_rxdvld,
        rxRdy                => rxRdy,
        rxEOP                => chif_rxdeop,
        simCycle             => simCycle,
        updateSimCycle       => updateSimCycle,
        simMode              => simMode,
        rxEOPAck             => rxEOPAck,
        txDataLength         => txDataLength,
        dout                 => chif_datatodut,
        unPackDone           => unPackDone,
        rxcclk               => rxcclk,
        rxCmd                => chif_rxcmd,
        rxCmdVld             => chif_rxcvld,
        rxCmdRdy             => chif_rxcrdy,
        rxCmdEOP             => chif_rxceop,
        cmd                  => chif_cmd,
        cmdVld               => chif_cmdvld,
        cmdRdy               => chif_cmdrdy,
        cmdEOP               => chif_cmdEOP
);

u_MWChIfTX: MWChIfTX 
GENERIC MAP (OUTPUT_DATAWIDTH => DUT_OUTPUT_DATAWIDTH
)
PORT MAP(
        dclk                 => txdclk,
        reset                => txdrst,
        dataOut              => chif_txdata,
        dataOutVld           => chif_txdvld,
        dataIn               => chif_datafromdut,
        dataInVld            => chif_datafromdutvld,
        txPayLoad            => shftOutReg
);

u_MWChIfCtrl: MWChIfCtrl 
GENERIC MAP (RX_DATAWIDTH => DUT_INPUT_DATAWIDTH,
TX_DATAWIDTH => DUT_OUTPUT_DATAWIDTH,
COUPLE_RXTX => COUPLE_RXTX
)
PORT MAP(
        rxdclk               => rxdclk,
        txdclk               => txdclk,
        rxdrst               => rxdrst,
        txdrst               => txdrst,
        dinVld               => chif_datafromdutvld,
        unPackDone           => unPackDone,
        txRdy                => chif_txdrdy,
        rxEOP                => rxEOPAck,
        simCycle             => simCycle,
        updateSimCycle       => updateSimCycle,
        dutEnb               => chif_dutenb,
        shftOutReg           => shftOutReg,
        rxRdy                => rxRdy,
        txEOP                => chif_txdeop,
        simMode              => simMode,
        NOPcmd               => chif_NOPcmd,
        tx_stream_en         => tx_stream_en
);

chif_rxdrdy <= rxRdy;


END;
