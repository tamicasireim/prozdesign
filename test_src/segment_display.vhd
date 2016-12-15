-- test file for the 7 segment display of the FPGA
-- the purpose of this file is to understand how the fuck the 7 segments
-- display works

-- behaviour : load a value you want to load on one of the display with the switches
--             btnu : load LD4
--             btnl : load LD3
--             btnr : load LD2
--             btnd : load LD1

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.numeric_std.all;


entity segmenttest is
  port (
    clk : in std_logic;

    sw : in std_logic_vector(7 downto 0);
    btnR     : in std_logic;
    btnU     : in std_logic;
    btnD     : in std_logic;
    btnL     : in std_logic;

    seg : out std_logic_vector(7 downto 0);
    seg_enable : out std_logic_vector(3 downto 0));
end entity;
architecture Behavioral of segmenttest is
begin
  
  seg <= sw;

  seg_enable <= btnR & btnL & btnU & btnL;

end Behavioral;
