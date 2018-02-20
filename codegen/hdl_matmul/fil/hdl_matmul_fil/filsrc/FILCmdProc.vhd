
-- ----------------------------------------------
-- File Name: FILCmdProc.vhd
-- Created:   08-Feb-2018 10:01:17
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY FILCmdProc IS 
GENERIC (
         VERSION: std_logic_vector(15 DOWNTO 0) := X"0100"
);

PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      cmd                             : IN  std_logic_vector(7 DOWNTO 0);
      cmdVld                          : IN  std_logic;
      txsRdy                          : IN  std_logic;
      cmdProcRdy                      : OUT std_logic;
      status                          : OUT std_logic_vector(7 DOWNTO 0);
      statusVld                       : OUT std_logic;
      statusEOP                       : OUT std_logic;
      softFPGAReset                   : OUT std_logic;
      softDUTReset                    : OUT std_logic;
      NOPcmd                          : OUT std_logic
);
END FILCmdProc;

ARCHITECTURE rtl of FILCmdProc IS

  type CMD_STATE_TYPE is (CMD_IDLE_STATE, CMD_CAPTURE_STATE);
  CONSTANT GETVERSION                     : std_logic_vector(7 DOWNTO 0) := X"80"; -- std8
  CONSTANT RESETDUT                       : std_logic_vector(7 DOWNTO 0) := X"81"; -- std8
  CONSTANT RESETFPGA                      : std_logic_vector(7 DOWNTO 0) := X"82"; -- std8
  CONSTANT FLUSH                          : std_logic_vector(7 DOWNTO 0) := X"83"; -- std8
  CONSTANT NOP                            : std_logic_vector(7 DOWNTO 0) := X"84"; -- std8
  SIGNAL command                          : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL dutResetReg                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL FPGAResetReg                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL cmdState                         : CMD_STATE_TYPE; 
  SIGNAL cmdReg                           : std_logic_vector(63 DOWNTO 0); 
  SIGNAL cmdRegVld                        : std_logic; -- boolean
  SIGNAL cmdProcBusy                      : std_logic; -- boolean
  SIGNAL versionReg                       : std_logic_vector(63 DOWNTO 0); 
  SIGNAL cnt                              : unsigned(3 DOWNTO 0); 

BEGIN

  command <= cmdReg(63 downto 56);

  cmdProcRdy  <= NOT cmdProcBusy;

 captureCmd_proc: process(clk, reset)
  begin 
    if reset = '1' then
     cmdReg    <= (others => '0');
     cmdState  <= CMD_IDLE_STATE;
     cmdRegVld <= '0';
    elsif clk'event and clk = '1' then 
     case cmdState is
       when CMD_IDLE_STATE =>
        cmdRegVld <= '0';
         if cmdVld = '1' then 
            cmdReg (7 downto 0) <= cmd;
            cmdState            <= CMD_CAPTURE_STATE;
         end if;
       when CMD_CAPTURE_STATE =>
         if cmdVld = '1' then 
            cmdReg(63 downto 8) <= cmdReg(55 downto 0);
            cmdReg (7 downto 0) <= cmd;
         else
            cmdRegVld <= '1';
            cmdState  <= CMD_IDLE_STATE;
         end if;
       when others =>
        cmdReg    <= (others => '0');
        cmdState  <= CMD_IDLE_STATE;
        cmdRegVld <= '0';
     end case;
    end if;
 end process captureCmd_proc;

  cmd_proc: process (clk, reset)
  begin 
    if reset = '1' then
     status      <= (others => '0');
     statusVld   <= '0';
     statusEOP   <= '0';
     NOPcmd      <= '0';
     cmdProcBusy <= '0';
     cnt         <= (others => '0');
     versionReg  <= (others => '0');
    elsif clk'event and clk = '1' then 
     status      <= (others => '0');
     statusVld   <= '0';
     statusEOP   <= '0';
     NOPcmd      <= '0';
     cmdProcBusy <= '0';
     cnt         <= (others => '0');
     versionReg(15 DOWNTO 0)  <= VERSION;
     versionReg(47 DOWNTO 16)  <= (others => '0');
     versionReg(63 DOWNTO 48) <= X"4000";
     if cmdRegVld = '1' OR cmdProcBusy = '1' then 
        cmdProcBusy <= '1';
        case command is
         when GETVERSION => 
           if txsRdy = '1' then
              versionReg(63 DOWNTO 8) <= versionReg(55 DOWNTO 0);
              status      <= versionReg(63 DOWNTO 56);
              statusVld   <= '1';
              cnt         <= cnt + 1;
              if cnt = to_unsigned (7, 4) then
                 statusEOP  <= '1';
              elsif cnt = to_unsigned (8, 4) then
                 cnt         <= (others => '0');
                 statusEOP   <= '0';
                 statusVld   <= '0';
                 cmdProcBusy <= '0';
                 versionReg(15 DOWNTO 0)  <= VERSION;
                 versionReg(47 DOWNTO 16)  <= (others => '0');
                 versionReg(63 DOWNTO 48) <= X"4000";
              end if;
           end if;
         when FLUSH => 
         when NOP => 
              NOPcmd      <= '1';
              cmdProcBusy <= '0';
         when others   => 
           status      <= (others => '0');
           statusVld   <= '0';
           cmdProcBusy <= '0';
        end case;
      else
           status    <= (others => '0');
           statusVld <= '0';
           cmdProcBusy <= '0';
      end if;
   end if;
  end process cmd_proc;

  rst_proc: process (clk)
  begin 
    if clk'event and clk = '1' then 
      dutResetReg  <= dutResetReg(6 downto 0) & '0';
      FPGAResetReg <= FPGAResetReg(6 downto 0) & '0';
      if cmdRegVld = '1' then 
        case command is
         when RESETDUT   => 
           dutResetReg <= ( others => '1');
         when RESETFPGA   => 
           FPGAResetReg<= ( others => '1');
         when others   => 
           dutResetReg  <= ( others => '0');
           FPGAResetReg <= ( others => '0');
        end case;
      end if;
    end if;
  end process rst_proc;

  softDUTReset  <= dutResetReg(7);
  softFPGAReset <= FPGAResetReg(7);

END;
