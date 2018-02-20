
-- ----------------------------------------------
-- File Name: MWChIfRX.vhd
-- Created:   08-Feb-2018 10:01:15
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfRX IS 
GENERIC (
         OUTPUT_DATAWIDTH: integer := 8;
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
END MWChIfRX;

ARCHITECTURE rtl of MWChIfRX IS

COMPONENT MWChIfRXDecoder IS 
PORT (
      clk                             : IN  std_logic;
      rxdrst                          : IN  std_logic;
      cmdrst                          : IN  std_logic;
      rxData                          : IN  std_logic_vector(7 DOWNTO 0);
      rxVld                           : IN  std_logic;
      rxRdy                           : IN  std_logic;
      rxEOP                           : IN  std_logic;
      updateSimCycle                  : IN  std_logic;
      unPackDone                      : IN  std_logic;
      rxcclk                          : IN  std_logic;
      rxCmd                           : IN  std_logic_vector(7 DOWNTO 0);
      rxCmdVld                        : IN  std_logic;
      rxCmdEOP                        : IN  std_logic;
      cmdRdy                          : IN  std_logic;
      coupleRxTx                      : IN  std_logic;
      rxEOPAck                        : OUT std_logic;
      simCycle                        : OUT std_logic_vector(15 DOWNTO 0);
      simMode                         : OUT std_logic;
      txDataLength                    : OUT std_logic_vector(15 DOWNTO 0);
      payLoad                         : OUT std_logic_vector(7 DOWNTO 0);
      payLoadVld                      : OUT std_logic;
      rxCmdRdy                        : OUT std_logic;
      cmd                             : OUT std_logic_vector(7 DOWNTO 0);
      cmdVld                          : OUT std_logic;
      cmdEOP                          : OUT std_logic
);
END COMPONENT;

COMPONENT MWChIfRXUnpack IS 
GENERIC (OUTPUT_DATAWIDTH: integer := 8
);
PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      rxData                          : IN  std_logic_vector(7 DOWNTO 0);
      rxVld                           : IN  std_logic;
      unPackDone                      : OUT std_logic;
      dout                            : OUT std_logic_vector(OUTPUT_DATAWIDTH - 1 DOWNTO 0)
);
END COMPONENT;

  SIGNAL payLoad                          : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL payLoadVld                       : std_logic; -- boolean
  SIGNAL unPktDone                        : std_logic; -- boolean
  SIGNAL dout_total                       : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL dout_0                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL dout_1                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL unPktDone_1                      : std_logic; -- boolean
  SIGNAL enbReg                           : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL mask                             : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL enbReg_0                         : std_logic; -- boolean
  SIGNAL enb                              : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL enbBit_1                         : std_logic; -- boolean
  SIGNAL enbBit_0                         : std_logic; -- boolean

BEGIN

u_MWChIfRXDecoder: MWChIfRXDecoder 
PORT MAP(
        clk                  => clk,
        rxdrst               => rxdrst,
        cmdrst               => cmdrst,
        rxData               => rxData,
        rxVld                => rxVld,
        rxRdy                => rxRdy,
        rxEOP                => rxEOP,
        rxEOPAck             => rxEOPAck,
        simCycle             => simCycle,
        updateSimCycle       => updateSimCycle,
        simMode              => simMode,
        txDataLength         => txDataLength,
        unPackDone           => unPktDone,
        payLoad              => payLoad,
        payLoadVld           => payLoadVld,
        rxcclk               => rxcclk,
        rxCmd                => rxCmd,
        rxCmdVld             => rxCmdVld,
        rxCmdRdy             => rxCmdRdy,
        rxCmdEOP             => rxCmdEOP,
        cmd                  => cmd,
        cmdVld               => cmdVld,
        cmdRdy               => cmdRdy,
        cmdEOP               => cmdEOP,
        coupleRxTx           => '1'
);

u_MWChIfRXUnpack: MWChIfRXUnpack 
GENERIC MAP (OUTPUT_DATAWIDTH => OUTPUT_DATAWIDTH
)
PORT MAP(
        clk                  => clk,
        reset                => rxdrst,
        rxData               => payLoad,
        rxVld                => payLoadVld,
        unPackDone           => unPktDone,
        dout                 => dout
);

unPackDone <= unPktDone;


END;
