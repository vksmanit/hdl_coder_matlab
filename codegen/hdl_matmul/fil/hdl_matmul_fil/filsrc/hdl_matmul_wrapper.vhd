
-- ----------------------------------------------
-- File Name: hdl_matmul_wrapper.vhd
-- Created:   08-Feb-2018 10:01:18
-- Copyright  2018 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;


ENTITY hdl_matmul_wrapper IS 
PORT (
      clk_enable                      : IN  std_logic;
      a_in                            : IN  std_logic_vector(7 DOWNTO 0);
      reset                           : IN  std_logic;
      clk                             : IN  std_logic;
      b_in                            : IN  std_logic_vector(7 DOWNTO 0);
      state_store                     : OUT std_logic_vector(7 DOWNTO 0);
      c_out                           : OUT std_logic_vector(7 DOWNTO 0)
);
END hdl_matmul_wrapper;

ARCHITECTURE rtl of hdl_matmul_wrapper IS

COMPONENT hdl_matmul IS 
PORT (
      clk_enable                      : IN  std_logic;
      a_in                            : IN  std_logic_vector(7 DOWNTO 0);
      reset                           : IN  std_logic;
      clk                             : IN  std_logic;
      b_in                            : IN  std_logic_vector(7 DOWNTO 0);
      state_store                     : OUT std_logic_vector(7 DOWNTO 0);
      c_out                           : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

  SIGNAL a_in_tmp                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL b_in_tmp                         : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL c_out_tmp                        : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL state_store_tmp                  : std_logic_vector(7 DOWNTO 0); -- std8

BEGIN

u_hdl_matmul: hdl_matmul 
PORT MAP(
        clk_enable           => clk_enable,
        a_in                 => a_in_tmp,
        reset                => reset,
        state_store          => state_store_tmp,
        clk                  => clk,
        b_in                 => b_in_tmp,
        c_out                => c_out_tmp
);

a_in_tmp <= a_in;
b_in_tmp <= b_in;
c_out <= c_out_tmp;
state_store <= state_store_tmp;

END;
