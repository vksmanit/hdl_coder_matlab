-- -------------------------------------------------------------
--
-- Module: hdl_matmul_tb_pkg
-- Path: /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/hdlsrc
-- Created: 2018-02-08 09:57:09
-- Generated by MATLAB 8.4, MATLAB Coder 2.7 and HDL Coder 3.5
-- 
-- Description: test bench package
--
--
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE work.hdl_matmul_pkg.ALL;

PACKAGE hdl_matmul_tb_pkg IS

  -- Type Definitions
  TYPE a_in_type IS ARRAY (0 TO 11) OF std_logic_vector(7 DOWNTO 0);

  -- Functions
  FUNCTION to_integer( x : IN std_logic) RETURN integer;
  FUNCTION to_hex( x : IN std_logic) RETURN string;
  FUNCTION to_hex( x : IN std_logic_vector) RETURN string;
  FUNCTION to_hex( x : IN signed ) RETURN string;
  FUNCTION to_hex( x : IN unsigned ) RETURN string;
  FUNCTION to_hex( x : IN real ) RETURN string;
  FUNCTION SLICE( x : IN bit_vector; slice : In Integer) RETURN std_logic_vector;
  FUNCTION SLICE( x : IN bit_vector; slice : In Integer) RETURN signed;
  FUNCTION SLICE( x : IN bit_vector; slice : In Integer) RETURN unsigned;

  -- Procedures
  PROCEDURE a_in_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic);

  PROCEDURE b_in_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic);

  PROCEDURE c_out_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic);

  PROCEDURE state_store_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic);

END hdl_matmul_tb_pkg;

