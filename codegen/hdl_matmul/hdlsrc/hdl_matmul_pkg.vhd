-- -------------------------------------------------------------
-- 
-- File Name: /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/hdlsrc/hdl_matmul_pkg.vhd
-- Created: 2018-02-08 09:56:52
-- 
-- Generated by MATLAB 8.4, MATLAB Coder 2.7 and HDL Coder 3.5
-- 
-- 
-- -------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE hdl_matmul_pkg IS
  TYPE vector_of_real IS ARRAY (NATURAL RANGE <>) OF real;
  TYPE vector_of_signed64 IS ARRAY (NATURAL RANGE <>) OF signed(63 DOWNTO 0);
END hdl_matmul_pkg;
