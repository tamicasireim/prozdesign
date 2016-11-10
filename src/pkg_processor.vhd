library ieee;
use ieee.std_logic_1164.all;

package pkg_processor is

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

end pkg_processor;
