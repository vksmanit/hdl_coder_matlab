
-- ----------------------------------------------
-- File Name: FILCommLayer.vhd
-- Created:   08-Feb-2018 10:01:17
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY FILCommLayer IS 
GENERIC (
         DUT_INPUT_DATAWIDTH: integer := 8;
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
END FILCommLayer;

ARCHITECTURE rtl of FILCommLayer IS

COMPONENT MWAJTAG IS 
PORT (
      TxEOP                           : IN  std_logic;
      TxData                          : IN  std_logic_vector(7 DOWNTO 0);
      TxDataLength                    : IN  std_logic_vector(12 DOWNTO 0);
      TxDataValid                     : IN  std_logic;
      CLK125                          : IN  std_logic;
      RxDataValid                     : OUT std_logic;
      RxEOP                           : OUT std_logic;
      TxReady                         : OUT std_logic;
      RxCRCBad                        : OUT std_logic;
      RxCRCOK                         : OUT std_logic;
      RxData                          : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

COMPONENT FILPKTBuilder IS 
PORT (
      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      txreset                         : IN  std_logic;
      bufferStatus                    : IN  std_logic_vector(3 DOWNTO 0);
      dataIn                          : IN  std_logic_vector(7 DOWNTO 0);
      dataInVld                       : IN  std_logic;
      dataEOP                         : IN  std_logic;
      dataLength                      : IN  std_logic_vector(12 DOWNTO 0);
      isStatus                        : IN  std_logic;
      TxReady                         : IN  std_logic;
      clearStatus                     : OUT std_logic;
      dataReq                         : OUT std_logic;
      TxData                          : OUT std_logic_vector(7 DOWNTO 0);
      TxDataValid                     : OUT std_logic;
      TxEOP                           : OUT std_logic;
      TxDataLength                    : OUT std_logic_vector(12 DOWNTO 0);
      TxSrcPort                       : OUT std_logic_vector(1 DOWNTO 0)
);
END COMPONENT;

COMPONENT FILSYNCBuffer IS 
GENERIC (BUFFERADDRWIDTH: integer := 12
);
PORT (
      reset                           : IN  std_logic;
      clearStatus                     : IN  std_logic;
      chif_txdclk                     : IN  std_logic;
      chif_txdata                     : IN  std_logic_vector(7 DOWNTO 0);
      chif_txdvld                     : IN  std_logic;
      chif_txdeop                     : IN  std_logic;
      chif_txsclk                     : IN  std_logic;
      chif_txstatus                   : IN  std_logic_vector(7 DOWNTO 0);
      chif_txsvld                     : IN  std_logic;
      chif_txseop                     : IN  std_logic;
      chif_rxdclk                     : IN  std_logic;
      chif_rxdrdy                     : IN  std_logic;
      chif_rxcclk                     : IN  std_logic;
      chif_rxcrdy                     : IN  std_logic;
      rxclk                           : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      RxData                          : IN  std_logic_vector(7 DOWNTO 0);
      RxDataValid                     : IN  std_logic;
      RxEOP                           : IN  std_logic;
      RxCRCOK                         : IN  std_logic;
      RxCRCBad                        : IN  std_logic;
      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      TxReady                         : IN  std_logic;
      bufferStatus                    : OUT std_logic_vector(3 DOWNTO 0);
      chif_txdrdy                     : OUT std_logic;
      chif_txsrdy                     : OUT std_logic;
      chif_rxdata                     : OUT std_logic_vector(7 DOWNTO 0);
      chif_rxdvld                     : OUT std_logic;
      chif_rxdeop                     : OUT std_logic;
      chif_rxcmd                      : OUT std_logic_vector(7 DOWNTO 0);
      chif_rxcvld                     : OUT std_logic;
      chif_rxceop                     : OUT std_logic;
      rxreset                         : OUT std_logic;
      txreset                         : OUT std_logic;
      TxData                          : OUT std_logic_vector(7 DOWNTO 0);
      TxDataValid                     : OUT std_logic;
      TxEOP                           : OUT std_logic;
      TxDataLength                    : OUT std_logic_vector(12 DOWNTO 0);
      TxStatus                        : OUT std_logic
);
END COMPONENT;

COMPONENT MWChIf IS 
GENERIC (DUT_INPUT_DATAWIDTH: integer := 8;
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
END COMPONENT;

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
  SIGNAL status                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL statusvld                        : std_logic; -- boolean
  SIGNAL statuseop                        : std_logic; -- boolean
  SIGNAL statuslen                        : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL statusRdy                        : std_logic; -- boolean
  SIGNAL txdata                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL txdatavld                        : std_logic; -- boolean
  SIGNAL dataeop                          : std_logic; -- boolean
  SIGNAL datalen                          : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL txrdy                            : std_logic; -- boolean
  SIGNAL rxdata                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL rxdvld                           : std_logic; -- boolean
  SIGNAL rxdeop                           : std_logic; -- boolean
  SIGNAL rxdrdy                           : std_logic; -- boolean
  SIGNAL rxdrdy_tmp                       : std_logic; -- boolean
  SIGNAL rxBufferStatus                   : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL txBufferStatus                   : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL tmpBufferStatus                  : std_logic_vector(3 DOWNTO 0); -- std4
  SIGNAL rxreset_sync                     : std_logic; -- boolean
  SIGNAL txreset_sync                     : std_logic; -- boolean
  SIGNAL shftOutReg                       : std_logic; -- boolean
  SIGNAL rxRdy                            : std_logic; -- boolean
  SIGNAL simCycle                         : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL simMode                          : std_logic; -- boolean
  SIGNAL txDataLength                     : std_logic_vector(15 DOWNTO 0); -- std16
  SIGNAL rxEOPAck                         : std_logic; -- boolean
  SIGNAL updateSimCycle                   : std_logic; -- boolean
  SIGNAL unPackDone                       : std_logic; -- boolean

BEGIN

u_MWAJTAG: MWAJTAG 
PORT MAP(
        TxEOP                => mac_txeop,
        RxDataValid          => mac_rxvld,
        RxEOP                => mac_rxeop,
        TxData               => mac_txdata,
        TxReady              => mac_txrdy,
        TxDataLength         => mac_txdatalength,
        RxCRCBad             => mac_rxcrcbad,
        TxDataValid          => mac_txvld,
        CLK125               => CLK125,
        RxCRCOK              => mac_rxcrcok,
        RxData               => mac_rxdata
);

u_FILPKTBuilder: FILPKTBuilder 
PORT MAP(
        txclk                => CLK125,
        txclk_en             => txclk_en,
        txreset              => mac_txreset,
        bufferStatus         => bufferStatus,
        clearStatus          => clearStatus,
        dataIn               => pkt_txdata,
        dataInVld            => pkt_txvld,
        dataEOP              => pkt_txeop,
        dataLength           => pkt_txdatalength,
        dataReq              => pkt_txrdy,
        isStatus             => pkt_txstatus,
        TxData               => mac_txdata,
        TxDataValid          => mac_txvld,
        TxReady              => mac_txrdy,
        TxEOP                => mac_txeop,
        TxDataLength         => mac_txdatalength,
        TxSrcPort            => mac_txsrcport
);

u_FILSYNCBuffer: FILSYNCBuffer 
GENERIC MAP (BUFFERADDRWIDTH => 12
)
PORT MAP(
        reset                => reset,
        bufferStatus         => bufferStatus,
        clearStatus          => clearStatus,
        chif_txdclk          => txdclk,
        chif_txdata          => chif_txdata,
        chif_txdvld          => chif_txdvld,
        chif_txdeop          => chif_txdeop,
        chif_txdrdy          => chif_txdrdy,
        chif_txsclk          => txsclk,
        chif_txstatus        => busIf_status,
        chif_txsvld          => busIf_statusVld,
        chif_txseop          => busIf_statusEOP,
        chif_txsrdy          => busIf_txsRdy,
        chif_rxdclk          => rxdclk,
        chif_rxdata          => chif_rxdata,
        chif_rxdvld          => chif_rxdvld,
        chif_rxdeop          => chif_rxdeop,
        chif_rxdrdy          => chif_rxdrdy,
        chif_rxcclk          => rxcclk,
        chif_rxcmd           => chif_rxcmd,
        chif_rxcvld          => chif_rxcvld,
        chif_rxceop          => chif_rxdeop_1,
        chif_rxcrdy          => chif_rxdrdy_1,
        rxclk                => CLK125,
        rxclk_en             => rxclk_en,
        rxreset              => mac_rxreset,
        RxData               => mac_rxdata,
        RxDataValid          => mac_rxvld,
        RxEOP                => mac_rxeop,
        RxCRCOK              => mac_rxcrcok,
        RxCRCBad             => mac_rxcrcbad,
        txclk                => CLK125,
        txclk_en             => txclk_en,
        txreset              => mac_txreset,
        TxData               => pkt_txdata,
        TxDataValid          => pkt_txvld,
        TxReady              => pkt_txrdy,
        TxEOP                => pkt_txeop,
        TxDataLength         => pkt_txdatalength,
        TxStatus             => pkt_txstatus
);

u_MWChIf: MWChIf 
GENERIC MAP (DUT_INPUT_DATAWIDTH => 16,
DUT_OUTPUT_DATAWIDTH => 16,
COUPLE_RXTX => '1'
)
PORT MAP(
        txdclk               => txdclk,
        txsclk               => txsclk,
        rxdclk               => rxdclk,
        rxcclk               => rxcclk,
        txdrst               => reset,
        rxdrst               => reset,
        sys_rst              => reset,
        chif_rxdata          => chif_rxdata,
        chif_rxdvld          => chif_rxdvld,
        chif_rxdeop          => chif_rxdeop,
        chif_rxdrdy          => chif_rxdrdy,
        chif_rxcmd           => chif_rxcmd,
        chif_rxcvld          => chif_rxcvld,
        chif_rxceop          => chif_rxdeop_1,
        chif_rxcrdy          => chif_rxdrdy_1,
        chif_txdata          => chif_txdata,
        chif_txdvld          => chif_txdvld,
        chif_txdeop          => chif_txdeop,
        chif_txdrdy          => chif_txdrdy,
        chif_cmd             => busIf_cmd,
        chif_cmdvld          => busIf_cmdVld,
        chif_cmdrdy          => busIf_cmdProcRdy,
        chif_datafromdut     => dut_dout,
        chif_datafromdutvld  => dut_doutvld,
        chif_datatodut       => dut_din,
        chif_dutenb          => dut_dinvld,
        chif_NOPcmd          => NOPcmd,
        tx_stream_en         => tx_stream_en
);


END;
