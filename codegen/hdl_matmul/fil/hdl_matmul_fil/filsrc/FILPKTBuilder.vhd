
-- ----------------------------------------------
-- File Name: FILPKTBuilder.vhd
-- Created:   08-Feb-2018 10:01:12
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY FILPKTBuilder IS 
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
END FILPKTBuilder;

ARCHITECTURE rtl of FILPKTBuilder IS

  type FILPKT_STATE_TYPE is (PKT_IDLE_STATE, PKT_STATUSWAIT_STATE, PKT_STATUSPKT_STATE, PKT_DATAPKT_WAIT_STATE,PKT_DATAPKT_HEADER_STATE, PKT_DATAPKT_WAIT4DATA_STATE, PKT_DATAPKT_PAYLOAD_STATE);
  CONSTANT DATA_HEADER_LENGTH             : integer := 5; 
  SIGNAL pkt_state                        : FILPKT_STATE_TYPE; 
  SIGNAL dataHeader                       : std_logic_vector(39 downto 0); 
  SIGNAL dataHeaderReg                    : std_logic_vector(39 downto 0); 
  SIGNAL seqNumber                        : unsigned(15 downto 0); 
  SIGNAL incSeqNumber                     : std_logic; 
  SIGNAL waitCycle                        : unsigned(6 downto 0); 
  SIGNAL dataReq_tmp                      : std_logic; 

BEGIN

 dataHeader(39 downto 32)   <= X"00";
 dataHeader(31 downto 24)  <= std_logic_vector(seqNumber(7 downto 0));
 dataHeader(23 downto 16) <= std_logic_vector(seqNumber(15 downto 8));
 dataHeader(15 downto 12) <= (others => '0');
 dataHeader(11 downto 8) <= bufferStatus;
 dataHeader(7 downto 0) <= (others => '0');
 process (txclk)
  begin
   if txclk'event and txclk = '1' then
     if txreset = '1' then
      pkt_state <= PKT_IDLE_STATE;
      TxDataValid <= '0';
      TxData      <= (others => '0');
      incSeqNumber <= '0';
      waitCycle    <= (others => '0');
      dataReq_tmp  <= '0';
      dataHeaderReg <= dataHeader;
      clearStatus    <= '0';
     elsif txclk_en = '1' then
       TxEOP        <= dataEOP;
       TxDataLength <= std_logic_vector(unsigned(dataLength) + to_unsigned(DATA_HEADER_LENGTH,13));
       if isStatus = '1' then
          TxDataLength <= dataLength;
       end if;
       case pkt_state is
          when PKT_IDLE_STATE => 
             pkt_state    <= PKT_IDLE_STATE;
             waitCycle    <= (others => '0');
             dataReq_tmp  <= '0';
             dataHeaderReg <= dataHeader;
             if TxReady = '1' then
                if isStatus = '1' then
                   pkt_state   <= PKT_STATUSWAIT_STATE;
                   dataReq_tmp <= TxReady;
                else
                   pkt_state <= PKT_DATAPKT_WAIT_STATE;
                   incSeqNumber  <= '1';
                   dataReq_tmp   <= '0';
                   dataHeaderReg <= dataHeader;
                   clearStatus    <= '1';
                end if;
             end if;
          when PKT_STATUSWAIT_STATE =>
             TxDataValid <= dataInVld;
             dataReq_tmp <= TxReady;
             if dataInVld = '1' then
                TxData      <= dataIn;
                pkt_state   <=  PKT_STATUSPKT_STATE;
             end if;
          when PKT_STATUSPKT_STATE =>
             TxDataValid <= dataInVld;
             dataReq_tmp <= TxReady;
             if dataInVld = '1' then
                TxData      <= dataIn;
             else
                pkt_state <=  PKT_IDLE_STATE;
             end if;
          when PKT_DATAPKT_WAIT_STATE =>
             incSeqNumber <= '0';
             waitCycle    <= waitCycle + 1;
             dataHeaderReg <= dataHeader;
             clearStatus    <= '0';
             if waitCycle = to_unsigned(3, 7) then
                pkt_state <=  PKT_DATAPKT_HEADER_STATE;
                TxDataValid <= '1';
                TxData      <= dataHeaderReg(39 downto 32);
                dataHeaderReg(39 downto 8) <= dataHeaderReg(31 downto 0 );
                dataHeaderReg( 7 downto 0) <=  (others => '0');
             end if;
          when PKT_DATAPKT_HEADER_STATE =>
             TxDataValid <= '1';
             TxData      <= dataHeaderReg(39 downto 32);
             dataHeaderReg(39 downto 8) <= dataHeaderReg(31 downto 0 );
             dataHeaderReg( 7 downto 0) <=  (others => '0');
             waitCycle    <= waitCycle + 1;
             if waitCycle = to_unsigned(4, 7) then
                dataReq_tmp <= TxReady;
                pkt_state   <=  PKT_DATAPKT_WAIT4DATA_STATE;
                waitCycle   <= to_unsigned(0, 7);
             end if;
          when PKT_DATAPKT_WAIT4DATA_STATE =>
             TxDataValid <= '1';
             TxData      <= dataHeaderReg(39 downto 32);
             dataHeaderReg(39 downto 8) <= dataHeaderReg(31 downto 0 );
             dataHeaderReg( 7 downto 0) <=  (others => '0');
             dataReq_tmp                <= TxReady;
             if dataInVld = '1' then
                pkt_state <=  PKT_DATAPKT_PAYLOAD_STATE;
                TxDataValid <= dataInVld;
               TxData      <= dataIn;
             end if;
          when PKT_DATAPKT_PAYLOAD_STATE =>
             dataReq_tmp <= TxReady;
             TxDataValid <= dataInVld;
             if dataInVld = '1' then
                TxData      <= dataIn;
             else
                pkt_state   <=  PKT_IDLE_STATE;
                dataReq_tmp <= '0';
             end if;
          when others =>
          pkt_state <= PKT_IDLE_STATE;
          TxDataValid <= '0';
          TxData      <= (others => '0');
          incSeqNumber <= '0';
          waitCycle    <= (others => '0');
          dataReq_tmp  <= '0';
          dataHeaderReg <= dataHeader;
          clearStatus    <= '0';
       end case;
     end if;
   end if;
  end process;

 process (txclk)
  begin
   if txclk'event and txclk = '1' then
     if txreset = '1' then
        seqNumber      <= (others => '0');
     elsif txclk_en = '1' and incSeqNumber = '1' then
        seqNumber <= seqNumber + 1;
     end if;
   end if;
  end process;

  dataReq <= dataReq_tmp;
  TxSrcPort <= (others => '0');

END;
