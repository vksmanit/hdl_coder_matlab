
-- ----------------------------------------------
-- File Name: MWTXBuffer.vhd
-- Created:   08-Feb-2018 10:01:13
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MWTXBuffer IS
GENERIC (BUFFERADDRWIDTH: INTEGER :=   12;
         PACKETADDRWIDTH: INTEGER :=    3;
         MAXPKTLEN      : INTEGER := 1467);
  PORT(
        
        txclk                             :   IN    std_logic;
        txclk_en                          :   IN    std_logic;
        txreset                           :   OUT   std_logic;
        -------------------------------------------------------------------
        forceTxEOP                        :   IN    std_logic;
        bufferStatus                      :   OUT   std_logic_vector(1 DOWNTo 0);
        clearStatus                       :   IN    std_logic;
        -----------------------------------------------------------------------
        chif_reset                        :   IN    std_logic;
        chif_txclk                        :   IN    std_logic;
        ChIf_txeop                        :   IN    std_logic;
        ChIf_txdata                       :   IN    std_logic_vector(7 DOWNTO 0);  
        ChIf_txvld                        :   IN    std_logic;
        ChIf_txrdy                        :   OUT   std_logic;
        -----------------------------------------------------------------------
        TxData                            :   OUT   std_logic_vector(7 DOWNTO 0);  
        TxDataValid                       :   OUT   std_logic;
        TxReady                           :   IN    std_logic;
        TxEOP                             :   OUT   std_logic;
        TxDataLength                      :   OUT   std_logic_vector(12 DOWNTO 0)
        );
END MWTXBuffer;


ARCHITECTURE rtl OF MWTXBuffer IS

  -- Component Declarations

  COMPONENT MWDPRAM
    GENERIC (
      DATAWIDTH : INTEGER;
      ADDRWIDTH : INTEGER);
    PORT (
      clkA     : IN  std_logic;
      enbA     : IN  std_logic;
      wr_dinA  : IN  std_logic_vector(DATAWIDTH-1 DOWNTO 0);
      wr_addrA : IN  std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
      wr_enA   : IN  std_logic;
      clkB     : IN  std_logic;
      enbB     : IN  std_logic;
      rd_addrB : IN  std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
      rd_doutB : OUT std_logic_vector(DATAWIDTH-1 DOWNTO 0));
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : MWDPRAM
    USE ENTITY work.MWDPRAM(rtl);

  TYPE BufferType   IS ARRAY (integer range <>) OF unsigned(BUFFERADDRWIDTH downto 0);
  TYPE EOP_STATE_TYPE IS (EOP_IDLE_STATE, EOP_WAIT4EOP_STATE, EOP_WAIT4EOPSYNC_STATE);
  
  CONSTANT ALLONE        : unsigned(BUFFERADDRWIDTH downto 0) := (OTHERS => '1');
  CONSTANT FULLWATERMARK : integer := (2**BUFFERADDRWIDTH) - 8;

  CONSTANT TXEOP_CNTMAX : UNSIGNED(PACKETADDRWIDTH-1 DOWNTO 0) := (OTHERS => '1');  -- max counter value

  -- Signals
  signal eop_state        : EOP_STATE_TYPE;
  signal txwrdata         : std_logic_vector(7 downto 0);  
  signal txwraddr         : unsigned(BUFFERADDRWIDTH downto 0); 
  signal txwraddr_sync0   : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_gray1   : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_gray2   : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_gray3   : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_bin     : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_sync    : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_syncdly : unsigned(BUFFERADDRWIDTH downto 0);
  signal txwraddr_syncdly1: unsigned(BUFFERADDRWIDTH downto 0);
  signal txrdaddr         : unsigned(BUFFERADDRWIDTH downto 0);  
  signal TxRAM_PortB      : std_logic_vector(7 downto 0);  
  signal newAddrBuffer    : BufferType(PACKETADDRWIDTH DOWNTO 0);
  signal EOPAddr1         : unsigned(BUFFERADDRWIDTH downto 0);
  signal EOPAddrVld       : std_logic_vector(PACKETADDRWIDTH DOWNTO 0);
  signal EOPReached       : std_logic;
  signal wrapAroundCond   : std_logic;
  signal dataLength       : unsigned(BUFFERADDRWIDTH DOWNTO 0);
  signal newAddr          : unsigned(BUFFERADDRWIDTH+1 downto 0);
  signal newAddrFlag      : std_logic;
  signal txeop_sync       : std_logic;
  signal txeop_sync0      : std_logic;
  signal txeop_sync1      : std_logic;
  signal txeop_sync2      : std_logic;
  signal txeop_sync3      : std_logic;
  signal txeop_sync4      : std_logic;
  signal txeop_sync5      : std_logic;
  signal txeop_sync6      : std_logic;
  signal txeop_cnt        : unsigned(PACKETADDRWIDTH-1 DOWNTO 0);
  signal txrdy_tmp        : std_logic;
  signal txrdy_tmp1       : std_logic;
  signal FullFlag         : std_logic;
  signal forceEOP         : std_logic;
  SIGNAL reset_sync1      : std_logic;
  SIGNAL reset_sync2      : std_logic;

 
