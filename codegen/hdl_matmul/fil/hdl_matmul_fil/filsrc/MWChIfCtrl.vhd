
-- ----------------------------------------------
-- File Name: MWChIfCtrl.vhd
-- Created:   08-Feb-2018 10:01:16
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfCtrl IS 
GENERIC (
         RX_DATAWIDTH: integer := 8;
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
END MWChIfCtrl;

ARCHITECTURE rtl of MWChIfCtrl IS

COMPONENT MWChIfRXCtrl IS 
GENERIC (RX_DATAWIDTH: integer := 8;
TX_DATAWIDTH: integer := 8;
COUPLE_RXTX: std_logic := '1'
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      unPackDone                      : IN  std_logic;
      simCycle                        : IN  std_logic_vector(15 DOWNTO 0);
      txCompleted                     : IN  std_logic;
      txDone                          : IN  std_logic;
      rxEOP                           : IN  std_logic;
      tx_stream_en                    : IN  std_logic;
      dutEnb                          : OUT std_logic;
      rxRdy                           : OUT std_logic;
      updateSimCycle                  : OUT std_logic
);
END COMPONENT;

COMPONENT MWChIfTXCtrl IS 
GENERIC (TX_DATAWIDTH: integer := 8;
RX_DATAWIDTH: integer := 8;
COUPLE_RXTX: std_logic := '1'
);
PORT (
      dclk                            : IN  std_logic;
      reset                           : IN  std_logic;
      dinVld                          : IN  std_logic;
      txRdy                           : IN  std_logic;
      rxEOP                           : IN  std_logic;
      simCycle                        : IN  std_logic_vector(15 DOWNTO 0);
      simMode                         : IN  std_logic;
      NOPcmd                          : IN  std_logic;
      shftOutReg                      : OUT std_logic;
      txEOP                           : OUT std_logic;
      txCompleted                     : OUT std_logic;
      txDone                          : OUT std_logic
);
END COMPONENT;

  SIGNAL txDone                           : std_logic; -- boolean
  SIGNAL txCompleted                      : std_logic; -- boolean
  SIGNAL simCycle_temp                    : std_logic_vector(15 DOWNTO 0); -- std16

BEGIN

u_MWChIfRXCtrl: MWChIfRXCtrl 
GENERIC MAP (RX_DATAWIDTH => RX_DATAWIDTH,
TX_DATAWIDTH => TX_DATAWIDTH,
COUPLE_RXTX => '1'
)
PORT MAP(
        clk                  => rxdclk,
        reset                => rxdrst,
        unPackDone           => unPackDone,
        simCycle             => simCycle,
        dutEnb               => dutEnb,
        rxRdy                => rxRdy,
        txCompleted          => txCompleted,
        txDone               => txDone,
        updateSimCycle       => updateSimCycle,
        rxEOP                => rxEOP,
        tx_stream_en         => tx_stream_en
);

u_MWChIfTXCtrl: MWChIfTXCtrl 
GENERIC MAP (TX_DATAWIDTH => TX_DATAWIDTH,
RX_DATAWIDTH => RX_DATAWIDTH,
COUPLE_RXTX => '1'
)
PORT MAP(
        dclk                 => txdclk,
        reset                => txdrst,
        dinVld               => dinVld,
        txRdy                => txRdy,
        rxEOP                => rxEOP,
        simCycle             => simCycle_temp,
        simMode              => simMode,
        NOPcmd               => NOPcmd,
        shftOutReg           => shftOutReg,
        txEOP                => txEOP,
        txCompleted          => txCompleted,
        txDone               => txDone
);

simCycle_temp <= std_logic_vector(simCycle);

END;
