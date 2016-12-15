library ieee;
use ieee.std_logic_1164.all;

package pkg_processor is
  -- constants for PC
  constant pc_size : integer := 12;
  
  -- constants for ALU operations

  constant op_add : std_logic_vector(3 downto 0) := "0000";  -- Addition
  constant op_NOP : std_logic_vector(3 downto 0) := "0000";  -- NoOperation (als Addition implementiert, die Ergebnisse
							     -- werden aber nicht gespeichert...
  constant op_sub : std_logic_vector(3 downto 0) := "0001";  -- Subtraction
  constant op_or : std_logic_vector(3 downto 0) := "0010";  -- bitwise OR
  constant op_ldi : std_logic_vector(3 downto 0) := "0011";  -- Load immediate

  constant op_and : std_logic_vector(3 downto 0) := "0100"; -- bitwise AND
  constant op_dec : std_logic_vector(3 downto 0) := "0101"; -- decrement
  constant op_inc : std_logic_vector(3 downto 0) := "0111"; -- increment

  constant op_lsr : std_logic_vector(3 downto 0) := "1000"; -- logical shift right
  constant op_xor : std_logic_vector(3 downto 0) := "1001"; -- bitwise xor
  

  -- Constants for regfile_data_in_selector

  constant regfile_data_in_alu : std_logic_vector(1 downto 0) := "00";
  constant regfile_data_in_datab : std_logic_vector(1 downto 0) := "01";
  constant regfile_data_in_memory : std_logic_vector(1 downto 0) := "10";
  constant regfile_data_in_instruction : std_logic_vector(1 downto 0) := "11";

  -- constant for pc_addr_selector

  constant s_pc_addr_from_memory : std_logic := '1';
  constant s_pc_addr_from_instruction : std_logic := '0';

  -- SRAM
  constant addr_first_memory : std_logic_vector(15 downto 0) := x"0060";
  constant addr_last_memory : std_logic_vector(15 downto 0) := x"045F";
  constant id_memory : std_logic_vector(3 downto 0) := "0001"; 

  -- pind
  constant addr_pind : std_logic_vector(15 downto 0) := x"0030";
  constant id_pind : std_logic_vector(3 downto 0) := "0010"; 
  -- pinc
  constant addr_pinc : std_logic_vector(15 downto 0) := x"0033";
  constant id_pinc : std_logic_vector(3 downto 0) := "0011"; 
  -- pinb
  constant addr_pinb : std_logic_vector(15 downto 0) := x"0036";
  constant id_pinb : std_logic_vector(3 downto 0) := "0100"; 
  -- portc
  constant addr_portc : std_logic_vector(15 downto 0) := x"0035";
  constant id_portc : std_logic_vector(3 downto 0) := "0101"; 
  -- pind
  constant addr_portb : std_logic_vector(15 downto 0) := x"0038";
  constant id_portb : std_logic_vector(3 downto 0) := "0110"; 

  -- 7 displays ports
  constant addr_seg0 : std_logic_vector(15 downto 0) := x"0041";
  constant addr_seg1 : std_logic_vector(15 downto 0) := x"0042";
  constant addr_seg2 : std_logic_vector(15 downto 0) := x"0043";
  constant addr_seg3 : std_logic_vector(15 downto 0) := x"0044";
  constant id_seg0 : std_logic_vector(3 downto 0) := "1000";
  constant id_seg1 : std_logic_vector(3 downto 0) := "1001";
  constant id_seg2 : std_logic_vector(3 downto 0) := "1011";
  constant id_seg3 : std_logic_vector(3 downto 0) := "1010";
  -- Seg Enable
  constant addr_seg_enable : std_logic_vector(15 downto 0) := x"0040";
  constant id_seg_enable : std_logic_vector(3 downto 0) := "1100";

end pkg_processor;
