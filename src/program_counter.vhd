----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2015 08:30:37 PM
-- Design Name: 
-- Module Name: Program_Counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

library work;
use work.pkg_processor.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Program_Counter is
  port (
    reset     : in  std_logic;
    clk       : in  std_logic;
    offset_pc : in  std_logic_vector (pc_size - 1 downto 0);

    addr_from_ext : in std_logic_vector(pc_size - 1 downto 0);
    load_addr_from_ext : in std_logic;

    Addr      : out std_logic_vector (pc_size - 1 downto 0));
end Program_Counter;

-- Rudimentaerer Programmzaehler ohne Ruecksetzen und springen...

architecture Behavioral of Program_Counter is
  signal PC_reg : std_logic_vector(pc_size - 1 downto 0);
begin
  count : process (clk)
  begin  -- process count
    if clk'event and clk = '1' then     -- rising clock edge
      if reset = '1' then               -- synchronous reset (active high)
        PC_reg <= "000000000000";
      else
        PC_reg <= std_logic_vector(unsigned(PC_reg) + unsigned(offset_pc) + 1);
      end if;
    end if;
  end process count;

  Addr <= addr_from_ext when load_addr_from_ext = '1' else 
          PC_reg;

end Behavioral;
