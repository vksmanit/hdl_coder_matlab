
-- ----------------------------------------------
-- File Name: MWChIfTXCtrl.vhd
-- Created:   08-Feb-2018 10:01:16
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfTXCtrl IS 
GENERIC (
         TX_DATAWIDTH: integer := 8;
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
END MWChIfTXCtrl;

ARCHITECTURE rtl of MWChIfTXCtrl IS

  FUNCTION dataWidthInBytes (constant DATAWIDTH : integer) return integer is
   variable tmp1 : integer;
   variable tmp2 : integer;
   BEGIN 
    tmp1 := DATAWIDTH mod 8;
    if tmp1 = 0 then
      tmp2 := DATAWIDTH / 8;
    else
      tmp2 := DATAWIDTH / 8 + 1;
    end if;
     return tmp2;
   END;

  type DTX_STATE_TYPE is (DTX_IDLE, DTX_DATA, DTX_DATA_1BYTE, DTX_CONT, DTX_CONT_1BYTE, DTX_WAIT, DTX_WAIT_1BYTE);
  type EOP_STATE_TYPE is (EOP_IDLE, EOP_RECEIVED, EOP_TX, EOP_COMPLETED);
  CONSTANT HEADER_AND_PAYLOAD_DATALENGTH  : integer := dataWidthInBytes(TX_DATAWIDTH) + 5; 
  CONSTANT PAYLOAD_DATALENGTH             : integer := dataWidthInBytes(TX_DATAWIDTH); 
  CONSTANT MAX_PAYLOAD                    : integer := 12; 
  SIGNAL DTX_state                        : DTX_STATE_TYPE; 
  SIGNAL eop_state                        : EOP_STATE_TYPE; 
  SIGNAL DTXDataCnt                       : unsigned(MAX_PAYLOAD - 1 DOWNTO 0); 
  SIGNAL txLength                         : unsigned(MAX_PAYLOAD - 1 DOWNTO 0); 
  SIGNAL enbCycleCnt                      : unsigned(15 DOWNTO 0); -- unit16
  SIGNAL EOP_cnt                          : unsigned(2 DOWNTO 0); -- uint32
  SIGNAL EOP_tmp                          : std_logic; -- boolean
  SIGNAL txDone_tmp                       : std_logic; -- boolean
  SIGNAL simModeS                         : std_logic; -- boolean
  SIGNAL shftOutregS                      : std_logic; -- boolean

BEGIN

   DTXCtrl_proc: process (dclk)
   begin 
     if dclk'event and dclk = '1' then 
       if reset = '1' then
         DTX_state     <= DTX_IDLE;
         enbCycleCnt   <= to_unsigned(0, 16);
         DTXDataCnt    <= to_unsigned(0, MAX_PAYLOAD);
         shftOutregS    <= '0';
         txDone_tmp    <= '1';
         simModeS      <= '0';
         txLength      <= to_unsigned(0, MAX_PAYLOAD);
       else 
         case DTX_state is 
           when DTX_IDLE => 
             DTX_state    <= DTX_IDLE;
             enbCycleCnt  <= to_unsigned(0, 16);
             DTXDataCnt   <= to_unsigned(0, MAX_PAYLOAD);
             txDone_tmp   <= '1';
             simModeS     <= simMode;
             txLength     <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             if dinVld = '1' then 
               DTX_state    <= DTX_DATA;
               enbCycleCnt <= enbCycleCnt + to_unsigned(1,16);
               if txLength > to_unsigned(1, MAX_PAYLOAD) AND txRdy = '1' then
                 txDone_tmp   <= '0';
                 shftOutregS   <= '1';
                 DTXDataCnt    <= DTXDataCnt + to_unsigned(1, MAX_PAYLOAD);
               elsif txLength = to_unsigned(1, MAX_PAYLOAD) AND txRdy = '1' then
                 txDone_tmp   <= '1';
                 shftOutregS   <= '0';
                 DTX_state   <= DTX_DATA_1BYTE;
               end if;
             end if;
           when DTX_DATA => 
             if txRdy = '1' then
               if DTXDataCnt < txLength - to_unsigned(1, MAX_PAYLOAD) then
                 shftOutregS   <= '1';
                 DTXDataCnt    <= DTXDataCnt + to_unsigned(1, MAX_PAYLOAD);
               else 
                 txDone_tmp <= '0';
                 shftOutregS <= '0';
                 if enbCycleCnt < unsigned(simCycle) then
                   txDone_tmp   <= '1';
                   DTX_state    <= DTX_CONT;
                 elsif simModeS = '1' then
                   if eop_state = EOP_COMPLETED then
                     DTX_state <= DTX_IDLE;
                     enbCycleCnt <= to_unsigned(0, 16);
                     txLength <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
                   else
                     DTX_state <= DTX_WAIT;
                   end if;
                 else 
                   if eop_state = EOP_COMPLETED then
                     DTX_state  <= DTX_IDLE;
                     enbCycleCnt <= to_unsigned(0, 16);
                     txLength  <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
                   else
                     DTX_state <= DTX_WAIT;
                     txLength    <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
                   end if;
                 end if;
               end if;
             else 
               shftOutregS <= '0';
             end if;
           when DTX_DATA_1BYTE => 
             txDone_tmp     <= '1';
             shftOutregS <= '0';
             if enbCycleCnt < unsigned(simCycle) then
               txDone_tmp   <= '1';
               DTX_state    <= DTX_CONT_1BYTE;
             elsif simModeS = '1' then
                if eop_state = EOP_COMPLETED then
                  DTX_state <= DTX_IDLE;
                  enbCycleCnt <= to_unsigned(0, 16);
                  txLength <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
                else
                  DTX_state  <= DTX_WAIT_1BYTE;
                  txDone_tmp <= '1';
                end if;
             else 
               if eop_state = EOP_COMPLETED then
                 DTX_state   <= DTX_IDLE;
                 enbCycleCnt <= to_unsigned(0, 16);
                 txLength  <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
               else
                 DTX_state  <= DTX_WAIT_1BYTE;
                 txDone_tmp <= '0';
               end if;
             end if;
           when DTX_CONT => 
             txDone_tmp      <= '0';
             if dinVld  = '1' then 
               DTX_state    <= DTX_DATA;
               txDone_tmp   <= '0';
               DTXDataCnt   <= to_unsigned(1, MAX_PAYLOAD);
               shftOutregS   <= '1';
               enbCycleCnt  <= enbCycleCnt + to_unsigned(1, 16);
               txLength     <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             elsif eop_state =  EOP_TX then 
               DTX_state <= DTX_CONT;
             elsif eop_state = EOP_RECEIVED OR eop_state = EOP_IDLE then
               txDone_tmp   <= '1';
             elsif eop_state = EOP_COMPLETED then
               DTX_state    <= DTX_IDLE;
               txDone_tmp   <= '1';
               enbCycleCnt  <= to_unsigned(0, 16);
               DTXDataCnt   <= to_unsigned(0, MAX_PAYLOAD);
               txLength     <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             end if;
           when DTX_CONT_1BYTE => 
             DTX_state    <= DTX_CONT_1BYTE;
             txDone_tmp      <= '1';
             if dinVld = '1' then 
               enbCycleCnt <= enbCycleCnt + to_unsigned(1,16);
               DTX_state   <= DTX_DATA_1BYTE;
             end if;
           when DTX_WAIT => 
             if dinVld  = '1' then 
               DTX_state    <= DTX_DATA;
               txDone_tmp   <= '0';
               DTXDataCnt    <= to_unsigned(1, MAX_PAYLOAD);
               enbCycleCnt <= to_unsigned(1, 16);
               if txLength > to_unsigned(1, MAX_PAYLOAD) then
                 shftOutregS   <= '1';
               elsif txLength = to_unsigned(1, MAX_PAYLOAD) then
                 shftOutregS   <= '0';
                 DTX_state    <= DTX_DATA_1BYTE;
               end if;
             elsif eop_state =  EOP_TX then 
               txDone_tmp   <= '0';
             elsif eop_state = EOP_RECEIVED OR eop_state = EOP_IDLE then
               txDone_tmp   <= '1';
             elsif eop_state = EOP_COMPLETED then
               DTX_state    <= DTX_IDLE;
               txDone_tmp  <= '0';
               enbCycleCnt <= to_unsigned(0, 16);
               DTXDataCnt  <= to_unsigned(0, MAX_PAYLOAD);
               txLength    <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             end if;
           when DTX_WAIT_1BYTE => 
             if dinVld  = '1' then 
               DTX_state    <= DTX_DATA_1BYTE;
               txDone_tmp   <= '1';
               DTXDataCnt   <= to_unsigned(0, MAX_PAYLOAD);
               enbCycleCnt <= to_unsigned(1, 16);
               txLength    <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             elsif eop_state =  EOP_TX then 
               txDone_tmp   <= '0';
             elsif eop_state = EOP_RECEIVED OR eop_state = EOP_IDLE then
               txDone_tmp      <= '1';
             elsif eop_state = EOP_COMPLETED then
               DTX_state    <= DTX_IDLE;
               txDone_tmp   <= '1';
               enbCycleCnt  <= to_unsigned(0, 16);
               DTXDataCnt   <= to_unsigned(0, MAX_PAYLOAD);
               txLength     <= to_unsigned(PAYLOAD_DATALENGTH, MAX_PAYLOAD);
             end if;           when others => 
             DTX_state    <= DTX_IDLE;
             enbCycleCnt  <= to_unsigned(0, 16);
             DTXDataCnt   <= to_unsigned(0, MAX_PAYLOAD);
             txDone_tmp   <= '1';
             simModeS     <= '0';
         end case;
       end if;
     end if;
   end process DTXCtrl_proc;

 eop_proc: process (dclk)
   begin 
     if dclk'event and dclk = '1' then 
       if reset = '1' then
         eop_state <= EOP_IDLE;
         EOP_cnt   <= to_unsigned(0, 3);
       else 
         case eop_state is 
           when EOP_IDLE => 
             if rxEOP = '1' then 
               if dinVld = '1' then
                 eop_state <= EOP_TX;
               elsif (txLength = to_unsigned(1, MAX_PAYLOAD))  then 
                 eop_state <= EOP_TX;
               else
                 eop_state <= EOP_RECEIVED;
               end if;
             end if;
           when EOP_RECEIVED => 
             if NOPcmd = '1' then
               eop_state <= EOP_IDLE;
             elsif dinVld = '1' then 
               eop_state <= EOP_TX;
             end if;
           when EOP_TX => 
             if NOPcmd = '1' then
               eop_state <= EOP_IDLE;
             elsif EOP_tmp = '1' then 
               if EOP_cnt = to_unsigned(7, 3) then
                 eop_state <= EOP_COMPLETED;
                 EOP_cnt   <= to_unsigned(0, 3);
               else
                 EOP_cnt   <= EOP_cnt + to_unsigned(1, 3);
               end if;
             end if;
           when EOP_COMPLETED => 
             eop_state <= EOP_IDLE;
           when others => 
             eop_state <= EOP_IDLE;
         end case;
       end if;
     end if;
   end process eop_proc;

 inter_eop: process(eop_state, DTX_state, DTXDataCnt, enbCycleCnt, simCycle, txLength)
 begin
 EOP_tmp <= '0';
 if (eop_state = EOP_TX) then 
    if (DTXDataCnt = txLength - to_unsigned(1, MAX_PAYLOAD)) AND (enbCycleCnt =  unsigned(simCycle)) then 
        EOP_tmp <= '1';
     end if;
  end if;
 end process inter_eop;

 txDone <= txDone_tmp AND (NOT dinVld);

 proc_status: process(eop_state)
 begin
  txCompleted  <= '0';
  if eop_state = EOP_COMPLETED then
     txCompleted <= '1';
  end if;
 end process proc_status;

 shftOutReg <= shftOutregS;
 txEOP      <= EOP_tmp;

END;