BEGIN

--*************************************************************************  
--************************************************************************* 
---------------------------------------------------------------------------
-- Receiving data from chif and transmit it o Media Interface (MAC, pci, etc).
---------------------------------------------------------------------------
--*************************************************************************
  tx_dpram: MWDPRAM
    GENERIC MAP (
      DATAWIDTH => 8,
      ADDRWIDTH => BUFFERADDRWIDTH)
    PORT MAP (
      clkA     => chif_txclk,
      enbA     => '1',
      wr_dinA  => txwrdata,
      wr_addrA => std_logic_vector(txwraddr(BUFFERADDRWIDTH - 1 downto 0)),
      wr_enA   => ChIf_txvld,
      clkB     => txclk,
      enbB     => txclk_en,
      rd_addrB => std_logic_vector(txrdaddr(BUFFERADDRWIDTH - 1  downto 0)),
      rd_doutB => TxRAM_PortB
      );
 
  -- Reset Synchronization
  reset_proc: PROCESS (txclk)
  BEGIN  -- PROCESS reset_proc
    IF txclk'event AND txclk = '1' THEN  -- rising clock edge
      reset_sync1 <= chif_reset;
      reset_sync2 <= reset_sync1;
    END IF;
  END PROCESS reset_proc;

  txreset <= reset_sync2;

  -- ChIf interface CLK domain --------------------------------------------
  txwrdata <= ChIf_txdata;
  txwraddr_process : PROCESS (chif_txclk, chif_reset)
  BEGIN
    IF chif_reset = '1' THEN
      txwraddr       <= to_unsigned(0, BUFFERADDRWIDTH + 1 );
      txwraddr_sync0 <= to_unsigned(0, BUFFERADDRWIDTH + 1 );
      txeop_sync1    <= '0';
    ELSIF chif_txclk'EVENT AND chif_txclk = '1' THEN
      if ChIf_txvld = '1' then
         txwraddr       <= txwraddr + 1;
         txwraddr_sync0 <= resize((txwraddr + 1), BUFFERADDRWIDTH + 1);
      end if;
      txeop_sync1    <= ChIf_txeop;
      --txeop_sync1    <= txeop_sync0;
    END IF;
  END PROCESS txwraddr_process;

  bin2gray_proc3: process (chif_txclk, chif_reset)
  begin 
    if chif_reset = '1' then
       txwraddr_gray1 <= (others => '0');
       txeop_sync2    <= '0';
    elsif chif_txclk'event and chif_txclk = '1' then
       txeop_sync2        <= txeop_sync1;
       txwraddr_gray1(txwraddr_gray1'LEFT) <= txwraddr_sync0(txwraddr_sync0'LEFT);
       txwraddr_gray1(txwraddr_gray1'LEFT-1 DOWNTO 0) <= txwraddr_sync0(txwraddr_sync0'LEFT DOWNTO 1)
                                                         XOR
                                                         txwraddr_sync0(txwraddr_sync0'LEFT-1 DOWNTO 0);
    end if;
  end process bin2gray_proc3;

  bin2gray_proc4: process (txclk)
  begin 
    if txclk'event and txclk = '1' then
     if reset_sync2 = '1' then
       txwraddr_gray2 <= (others => '0');
       txwraddr_gray3 <= (others => '0');
       txeop_sync3    <= '0';
       txeop_sync4    <= '0';
		  elsif txclk_en='1' then
       txwraddr_gray2     <= txwraddr_gray1;
       txwraddr_gray3     <= txwraddr_gray2;
       txeop_sync3        <= txeop_sync2;
       txeop_sync4        <= txeop_sync3;
    end if;
   end if;
  end process bin2gray_proc4;

  txwraddr_bin(txwraddr_bin'LEFT) <= txwraddr_gray3(txwraddr_gray3'LEFT);
  txwraddr_bin(txwraddr_bin'LEFT-1 DOWNTO 0) <= txwraddr_bin(txwraddr_bin'LEFT DOWNTO 1)
                                                XOR
                                                txwraddr_gray3(txwraddr_gray3'LEFT-1 DOWNTO 0);

---- TXCLK (125 MHz) clock domain -----------------------------------------
  gray3bin_proc3:process(txclk)
  begin
   if txclk'event and txclk = '1' then
     if reset_sync2 = '1' then
       txwraddr_sync     <= (others => '0');
       txwraddr_syncdly  <= (others => '0');
       txwraddr_syncdly1 <= (others => '0');
       txeop_sync5       <= '0';
       txeop_sync6       <= '0';
       txeop_sync        <= '0';
		  elsif txclk_en = '1' then
       txwraddr_sync     <= resize(txwraddr_bin, BUFFERADDRWIDTH+1);
       txwraddr_syncdly  <= txwraddr_sync;
       txwraddr_syncdly1 <= txwraddr_syncdly;
       txeop_sync5       <= txeop_sync4;
       txeop_sync6       <= txeop_sync5;
       txeop_sync        <= txeop_sync6;
    end if;
   end if;
  end process gray3bin_proc3;

---- Buffering EOP address and txeop signal -------------------------------
process(txclk)
  begin
   if txclk'event and txclk = '1' then 
    if reset_sync2 = '1' then
      newAddr     <= (others => '0');
      newAddrFlag <= '0'; 
      txeop_cnt   <= to_unsigned(0, PACKETADDRWIDTH);
      eop_state   <= EOP_IDLE_STATE;
			 elsif  txclk_en = '1' then
     case eop_state is
       when EOP_IDLE_STATE =>
          newAddrFlag <= '0'; 
          txeop_cnt   <= to_unsigned(0, PACKETADDRWIDTH);
          eop_state   <= EOP_IDLE_STATE;
          if txeop_sync = '1' then -- We need to wait and make sure that data is stable
             txeop_cnt <= txeop_cnt + to_unsigned(1, PACKETADDRWIDTH);
             eop_state <= EOP_WAIT4EOP_STATE;
          elsif (newAddr(BUFFERADDRWIDTH downto 0) /= txwraddr_syncdly1) then
             newAddr     <= '0' & txwraddr_syncdly1; -- EOP flag & addr.
             newAddrFlag <= '1';
          end if;
       when EOP_WAIT4EOP_STATE =>
          if txeop_cnt = to_unsigned(1, PACKETADDRWIDTH) then
             newAddr     <= '1' & txwraddr_syncdly1; -- EOP flag & addr.
             newAddrFlag <= '1';
          else 
             newAddrFlag <= '0';
          end if;
          txeop_cnt <=  txeop_cnt + to_unsigned(1, PACKETADDRWIDTH);
          if txeop_cnt = TXEOP_CNTMAX then
             eop_state <= EOP_WAIT4EOPSYNC_STATE;
             txeop_cnt   <= to_unsigned(0, PACKETADDRWIDTH);
          end if;  
       when EOP_WAIT4EOPSYNC_STATE =>
          eop_state <= EOP_WAIT4EOPSYNC_STATE;
          if txeop_sync = '0' then
             eop_state <= EOP_IDLE_STATE;
          end if;  
       when others =>
          newAddr     <= (others => '0');
          newAddrFlag <= '0'; 
          txeop_cnt   <= to_unsigned(0, PACKETADDRWIDTH);
          eop_state   <= EOP_IDLE_STATE;
     end case;
    end if;
   end if;
end process;

process(txclk)
  begin
   if txclk'event and txclk = '1' then
    if reset_sync2 = '1' then
      newAddrBuffer   <= (others => (others => '0'));
      EOPAddrVld      <= (others => '0'); 
			 elsif  txclk_en = '1' then
      if (newAddrFlag = '1') AND (EOPAddrVld(0) = '0')  then
         newAddrBuffer(0) <= newAddr(BUFFERADDRWIDTH downto 0);
         EOPAddrVld(0)    <= newAddr(BUFFERADDRWIDTH + 1);
     elsif (EOPAddrVld(1) = '0') then -- The address will move to next location in next cycle.
         EOPAddrVld(0)    <= '0';   
     end if;
-------------------------------------------------------------------------------
     Shift1: FOR k IN (PACKETADDRWIDTH-1) DOWNTO 1 LOOP
       IF EOPAddrVld(k) = '0' THEN
         newAddrBuffer(k) <= newAddrBuffer(k-1);
         EOPAddrVld(k)    <= EOPAddrVld(k-1);
       ELSIF EOPAddrVld(k+1) = '0' THEN
         EOPAddrVld(k)    <= '0';
       END IF;
     END LOOP Shift1;
-------------------------------------------------------------------------------
     if (forceEOP = '0') then
       if (EOPReached = '1') then
          newAddrBuffer(newAddrBuffer'LEFT) <= newAddrBuffer(newAddrBuffer'LEFT-1); 
          EOPAddrVld(EOPAddrVld'LEFT)    <= EOPAddrVld(EOPADDRVld'LEFT-1);
          if newAddrBuffer(newAddrBuffer'LEFT) = newAddrBuffer(newAddrBuffer'LEFT-1) then
            EOPAddrVld(EOPAddrVld'LEFT)    <= '0';
          end if;
       elsif (EOPAddrVld(EOPAddrVld'LEFT) = '0') then
          newAddrBuffer(newAddrBuffer'LEFT) <= newAddrBuffer(newAddrBuffer'LEFT-1); 
          EOPAddrVld(EOPAddrVld'LEFT)    <= EOPAddrVld(EOPAddrVld'LEFT-1);
       end if;
     else
       EOPAddrVld(EOPAddrVld'LEFT) <= forceEOP;
     end if;
    end if;
   end if;
  end process;

---------------------------------------------------------------------------
  process(txclk)
  begin
   if txclk'event and txclk = '1' then
    if reset_sync2 = '1' then
      TxDataValid <= '0';
      txrdaddr    <= ( others => '0');
    elsif  txclk_en = '1' then
      TxDataValid <= TxReady;
      if TxReady = '1' AND dataLength > 0 then
         txrdaddr  <= txrdaddr + 1;
      end if;
    end if;
   end if;
  end process;

  process(dataLength, forceTxEOP)
  begin
    forceEOP <= '0';
    if forceTxEOP = '1' and resize(dataLength, BUFFERADDRWIDTH+1) = to_unsigned(MAXPKTLEN, BUFFERADDRWIDTH+1) then
       forceEOP <= '1';
    end if;
  end process;

  EOPAddr1   <= newAddrBuffer(newAddrBuffer'LEFT);
  EOPReached <= '1' when EOPAddr1 = txrdaddr else
                '0';
   
  wrapAroundCond <= (txrdaddr(BUFFERADDRWIDTH) AND (NOT EOPAddr1(BUFFERADDRWIDTH)));
  dataLength     <= (EOPAddr1 + to_unsigned(1, BUFFERADDRWIDTH) + (ALLONE - txrdaddr)) when wrapAroundCond = '1' else
                  ((EOPAddr1) - txrdaddr);
 
--- OUTPUT signals --------------------------------------------------------
  TxData <= TxRAM_PortB(7 DOWNTO 0);

  TxEOP  <= EOPAddrVld(PACKETADDRWIDTH);

  TxDataLength <= std_logic_vector(resize(dataLength,13));

  FullFlag <= '0' when dataLength <= to_unsigned(FULLWATERMARK, BUFFERADDRWIDTH + 1) else
              '1';

process(txclk)
begin
  if txclk'event and txclk = '1' then
   if reset_sync2 = '1' then
     bufferStatus <= (others => '0');
   elsif  txclk_en = '1' then
     bufferStatus(1) <= '0';            --always zero?
     if FullFlag = '1' and newAddrFlag = '1' then
        bufferStatus(0) <= '1'; 
     elsif clearStatus = '1' then
        bufferStatus(0) <= '0';
     end if;
   end if;
  end if;
end process;

process(txclk)
  begin
   if txclk'event and txclk = '1' then
    if reset_sync2 = '1' then
      txrdy_tmp  <= '0';
    elsif  txclk_en = '1' then
      txrdy_tmp  <= NOT FullFlag;
    end if;
   end if;
  end process;

-- Sync the txrdy to slow clk domain 'clk'---
  process(chif_txclk, chif_reset)
  begin
   if chif_reset = '1' then
     txrdy_tmp1  <= '0';
     ChIf_txrdy  <= '0';
   elsif chif_txclk'event and chif_txclk = '1' then
     txrdy_tmp1 <= txrdy_tmp;
     ChIf_txrdy <= txrdy_tmp1;
   end if;
  end process;
END rtl;

