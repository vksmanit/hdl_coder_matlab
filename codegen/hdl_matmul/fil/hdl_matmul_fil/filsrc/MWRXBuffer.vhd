
-- ----------------------------------------------
-- File Name: MWRXBuffer.vhd
-- Created:   08-Feb-2018 10:01:13
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MWRXBuffer IS
GENERIC (BUFFERADDRWIDTH: INTEGER :=   12;
         OVERFLOWMARGIN: INTEGER :=   0;
         ISSDRDATABUFFER: INTEGER := 0);

  PORT(
        rxreset                           :   OUT   std_logic;
        rxclk                             :   IN    std_logic;
        rxclk_en                          :   IN    std_logic;
        -----------------------------------------------------------------------
        bufferStatus                      :   OUT   std_logic_vector(7 DOWNTO 0);
        ----------------------------------------------------------------------- 
        chif_reset                        :   IN    std_logic;
        chif_rxclk                        :   IN    std_logic;
        ChIf_rxrdy                        :   IN    std_logic;
        ChIf_rxdata                       :   OUT   std_logic_vector(7 DOWNTO 0);  
        ChIf_rxvld                        :   OUT   std_logic;
        ChIf_rxeop                        :   OUT   std_logic;
        -----------------------------------------------------------------------
        RxData                            :   IN    std_logic_vector(7 DOWNTO 0);  
        RxDataValid                       :   IN    std_logic;
        RxEOP                             :   IN    std_logic;
        RxCRCOK                           :   IN    std_logic;  
        RxCRCBad                          :   IN    std_logic
        );
END MWRXBuffer;


ARCHITECTURE rtl OF MWRXBuffer IS

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

  TYPE RAM2CHIFTYPE IS (RXRD_IDLE_STATE, RXRD_WAIT4RDY_STATE, RXRD_WAIT4VLD_STATE, RXRD_DATA_STATE);
  TYPE MAC2RAMTYPE  IS (RXWR_IDLE_STATE, RXWR_DATA_STATE, RXWR_CHECKCRC_STATE);
  TYPE RXPKTTYPE    IS (RXPKT_IDLE_STATE, RXPKT_NEW_STATE);
  TYPE BufferType   IS ARRAY (integer range <>) OF unsigned(BUFFERADDRWIDTH downto 0);
  
  CONSTANT ALLONE    : unsigned(BUFFERADDRWIDTH downto 0) := (OTHERS => '1');
  SIGNAL rxrd_state  : RAM2CHIFTYPE;
  SIGNAL rxwr_state  : MAC2RAMTYPE;
  SIGNAL rxpkt_state : RXPKTTYPE;

  -- Signals
  SIGNAL rxwrdata         : std_logic_vector(8 downto 0);
  SIGNAL rxwrfirstaddr    : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwrlastaddr     : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr         : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_eop     : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_reg     : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_gray1   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_gray2   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_gray3   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_bin     : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_bin1    : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_bin2    : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxwraddr_sync    : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxrdaddr         : unsigned(BUFFERADDRWIDTH downto 0);
  
  SIGNAL rxrddata         : std_logic_vector(8 downto 0);
  SIGNAL rxdpramEmpty     : std_logic;
  SIGNAL rxvld            : std_logic;
  SIGNAL rxDataSlice      : std_logic_vector(7 downto 0);  -- uint8
  SIGNAL rxEOPSlice       : std_logic;              -- ufix1

  SIGNAL reset_sync1      : std_logic;
  SIGNAL reset_sync2      : std_logic;
  
  -- add signals and constants for flow control
  SIGNAL rxrdaddr_gray1   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxrdaddr_gray2   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxrdaddr_gray3   : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL rxrdaddr_bin     : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL dataLen          : unsigned(BUFFERADDRWIDTH downto 0);
  SIGNAL ChIf_rxrdy_sync1 : std_logic;
  SIGNAL ChIf_rxrdy_sync2 : std_logic;
  SIGNAl fullFlag         : std_logic;
  SIGNAl fullFlagSDR      : std_logic;
  SIGNAL RxDataValid_delay: std_logic;
  SIGNAL RxDataValid_posedge : std_logic;
  SIGNAL RxDataStart      : std_logic;
  
  CONSTANT OVERFLOWMARK   : integer := (2**BUFFERADDRWIDTH) - 1; -- FULL
  CONSTANT HIGHMARK       : integer := (2**(BUFFERADDRWIDTH-1)) + (2**(BUFFERADDRWIDTH-2)); -- 3/4 FULL
  CONSTANT PRIMEMARK      : integer := (2**(BUFFERADDRWIDTH-1)); -- 1/2 FULL
  CONSTANT LOWMARK        : integer := (2**(BUFFERADDRWIDTH-1)) - (2**(BUFFERADDRWIDTH-2)); -- 1/4 FULL
  CONSTANT UNDERFLOWMARK  : integer := 0; -- EMPTY

  CONSTANT TRIGGERMARGIN  : integer := 256;
  CONSTANT HIGHMARKTRIGGER: integer := HIGHMARK -TRIGGERMARGIN; -- ready to trigger high mark 
  CONSTANT LOWMARKTRIGGER : integer := LOWMARK  +TRIGGERMARGIN; -- ready to trigger low mark

