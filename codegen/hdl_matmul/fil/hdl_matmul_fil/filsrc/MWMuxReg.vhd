
-- ----------------------------------------------
-- File Name: MWMuxReg.vhd
-- Created:   08-Feb-2018 10:01:15
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWMuxReg IS 
GENERIC (
         DATA_WIDTH: integer := 8
);

PORT (
      clk                             : IN  std_logic;
      reset                           : IN  std_logic;
      selIn1                          : IN  std_logic;
      in1                             : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      in2                             : IN  std_logic_vector(DATA_WIDTH - 1 DOWNTO 0);
      output                          : OUT std_logic_vector(DATA_WIDTH - 1 DOWNTO 0)
);
END MWMuxReg;

ARCHITECTURE rtl of MWMuxReg IS


BEGIN

 process (clk,reset)
  begin
   if reset = '1' then
     output <= (others => '0');
   elsif clk'event and clk = '1' then
     if selIn1 = '1' then 
       output <= in1;
     else
       output <= in2;
     end if;
   end if;
 end process;

END;
