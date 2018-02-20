
-- ----------------------------------------------
-- File Name: MWChIfRXDecoder.vhd
-- Created:   08-Feb-2018 10:01:14
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfRXDecoder IS 
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
END MWChIfRXDecoder;

ARCHITECTURE rtl of MWChIfRXDecoder IS

  type DSTATE_TYPE is (IDLE_DSTATE, WAIT4READY_DSTATE, WAIT4VALID_DSTATE, EOP_DSTATE,  DATA_DSTATE, SET_TXLEN_DSTATE_1, SET_TXLEN_DSTATE_2, SET_CYCLE_DSTATE_1, SET_CYCLE_DSTATE_2);
  type CSTATE_TYPE is (IDLE_CSTATE, WAIT4READY_CSTATE, WAIT4VALID_CSTATE, CMD_WAIT4DATA, EOP_CSTATE,  CMD_LEN_1, CMD_LEN_2, CMD_DATA);
  CONSTANT DATA_PACKET                    : std_logic_vector(1 downto 0) := "00"; 
  CONSTANT COMMAND_PACKET                 : std_logic_vector(1 downto 0) := "10"; 
  SIGNAL dstate                           : DSTATE_TYPE; 
  SIGNAL cstate                           : CSTATE_TYPE; 
  SIGNAL pktHeader                        : std_logic_vector(1 DOWNTO 0); 
  SIGNAL cmdHeader                        : std_logic_vector(1 DOWNTO 0); 
  SIGNAL simModeS                         : std_logic; -- boolean
  SIGNAL rxEOPS                           : std_logic; -- boolean
  SIGNAL rxdLock                          : std_logic; -- boolean
  SIGNAL rxcLock                          : std_logic; -- boolean
  SIGNAL simCycle_tmp                     : std_logic_vector(15 DOWNTO 0); 
  SIGNAL simCycle_dly                     : std_logic_vector(15 DOWNTO 0); 
  SIGNAL cmdLength                        : unsigned(15 DOWNTO 0); 
  SIGNAL cmdLenTmp                        : std_logic_vector(7 DOWNTO 0); 

