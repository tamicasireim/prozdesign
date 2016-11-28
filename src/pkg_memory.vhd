library ieee;
use ieee.std_logic_1164.all;

package pkg_memory is

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
end pkg_memory;