BEGIN

--*************************************************************************  
---------------------------------------------------------------------------
---- receiving data from Media Interface(MAC, pci, etc) and transmit it to ChIf.
--------------------------------------------------------------------------- 
--*************************************************************************
  rx_dpram: MWDPRAM
    GENERIC MAP (
      DATAWIDTH => 9,
      ADDRWIDTH => BUFFERADDRWIDTH)
    PORT MAP (
      clkA     => rxclk,
      enbA     => '1',
      wr_dinA  => rxwrdata,
      wr_addrA => std_logic_vector(rxwraddr(BUFFERADDRWIDTH - 1 downto 0)), 
      wr_enA   => RxDataValid,
      clkB     => chif_rxclk,
      enbB     => '1',
      rd_addrB => std_logic_vector(rxrdaddr(BUFFERADDRWIDTH - 1 downto 0)),
      rd_doutB => rxrddata);

 -- Reset Synchroniation
 reset_sync: PROCESS (rxclk)
  BEGIN  -- PROCESS reset_sync
    IF rxclk'event AND rxclk = '1' THEN  -- rising clock edge
		if rxclk_en = '1' then
      reset_sync1 <= chif_reset;
      reset_sync2 <= reset_sync1;
		end if;
    END IF;
  END PROCESS reset_sync;

  rxreset <= reset_sync2;

  -- MAC interface 125 MHz Clk---------------------------------------------
  rxwrdata <= RxEOP & RxData; 
  rxwr_fsm: process (rxclk)
  begin  -- process rxwraddr_process
   if rxclk'event and rxclk = '1' then  -- rising clock edge
    if reset_sync2 = '1' then
      rxwr_state    <= RXWR_IDLE_STATE;
      rxwraddr      <= to_unsigned(0, BUFFERADDRWIDTH + 1);
      rxwrfirstaddr <= to_unsigned(0, BUFFERADDRWIDTH + 1);
      rxwrlastaddr  <= to_unsigned(0, BUFFERADDRWIDTH + 1);
    elsif rxclk_en = '1' then
      case rxwr_state is
        when RXWR_IDLE_STATE =>
          if RxDataStart = '1' and fullFlag = '0' then -- if buffer full, no wr addr increment
            rxwraddr      <= rxwraddr + 1;
            rxwrfirstaddr <= rxwraddr;
            rxwr_state    <= RXWR_DATA_STATE;
          end if;
        when RXWR_DATA_STATE =>
          if RxDataValid = '1' then
            rxwraddr <= rxwraddr + 1;
            if RxEOP = '1' then
              rxwr_state <= RXWR_CHECKCRC_STATE;
            end if;
          end if;
        when RXWR_CHECKCRC_STATE =>
          if RxCRCOK = '1' then
            rxwrlastaddr <= rxwraddr;
            rxwr_state <= RXWR_IDLE_STATE;
          elsif RxCRCBAD = '1' then
            rxwraddr      <= rxwrfirstaddr;
            rxwr_state    <= RXWR_IDLE_STATE;
          end if;
        when others => 
          rxwr_state    <= RXWR_IDLE_STATE;
          rxwraddr      <= to_unsigned(0, BUFFERADDRWIDTH + 1);
          rxwrfirstaddr <= to_unsigned(0, BUFFERADDRWIDTH + 1);
          rxwrlastaddr  <= to_unsigned(0, BUFFERADDRWIDTH + 1);
      end case; 
    end if; 
   end if;
  end process rxwr_fsm;

  -- Sync the rxwradd to 'clk' domain ----------------------
  -- Binary to Gray
  
 process (rxclk)
  begin 
  if rxclk'event and rxclk = '1' then
   if reset_sync2 = '1' then
     rxwraddr_eop <= (others => '0');
     rxwraddr_reg <= (others => '0');
   elsif rxclk_en = '1' then
     if rxCRCOK = '1' then
        rxwraddr_reg <= rxwraddr;
     end if;
     rxwraddr_eop <= rxwraddr_reg;
   end if;
  end if;
 end process;

  bin2gray_proc1: process (rxclk)
  begin 
   if rxclk'event and rxclk = '1' then
    if reset_sync2 = '1' then
       rxwraddr_gray1 <= (others => '0');
    elsif rxclk_en = '1' then
      rxwraddr_gray1(rxwraddr_gray1'LEFT) <= rxwraddr_eop(rxwraddr_eop'LEFT);
      rxwraddr_gray1(rxwraddr_gray1'LEFT-1 DOWNTO 0) <= rxwraddr_eop(rxwraddr_eop'LEFT   DOWNTO 1) XOR
                                                        rxwraddr_eop(rxwraddr_eop'LEFT-1 DOWNTO 0);
    end if;
   end if;
  end process bin2gray_proc1;

  bin2gray_proc2: process (chif_rxclk, chif_reset)
  begin 
    if chif_reset = '1' then
       rxwraddr_gray2 <= (others => '0');
       rxwraddr_gray3 <= (others => '0');
    elsif chif_rxclk'event and chif_rxclk = '1' then
       rxwraddr_gray2     <= rxwraddr_gray1;
       rxwraddr_gray3     <= rxwraddr_gray2;
    end if;
  end process bin2gray_proc2;

  rxwraddr_bin(rxwraddr_bin'LEFT) <= rxwraddr_gray3(rxwraddr_gray3'LEFT);
  rxwraddr_bin(rxwraddr_bin'LEFT-1 DOWNTO 0) <= rxwraddr_bin(rxwraddr_bin'LEFT DOWNTO 1)
                                                XOR
                                                rxwraddr_gray3(rxwraddr_gray3'LEFT-1 DOWNTO 0);

  gray2bin_proc1:process(chif_rxclk, chif_reset)
  begin
    if chif_reset = '1' then
       rxwraddr_bin1 <= (others => '0');
       rxwraddr_bin2 <= (others => '0');
       rxwraddr_sync <= (others => '0');
       rxpkt_state   <= RXPKT_IDLE_STATE;
    elsif chif_rxclk'event and chif_rxclk = '1' then
       rxwraddr_bin1 <= rxwraddr_bin;
       rxwraddr_bin2 <= rxwraddr_bin1;
       case rxpkt_state is
        when RXPKT_IDLE_STATE =>
          rxpkt_state <= RXPKT_IDLE_STATE;
          if rxwraddr_bin2 /= rxwraddr_bin1 then
             rxpkt_state <= RXPKT_NEW_STATE;
          end if;
        when RXPKT_NEW_STATE =>
          rxpkt_state <= RXPKT_IDLE_STATE;
          rxwraddr_sync <= rxwraddr_bin;
        end case; 
    end if;
  end process gray2bin_proc1;

  -- rx_dpram EMPTY status.
  rxdpramEmpty <= '1' when rxrdaddr = rxwraddr_sync else
                  '0';
  
  -- ChIf Interface (transmit to ChIf) ----------------------------------------
  rxEOPSlice   <= rxrddata(8); 
  rxDataSlice  <= rxrddata(7 DOWNTO 0);
  
 rxrd_fsm : PROCESS (chif_rxclk, chif_reset)
  BEGIN
    IF chif_reset = '1' THEN
       rxrd_state   <= RXRD_IDLE_STATE;
       rxrdaddr     <= to_unsigned(0, BUFFERADDRWIDTH + 1 );
       rxvld       <= '0'; 
    ELSIF chif_rxclk'EVENT AND chif_rxclk = '1' THEN
       CASE rxrd_state IS
         WHEN RXRD_IDLE_STATE => 
           rxrd_state   <= RXRD_IDLE_STATE;
           rxvld       <= '0';
           if ChIf_rxrdy = '1' and rxdpramEmpty = '0' then
             rxrdaddr    <= rxrdaddr + 1;
             rxvld      <= '1';
             rxrd_state  <= RXRD_DATA_STATE;
           elsif ChIf_rxrdy = '0' and rxdpramEmpty = '0' then
             rxrd_state  <= RXRD_WAIT4RDY_STATE;
           elsif ChIf_rxrdy = '1' and rxdpramEmpty = '1' then
             rxrd_state  <= RXRD_WAIT4VLD_STATE;
           end if;
         WHEN RXRD_DATA_STATE =>
           rxrd_state   <= RXRD_DATA_STATE;
           if ChIf_rxrdy = '1' and rxdpramEmpty = '0' then
             rxrdaddr    <= rxrdaddr + 1;
             rxvld      <= '1';
             rxrd_state  <= RXRD_DATA_STATE;
           elsif ChIf_rxrdy = '0' and rxdpramEmpty = '0' then 
             rxrd_state   <= RXRD_WAIT4RDY_STATE;
           elsif ChIf_rxrdy = '1' and rxdpramEmpty = '1' then
             rxrd_state   <= RXRD_WAIT4VLD_STATE; 
             rxvld        <= '0';
           else -- ChIf_rxrdy = '0' and rxdpramEmpty = '1'
             rxrd_state  <= RXRD_IDLE_STATE;
             rxvld       <= '0';
           end if;
         WHEN RXRD_WAIT4RDY_STATE => 
           rxrd_state   <= RXRD_WAIT4RDY_STATE;
           rxvld       <= '0';
           if ChIf_rxrdy = '1' then
             rxrdaddr    <= rxrdaddr + 1;
             rxvld      <= '1';
             rxrd_state  <= RXRD_DATA_STATE;
           elsif rxdpramEmpty = '1' then
             rxrd_state  <= RXRD_IDLE_STATE;
             rxvld       <= '0';
           end if;
        WHEN RXRD_WAIT4VLD_STATE => 
           rxrd_state   <= RXRD_WAIT4VLD_STATE;
           rxvld       <= '0';
           if rxdpramEmpty = '0' then
             rxrdaddr    <= rxrdaddr + 1;
             rxvld       <= '1';
             rxrd_state  <= RXRD_DATA_STATE;
           elsif ChIf_rxrdy = '0' then  
             rxrd_state  <= RXRD_IDLE_STATE;
             rxvld       <= '0';
           end if;
         WHEN OTHERS => 
           rxrd_state <= RXRD_IDLE_STATE;
           rxvld     <= '0';
           rxrdaddr   <= to_unsigned(0, BUFFERADDRWIDTH + 1 );  
      END CASE;
    END IF;
  END PROCESS rxrd_fsm;
ChIf_rxdata  <= rxDataSlice;
ChIf_rxeop   <= rxEOPSlice AND rxvld;
ChIf_rxvld  <= rxvld;


-- FLOW CONTROL LOGIC

-- rd addr bin ->  gray
rxrdaddr_gray1(rxrdaddr_gray1'LEFT) <= rxrdaddr(rxrdaddr'LEFT);
rxrdaddr_gray1(rxrdaddr_gray1'LEFT-1 DOWNTO 0) <= rxrdaddr(rxrdaddr'LEFT   DOWNTO 1) XOR
                                                        rxrdaddr(rxrdaddr'LEFT-1 DOWNTO 0);
-- rd add gray sync to wr clk
process (rxclk)
begin 
  if rxclk'event and rxclk = '1' then
    if reset_sync2 = '1' then
      rxrdaddr_gray2 <= (others => '0');
      rxrdaddr_gray3 <= (others => '0');
    else
      rxrdaddr_gray2 <= rxrdaddr_gray1;
      rxrdaddr_gray3 <= rxrdaddr_gray2;
    end if;
  end if;
end process;

-- synced rd addr gray -> bin
rxrdaddr_bin(rxrdaddr_bin'LEFT) <= rxrdaddr_gray3(rxrdaddr_gray3'LEFT);
rxrdaddr_bin(rxrdaddr_bin'LEFT-1 DOWNTO 0) <= rxrdaddr_bin(rxrdaddr_bin'LEFT DOWNTO 1) XOR
                                              rxrdaddr_gray3(rxrdaddr_gray3'LEFT-1 DOWNTO 0);
-- rd en sync to wr clk
process (rxclk)
begin 
  if rxclk'event and rxclk = '1' then  
    if reset_sync2 = '1' then
      ChIf_rxrdy_sync1 <= '0';
      ChIf_rxrdy_sync2 <= '0';
    else
     ChIf_rxrdy_sync1 <= ChIf_rxrdy;
     ChIf_rxrdy_sync2 <= ChIf_rxrdy_sync1;
    end if;
  end if;
end process;

-- bufferStatus
dataLen <= to_unsigned(2**(BUFFERADDRWIDTH+1)-1,BUFFERADDRWIDTH+1) - rxrdaddr_bin + rxwraddr
           when (rxrdaddr_bin(BUFFERADDRWIDTH) = '1' and rxwraddr(BUFFERADDRWIDTH) = '0')
           else  rxwraddr - rxrdaddr_bin;
-- SDR tx data buffer: give almost one full pkt margin (1500 byte) to set full flag, in order to prevent incomplete pkt goes into the buffer.
-- when a new pkt is ready, if fullFlagSDR = '1', this pkt will not go into to the buffer, because the buffer probably will overflow in the middle of 
-- the pkt.
-- FIL tx data buffer: fullFlag = 0
fullFlagSDR <= '1' when dataLen >= to_unsigned((OVERFLOWMARK-OVERFLOWMARGIN),BUFFERADDRWIDTH+1) else '0';
fullFlag <= '0' when ISSDRDATABUFFER = 0 else fullFlagSDR;

 
-- Detect posedge of RxDataValid
PROCESS (rxclk)
BEGIN
IF rxclk'event AND rxclk = '1' THEN 
  RxDataValid_delay <= RxDataValid;
END IF;
END PROCESS;
RxDataValid_posedge <= (not RxDataValid_delay) and RxDataValid;

-- SDR tx data buffer: RxDataStart is posedge of RxDataValid, in prevent incomplete pkt goes into the buffer. 
-- It works for GMII, not for MII, because MII data valid signal is not continuously high.
-- FIL tx data buffer: RxDataStart is RxDataValid. It works for both MII and GMII
RxDataStart <= RxDataValid when ISSDRDATABUFFER = 0 else RxDataValid_posedge;

process (rxclk)
begin 
  if rxclk'event and rxclk = '1' then  
    if reset_sync2 = '1' then
       bufferStatus <= (others => '0');
    else
      if dataLen = to_unsigned((OVERFLOWMARK-OVERFLOWMARGIN),BUFFERADDRWIDTH+1) then
        if RxDataValid = '1' then
          bufferStatus <= X"04"; -- full and try to write
        end if;
      elsif dataLen = to_unsigned(HIGHMARK,BUFFERADDRWIDTH+1) then
        if RxDataValid = '1' then 
          bufferStatus <= X"03"; -- 3/4 full and try to write
        end if;
      elsif dataLen = to_unsigned(HIGHMARKTRIGGER,BUFFERADDRWIDTH+1) or dataLen = to_unsigned(LOWMARKTRIGGER,BUFFERADDRWIDTH+1) then
          bufferStatus <= X"FF"; -- FF: ready to trigger state for high and low watermark
      elsif dataLen = to_unsigned(LOWMARK,BUFFERADDRWIDTH+1) then
        if ChIf_rxrdy_sync2 = '1' then
          bufferStatus <= X"01"; -- 1/4 full and try to read
        end if;
      elsif dataLen = to_unsigned(UNDERFLOWMARK,BUFFERADDRWIDTH+1)then   
        if ChIf_rxrdy_sync2 = '1' then
          bufferStatus <= X"00"; -- empty and try to read
        end if;
      end if;
    end if;
  end if;
end process;
-------- End of Sending data to ChIf --------------------------------------

END rtl;