
-- ----------------------------------------------
-- File Name: FILSYNCBuffer.vhd
-- Created:   08-Feb-2018 10:01:13
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY FILSYNCBuffer IS 
GENERIC (
         BUFFERADDRWIDTH: integer := 12
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
END FILSYNCBuffer;

ARCHITECTURE rtl of FILSYNCBuffer IS

COMPONENT MWRXBuffer IS 
GENERIC (BUFFERADDRWIDTH: integer := 12;
OVERFLOWMARGIN: integer := 0;
ISSDRDATABUFFER: integer := 0
);
PORT (
      rxclk                           : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      chif_reset                      : IN  std_logic;
      chif_rxclk                      : IN  std_logic;
      chif_rxrdy                      : IN  std_logic;
      RxData                          : IN  std_logic_vector(7 DOWNTO 0);
      RxDataValid                     : IN  std_logic;
      RxEOP                           : IN  std_logic;
      RxCRCOK                         : IN  std_logic;
      RxCRCBad                        : IN  std_logic;
      rxreset                         : OUT std_logic;
      bufferStatus                    : OUT std_logic_vector(7 DOWNTO 0);
      chif_rxdata                     : OUT std_logic_vector(7 DOWNTO 0);
      chif_rxvld                      : OUT std_logic;
      chif_rxeop                      : OUT std_logic
);
END COMPONENT;

COMPONENT MWTXBuffer IS 
GENERIC (BUFFERADDRWIDTH: integer := 12;
MAXPKTLEN: integer := 1467
);
PORT (
      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      forceTxEOP                      : IN  std_logic;
      clearStatus                     : IN  std_logic;
      chif_reset                      : IN  std_logic;
      chif_txclk                      : IN  std_logic;
      chif_txeop                      : IN  std_logic;
      chif_txdata                     : IN  std_logic_vector(7 DOWNTO 0);
      chif_txvld                      : IN  std_logic;
      TxReady                         : IN  std_logic;
      txreset                         : OUT std_logic;
      bufferStatus                    : OUT std_logic_vector(1 DOWNTO 0);
      chif_txrdy                      : OUT std_logic;
      TxData                          : OUT std_logic_vector(7 DOWNTO 0);
      TxDataValid                     : OUT std_logic;
      TxEOP                           : OUT std_logic;
      TxDataLength                    : OUT std_logic_vector(12 DOWNTO 0)
);
END COMPONENT;

COMPONENT MWArbiter IS 
PORT (
      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      txreset                         : IN  std_logic;
      status                          : IN  std_logic_vector(7 DOWNTO 0);
      statusvld                       : IN  std_logic;
      statuseop                       : IN  std_logic;
      statuslen                       : IN  std_logic_vector(12 DOWNTO 0);
      data                            : IN  std_logic_vector(7 DOWNTO 0);
      datavld                         : IN  std_logic;
      dataeop                         : IN  std_logic;
      datalen                         : IN  std_logic_vector(12 DOWNTO 0);
      TxReady                         : IN  std_logic;
      statustx                        : OUT std_logic;
      datatx                          : OUT std_logic;
      TxData                          : OUT std_logic_vector(7 DOWNTO 0);
      TxDataValid                     : OUT std_logic;
      TxEOP                           : OUT std_logic;
      TxDataLength                    : OUT std_logic_vector(12 DOWNTO 0);
      TxStatus                        : OUT std_logic
);
END COMPONENT;

  SIGNAL status                           : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL statusvld                        : std_logic; -- boolean
  SIGNAL statuseop                        : std_logic; -- boolean
  SIGNAL statuslen                        : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL statusRdy                        : std_logic; -- boolean
  SIGNAL txdata_1                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL txdatavld                        : std_logic; -- boolean
  SIGNAL dataeop                          : std_logic; -- boolean
  SIGNAL datalen                          : std_logic_vector(12 DOWNTO 0); -- std13
  SIGNAL txrdy                            : std_logic; -- boolean
  SIGNAL rxdata_1                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL rxdvld                           : std_logic; -- boolean
  SIGNAL rxdeop                           : std_logic; -- boolean
  SIGNAL rxdrdy                           : std_logic; -- boolean
  SIGNAL rxdrdy_tmp                       : std_logic; -- boolean
  SIGNAL rxBufferStatus                   : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL txBufferStatus                   : std_logic_vector(1 DOWNTO 0); -- std2
  SIGNAL tmpBufferStatus                  : std_logic_vector(3 DOWNTO 0); -- std4
  SIGNAL rxreset_sync                     : std_logic; -- boolean
  SIGNAL txreset_sync                     : std_logic; -- boolean

BEGIN

u_MWRXDataBuffer: MWRXBuffer 
GENERIC MAP (BUFFERADDRWIDTH => BUFFERADDRWIDTH,
OVERFLOWMARGIN => 0,
ISSDRDATABUFFER => 0
)
PORT MAP(
        rxclk                => rxclk,
        rxclk_en             => rxclk_en,
        rxreset              => rxreset_sync,
        bufferStatus         => OPEN,
        chif_reset           => reset,
        chif_rxclk           => chif_rxdclk,
        chif_rxdata          => rxdata_1,
        chif_rxvld           => rxdvld,
        chif_rxeop           => rxdeop,
        chif_rxrdy           => rxdrdy,
        RxData               => RxData,
        RxDataValid          => RxDataValid,
        RxEOP                => RxEOP,
        RxCRCOK              => RxCRCOK,
        RxCRCBad             => RxCRCBad
);

u_MWTXDataBuffer: MWTXBuffer 
GENERIC MAP (BUFFERADDRWIDTH => BUFFERADDRWIDTH,
MAXPKTLEN => 1467
)
PORT MAP(
        txclk                => txclk,
        txclk_en             => txclk_en,
        txreset              => txreset_sync,
        forceTxEOP           => '0',
        bufferStatus         => txBufferStatus,
        clearStatus          => clearStatus,
        chif_reset           => reset,
        chif_txclk           => chif_txdclk,
        chif_txeop           => chif_txdeop,
        chif_txdata          => chif_txdata,
        chif_txvld           => chif_txdvld,
        chif_txrdy           => chif_txdrdy,
        TxData               => txdata_1,
        TxDataValid          => txdatavld,
        TxReady              => txrdy,
        TxEOP                => dataeop,
        TxDataLength         => datalen
);

u_MWStatusBuffer: MWTXBuffer 
GENERIC MAP (BUFFERADDRWIDTH => 6,
MAXPKTLEN => 64
)
PORT MAP(
        txclk                => txclk,
        txclk_en             => txclk_en,
        txreset              => OPEN,
        forceTxEOP           => '0',
        bufferStatus         => OPEN,
        clearStatus          => '0',
        chif_reset           => reset,
        chif_txclk           => chif_txsclk,
        chif_txeop           => chif_txseop,
        chif_txdata          => chif_txstatus,
        chif_txvld           => chif_txsvld,
        chif_txrdy           => chif_txsrdy,
        TxData               => status,
        TxDataValid          => statusvld,
        TxReady              => statusRdy,
        TxEOP                => statuseop,
        TxDataLength         => statuslen
);

u_FILArbiter: MWArbiter 
PORT MAP(
        txclk                => txclk,
        txclk_en             => txclk_en,
        txreset              => txreset_sync,
        status               => status,
        statusvld            => statusvld,
        statuseop            => statuseop,
        statuslen            => statuslen,
        statustx             => statusRdy,
        data                 => txdata_1,
        datavld              => txdatavld,
        dataeop              => dataeop,
        datalen              => datalen,
        datatx               => txrdy,
        TxData               => TxData,
        TxDataValid          => TxDataValid,
        TxReady              => TxReady,
        TxEOP                => TxEOP,
        TxDataLength         => TxDataLength,
        TxStatus             => TxStatus
);

chif_rxdata <= rxdata_1;
chif_rxcmd <= rxdata_1;
chif_rxdvld <= rxdvld;

chif_rxcvld <= rxdvld;

chif_rxdeop <= rxdeop;

chif_rxceop <= rxdeop;

rxdrdy <= rxdrdy_tmp;

rxdrdy_tmp <= chif_rxdrdy AND chif_rxcrdy;
rxBufferStatus <= (others => '0');
bufferStatus <= rxBufferStatus & txBufferStatus;
rxreset <= rxreset_sync;

txreset <= txreset_sync;


END;
