
-- ----------------------------------------------
-- File Name: MWChIfTX.vhd
-- Created:   08-Feb-2018 10:01:15
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY MWChIfTX IS 
GENERIC (
         OUTPUT_DATAWIDTH: integer := 8
);

PORT (
      dclk                            : IN  std_logic;
      reset                           : IN  std_logic;
      dataIn                          : IN  std_logic_vector(OUTPUT_DATAWIDTH - 1 DOWNTO 0);
      dataInVld                       : IN  std_logic;
      txPayLoad                       : IN  std_logic;
      dataOut                         : OUT std_logic_vector(7 DOWNTO 0);
      dataOutVld                      : OUT std_logic
);
END MWChIfTX;

ARCHITECTURE rtl of MWChIfTX IS

  SIGNAL payLoadReg                       : std_logic_vector(OUTPUT_DATAWIDTH + 39  downto 0); 

BEGIN

 payloadTransfer : process (dclk)
 begin
   if dclk'event and dclk = '1' then 
     if reset = '1' then
       payLoadReg <= (others => '0');
     else 
       if dataInVld = '1' then
         payLoadReg(OUTPUT_DATAWIDTH - 1 downto 0) <= dataIn;
       elsif txPayLoad = '1' then
         payLoadReg(OUTPUT_DATAWIDTH - 1 downto OUTPUT_DATAWIDTH - 8) <= (others => '0');
         payLoadReg(OUTPUT_DATAWIDTH - 9 downto 0)                    <= payLoadReg(OUTPUT_DATAWIDTH - 1 downto 8);
       end if;
     end if;
   end if;
 end process payloadTransfer;

   --dataOut  <= dataIn(7 downto 0);
 --dataOutVld   <= txPayLoad;
 dataOut  <= payLoadReg(15 downto 8) when txPayLoad = '1' else
                       dataIn(7 downto 0);
 dataOutVld   <= txPayLoad OR dataInVld;


END;
