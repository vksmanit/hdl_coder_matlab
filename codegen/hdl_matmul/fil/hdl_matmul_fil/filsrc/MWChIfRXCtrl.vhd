
-- ----------------------------------------------
-- File Name: MWChIfRXCtrl.vhd
-- Created:   08-Feb-2018 10:01:16
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfRXCtrl IS 
GENERIC (
         RX_DATAWIDTH: integer := 8;
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
END MWChIfRXCtrl;

ARCHITECTURE rtl of MWChIfRXCtrl IS

  type DRDY_STATE_TYPE is (DRDY_IDLE,  DRDY_WAIT4DUTENB, DRDY_WAIT4TXCOMPLETED, DRDY_WAIT4TXFINISHING);
  type DUTENB_STATE_TYPE is (DUTENB_IDLE, DUTENB_DEASSERT, DUTENB_WAIT, DUTENB_WAIT4TXDONE);
  type SIMCYCLE_STATE_TYPE is (SIMCYCLE_IDLE, SIMCYCLE_START, SIMCYCLE_WAIT4COMPLETION);

  SIGNAL enbCycleCnt                      : unsigned(15 DOWNTO 0); -- uint16
  SIGNAL simCycle_tmp                     : std_logic_vector(15 DOWNTO 0); -- std_logic_vector
  SIGNAL rdy                              : std_logic; -- boolean
  SIGNAL dutEnb_state                     : DUTENB_STATE_TYPE; 
  SIGNAL dutEnb_tmp                       : std_logic; -- boolean
  SIGNAL drdy_state                       : DRDY_STATE_TYPE; 
  SIGNAL simcycle_state                   : SIMCYCLE_STATE_TYPE; 
  SIGNAL tx_stream_en_sync1               : std_logic; -- boolean
  SIGNAL tx_stream_en_sync2               : std_logic; -- boolean
  SIGNAL dutEnb_tmp_d                     : std_logic; -- boolean
  SIGNAL dutEnb_tmp_posedge               : std_logic; -- boolean

BEGIN

  sync_proc : process(clk)
  begin 
    if clk'event and clk = '1' then 
      tx_stream_en_sync1 <= tx_stream_en;
      tx_stream_en_sync2 <= tx_stream_en_sync1;
    end if;
  end process sync_proc;
 rxRdy <= rdy and (not unPackDone) and tx_stream_en_sync2;

 dutEnb_proc: process (clk)
   begin 
     if clk'event and clk = '1' then 
       if reset = '1' then
         dutEnb_tmp     <= '0';
         dutEnb_state   <= DUTENB_IDLE;
         enbCycleCnt <= to_unsigned(0, 16);
         simCycle_tmp <= (others => '0');
       else 
         case dutEnb_state is
           when DUTENB_IDLE=> 
             dutEnb_state   <= DUTENB_IDLE;
             enbCycleCnt    <= to_unsigned(0, 16);
             dutEnb_tmp     <= '0';
             if unsigned(simCycle) > to_unsigned(0, 16) then
               --simCycle_tmp <= simCycle;
               if unPackDone = '1' then
                 simCycle_tmp <= simCycle;
                 if txDone = '1' then 
                   enbCycleCnt <= to_unsigned(1, 16);
                   dutEnb_tmp  <= '1';
                   dutEnb_state <= DUTENB_DEASSERT;
                 else
                   dutEnb_state <= DUTENB_WAIT;
                 end if;
               end if;
             end if;
           when DUTENB_DEASSERT =>
             if unsigned(simCycle) > to_unsigned(0, 16) then
               simCycle_tmp <= simCycle;
             end if;
             if enbCycleCnt < unsigned(simCycle_tmp) then
               if txDone = '1' then 
                 dutEnb_tmp  <= '1';
                 enbCycleCnt <= enbCycleCnt + 1 ;
               else
                 dutEnb_state <= DUTENB_WAIT;
                 dutEnb_tmp   <= '0';
               end if;
             else
               dutEnb_tmp   <= '0';
               dutEnb_state   <= DUTENB_IDLE;
               enbCycleCnt <= to_unsigned(0, 16);
             end if;
           when DUTENB_WAIT =>
             if txDone = '1' AND unPackDone = '1' then
               dutEnb_tmp  <= '1';
               enbCycleCnt <= to_unsigned(1, 16);
               dutEnb_state   <= DUTENB_DEASSERT;
             elsif unPackDone = '1' then
               enbCycleCnt    <= to_unsigned(0, 16);
               dutEnb_tmp     <= '0';
               dutEnb_state   <= DUTENB_WAIT4TXDONE;
             elsif txDone = '1' then
               if enbCycleCnt < unsigned(simCycle_tmp) then
                 dutEnb_tmp   <= '1';
                 enbCycleCnt  <= enbCycleCnt + 1 ;
                 dutEnb_state <= DUTENB_DEASSERT;
               else
                 dutEnb_state   <= DUTENB_IDLE;
                 enbCycleCnt    <= to_unsigned(0, 16);
               end if;
             end if;
           when DUTENB_WAIT4TXDONE =>
             if txDone = '1' then
               enbCycleCnt <= to_unsigned(1, 16);
               dutEnb_tmp  <= '1';
               if enbCycleCnt < unsigned(simCycle_tmp) then
                 enbCycleCnt <= enbCycleCnt + 1 ;
                 dutEnb_state <= DUTENB_DEASSERT;
               end if;
             end if;
           when others => 
             dutEnb_tmp     <= '0';
             dutEnb_state   <= DUTENB_IDLE;
             enbCycleCnt <= to_unsigned(0, 16);
         end case;
       end if;
     end if;
   end process dutEnb_proc;

 Rdy_proc: process (clk)
   begin 
     if clk'event and clk = '1' then 
       if reset = '1' then
         rdy        <= '1';
         drdy_state <= DRDY_IDLE;
       else 
         case drdy_state is
           when DRDY_IDLE => 
             rdy        <= '1';
             drdy_state <= DRDY_IDLE;
             if unPackDone = '1' then
               rdy        <= '0';
               if rxEOP = '1' then
                 drdy_state <= DRDY_WAIT4DUTENB;
               elsif  unsigned(simCycle_tmp) = to_unsigned(1, 16) AND txDone = '1' then
                 rdy        <= '1';
                 drdy_state <= DRDY_IDLE;
               else
                 drdy_state <= DRDY_WAIT4TXFINISHING;
               end if;
             end if;
           when DRDY_WAIT4TXFINISHING => 
             if enbCycleCnt = unsigned(simCycle_tmp) - to_unsigned(1, 16) AND txDone = '1' then
               rdy        <= '1';
               drdy_state <= DRDY_IDLE;
             end if;
           when DRDY_WAIT4DUTENB => 
             if dutEnb_tmp = '1' AND enbCycleCnt = unsigned(simCycle_tmp) then
               drdy_state <= DRDY_WAIT4TXCOMPLETED;
             end if;
           when DRDY_WAIT4TXCOMPLETED => 
             if txCompleted = '1' then
               drdy_state <= DRDY_IDLE;
               rdy        <= '1';
             end if;
           when others => 
             rdy        <= '1';
             drdy_state <= DRDY_IDLE;
         end case;
       end if;
     end if;
   end process Rdy_proc;

 simCycleUpdate_proc: process (clk)
   begin 
     if  clk'event and clk = '1' then 
       if reset = '1' then
        updateSimCycle  <= '0';
        simcycle_state  <= SIMCYCLE_IDLE;
       else 
         case simcycle_state is 
           when SIMCYCLE_IDLE =>
             updateSimCycle <= '1';
             simcycle_state <= SIMCYCLE_START;
           when SIMCYCLE_START =>
             if rxEOP = '1' then
               updateSimCycle <= '0';
               simcycle_state <= SIMCYCLE_WAIT4COMPLETION;
             end if;
           when SIMCYCLE_WAIT4COMPLETION =>
             if txCompleted= '1' then
               simcycle_state <= SIMCYCLE_IDLE;
             end if;
           when others =>
             updateSimCycle  <= '0';
             simcycle_state  <= SIMCYCLE_IDLE;
         end case;
       end if;
     end if;
   end process simCycleUpdate_proc;

 -- if SDR tx, dutEnb is dutEnb_tmp_posedge; if FIL, dutEnb is dutEnb_tmp. 
 process(clk) 
   begin 
     if  clk'event and clk = '1' then 
       dutEnb_tmp_d <= dutEnb_tmp;
     end if;
   end process; 

 dutEnb_tmp_posedge <= (not dutEnb_tmp_d) and dutEnb_tmp;
 dutEnb         <= dutEnb_tmp_posedge when COUPLE_RXTX  = '0' else dutEnb_tmp;

END;
