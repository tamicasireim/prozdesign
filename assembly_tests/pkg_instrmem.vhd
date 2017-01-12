library ieee;
use ieee.std_logic_1164.all;
-- ---------------------------------------------------------------------------------
-- Memory initialisation package from input file : test_stack.hex
-- ---------------------------------------------------------------------------------
package pkg_instrmem is

	type t_instrMem   is array(0 to 4096-1) of std_logic_vector(15 downto 0);
	constant PROGMEM : t_instrMem := (
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"0000000000000000",
		"1110000000000011",
		"1001001100001111",
		"1001010100000011",
		"1001001100001111",
		"1001000100011111",
		"1001000100101111",
		
		others => (others => '0')
	);

end package pkg_instrmem;
