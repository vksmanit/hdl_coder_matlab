
-- ----------------------------------------------
-- File Name: MWRotateRight.vhd
-- Created:   08-Feb-2018 10:01:15
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWRotateRight IS 
GENERIC (
         DATA_WIDTH: integer := 8
);

PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      shift                           : IN  std_logic;
      load                            : IN  std_logic;
      input                           : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      output                          : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
);
END MWRotateRight;

ARCHITECTURE rtl of MWRotateRight IS

  SIGNAL sel                              : std_logic_vector(1 downto 0); 
  SIGNAL tempReg                          : std_logic_vector(DATA_WIDTH -1  downto 0); 

BEGIN

 sel    <= load & shift;
 output <= tempReg;

 process (clk,reset)
  begin
   if reset = '1' then
     tempReg(DATA_WIDTH - 1) <= '1';
     tempReg(DATA_WIDTH - 2 DOWNTO 0) <= (others => '0');
   elsif clk'event and clk = '1' then
     case sel is
      when "10" =>
        tempReg <= input;
      when "01" =>
        tempReg(DATA_WIDTH - 1)          <= tempReg(0);
        tempReg(DATA_WIDTH - 2 downto 0) <= tempReg(DATA_WIDTH - 1 downto 1);
      when "11" =>
        tempReg(DATA_WIDTH - 1)          <= input(0);
        tempReg(DATA_WIDTH - 2 downto 0) <= input(DATA_WIDTH - 1 downto 1); 
      when others =>
        tempReg <= tempReg;
 end case;
end if;
end process;


END;