BEGIN

 pktHeader  <= rxData(7 downto 6);
 simMode    <= simModeS;
 rxEOPAck   <= rxEOPS;
 rxCmdRdy   <= cmdRdy;
 saveSimCycle: process(clk)
   begin 
     if clk'event and clk = '1' then 
       if rxdrst = '1' then
         simCycle_dly  <= (others => '0');
         simCycle       <= (others => '0');
       else 
         if updateSimCycle = '1' then
           simCycle   <= simCycle_tmp;
         else
           simCycle   <=  simCycle_dly;

         end if;
         if updateSimCycle = '1' then
           simCycle_dly       <= simCycle_tmp;
         end if;
       end if;
     end if;
   end process saveSimCycle;

 dstate_machine: process (clk)
   begin 
     if clk'event and clk = '1' then 
       if rxdrst = '1' then
         dstate        <= IDLE_DSTATE;
         simModeS     <= '0';
         txDataLength <= (others => '0');
         rxEOPS       <= '0';
         simCycle_tmp  <= (others => '0');
         rxdLock       <= '0';
       else 
         case dstate is 
           when IDLE_DSTATE => 
             rxEOPS       <= '0';
             simModeS     <= '0';
             simCycle_tmp  <= (others => '0');
             rxdLock       <= '0';
             if rxRdy = '1' then
               if rxVld = '0' then
                 dstate    <= WAIT4VALID_DSTATE;
               elsif rxcLock = '0' AND rxVld = '1' AND pktHeader = DATA_PACKET then
                 dstate     <= SET_TXLEN_DSTATE_1;
                 simModeS   <= rxData(0) OR (NOT coupleRxTx);
                 rxdLock     <= coupleRxTx;
               end if;
             end if;
           when WAIT4VALID_DSTATE =>
             if rxcLock = '0' then
               if rxVld = '1' AND pktHeader = DATA_PACKET then
                 dstate     <= SET_TXLEN_DSTATE_1;
                 simModeS   <= rxData(0) OR (NOT coupleRxTx);
                 rxdLock     <= coupleRxTx;
               end if;
             else
               dstate        <= IDLE_DSTATE;
             end if;
           when SET_TXLEN_DSTATE_1 =>
             if rxVld = '1'  then
             -- Endianness --------------
             -- Big Endian
             --  txDataLength(15 downto 8) <= rxData;
             -- Little Endian
               txDataLength(7 downto 0) <= rxData;
             -----------------------------
               dstate                  <= SET_TXLEN_DSTATE_2;
             end if;
           when SET_TXLEN_DSTATE_2 =>
             if rxVld = '1'  then
             -- Endianness --------------
             -- Big Endian
             -- txDataLength(7 downto 0) <= rxData;
             -- Little Endian
               txDataLength(15 downto 8) <= rxData;
              -----------------------------
               dstate                  <= SET_CYCLE_DSTATE_1;
             end if;
           when SET_CYCLE_DSTATE_1 =>
             if rxVld = '1'  then
             -- Endianness --------------
             -- Big Endian
             -- simCycle_tmp(15 downto 8) <= rxData;
             -- Little Endian
               simCycle_tmp(7 downto 0) <= rxData;
             -----------------------------
               dstate                 <= SET_CYCLE_DSTATE_2;
             end if;
           when SET_CYCLE_DSTATE_2 =>
             if rxVld = '1'  then
             -- Endianness --------------
             -- Big Endian
             -- simCycle_tmp(7 downto 0) <= rxData;
             -- Little Endian
               simCycle_tmp(15 downto 8) <= rxData;
            -----------------------------
               dstate                    <= DATA_DSTATE;
               if rxEOP = '1' then
                 dstate <= IDLE_DSTATE;
                 rxEOPS <= '1';
                 rxdLock <= '0';
               end if;
             end if;
           when DATA_DSTATE =>
             if simModeS = '0' then
               if unPackDone = '1' then
                 dstate <= IDLE_DSTATE;
                 rxdLock <= '0';
                 rxEOPS <= rxEOP;
               elsif rxVld = '1'  then
                 rxEOPS <= rxEOP;
               end if;
             else 
               if unPackDone = '1' then
                 dstate  <= WAIT4READY_DSTATE;
                 rxEOPS <= rxEOP;
                 if rxEOP = '1' then
                   dstate <= EOP_DSTATE;
                 end if;
               elsif rxVld = '1'  then
                 rxEOPS <= rxEOP;
                 if rxEOP = '1' then
                   dstate <= EOP_DSTATE;
                 end if;
               end if;
             end if;
           when EOP_DSTATE => 
             if updateSimCycle = '1' then
               dstate     <= IDLE_DSTATE;
               rxdLock    <= '0';
               rxEOPS    <= '0';
             end if;
           when WAIT4READY_DSTATE => 
             if rxRdy = '1'  then
               dstate <= DATA_DSTATE;
             end if;
           when others =>
             dstate     <= IDLE_DSTATE;
             rxdLock     <= '0';
             rxEOPS     <= '0';
         end case;
       end if;
     end if;
   end process dstate_machine;

   payLoad    <= rxData;
   payLoadVld <= '1' when (rxVld = '1' AND dstate = DATA_DSTATE) else
                      '0';


 cmdHeader  <= rxCmd(7 downto 6);
   cstate_machine: process (rxcclk)
   begin 
     if rxcclk'event and rxcclk = '1' then 
       if cmdrst = '1' then
         cstate  <= IDLE_CSTATE;
         cmd     <= (others => '0');
         cmdVld  <= '0';
         cmdEOP   <= '0';
         rxcLock  <= '0';
         cmdLength<= to_unsigned(0,16);
         cmdLenTmp<= (others => '0');
       else 
         case cstate is 
           when IDLE_CSTATE => 
             cmdVld  <= '0';
             rxcLock  <= '0';
             cmdEOP   <= '0';
             cmdLength <= to_unsigned(0,16);
             if cmdRdy = '1' then
               if rxCmdVld = '0' then 
                 cstate    <= WAIT4VALID_CSTATE;
               elsif rxdLock = '0' AND cmdHeader = COMMAND_PACKET then
                 rxcLock  <= coupleRxTx;
                 cstate  <= CMD_LEN_1;
                 cmd      <= rxCmd;
                 cmdVld  <= '1';
               end if;
             end if;
           when WAIT4VALID_CSTATE =>
             if rxdLock = '0' then
               if rxCmdVld = '1'  AND cmdHeader = COMMAND_PACKET then
                 rxcLock  <= coupleRxTx;
                 cstate  <= CMD_LEN_1;
                 cmd      <= rxCmd;
                 cmdVld  <= '1';
               end if;
             else
               cstate  <= IDLE_CSTATE;
             end if;
           when CMD_LEN_1 =>
             if rxCmdVld = '1'  then
               cmd        <= rxCmd;
               cmdLenTmp  <= rxCmd;
               cmdVld    <= '1';
               cstate    <= CMD_LEN_2;
             else
               cmdVld  <= '0';
             end if;
           when CMD_LEN_2 =>
             if rxCmdVld = '1'  then
               cmd       <= rxCmd;
               cmdVld   <= '1';
             -- Endianness --------------------------------------------
             -- Big Endian --
             -- cmdLength <= unsigned(cmdLenTmp & rxCmd);
             -- if unsigned(cmdLenTmp & rxCmd) = to_unsigned(0, 8) then
             --    cmdLength <= to_unsigned(5, 16);
             -- end if;
             -- Small Endian --
               cmdLength <= unsigned(rxCmd & cmdLenTmp);
               if unsigned(rxCmd & cmdLenTmp) = to_unsigned(0, 8) then
                 cmdLength <= to_unsigned(5, 16);
               end if;
               cstate <= CMD_DATA;
             else
               cmdVld  <= '0';
             end if;
           when CMD_DATA =>
             if cmdLength = to_unsigned(0, 16) then
               cstate <= IDLE_CSTATE;
               rxcLock <= '0';
               cmdVld <= '0';
             elsif rxCmdVld = '1'  and cmdRdy = '1' then
               cmd        <= rxCmd;
               cmdVld    <= '1';
               cmdLength <= cmdLength - 1;
             elsif rxCmdVld = '1'  and cmdRdy = '0' then
               cmd        <= rxCmd;
               cmdVld    <= '1';
               cmdLength <= cmdLength - 1;
               cstate <= CMD_WAIT4DATA;
             else
               cmdVld  <= '0';
             end if;
             cmdEOP <= rxCmdEOP;
           when CMD_WAIT4DATA =>
             if cmdLength = to_unsigned(0, 16) then
               cstate <= IDLE_CSTATE;
               rxcLock <= '0';
               cmdVld <= '0';
             elsif cmdRdy = '1' then
             --cmd        <= rxCmd;
             --cmdVld    <= '1';
             --cmdLength <= cmdLength - 1;
               cstate <= CMD_DATA;
             else
               cmdVld  <= '0';
             end if;
             cmdEOP <= rxCmdEOP;
           when others =>
             cstate  <= IDLE_CSTATE;
             cmd     <= (others => '0');
             cmdVld  <= '0';
             rxcLock  <= '0';
             cmdLength <= to_unsigned(0,16);
         end case;
       end if;
     end if;
   end process cstate_machine;

END;
