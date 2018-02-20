
-- ----------------------------------------------
-- File Name: MWArbiter.vhd
-- Created:   08-Feb-2018 10:01:13
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MWArbiter IS
  PORT(
        txclk        : IN  std_logic;
		  txclk_en		: IN  std_logic;
        txreset      : IN  std_logic;
        -----------------------------------------------------------------------
        status       : IN std_logic_vector(7 downto 0);
        statusvld    : IN std_logic;
        statuseop    : IN std_logic;
        statuslen    : IN std_logic_vector(12 downto 0);
        statustx     : OUT std_logic;
        data         : IN std_logic_vector(7 downto 0);
        datavld      : IN std_logic;
        dataeop      : IN std_logic;
        datalen      : IN std_logic_vector(12 downto 0);
        datatx       : OUT std_logic;
         -----------------------------------------------------------------------
        TxData       : OUT std_logic_vector(7 DOWNTO 0);  
        TxDataValid  : OUT std_logic;
        TxEOP        : OUT std_logic;
        TxReady      : IN  std_logic;
        TxStatus     : OUT std_logic;
        TxDataLength : OUT std_logic_vector(12 downto 0)
        );
END MWArbiter;


ARCHITECTURE rtl OF MWArbiter IS

 TYPE ARBITERTYPE IS (ARB_IDLE_STATE, ARB_TXDATA_STATE, ARB_TXSTATUS_STATE, ARB_WAITDATA_STATE, ARB_WAITSTATUS4RDY_STATE, ARB_WAITSTATUS4VLD_STATE);

 signal arb_state : ARBITERTYPE;

BEGIN

  ARB_STATE_MACHINE: process(txclk)
  begin
   if txclk'event and txclk = '1' then
    if txreset = '1' then
      arb_state    <= ARB_IDLE_STATE;
      TxData       <= (others => '0');
      TxDataValid  <= '0';
      TxEop        <= '0';
      TxDataLength <= (others => '0');
      TxStatus     <= '0';
      datatx       <= '0';
      statustx     <= '0';
    elsif txclk_en = '1' then
      case arb_state is
         when ARB_IDLE_STATE =>
            arb_state <= ARB_IDLE_STATE;
            TxData       <= (others => '0');
            TxDataValid  <= '0';
            TxEop        <= '0';
            TxStatus     <= '0';
            TxDataLength <= (others => '0');
            datatx       <= '0';
            statustx     <= '0';
            if unsigned(datalen) >= to_unsigned(1200, 13) OR dataeop = '1' then 
               arb_state    <= ARB_TXDATA_STATE;
               TxData       <= data;
               TxDataValid  <= datavld;
               TxEop        <= dataeop;
               datatx       <= TxReady;
               TxDataLength <= datalen;
               TxStatus     <= '0';
            elsif statuseop = '1' then
               arb_state <= ARB_WAITSTATUS4RDY_STATE;
               TxData       <= status;
               TxDataValid  <= statusvld;
               TxEop        <= statuseop;
               statustx     <= TxReady;
               TxDataLength <= statuslen;
               TxStatus     <= '1';
            end if;
         when ARB_TXDATA_STATE =>
            TxData       <= data;
            TxDataValid  <= datavld;
            TxEop        <= dataeop;
            datatx       <= TxReady;
            TxDataLength <= datalen;
            TxStatus     <= '0';
            if TxReady = '1' then
               arb_state <= ARB_WAITDATA_STATE;
            end if;
         when ARB_WAITSTATUS4RDY_STATE =>
            TxData       <= status;
            TxDataValid  <= statusvld;
            TxEop        <= statuseop;
            statustx     <= TxReady;
            TxDataLength <= statuslen;
            TxStatus     <= '1';
            if TxReady = '1' then
               arb_state <= ARB_WAITSTATUS4VLD_STATE;
            end if;
          when ARB_WAITDATA_STATE =>
            TxData       <= data;
            TxDataValid  <= datavld;
            TxEop        <= dataeop;
            datatx       <= TxReady;
            TxDataLength <= datalen;
            TxStatus     <= '0';
            if datavld = '0' then
               arb_state <= ARB_IDLE_STATE;
            end if;
         when ARB_WAITSTATUS4VLD_STATE =>
            TxData       <= status;
            TxDataValid  <= statusvld;
            TxEop        <= statuseop;
            statustx     <= TxReady;
            TxDataLength <= statuslen;
            TxStatus     <= '1';
            if statusvld = '1' then
               arb_state <= ARB_TXSTATUS_STATE;
            end if;
         when ARB_TXSTATUS_STATE =>
            TxData       <= status;
            TxDataValid  <= statusvld;
            TxEop        <= statuseop;
            statustx     <= TxReady;
            TxDataLength <= statuslen;
            TxStatus     <= '1';
            if statusvld = '0' then
               arb_state <= ARB_IDLE_STATE;
               TxStatus     <= '0';
            end if;
         when others =>
             arb_state <= ARB_IDLE_STATE;
             TxData       <= (others => '0');
             TxDataValid  <= '0';
             TxEop        <= '0';
             TxDataLength <= (others => '0');
             TxStatus     <= '0';
             datatx       <= '0';
             statustx     <= '0';
      end case;
    end if;
   end if;
  end process;
END rtl;