PACKAGE BODY hdl_matmul_tb_pkg IS
  FUNCTION to_integer( x : IN std_logic) RETURN integer IS
    VARIABLE int: integer;
  BEGIN
    IF x = '0' THEN
      int := 0;
    ELSE
      int := 1;
    END IF;
    RETURN int;
  END;

  FUNCTION to_hex( x : IN std_logic_vector) RETURN string IS
    VARIABLE result  : STRING(1 TO 256); -- 1024 bits max
    VARIABLE i       : INTEGER;
    VARIABLE imod    : INTEGER;
    VARIABLE j       : INTEGER;
    VARIABLE jinc    : INTEGER;
    VARIABLE newx    : std_logic_vector(1023 DOWNTO 0);
  BEGIN
    newx := (OTHERS => '0');
    IF x'LEFT > x'RIGHT THEN
      j := x'LENGTH-1;
      jinc := -1;
    ELSE
      j := 0;
      jinc := 1;
    END IF;
    FOR i IN x'RANGE LOOP
      newx(j) := x(i);
      j := j+jinc;
    END LOOP;  -- i
    i := x'LENGTH-1;
    imod := x'LENGTH MOD 4;
    IF    imod = 1 THEN i := i+3;
    ELSIF imod = 2 THEN i := i+2;
    ELSIF imod = 3 THEN i := i+1;
    END IF;
    j := 1;
    WHILE i >= 3 LOOP
      IF    newx(i DOWNTO (i-3)) = "0000" THEN result(j) := '0';
      ELSIF newx(i DOWNTO (i-3)) = "0001" THEN result(j) := '1';
      ELSIF newx(i DOWNTO (i-3)) = "0010" THEN result(j) := '2';
      ELSIF newx(i DOWNTO (i-3)) = "0011" THEN result(j) := '3';
      ELSIF newx(i DOWNTO (i-3)) = "0100" THEN result(j) := '4';
      ELSIF newx(i DOWNTO (i-3)) = "0101" THEN result(j) := '5';
      ELSIF newx(i DOWNTO (i-3)) = "0110" THEN result(j) := '6';
      ELSIF newx(i DOWNTO (i-3)) = "0111" THEN result(j) := '7';
      ELSIF newx(i DOWNTO (i-3)) = "1000" THEN result(j) := '8';
      ELSIF newx(i DOWNTO (i-3)) = "1001" THEN result(j) := '9';
      ELSIF newx(i DOWNTO (i-3)) = "1010" THEN result(j) := 'A';
      ELSIF newx(i DOWNTO (i-3)) = "1011" THEN result(j) := 'B';
      ELSIF newx(i DOWNTO (i-3)) = "1100" THEN result(j) := 'C';
      ELSIF newx(i DOWNTO (i-3)) = "1101" THEN result(j) := 'D';
      ELSIF newx(i DOWNTO (i-3)) = "1110" THEN result(j) := 'E';
      ELSIF newx(i DOWNTO (i-3)) = "1111" THEN result(j) := 'F';
      ELSE result(j) := 'X';
      END IF;
      i := i-4;
      j := j+1;
    END LOOP;
    RETURN result(1 TO j-1);
  END;


  FUNCTION to_hex( x : IN std_logic ) RETURN string IS
  BEGIN
    RETURN std_logic'image(x);
  END;


  FUNCTION to_hex( x : IN signed ) RETURN string IS
  BEGIN
    RETURN to_hex( std_logic_vector(x) );
  END;


  FUNCTION to_hex( x : IN unsigned ) RETURN string IS
  BEGIN
    RETURN to_hex( std_logic_vector(x) );
  END;


  FUNCTION to_hex( x : IN real ) RETURN string IS
  BEGIN
    RETURN real'image(x);
  END;


  FUNCTION SLICE( x : IN bit_vector; slice : IN Integer) RETURN std_logic_vector IS
    variable result : std_logic_vector(slice - 1 DOWNTO 0);
  BEGIN
    result := to_stdlogicvector(bit_vector'(x))(slice - 1 DOWNTO 0);
    RETURN result;
  END;


  FUNCTION SLICE( x : IN bit_vector; slice : IN Integer) RETURN signed IS
    variable result : signed(slice -  1 DOWNTO 0);
  BEGIN
    result := signed(to_stdlogicvector(bit_vector'(x))(slice - 1 DOWNTO 0));
    RETURN result;
  END;


  FUNCTION SLICE( x : IN bit_vector; slice : IN Integer) RETURN unsigned IS
    variable result : unsigned(slice -  1 DOWNTO 0);
  BEGIN
    result := unsigned(to_stdlogicvector(bit_vector'(x))(slice - 1 DOWNTO 0));
    RETURN result;
  END;


  PROCEDURE a_in_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic) IS
  BEGIN
-- Counter to generate Addr.
    IF reset  = '1' THEN
      addr     <= TO_UNSIGNED(0,4);
    ELSIF clk'event and clk = '1' THEN
      IF rdenb = '1' THEN
        IF (addr = TO_UNSIGNED(11, 4 )) THEN
          addr     <= addr; 
        ELSE
          addr     <= addr + TO_UNSIGNED(1,4); 
        END IF;
      ELSE 
        addr <= addr;
      END IF;
    END IF;

-- Done Signal generation.
    IF reset  = '1' THEN
      done <= '0'; 
    ELSIF (addr = TO_UNSIGNED(11, 4 )) THEN
      done <= '1'; 
    ELSE
      done <= '0'; 
    END IF;
  END a_in_procedure;

  PROCEDURE b_in_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic) IS
  BEGIN
-- Counter to generate Addr.
    IF reset  = '1' THEN
      addr     <= TO_UNSIGNED(0,4);
    ELSIF clk'event and clk = '1' THEN
      IF rdenb = '1' THEN
        IF (addr = TO_UNSIGNED(11, 4 )) THEN
          addr     <= addr; 
        ELSE
          addr     <= addr + TO_UNSIGNED(1,4); 
        END IF;
      ELSE 
        addr <= addr;
      END IF;
    END IF;

-- Done Signal generation.
    IF reset  = '1' THEN
      done <= '0'; 
    ELSIF (addr = TO_UNSIGNED(11, 4 )) THEN
      done <= '1'; 
    ELSE
      done <= '0'; 
    END IF;
  END b_in_procedure;

  PROCEDURE c_out_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic) IS
  BEGIN
-- Counter to generate Addr.
    IF reset  = '1' THEN
      addr     <= TO_UNSIGNED(0,4);
    ELSIF clk'event and clk = '1' THEN
      IF rdenb = '1' THEN
        IF (addr = TO_UNSIGNED(11, 4 )) THEN
          addr     <= addr; 
        ELSE
          addr     <= addr + TO_UNSIGNED(1,4); 
        END IF;
      ELSE 
        addr <= addr;
      END IF;
    END IF;

-- Done Signal generation.
    IF reset  = '1' THEN
      done <= '0'; 
    ELSIF (addr = TO_UNSIGNED(11, 4 )) THEN
      done <= '1'; 
    ELSE
      done <= '0'; 
    END IF;
  END c_out_procedure;

  PROCEDURE state_store_procedure 
    (SIGNAL clk      : IN    std_logic;
     SIGNAL reset    : IN    std_logic;
     SIGNAL rdenb    : IN    std_logic;
     SIGNAL addr     : INOUT unsigned(3 DOWNTO 0);
     SIGNAL done     : OUT   std_logic) IS
  BEGIN
-- Counter to generate Addr.
    IF reset  = '1' THEN
      addr     <= TO_UNSIGNED(0,4);
    ELSIF clk'event and clk = '1' THEN
      IF rdenb = '1' THEN
        IF (addr = TO_UNSIGNED(11, 4 )) THEN
          addr     <= addr; 
        ELSE
          addr     <= addr + TO_UNSIGNED(1,4); 
        END IF;
      ELSE 
        addr <= addr;
      END IF;
    END IF;

-- Done Signal generation.
    IF reset  = '1' THEN
      done <= '0'; 
    ELSIF (addr = TO_UNSIGNED(11, 4 )) THEN
      done <= '1'; 
    ELSE
      done <= '0'; 
    END IF;
  END state_store_procedure;

END hdl_matmul_tb_pkg;

-- -------------------------------------------------------------
--
-- Module: hdl_matmul_tb_data
-- Path: /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/hdlsrc
-- Created: 2018-02-08 09:57:09
-- Generated by MATLAB 8.4, MATLAB Coder 2.7 and HDL Coder 3.5
-- 
-- Description: test bench data package
--
--
-- -------------------------------------------------------------

USE work.hdl_matmul_pkg.ALL;
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE work.hdl_matmul_tb_pkg.ALL;

PACKAGE hdl_matmul_tb_data IS

  CONSTANT a_in_force : a_in_type;
  CONSTANT b_in_force : a_in_type;
  CONSTANT c_out_expected : a_in_type;
  CONSTANT state_store_expected : a_in_type;

END hdl_matmul_tb_data;

PACKAGE BODY hdl_matmul_tb_data IS

  CONSTANT a_in_force : a_in_type :=
    (
         X"01",
         X"02",
         X"02",
         X"03",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00");

  CONSTANT b_in_force : a_in_type :=
    (
         X"01",
         X"00",
         X"00",
         X"01",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00");

  CONSTANT c_out_expected : a_in_type :=
    (
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"00",
         X"01",
         X"02",
         X"02",
         X"03",
         X"00",
         X"00");

  CONSTANT state_store_expected : a_in_type :=
    (
         X"00",
         X"00",
         X"00",
         X"01",
         X"01",
         X"01",
         X"02",
         X"02",
         X"02",
         X"00",
         X"00",
         X"00");

END hdl_matmul_tb_data;
-- -------------------------------------------------------------
--
-- Module: hdl_matmul_tb
-- Path: /home/vipinsoni/MTP/hdl_coder_matlab/codegen/hdl_matmul/hdlsrc
-- Created: 2018-02-08 09:57:09
-- Generated by MATLAB 8.4, MATLAB Coder 2.7 and HDL Coder 3.5
-- 
-- Hierarchy Level: 1
--
--
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.all;
USE IEEE.numeric_std.ALL;
USE work.hdl_matmul_pkg.ALL;
USE work.hdl_matmul_tb_pkg.ALL;

USE work.hdl_matmul_tb_data.ALL;

ENTITY hdl_matmul_tb IS

END hdl_matmul_tb;


ARCHITECTURE rtl OF hdl_matmul_tb IS
  -- -------------------------------------------------------------
  -- Component Declarations
  -- -------------------------------------------------------------
  COMPONENT hdl_matmul
   PORT( clk                             :   IN    std_logic; 
         reset                           :   IN    std_logic; 
         clk_enable                      :   IN    std_logic; 
         a_in                            :   IN    std_logic_vector(7 DOWNTO 0); -- int8
         b_in                            :   IN    std_logic_vector(7 DOWNTO 0); -- int8
         ce_out                          :   OUT   std_logic; 
         c_out                           :   OUT   std_logic_vector(7 DOWNTO 0); -- int8
         state_store                     :   OUT   std_logic_vector(7 DOWNTO 0)  -- int8
         );
  END COMPONENT;

  -- -------------------------------------------------------------
  -- Component Configuration Statements
  -- -------------------------------------------------------------
  FOR ALL : hdl_matmul
    USE ENTITY work.hdl_matmul(rtl);

  -- Constants
  CONSTANT clk_high                         : time := 5 ns;
  CONSTANT clk_low                          : time := 5 ns;
  CONSTANT clk_period                       : time := 10 ns;
  CONSTANT clk_hold                         : time := 2 ns;
  CONSTANT MAX_ERROR_COUNT                : integer := 1; -- uint32


  -- Signals
  SIGNAL clk                              : std_logic := '0'; -- boolean
  SIGNAL reset                            : std_logic := '1'; -- boolean
  SIGNAL clk_enable                       : std_logic; -- boolean
  SIGNAL a_in                             : std_logic_vector(7 DOWNTO 0); -- int8
  SIGNAL b_in                             : std_logic_vector(7 DOWNTO 0); -- int8
  SIGNAL ce_out                           : std_logic; -- boolean
  SIGNAL c_out                            : std_logic_vector(7 DOWNTO 0); -- int8
  SIGNAL state_store                      : std_logic_vector(7 DOWNTO 0); -- int8

  SIGNAL tb_enb                           : std_logic; -- boolean
  SIGNAL srcDone                          : std_logic; -- boolean
  SIGNAL snkDone                          : std_logic; -- boolean
  SIGNAL testFailure                      : std_logic; -- boolean
  SIGNAL tbenb_dly                        : std_logic; -- boolean
  SIGNAL rdEnb                            : std_logic; -- boolean
  SIGNAL a_in_rdenb                       : std_logic; -- boolean
  SIGNAL a_in_addr                        : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL a_in_done                        : std_logic; -- boolean
  SIGNAL b_in_rdenb                       : std_logic; -- boolean
  SIGNAL b_in_addr                        : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL b_in_done                        : std_logic; -- boolean
  SIGNAL c_out_testFailure                : std_logic; -- boolean
  SIGNAL c_out_errCnt                     : integer; -- uint32
  SIGNAL c_out_rdenb                      : std_logic; -- boolean
  SIGNAL c_out_addr                       : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL c_out_done                       : std_logic; -- boolean
  SIGNAL c_out_ref                        : std_logic_vector(7 DOWNTO 0); -- int8
  SIGNAL check1_Done                      : std_logic; -- boolean
  SIGNAL state_store_testFailure          : std_logic; -- boolean
  SIGNAL state_store_errCnt               : integer; -- uint32
  SIGNAL state_store_rdenb                : std_logic; -- boolean
  SIGNAL state_store_addr                 : unsigned(3 DOWNTO 0); -- ufix4
  SIGNAL state_store_done                 : std_logic; -- boolean
  SIGNAL state_store_ref                  : std_logic_vector(7 DOWNTO 0); -- int8
  SIGNAL check2_Done                      : std_logic; -- boolean
  SIGNAL srcDone_delay                    : std_logic; -- boolean


BEGIN
  -- Component Instances
  u_hdl_matmul: hdl_matmul
    PORT MAP (
              clk                              => clk,
              reset                            => reset,
              clk_enable                       => clk_enable,
              a_in                             => a_in,
              b_in                             => b_in,
              ce_out                           => ce_out,
              c_out                            => c_out,
              state_store                      => state_store      );


  -- Block Statements
  -- -------------------------------------------------------------
  -- Driving the test bench enable
  -- -------------------------------------------------------------

  tb_enb <= '0' WHEN reset = '1' ELSE 
            '1' WHEN snkDone = '0' ELSE 
            '0' AFTER clk_period * 2;

  completed_msg: PROCESS (clk, reset)
  BEGIN
    IF (reset = '1') THEN 
       -- Nothing to reset here.
    ELSIF clk'event AND clk = '1' THEN
      IF snkDone='1' THEN
        IF (testFailure = '0') THEN
              ASSERT FALSE
                REPORT "**************TEST COMPLETED (PASSED)**************"
                SEVERITY NOTE;
        ELSE
              ASSERT FALSE
                REPORT "**************TEST COMPLETED (FAILED)**************"
                SEVERITY NOTE;
        END IF;
      END IF;
    END IF;
  END PROCESS completed_msg;

  -- -------------------------------------------------------------
  -- System Clock (fast clock) and reset
  -- -------------------------------------------------------------

  clk_gen: PROCESS
  BEGIN
    clk <= '1';
    WAIT FOR clk_high;
    clk <= '0';
    WAIT FOR clk_low;
    IF snkDone = '1' THEN
      clk <= '1';
      WAIT FOR clk_high;
      clk <= '0';
      WAIT FOR clk_low;
      WAIT;
    END IF;
  END PROCESS clk_gen;

  reset_gen: PROCESS
  BEGIN
    reset <= '1';
    WAIT FOR clk_period * 2;
    WAIT UNTIL clk'event AND clk = '1';
    WAIT FOR clk_hold;
    reset <= '0';
    WAIT;
  END PROCESS reset_gen;

  -- -------------------------------------------------------------
  -- Testbench clock enable
  -- -------------------------------------------------------------

  tbenb_dly <= tb_enb;
  rdEnb <= tbenb_dly WHEN snkDone =  '0' ELSE
           '0';

  -- -------------------------------------------------------------
  -- Read the data and transmit it to the DUT
  -- -------------------------------------------------------------

  a_in_procedure (
    clk       => clk,
    reset     => reset,
    rdenb     => a_in_rdenb,
    addr      => a_in_addr,
    done      => a_in_done);

  a_in_rdenb <= rdEnb;

  stimuli_a_in : PROCESS(a_in_addr, a_in_rdenb)
  BEGIN
    IF a_in_rdenb = '1' THEN
      a_in <= a_in_force(TO_INTEGER(a_in_addr)) AFTER clk_hold;
    END IF;
  END PROCESS stimuli_a_in;

  -- -------------------------------------------------------------
  -- Read the data and transmit it to the DUT
  -- -------------------------------------------------------------

  b_in_procedure (
    clk       => clk,
    reset     => reset,
    rdenb     => b_in_rdenb,
    addr      => b_in_addr,
    done      => b_in_done);

  b_in_rdenb <= rdEnb;

  stimuli_b_in : PROCESS(b_in_addr, b_in_rdenb)
  BEGIN
    IF b_in_rdenb = '1' THEN
      b_in <= b_in_force(TO_INTEGER(b_in_addr)) AFTER clk_hold;
    END IF;
  END PROCESS stimuli_b_in;

  -- -------------------------------------------------------------
  -- Create done signal for Input data
  -- -------------------------------------------------------------

  srcDone <= a_in_done AND b_in_done;

  -- -------------------------------------------------------------
  --  Checker: Checking the data received from the DUT.
  -- -------------------------------------------------------------

  c_out_procedure (
    clk       => clk,
    reset     => reset,
    rdenb     => c_out_rdenb,
    addr      => c_out_addr,
    done      => c_out_done);

  c_out_rdenb <= ce_out;

  c_out_ref <= c_out_expected(TO_INTEGER(c_out_addr));
  checker_1: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN
      c_out_errCnt <= 0;
      c_out_testFailure <= '0';
    ELSIF clk'event and clk ='1' THEN
      IF c_out_rdenb = '1' THEN
        IF c_out /= c_out_expected(TO_INTEGER(c_out_addr)) THEN
          c_out_errCnt <= c_out_errCnt + 1;
          c_out_testFailure <= '1';
          ASSERT FALSE 
            REPORT "Error in c_out: Expected " 
            & to_hex(c_out_expected(TO_INTEGER(c_out_addr)))
            & " Actual "
            & to_hex(c_out)
            SEVERITY ERROR;
          IF c_out_errCnt >= MAX_ERROR_COUNT THEN
            ASSERT FALSE
              REPORT "Number of errors have exceeded the maximum error"
              SEVERITY Warning;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS checker_1;

  checkDone_1: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN
      check1_Done <= '0';
    ELSIF clk'event and clk ='1' THEN
      IF check1_Done = '0' AND c_out_done = '1' AND c_out_rdenb = '1' THEN
        check1_Done <= '1';
      END IF;
    END IF;
  END PROCESS checkDone_1;
  -- -------------------------------------------------------------
  --  Checker: Checking the data received from the DUT.
  -- -------------------------------------------------------------

  state_store_procedure (
    clk       => clk,
    reset     => reset,
    rdenb     => state_store_rdenb,
    addr      => state_store_addr,
    done      => state_store_done);

  state_store_rdenb <= ce_out;

  state_store_ref <= state_store_expected(TO_INTEGER(state_store_addr));
  checker_2: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN
      state_store_errCnt <= 0;
      state_store_testFailure <= '0';
    ELSIF clk'event and clk ='1' THEN
      IF state_store_rdenb = '1' THEN
        IF state_store /= state_store_expected(TO_INTEGER(state_store_addr)) THEN
          state_store_errCnt <= state_store_errCnt + 1;
          state_store_testFailure <= '1';
          ASSERT FALSE 
            REPORT "Error in state_store: Expected " 
            & to_hex(state_store_expected(TO_INTEGER(state_store_addr)))
            & " Actual "
            & to_hex(state_store)
            SEVERITY ERROR;
          IF state_store_errCnt >= MAX_ERROR_COUNT THEN
            ASSERT FALSE
              REPORT "Number of errors have exceeded the maximum error"
              SEVERITY Warning;
          END IF;
        END IF;
      END IF;
    END IF;
  END PROCESS checker_2;

  checkDone_2: PROCESS(clk, reset)
  BEGIN
    IF reset = '1' THEN
      check2_Done <= '0';
    ELSIF clk'event and clk ='1' THEN
      IF check2_Done = '0' AND state_store_done = '1' AND state_store_rdenb = '1' THEN
        check2_Done <= '1';
      END IF;
    END IF;
  END PROCESS checkDone_2;
  -- -------------------------------------------------------------
  -- Create done and test failure signal for output data
  -- -------------------------------------------------------------

  snkDone <= check1_Done AND check2_Done;

  testFailure <= c_out_testFailure OR state_store_testFailure;

  -- -------------------------------------------------------------
  -- Global clock enable
  -- -------------------------------------------------------------

  srcDone_delay_process : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      srcDone_delay <= '0';
    ELSIF clk'event AND clk = '1' THEN
      IF clk_enable = '1' THEN
        srcDone_delay <= srcDone;
      END IF;
    END IF; 
  END PROCESS srcDone_delay_process;

  clk_enable <= rdEnb AFTER clk_hold WHEN srcDone_delay = '0' ELSE
                '0' AFTER clk_hold;

  -- Assignment Statements



END rtl;
